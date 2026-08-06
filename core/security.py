import time
from typing import Optional, Union
from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from agora_token_builder import RtcTokenBuilder

from core.config import settings

# Password hashing configuration
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# --- Password Helpers ---
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against its hash."""
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception:
        return False


def get_password_hash(password: str) -> str:
    """Generate a bcrypt hash of the password."""
    return pwd_context.hash(password)


# --- JWT Helpers ---
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


def decode_access_token(token: str) -> Optional[dict]:
    """Decode and verify a JWT access token."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None


# --- Agora Token Helpers ---
def generate_voice_room_token(channel_name: str, uid: int, role: int = 1, expire_time_seconds: int = 3600) -> str:
    """
    Generate an Agora RTC token for a voice room.

    Parameters:
    - channel_name: The name of the voice room / channel.
    - uid: The integer user ID of the participant.
    - role: 1 for Publisher (can speak and hear), 2 for Subscriber (can only hear).
    - expire_time_seconds: Token TTL in seconds (default: 1 hour).
    """
    # Calculate token expiration timestamp
    current_time = int(time.time())
    privilege_expired_ts = current_time + expire_time_seconds

    # Access Agora credentials
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
        # Fallback / Debug representation if credentials are placeholders or if error occurs
        raise ValueError(f"Failed to generate Agora token: {str(e)}")
