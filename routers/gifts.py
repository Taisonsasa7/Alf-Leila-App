import asyncio
from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field
from typing import List, Dict, Optional

from routers.auth import get_current_user, UserProfile

router = APIRouter(prefix="/gifts", tags=["Gift & Interactive System"])

# Lock to ensure atomic coin deduction and prevent double spending under high concurrency
gift_transaction_lock = asyncio.Lock()

# Modular Gift Item definition
class GiftItem(BaseModel):
    id: str
    name: str
    price: int  # Price in coins
    icon_placeholder: str
    description: str

# Modular Gift Catalog - Easily customizable and pluggable
GIFT_CATALOG: Dict[str, GiftItem] = {
    "gift_rose": GiftItem(
        id="gift_rose",
        name="وردة جورية (Rose)",
        price=10,
        icon_placeholder="🌹",
        description="وردة حمراء جميلة لتعبر عن التقدير"
    ),
    "gift_heart": GiftItem(
        id="gift_heart",
        name="قلب نابض (Heart)",
        price=50,
        icon_placeholder="💖",
        description="قلب دافئ ينبض بالمحبة والأخوة"
    ),
    "gift_supercar": GiftItem(
        id="gift_supercar",
        name="سيارة خارقة (Supercar)",
        price=1000,
        icon_placeholder="🏎️",
        description="سيارة رياضية فارهة للاستعراض على المسرح"
    ),
    "gift_castle": GiftItem(
        id="gift_castle",
        name="قصر الأحلام (Dream Castle)",
        price=5000,
        icon_placeholder="🏰",
        description="قصر أسطوري فخم يعلن سيادتك على الغرفة"
    )
}

# In-memory database tracking user coin balances
# Defaults to 10,000 coins per user for testing/mock purposes
USER_BALANCES: Dict[str, int] = {}

# In-memory storage for gift live broadcasts (room events feed)
ROOM_GIFT_EVENTS: Dict[str, List[dict]] = {}


# --- Schemas ---
class GiftSend(BaseModel):
    gift_id: str
    room_id: str
    receiver_id: str = Field(..., description="The user ID of the recipient on stage/chair")


class GiftSendResponse(BaseModel):
    success: bool
    sender_id: str
    sender_username: str
    receiver_id: str
    gift_id: str
    gift_name: str
    gift_icon: str
    price: int
    new_balance: int
    message: str


class BalanceResponse(BaseModel):
    user_id: str
    username: str
    balance: int


# --- Endpoints ---

@router.get("/catalog", response_model=List[GiftItem])
async def get_gift_catalog():
    """
    Get the modular gift catalog.
    Easily pluggable with custom items and prices.
    """
    return list(GIFT_CATALOG.values())


@router.get("/balance", response_model=BalanceResponse)
async def get_user_balance(current_user: UserProfile = Depends(get_current_user)):
    """
    Retrieve the current user's coin balance.
    """
    async with gift_transaction_lock:
        # Initialize user balance if not exists
        if current_user.id not in USER_BALANCES:
            USER_BALANCES[current_user.id] = 10000

        return BalanceResponse(
            user_id=current_user.id,
            username=current_user.username,
            balance=USER_BALANCES[current_user.id]
        )


@router.post("/send", response_model=GiftSendResponse)
async def send_gift(payload: GiftSend, current_user: UserProfile = Depends(get_current_user)):
    """
    Send a gift to a user in a room.
    Performs atomic coin deduction, balance validation, and simulates live broadcasting.
    """
    gift_id = payload.gift_id
    room_id = payload.room_id
    receiver_id = payload.receiver_id

    async with gift_transaction_lock:
        # 1. Validate gift existence
        if gift_id not in GIFT_CATALOG:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Gift item not found in catalog"
            )

        gift = GIFT_CATALOG[gift_id]

        # 2. Initialize sender balance
        if current_user.id not in USER_BALANCES:
            USER_BALANCES[current_user.id] = 10000

        sender_balance = USER_BALANCES[current_user.id]

        # 3. Check coin coverage
        if sender_balance < gift.price:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail="عذراً! رصيدك غير كافٍ لإرسال هذه الهدية. يرجى الشحن أولاً."
            )

        # 4. Deduct coins and credit receiver (optional mock crediting)
        USER_BALANCES[current_user.id] = sender_balance - gift.price

        # Initialize receiver balance if not exists
        if receiver_id not in USER_BALANCES:
            USER_BALANCES[receiver_id] = 10000
        USER_BALANCES[receiver_id] += gift.price

        # 5. Broadcast to room events feed
        if room_id not in ROOM_GIFT_EVENTS:
            ROOM_GIFT_EVENTS[room_id] = []

        event = {
            "sender_id": current_user.id,
            "sender_username": current_user.username,
            "receiver_id": receiver_id,
            "gift_id": gift_id,
            "gift_name": gift.name,
            "gift_icon": gift.icon_placeholder,
            "timestamp": float(asyncio.get_event_loop().time())
        }

        # Keep only last 50 events in feed to protect memory consumption
        ROOM_GIFT_EVENTS[room_id].append(event)
        if len(ROOM_GIFT_EVENTS[room_id]) > 50:
            ROOM_GIFT_EVENTS[room_id].pop(0)

        return GiftSendResponse(
            success=True,
            sender_id=current_user.id,
            sender_username=current_user.username,
            receiver_id=receiver_id,
            gift_id=gift_id,
            gift_name=gift.name,
            gift_icon=gift.icon_placeholder,
            price=gift.price,
            new_balance=USER_BALANCES[current_user.id],
            message=f"تم إرسال {gift.name} بنجاح إلى الغرفة!"
        )


@router.get("/events/{room_id}", response_model=List[dict])
async def get_room_gift_events(room_id: str):
    """
    Retrieve real-time gift broadcast feed events for a given room.
    """
    return ROOM_GIFT_EVENTS.get(room_id, [])
