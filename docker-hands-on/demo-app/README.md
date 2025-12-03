# FastAPI + PostgreSQL Docker Deployment Guide

This guide provides a complete example of deploying a FastAPI application with PostgreSQL using Docker, following best practices for production deployments.

## Project Structure

```
demo-app/
├── main.py                 # FastAPI demo application
├── pyproject.toml         # UV project configuration
├── uv.lock                 # UV lock file
├── Dockerfile             # Multi-stage Docker build
├── docker-compose.yml     # Complete orchestration
└── README.md             # This guide
```

## Step-by-Step Deployment Process

### 1. Application Overview

The sample FastAPI application includes:
- **CRUD operations** for user management
- **PostgreSQL integration** with SQLAlchemy ORM
- **Environment-based configuration** for database credentials
- **Health check endpoint** for monitoring
- **Proper error handling** with HTTP status codes

Key endpoints:
- `GET /health` - Health check
- `GET /users` - List all users
- `POST /users` - Create new user
- `GET /users/{id}` - Get user by ID
- `DELETE /users/{id}` - Delete user
- `GET /docs` - Swagger UI documentation

### 2. Dependency Management with UV

UV is used for fast Python package management:

```bash
# Install UV (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv sync

# Add new dependencies
uv add package-name

# Run the application locally
uv run python main.py
```

### 3. Dockerfile Best Practices Implemented

#### Multi-Stage Build
- **Builder stage**: Installs build dependencies and creates virtual environment
- **Runtime stage**: Only includes runtime dependencies, reducing final image size

#### Security Measures
- **Non-root user**: Application runs as `appuser` for security
- **Minimal base image**: Uses `python:3.11-slim` for smaller attack surface
- **Dependency separation**: System packages separated from Python packages

#### Performance Optimizations
- **Layer caching**: Dependencies copied before application code
- **Virtual environment**: Isolated Python environment
- **Health checks**: Built-in container health monitoring

### 4. Docker CLI Commands Explained

#### Network Creation
```bash
docker network create app-network
```
- Creates isolated network for service communication
- Enables DNS resolution between containers using service names

#### PostgreSQL Container
```bash
docker run -d \
  --name postgres-db \
  --network app-network \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=securepassword \
  -e POSTGRES_DB=appdb \
  -v postgres_data:/var/lib/postgresql/data \
  --memory=512m \
  --cpus=0.5 \
  postgres:15-alpine
```

**Key Components:**
- **Named volume**: `postgres_data` persists database beyond container lifecycle
- **Resource limits**: Prevents database from consuming all system resources
- **Environment variables**: Configures database credentials and settings

#### Application Container
```bash
docker run -d \
  --name demo-app \
  --network app-network \
  -e DATABASE_URL="postgresql://appuser:securepassword@postgres-db:5432/appdb" \
  -p 8000:8000 \
  --memory=256m \
  --cpus=0.25 \
  docker-demo-app:latest
```

**Key Components:**
- **Network communication**: Uses `postgres-db` hostname to connect to database
- **Environment variables**: Database connection string passed securely
- **Port mapping**: Exposes application on host port 8000

### 5. Docker Compose Orchestration

The docker-compose.yml provides:

#### Service Dependencies
```yaml
depends_on:
  postgres:
    condition: service_healthy
```
- Ensures database is ready before starting application
- Uses health checks to verify service readiness

#### Volume Management
```yaml
volumes:
  postgres_data:
    driver: local
```
- **Named volumes**: Persist data independently of container lifecycle
- **Driver specification**: Uses local storage driver

#### Resource Management
```yaml
deploy:
  resources:
    limits:
      memory: 256M
      cpus: '0.25'
    reservations:
      memory: 128M
      cpus: '0.1'
```
- **Limits**: Maximum resources container can use
- **Reservations**: Guaranteed minimum resources

#### Health Checks
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```
- **Regular monitoring**: Checks service health every 30 seconds
- **Automatic recovery**: Docker can restart unhealthy containers

### 6. Persistence and Data Management

#### Database Persistence
- **Named volumes** ensure data survives container restarts
- **PostgreSQL data directory** (`PGDATA`) properly configured
- **Backup strategies** included in CLI commands

#### Log Management
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```
- **Log rotation**: Prevents logs from consuming excessive disk space
- **Structured logging**: JSON format for better log processing

### 7. Network Configuration

#### Custom Bridge Network
```yaml
networks:
  app-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```
- **Isolated communication**: Services communicate on dedicated network
- **DNS resolution**: Containers can reach each other by service name
- **IP address management**: Custom subnet prevents conflicts

### 8. Security Best Practices

#### Container Security
- **Non-root execution**: All processes run as non-privileged users
- **Resource limits**: Prevent resource exhaustion attacks
- **Health monitoring**: Early detection of compromised services

#### Secret Management
```bash
# Production recommendation: Use Docker Secrets
docker secret create postgres_password password.txt
```

#### Network Security
- **Internal communication**: Services communicate on isolated network
- **Minimal exposure**: Only necessary ports exposed to host

### 9. Production Deployment Commands

#### Using Docker CLI
```bash
# 1. Create network
docker network create app-network

# 2. Start PostgreSQL
docker run -d --name postgres-db --network app-network \
  -e POSTGRES_USER=appuser -e POSTGRES_PASSWORD=securepassword \
  -e POSTGRES_DB=appdb -v postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine

# 3. Build and run application
docker build -t fastapi-app:latest .
docker run -d --name fastapi-container --network app-network \
  -e DATABASE_URL="postgresql://appuser:securepassword@postgres-db:5432/appdb" \
  -p 8000:8000 fastapi-app:latest
```

#### Using Docker Compose
```bash
# Single command deployment
docker-compose up --build -d

# View logs
docker-compose logs -f

# Scale application
docker-compose up -d --scale app=3

# Cleanup
docker-compose down -v
```

### 10. Monitoring and Maintenance

#### Health Monitoring
```bash
# Check container health
docker ps
docker stats

# Application health
curl http://localhost:8000/health
```

#### Database Maintenance
```bash
# Access database
docker exec -it postgres-db psql -U appuser -d appdb

# Backup database
docker exec postgres-db pg_dump -U appuser -d appdb > backup.sql

# Monitor database logs
docker logs postgres-db -f
```

### 11. Troubleshooting Common Issues

#### Container Communication
- Ensure containers are on the same network
- Use service names (not localhost) for inter-container communication
- Check firewall rules and port mappings

#### Database Connection
- Verify database is healthy: `docker logs postgres-db`
- Check connection string format
- Ensure database is ready before application starts

#### Resource Issues
- Monitor resource usage: `docker stats`
- Adjust memory and CPU limits as needed
- Check disk space for volumes

### 12. Scaling and Performance

#### Horizontal Scaling
```bash
# Scale application instances
docker-compose up -d --scale app=3

# Load balancer required for multiple instances
# Consider nginx or HAProxy
```

#### Performance Monitoring
- Use health checks for automatic failover
- Monitor resource usage regularly
- Implement proper logging and metrics collection

This deployment setup provides a robust foundation for running FastAPI applications with PostgreSQL in production environments, incorporating security, performance, and operational best practices.
