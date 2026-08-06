import time
from typing import Optional
from datetime import datetime, timedelta, timezone
from jose import jwt, JWTError
from passlib.context import CryptContext
from agora_token_builder import RtcTokenBuilder

from core.config import settings

# Password hashing context configuration
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# --- Password Cryptography ---
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a plain password against its bcrypt hash.
    Designed for safety against timing attacks.
    """
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception:
        return False


def get_password_hash(password: str) -> str:
    """
    Generate a secure bcrypt hash of a password.
    """
    return pwd_context.hash(password)


# --- JWT Token Handlers ---
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Create a highly secure JWT access token with defined expiration.
    """
    to_encode = data.copy()
    now_utc = datetime.now(timezone.utc)
    if expires_delta:
        expire = now_utc + expires_delta
    else:
        expire = now_utc + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    """
    Decode and verify JWT signature and claims.
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None


# --- Agora Voice Token Engine ---
def generate_voice_room_token(channel_name: str, uid: int, role: int = 1, expire_time_seconds: int = 3600) -> str:
    """
    Generate a high-performance, secure Agora RTC token for real-time voice rooms.

    Parameters:
    - channel_name: The target audio room name / channel name.
    - uid: The unique integer ID of the joining user.
    - role: 1 for Publisher (Speak and Listen), 2 for Subscriber (Listen Only).
    - expire_time_seconds: The life of the token in seconds.
    """
    current_time = int(time.time())
    privilege_expired_ts = current_time + expire_time_seconds

    app_id = settings.AGORA_APP_ID
    app_certificate = settings.AGORA_APP_CERTIFICATE

    try:
        token = RtcTokenBuilder.buildTokenWithUid(
            app_id,
            app_certificate,
            channel_name,
            uid,
            role,
            privilege_expired_ts
        )
        return token
    except Exception as e:
        # Provide clean details if token generation failed (e.g. placeholder configurations)
        raise ValueError(f"Agora voice token generation failed: {str(e)}")
