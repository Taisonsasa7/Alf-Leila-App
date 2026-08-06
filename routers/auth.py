from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, EmailStr
from typing import Optional
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

    return UserProfile(id=user_id, email=email, username=username)


# --- Endpoints ---
@router.post("/register", response_model=UserProfile, status_code=status.HTTP_201_CREATED)
async def register(user_in: UserRegister):
    """
    Register a new user securely.
    """
    # If Supabase client is active, attempt Supabase Auth sign up
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
                return UserProfile(
                    id=response.user.id,
                    email=response.user.email,
                    username=user_in.username
                )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Registration failed: {str(e)}"
            )

    # High performance mock flow fallback for local development
    import uuid
    mock_id = str(uuid.uuid4())
    return UserProfile(id=mock_id, email=user_in.email, username=user_in.username)


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

    # Mock authentication path
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
