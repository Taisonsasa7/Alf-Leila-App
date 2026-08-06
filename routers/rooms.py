import random
from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field
from typing import List, Optional

from core.security import generate_voice_room_token
from routers.auth import get_current_user, UserProfile

router = APIRouter(prefix="/rooms", tags=["Voice Rooms"])

# In-memory storage for rooms (acts as active voice rooms cache)
# In production, this would use Redis or Supabase tables
ACTIVE_ROOMS_DB = {}


# --- Schemas ---
class RoomCreate(BaseModel):
    name: str = Field(..., min_length=3, max_length=50, description="The name of the audio room")
    description: Optional[str] = Field(None, max_length=200, description="Optional description of the room")


class RoomJoin(BaseModel):
    room_id: str
    uid: Optional[int] = Field(None, description="Optional custom integer Agora User ID (UID)")


class RoomInfo(BaseModel):
    id: str
    name: str
    description: Optional[str]
    host_id: str
    host_username: str
    participants_count: int


class RoomJoinResponse(BaseModel):
    room_id: str
    room_name: str
    token: str
    uid: int
    agora_app_id: str


# --- Endpoints ---
@router.post("/create", response_model=RoomInfo, status_code=status.HTTP_201_CREATED)
async def create_room(room_in: RoomCreate, current_user: UserProfile = Depends(get_current_user)):
    """
    Create a new voice room.
    The creator of the room is designated as the Host.
    """
    import uuid
    room_id = str(uuid.uuid4())[:8] # Short unique ID for ease of sharing/joining

    room_info = RoomInfo(
        id=room_id,
        name=room_in.name,
        description=room_in.description,
        host_id=current_user.id,
        host_username=current_user.username,
        participants_count=1
    )

    # Store room in active database cache
    ACTIVE_ROOMS_DB[room_id] = {
        "info": room_info,
        "participants": {current_user.id: current_user.username}
    }

    return room_info


@router.post("/join", response_model=RoomJoinResponse)
async def join_room(room_join: RoomJoin, current_user: UserProfile = Depends(get_current_user)):
    """
    Join an existing voice room and generate a secure Agora RTC voice token.
    """
    room_id = room_join.room_id
    if room_id not in ACTIVE_ROOMS_DB:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Room not found or has been closed."
        )

    room = ACTIVE_ROOMS_DB[room_id]

    # Add participant to the room
    room["participants"][current_user.id] = current_user.username
    room["info"].participants_count = len(room["participants"])

    # Determine Agora user ID (UID). Must be an integer for RtcTokenBuilder.
    # If not provided, we generate a random 32-bit positive integer.
    uid = room_join.uid
    if uid is None:
        uid = random.randint(100000, 999999)

    # Generate the Agora RTC voice room token
    # Role 1 is Publisher (allows sending and receiving audio)
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
        agora_app_id=settings.AGORA_APP_ID
    )


@router.get("/active", response_model=List[RoomInfo])
async def list_active_rooms():
    """
    List all currently active voice rooms.
    """
    return [room["info"] for room in ACTIVE_ROOMS_DB.values()]
