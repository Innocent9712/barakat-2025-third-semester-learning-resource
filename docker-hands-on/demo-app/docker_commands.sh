#!/bin/bash

# Docker CLI Commands for FastAPI + PostgreSQL Deployment

# =============================================================================
# 1. CREATE DOCKER NETWORK
# =============================================================================
# Create a custom bridge network for container communication
docker network create app-network

# =============================================================================
# 2. RUN POSTGRESQL DATABASE
# =============================================================================
# Run PostgreSQL container with persistent volume and resource limits
docker run -d \
  --name postgres-db \
  --network app-network \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=securepassword \
  -e POSTGRES_DB=appdb \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  --memory=512m \
  --cpus=0.5 \
  --restart=unless-stopped \
  postgres:15-alpine

# Wait for PostgreSQL to be ready (optional)
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# =============================================================================
# 3. BUILD APPLICATION IMAGE
# =============================================================================
# Build the FastAPI application image
docker build -t docker-demo-app:latest .

# Optional: Tag for versioning
docker tag docker-demo-app:latest docker-demo-app:v1.0.0

# =============================================================================
# 4. RUN APPLICATION CONTAINER
# =============================================================================
# Run FastAPI application with environment variables and resource limits
docker run -d \
  --name demo-app-container \
  --network app-network \
  -e DATABASE_URL="postgresql://appuser:securepassword@postgres-db:5432/appdb" \
  -e ENVIRONMENT="production" \
  -p 8000:8000 \
  --memory=256m \
  --cpus=0.25 \
  --restart=unless-stopped \
  --health-cmd="curl -f http://localhost:8000/health || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  docker-demo-app:latest

# =============================================================================
# 5. USEFUL MANAGEMENT COMMANDS
# =============================================================================

# Check container status
docker ps

# View application logs
docker logs demo-app-container -f

# View PostgreSQL logs
docker logs postgres-db -f

# Execute commands in running containers
docker exec -it demo-app-container /bin/bash
docker exec -it postgres-db psql -U appuser -d appdb

# Check network
docker network inspect app-network

# Monitor resource usage
docker stats

# =============================================================================
# 6. BACKUP AND RESTORE DATABASE
# =============================================================================

# Backup database
docker exec postgres-db pg_dump -U appuser -d appdb > backup.sql

# Restore database (with running container)
docker exec -i postgres-db psql -U appuser -d appdb < backup.sql

# =============================================================================
# 7. CLEANUP COMMANDS
# =============================================================================

# Stop and remove containers
docker stop demo-app-container postgres-db
docker rm demo-app-container postgres-db

# Remove network
docker network rm app-network

# Remove volumes (WARNING: This deletes all data!)
docker volume rm postgres_data

# Remove images
docker rmi docker-demo-app:latest docker-demo-app:v1.0.0

# Clean up unused resources
docker system prune -a

# =============================================================================
# 8. TESTING THE APPLICATION
# =============================================================================

# Test health endpoint
curl http://localhost:8000/health

# Test creating a user
curl -X POST "http://localhost:8000/users" \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'

# Test getting users
curl http://localhost:8000/users

# Test getting specific user
curl http://localhost:8000/users/1

# =============================================================================
# NOTES ON BEST PRACTICES:
# =============================================================================

# 1. NETWORKS:
#    - Use custom networks instead of default bridge for better DNS resolution
#    - Containers on same network can communicate using container names

# 2. VOLUMES:
#    - Named volumes persist data beyond container lifecycle
#    - Use bind mounts for development, named volumes for production

# 3. RESOURCE LIMITS:
#    - Always set memory and CPU limits to prevent resource exhaustion
#    - Monitor usage with `docker stats`

# 4. RESTART POLICIES:
#    - "unless-stopped": Restarts container unless explicitly stopped
#    - "always": Always restarts (even after system reboot)
#    - "on-failure": Only restarts on non-zero exit codes

# 5. SECURITY:
#    - Run containers as non-root users
#    - Use secrets management for sensitive data in production
#    - Regularly update base images for security patches

# 6. MONITORING:
#    - Use health checks for container health monitoring
#    - Set up log aggregation in production environments
