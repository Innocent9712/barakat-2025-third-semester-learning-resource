# Multi-stage Dockerfile for FastAPI application
# Stage 1: Build stage
FROM python:3.13-slim AS builder

# Install system dependencies needed for building
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv for fast dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen

# Stage 2: Runtime stage
FROM python:3.13-slim AS runtime

# Install runtime system dependencies
RUN apt-get update && apt-get install -y \
    libpq5 curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy Python environment from builder stage
COPY --from=builder /app/.venv /app/.venv

# Add venv to PATH
ENV PATH="/app/.venv/bin:$PATH"

# Copy application code
COPY main.py ./

# Change ownership of app directory to appuser
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Set resource limits (handled by docker run or compose)
# These are examples - actual limits should be set via docker run --memory/--cpus

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]

# Best Practices implemented:
# 1. Multi-stage build to reduce final image size
# 2. Non-root user for security
# 3. Minimal base image (slim)
# 4. Health check endpoint
# 5. Proper layer caching by copying dependencies first
# 6. Clean up package cache to reduce image size
# 7. Explicit port exposure
# 8. Use of uv for faster dependency resolution
