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
ACTIVE_ROOMS_DB: Dict[str, dict] = {}


# --- Schemas ---
class RoomCreate(BaseModel):
    name: str = Field(..., min_length=3, max_length=50, description="The name of the audio room")
    description: Optional[str] = Field(None, max_length=200, description="Optional description of the room")
    total_chairs: int = Field(25, ge=1, le=25, description="Number of maximum audio chairs on stage (up to 25)")
    active_chairs_limit: int = Field(25, ge=1, le=25, description="Initial active seat display limit (e.g., 8, 16, or 25)")


class RoomJoin(BaseModel):
    room_id: str
    uid: Optional[int] = Field(None, description="Optional custom integer Agora User ID (UID)")


class ChairInfo(BaseModel):
    chair_index: int
    user_id: Optional[str] = None
    username: Optional[str] = None
    is_muted: bool = False
    media_state: str = Field("Voice", description="Active media state on seat: Voice, Camera, Both, or None")


class RoomInfo(BaseModel):
    id: str
    name: str
    description: Optional[str]
    host_id: str
    host_username: str
    participants_count: int
    active_chairs_limit: int = 25
    chairs: List[ChairInfo]


class RoomJoinResponse(BaseModel):
    room_id: str
    room_name: str
    token: str
    uid: int
    agora_app_id: str
    active_chairs_limit: int
    chairs: List[ChairInfo]


class ChairAction(BaseModel):
    room_id: str
    chair_index: int


class CapacityAction(BaseModel):
    room_id: str
    active_chairs_limit: int = Field(25, ge=1, le=25, description="New active seat display limit (e.g., 8, 16, or 25)")


class MediaAction(BaseModel):
    room_id: str
    chair_index: int
    media_state: str = Field("Voice", description="Desired media state: Voice, Camera, Both, or None")


# --- Room Dashboard, Level Progression & Security Schemas ---

class RoomLevelProgressionInfo(BaseModel):
    current_level: int = 1
    xp_progress: int = 450
    xp_required_for_next: int = 1000
    daily_energy_today: int = 120
    my_contribution: int = 35
    # Daily room tasks (00:00 UTC Reset)
    task_gold_diamonds_sent: int = 1500  # 1 gold diamond = 1 heat energy
    task_silver_diamonds_sent: int = 3200
    task_mic_minutes_accumulated: int = 45
    # Daily member tasks
    member_gifts_sent_diamonds: int = 1800
    member_general_messages_count: int = 240
    member_room_visits_count: int = 85


class RoomDashboardInfo(BaseModel):
    room_id: str
    cover_image_url: str = "https://via.placeholder.com/150"
    room_name: str
    announcement: str = "مرحباً بكم في مجلس ألف ليلة وليلة المشرق والممتع!"
    welcome_message: str = "أهلاً بك يا بطل في الغرفة الصوتية. نتمنى لك أطيب الأوقات ومحادثات ممتعة."
    level: int = 1
    xp_progress: int = 450
    xp_required: int = 1000
    members_count: int = 124
    admins_count: int = 5
    admins_limit: int = 10
    room_mode: str = "دردشة"
    room_theme: str = "الأرابيسك الذهبي"
    room_password: str = ""
    microphone_level_skin: str = "Default"
    super_mic_enabled: bool = False

    # Security/Permissions Lock status
    entrance_mode_locked: bool = False  # requires Lv.4
    microphone_mode_locked: bool = False  # requires Lv.3
    public_chat_mode_locked: bool = False  # requires Lv.2

    # Active user counts and logs
    banned_chat_users_count: int = 3
    kicked_users_log_count: int = 0
    progression: RoomLevelProgressionInfo


class RoomSettingsUpdate(BaseModel):
    room_name: Optional[str] = Field(None, min_length=1, max_length=30)
    cover_image_url: Optional[str] = None
    announcement: Optional[str] = None
    welcome_message: Optional[str] = Field(None, max_length=100)
    room_mode: Optional[str] = None
    room_theme: Optional[str] = None
    room_password: Optional[str] = None
    microphone_level_skin: Optional[str] = None
    super_mic_enabled: Optional[bool] = None
    entrance_mode_locked: Optional[bool] = None
    microphone_mode_locked: Optional[bool] = None
    public_chat_mode_locked: Optional[bool] = None


# --- Endpoints ---

@router.post("/create", response_model=RoomInfo, status_code=status.HTTP_201_CREATED)
async def create_room(room_in: RoomCreate, current_user: UserProfile = Depends(get_current_user)):
    """
    Create a new voice room supporting up to 25 mic seats with dynamic capacity limit control.
    """
    import uuid

    async with room_state_lock:
        room_id = str(uuid.uuid4())[:8]

        # Initialize 25 total chairs
        chairs = [
            ChairInfo(chair_index=i, user_id=None, username=None, is_muted=False, media_state="Voice")
            for i in range(room_in.total_chairs)
        ]

        # Automatically assign Host to Chair 0
        chairs[0].user_id = current_user.id
        chairs[0].username = current_user.username
        chairs[0].media_state = "Both"  # Host starts with voice and video enabled

        room_info = RoomInfo(
            id=room_id,
            name=room_in.name,
            description=room_in.description,
            host_id=current_user.id,
            host_username=current_user.username,
            participants_count=1,
            active_chairs_limit=room_in.active_chairs_limit,
            chairs=chairs
        )

        progression_data = RoomLevelProgressionInfo(
            current_level=1,
            xp_progress=450,
            xp_required_for_next=1000,
            daily_energy_today=120,
            my_contribution=35,
            task_gold_diamonds_sent=1500,
            task_silver_diamonds_sent=3200,
            task_mic_minutes_accumulated=45,
            member_gifts_sent_diamonds=1800,
            member_general_messages_count=240,
            member_room_visits_count=85
        )

        dashboard_info = RoomDashboardInfo(
            room_id=room_id,
            cover_image_url="https://via.placeholder.com/150",
            room_name=room_in.name,
            announcement="مرحباً بكم في مجلس ألف ليلة وليلة المشرق والممتع!",
            welcome_message="أهلاً بك يا بطل في الغرفة الصوتية. نتمنى لك أطيب الأوقات ومحادثات ممتعة.",
            level=1,
            xp_progress=450,
            xp_required=1000,
            members_count=124,
            admins_count=5,
            admins_limit=10,
            room_mode="دردشة",
            room_theme="الأرابيسك الذهبي",
            room_password="",
            microphone_level_skin="Default",
            super_mic_enabled=False,
            entrance_mode_locked=False,
            microphone_mode_locked=False,
            public_chat_mode_locked=False,
            banned_chat_users_count=3,
            kicked_users_log_count=0,
            progression=progression_data
        )

        ACTIVE_ROOMS_DB[room_id] = {
            "info": room_info,
            "participants": {current_user.id: current_user.username},
            "dashboard": dashboard_info
        }

        return room_info


@router.post("/join", response_model=RoomJoinResponse)
async def join_room(room_join: RoomJoin, current_user: UserProfile = Depends(get_current_user)):
    """
    Join a room and return the updated dynamic seat list and active capacity limits.
    """
    room_id = room_join.room_id

    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Room not found or has been closed."
            )

        room = ACTIVE_ROOMS_DB[room_id]
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
            active_chairs_limit=room["info"].active_chairs_limit,
            chairs=room["info"].chairs
        )


@router.post("/chair/occupy", response_model=RoomInfo)
async def occupy_chair(action: ChairAction, current_user: UserProfile = Depends(get_current_user)):
    """
    Occupy a specific chair. Prevents double-booking.
    """
    room_id = action.room_id
    idx = action.chair_index

    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Room not found")

        room = ACTIVE_ROOMS_DB[room_id]
        chairs = room["info"].chairs

        if idx < 0 or idx >= len(chairs):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid chair index")

        # Ensure user isn't on another chair
        for chair in chairs:
            if chair.user_id == current_user.id:
                chair.user_id = None
                chair.username = None
                chair.is_muted = False
                chair.media_state = "Voice"

        if chairs[idx].user_id is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Chair occupied")

        chairs[idx].user_id = current_user.id
        chairs[idx].username = current_user.username
        chairs[idx].is_muted = False
        chairs[idx].media_state = "Voice"

        return room["info"]


@router.post("/chair/leave", response_model=RoomInfo)
async def leave_chair(action: ChairAction, current_user: UserProfile = Depends(get_current_user)):
    """
    Leave an occupied chair.
    """
    room_id = action.room_id
    idx = action.chair_index

    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Room not found")

        room = ACTIVE_ROOMS_DB[room_id]
        chairs = room["info"].chairs

        if idx < 0 or idx >= len(chairs):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid chair index")

        if chairs[idx].user_id != current_user.id and room["info"].host_id != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

        chairs[idx].user_id = None
        chairs[idx].username = None
        chairs[idx].is_muted = False
        chairs[idx].media_state = "Voice"

        return room["info"]


@router.post("/seats/capacity", response_model=RoomInfo)
async def change_seats_capacity(action: CapacityAction, current_user: UserProfile = Depends(get_current_user)):
    """
    Dynamically scale active mic seats limit (e.g. 8, 16, or 25).
    Only the Host can execute this operation.
    """
    room_id = action.room_id
    limit = action.active_chairs_limit

    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Room not found")

        room = ACTIVE_ROOMS_DB[room_id]

        # Verify host permissions
        if room["info"].host_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="فقط صاحب الغرفة (Host) يمكنه تغيير سعة كراسي الصوت."
            )

        room["info"].active_chairs_limit = limit
        return room["info"]


@router.post("/seats/media", response_model=RoomInfo)
async def change_seat_media_state(action: MediaAction, current_user: UserProfile = Depends(get_current_user)):
    """
    Allow any user sitting on an active mic seat to flexibly toggle their media state:
    Voice (Audio only), Camera (Video only), Both, or None.
    """
    room_id = action.room_id
    idx = action.chair_index
    state = action.media_state

    if state not in ["Voice", "Camera", "Both", "None"]:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid media state")

    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Room not found")

        room = ACTIVE_ROOMS_DB[room_id]
        chairs = room["info"].chairs

        if idx < 0 or idx >= len(chairs):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid chair index")

        # Verify user is actually sitting on this chair
        if chairs[idx].user_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="لا يمكنك تغيير الحالة الإعلامية لكرسي لا تجلس عليه."
            )

        chairs[idx].media_state = state
        return room["info"]


@router.get("/active", response_model=List[RoomInfo])
async def list_active_rooms():
    """
    List all active high-concurrency rooms.
    """
    async with room_state_lock:
        return [room["info"] for room in ACTIVE_ROOMS_DB.values()]


@router.get("/{room_id}/dashboard", response_model=RoomDashboardInfo)
async def get_room_dashboard(room_id: str, current_user: UserProfile = Depends(get_current_user)):
    """
    Retrieve the complete Room Dashboard data, including progression levels,
    daily missions reset details, and administrative controls.
    """
    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            # For newly created rooms or local tests, build a fallback/mock dashboard
            progression_data = RoomLevelProgressionInfo(
                current_level=1,
                xp_progress=450,
                xp_required_for_next=1000,
                daily_energy_today=120,
                my_contribution=35
            )
            return RoomDashboardInfo(
                room_id=room_id,
                room_name="مجلس ألف ليلة وليلة",
                progression=progression_data
            )

        return ACTIVE_ROOMS_DB[room_id]["dashboard"]


@router.post("/{room_id}/settings/update", response_model=RoomDashboardInfo)
async def update_room_settings(
    room_id: str,
    settings_in: RoomSettingsUpdate,
    current_user: UserProfile = Depends(get_current_user)
):
    """
    Update the room parameters (Basic Info, Security settings, or custom styling themes).
    Validates level permissions for special features.
    """
    async with room_state_lock:
        if room_id not in ACTIVE_ROOMS_DB:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="الغرفة المطلوبة غير موجودة."
            )

        room = ACTIVE_ROOMS_DB[room_id]
        dashboard: RoomDashboardInfo = room["dashboard"]

        # Verify host / owner permission
        if room["info"].host_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="عذراً! لا تملك صلاحية لتحديث إعدادات هذه الغرفة."
            )

        # Update settings fields if supplied
        if settings_in.room_name is not None:
            dashboard.room_name = settings_in.room_name
            room["info"].name = settings_in.room_name

        if settings_in.cover_image_url is not None:
            dashboard.cover_image_url = settings_in.cover_image_url

        if settings_in.announcement is not None:
            dashboard.announcement = settings_in.announcement

        if settings_in.welcome_message is not None:
            dashboard.welcome_message = settings_in.welcome_message

        if settings_in.room_mode is not None:
            dashboard.room_mode = settings_in.room_mode

        if settings_in.room_theme is not None:
            dashboard.room_theme = settings_in.room_theme

        if settings_in.room_password is not None:
            dashboard.room_password = settings_in.room_password

        if settings_in.microphone_level_skin is not None:
            dashboard.microphone_level_skin = settings_in.microphone_level_skin

        if settings_in.super_mic_enabled is not None:
            # Super mic lock condition
            dashboard.super_mic_enabled = settings_in.super_mic_enabled

        if settings_in.entrance_mode_locked is not None:
            if settings_in.entrance_mode_locked and dashboard.level < 4:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="عذراً! وضع دخول الغرفة المشروط يتطلب مستوى غرفة Lv.4 على الأقل."
                )
            dashboard.entrance_mode_locked = settings_in.entrance_mode_locked

        if settings_in.microphone_mode_locked is not None:
            if settings_in.microphone_mode_locked and dashboard.level < 3:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="عذراً! وضع كتم الميكروفون المشروط يتطلب مستوى غرفة Lv.3 على الأقل."
                )
            dashboard.microphone_mode_locked = settings_in.microphone_mode_locked

        if settings_in.public_chat_mode_locked is not None:
            if settings_in.public_chat_mode_locked and dashboard.level < 2:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="عذراً! تقييد الدردشة العامة يتطلب مستوى غرفة Lv.2 على الأقل. يرجى تلبية شروط الترقية أولاً."
                )
            dashboard.public_chat_mode_locked = settings_in.public_chat_mode_locked

        room["dashboard"] = dashboard
        return dashboard
