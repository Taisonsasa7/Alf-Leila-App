import random
from fastapi import APIRouter, HTTPException, Depends, status, UploadFile, File
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, EmailStr
from typing import Optional, Dict
from supabase import create_client, Client

from core.config import settings
from core.security import create_access_token, decode_access_token, get_password_hash, verify_password

router = APIRouter(prefix="/auth", tags=["Authentication"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")

# Initialize Supabase client if configured
supabase_client: Optional[Client] = None
try:
    if settings.SUPABASE_URL and settings.SUPABASE_KEY and "your-supabase" not in settings.SUPABASE_URL:
        supabase_client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
except Exception:
    pass


# --- Schemas ---
class UserRegister(BaseModel):
    email: EmailStr
    username: str
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str


class UserProfile(BaseModel):
    id: str
    email: EmailStr
    username: str
    has_free_avatar_generated: bool = False
    avatar_shader_preset: Optional[str] = "Default"


class AvatarGenerateResponse(BaseModel):
    success: bool
    is_free: bool
    deducted_price: int
    new_balance: int
    avatar_shader_preset: str
    message: str


# In-memory database tracking profile features (for mock/local purposes)
USER_PROFILES_DB: Dict[str, UserProfile] = {}


# --- Dependency for Authentication ---
async def get_current_user(token: str = Depends(oauth2_scheme)) -> UserProfile:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception

    user_id: str = payload.get("sub")
    email: str = payload.get("email")
    username: str = payload.get("username", "user")

    if user_id is None or email is None:
        raise credentials_exception

    # Check/Initialize in-memory profile cache
    if user_id not in USER_PROFILES_DB:
        USER_PROFILES_DB[user_id] = UserProfile(
            id=user_id,
            email=email,
            username=username,
            has_free_avatar_generated=False,
            avatar_shader_preset="Default"
        )

    return USER_PROFILES_DB[user_id]


# --- Endpoints ---
@router.post("/register", response_model=UserProfile, status_code=status.HTTP_201_CREATED)
async def register(user_in: UserRegister):
    """
    Register a new user securely.
    """
    if supabase_client:
        try:
            response = supabase_client.auth.sign_up({
                "email": user_in.email,
                "password": user_in.password,
                "options": {
                    "data": {
                        "username": user_in.username
                    }
                }
            })
            if response.user:
                profile = UserProfile(
                    id=response.user.id,
                    email=response.user.email,
                    username=user_in.username,
                    has_free_avatar_generated=False,
                    avatar_shader_preset="Default"
                )
                USER_PROFILES_DB[profile.id] = profile
                return profile
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Registration failed: {str(e)}"
            )

    import uuid
    mock_id = str(uuid.uuid4())
    profile = UserProfile(
        id=mock_id,
        email=user_in.email,
        username=user_in.username,
        has_free_avatar_generated=False,
        avatar_shader_preset="Default"
    )
    USER_PROFILES_DB[mock_id] = profile
    return profile


@router.post("/login", response_model=Token)
async def login(user_in: UserLogin):
    """
    Authenticate user and issue high performance access token.
    """
    if supabase_client:
        try:
            response = supabase_client.auth.sign_in_with_password({
                "email": user_in.email,
                "password": user_in.password
            })
            if response.user and response.session:
                access_token = create_access_token(
                    data={
                        "sub": response.user.id,
                        "email": response.user.email,
                        "username": response.user.user_metadata.get("username", "user")
                    }
                )
                return Token(access_token=access_token, token_type="bearer")
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Authentication failed: {str(e)}"
            )

    access_token = create_access_token(
        data={"sub": "mock-user-id", "email": user_in.email, "username": user_in.email.split("@")[0]}
    )
    return Token(access_token=access_token, token_type="bearer")


@router.get("/me", response_model=UserProfile)
async def get_me(current_user: UserProfile = Depends(get_current_user)):
    """
    Get current logged in user profile.
    """
    return current_user


@router.post("/avatar/generate", response_model=AvatarGenerateResponse)
async def generate_likeness_avatar(
    file: UploadFile = File(...),
    current_user: UserProfile = Depends(get_current_user)
):
    """
    Upload profile picture to map and generate a hyper-realistic custom 3D avatar.
    - First generation is 100% Free.
    - Subsequent generations cost 100 coins/diamonds.
    """
    from routers.gifts import USER_BALANCES, gift_transaction_lock

    async with gift_transaction_lock:
        # Determine pricing
        is_free = not current_user.has_free_avatar_generated
        price = 0 if is_free else 100

        # Initialize user balance if not exists
        if current_user.id not in USER_BALANCES:
            USER_BALANCES[current_user.id] = 10000

        current_balance = USER_BALANCES[current_user.id]

        if current_balance < price:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail="عذراً! رصيدك غير كافٍ لإعادة توليد الصورة الرمزية ثلاثية الأبعاد. السعر: 100 ذهبة."
            )

        # Deduct coins
        USER_BALANCES[current_user.id] = current_balance - price

        # Mark free status as claimed and update texture preset based on file characteristics
        current_user.has_free_avatar_generated = True

        # Simulate AI texture extraction
        presets = ["Gladiator", "Divas", "RoyalGold", "Cyberpunk", "NebulaSkin"]
        simulated_shader = random.choice(presets)
        current_user.avatar_shader_preset = simulated_shader

        # Update cache
        USER_PROFILES_DB[current_user.id] = current_user

        message = "تهانينا! تم توليد صورتك الرمزية ثلاثية الأبعاد الأولى مجاناً بنجاح!" if is_free else f"تم تحديث الرمزية ثلاثية الأبعاد بنجاح، وخصم {price} عملة من رصيدك."

        return AvatarGenerateResponse(
            success=True,
            is_free=is_free,
            deducted_price=price,
            new_balance=USER_BALANCES[current_user.id],
            avatar_shader_preset=simulated_shader,
            message=message
        )
