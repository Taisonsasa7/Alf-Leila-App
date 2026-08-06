import asyncio
import random
from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field
from typing import List, Dict, Optional

from core.security import generate_voice_room_token
from routers.auth import get_current_user, UserProfile

router = APIRouter(prefix="/rooms", tags=["Voice Rooms & Live Chairs"])

# Thread/Asyncio safe memory lock for room state modifications
room_state_lock = asyncio.Lock()

# In-memory storage for rooms with live chairs
# In production, this would reside in Redis with distributed locking (Redlock)
ACTIVE_ROOMS_DB: Dict[str, dict] = {}


# --- Schemas ---
class RoomCreate(BaseModel):
    name: str = Field(..., min_length=3, max_length=50, description="The name of the audio room")
    description: Optional[str] = Field(None, max_length=200, description="Optional description of the room")
    total_chairs: int = Field(10, ge=1, le=20, description="Number of audio chairs on stage")


class RoomJoin(BaseModel):
    room_id: str
    uid: Optional[int] = Field(None, description="Optional custom integer Agora User ID (UID)")


class ChairInfo(BaseModel):
    chair_index: int
    user_id: Optional[str] = None
    username: Optional[str] = None
    is_muted: bool = False


class RoomInfo(BaseModel):
    id: str
    name: str
    description: Optional[str]
    host_id: str
    host_username: str
    participants_count: int
    chairs: List[ChairInfo]


class RoomJoinResponse(BaseModel):
    room_id: str
    room_name: str
    token: str
    uid: int
    agora_app_id: str
    chairs: List[ChairInfo]


class ChairAction(BaseModel):
    room_id: str
    chair_index: int


# --- Endpoints ---

@router.post("/create", response_model=RoomInfo, status_code=status.HTTP_201_CREATED)
async def create_room(room_in: RoomCreate, current_user: UserProfile = Depends(get_current_user)):
    """
    Create a new high-concurrency voice room with sound chairs.
    Each room initializes a dedicated array of chairs (الكراسي الصوتية).
    """
    import uuid

    async with room_state_lock:
        room_id = str(uuid.uuid4())[:8]

        # Initialize default audio chairs
        chairs = [
            ChairInfo(chair_index=i, user_id=None, username=None, is_muted=False)
            for i in range(room_in.total_chairs)
        ]

        # Automatically assign the Host to Chair 0
        chairs[0].user_id = current_user.id
        chairs[0].username = current_user.username

        room_info = RoomInfo(
            id=room_id,
            name=room_in.name,
            description=room_in.description,
            host_id=current_user.id,
            host_username=current_user.username,
            participants_count=1,
            chairs=chairs
        )

        ACTIVE_ROOMS_DB[room_id] = {
            "info": room_info,
            "participants": {current_user.id: current_user.username}
        }

        return room_info


@router.post("/join", response_model=RoomJoinResponse)
async def join_room(room_join: RoomJoin, current_user: UserProfile = Depends(get_current_user)):
    """
    Join an existing voice room and obtain a secure Agora RTC voice token asynchronously.
    """
    room_id = room_join.room_id

    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Room not found or has been closed."
            )

        room = ACTIVE_ROOMS_DB[room_id]

        # Track active viewer count
        room["participants"][current_user.id] = current_user.username
        room["info"].participants_count = len(room["participants"])

        uid = room_join.uid
        if uid is None:
            uid = random.randint(100000, 999999)

        try:
            from core.config import settings
            token = generate_voice_room_token(
                channel_name=room_id,
                uid=uid,
                role=1
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error generating voice token: {str(e)}"
            )

        return RoomJoinResponse(
            room_id=room_id,
            room_name=room["info"].name,
            token=token,
            uid=uid,
            agora_app_id=settings.AGORA_APP_ID,
            chairs=room["info"].chairs
        )


@router.post("/chair/occupy", response_model=RoomInfo)
async def occupy_chair(action: ChairAction, current_user: UserProfile = Depends(get_current_user)):
    """
    Async thread-safe endpoint for occupying a specific audio chair (الجلوس على الكرسي الصوتي).
    Prevents two users from occupying the same chair concurrently.
    """
    room_id = action.room_id
    idx = action.chair_index

    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Room not found"
            )

        room = ACTIVE_ROOMS_DB[room_id]
        chairs = room["info"].chairs

        if idx < 0 or idx >= len(chairs):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid chair index"
            )

        # Check if the user is already on another chair
        for chair in chairs:
            if chair.user_id == current_user.id:
                # Leave current chair first
                chair.user_id = None
                chair.username = None
                chair.is_muted = False

        # Check if the target chair is occupied
        if chairs[idx].user_id is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This chair is already occupied"
            )

        # Occupy chair
        chairs[idx].user_id = current_user.id
        chairs[idx].username = current_user.username
        chairs[idx].is_muted = False

        return room["info"]


@router.post("/chair/leave", response_model=RoomInfo)
async def leave_chair(action: ChairAction, current_user: UserProfile = Depends(get_current_user)):
    """
    Async endpoint to leave the voice chair (مغادرة الكرسي الصوتي والعودة للجمهور).
    """
    room_id = action.room_id
    idx = action.chair_index

    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Room not found"
            )

        room = ACTIVE_ROOMS_DB[room_id]
        chairs = room["info"].chairs

        if idx < 0 or idx >= len(chairs):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid chair index"
            )

        # Verify the user is the one occupying it or is host
        if chairs[idx].user_id != current_user.id and room["info"].host_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to modify this chair"
            )

        # Leave chair
        chairs[idx].user_id = None
        chairs[idx].username = None
        chairs[idx].is_muted = False

        return room["info"]


@router.get("/active", response_model=List[RoomInfo])
async def list_active_rooms():
    """
    List all active high-concurrency rooms.
    """
    async with room_state_lock:
        return [room["info"] for room in ACTIVE_ROOMS_DB.values()]
