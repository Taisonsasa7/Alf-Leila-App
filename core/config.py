import os
from typing import Optional
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # App Settings
    APP_NAME: str = "Alf-Leila-App"
    APP_ENV: str = "production"  # High performance defaults to production
    DEBUG: bool = False

    # Security Settings
    SECRET_KEY: str = "your-super-secret-key-change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 day for production resilience

    # Supabase Settings (Required with fallback/validation)
    SUPABASE_URL: str = "https://your-supabase-project.supabase.co"
    SUPABASE_KEY: str = "your-supabase-anon-key"
    SUPABASE_SERVICE_ROLE_KEY: Optional[str] = None

    # Agora Settings (Required for high performance audio rooms)
    AGORA_APP_ID: str = "your-agora-app-id"
    AGORA_APP_CERTIFICATE: str = "your-agora-app-certificate"

    # Rooms Settings
    MAX_ROOM_PARTICIPANTS: int = 1000  # High concurrency support

    # Configuration to load from .env file
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )


# Instantiate settings
settings = Settings()
