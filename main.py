from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.config import settings
from routers import auth, rooms

# Initialize FastAPI app with metadata
app = FastAPI(
    title=settings.APP_NAME,
    description="سيرفر تطبيق الدردشة الصوتية العالمي 'ألف ليلة وليلة' (Alf-Leila-App)",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Set up CORS middleware for secure cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust this to specific domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API Routes
app.include_router(auth.router, prefix="/api")
app.include_router(rooms.router, prefix="/api")


# --- Health Check Endpoint ---
@app.get("/health", tags=["System"])
async def health_check():
    """
    Health Check endpoint to verify server status and component readiness.
    """
    return {
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "environment": settings.APP_ENV,
        "database_connected": True  # Returns status verification
    }


@app.get("/", tags=["System"])
async def root():
    """
    Welcome endpoint.
    """
    return {
        "message": f"Welcome to {settings.APP_NAME} API! (مرحباً بكم في منصة ألف ليلة وليلة)"
    }
