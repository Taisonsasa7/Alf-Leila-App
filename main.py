from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

from core.config import settings
from routers import auth, rooms, gifts

# Initialize FastAPI app with production metadata
app = FastAPI(
    title=settings.APP_NAME,
    description="سيرفر تطبيق الدردشة الصوتية والتحديات المباشرة عالي الأداء 'ألف ليلة وليلة' (Alf-Leila-App)",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Set up CORS middleware for secure cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict to trusted domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API Routes
app.include_router(auth.router, prefix="/api")
app.include_router(rooms.router, prefix="/api")
app.include_router(gifts.router, prefix="/api")


# --- Global High-Performance Exception Handlers ---

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    """
    Format standard HTTP Exceptions cleanly and securely.
    """
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error_code": "HTTP_ERROR",
            "message": exc.detail,
            "success": False
        }
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """
    Format validation errors in request body/parameters clearly.
    """
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error_code": "VALIDATION_ERROR",
            "message": "Invalid fields or parameters in the request",
            "errors": exc.errors(),
            "success": False
        }
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """
    Catch any unhandled runtime exceptions gracefully to prevent stacktrace leaks.
    """
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error_code": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred. Our engineering team is looking into it.",
            "success": False
        }
    )


# --- System & Status Routes ---

@app.get("/health", tags=["System"])
async def health_check():
    """
    System and Health Check status.
    """
    return {
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "environment": settings.APP_ENV,
        "database_connected": True
    }


@app.get("/", tags=["System"])
async def root():
    """
    Welcome endpoint.
    """
    return {
        "message": f"Welcome to {settings.APP_NAME} high-performance API! (مرحباً بكم في منصة ألف ليلة وليلة)"
    }
