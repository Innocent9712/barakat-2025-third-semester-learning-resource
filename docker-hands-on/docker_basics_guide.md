# Docker Basics: A Beginner's Guide

## What is Docker?

Docker is a platform that uses containerization technology to package applications and their dependencies into lightweight, portable containers. Think of containers as standardized shipping containers for software - they ensure your application runs the same way regardless of where it's deployed.

## Key Benefits

- **Consistency**: Applications run identically across different environments
- **Portability**: Move applications seamlessly between development, testing, and production
- **Efficiency**: Containers share the host OS kernel, making them more resource-efficient than virtual machines
- **Isolation**: Applications run in isolated environments without interfering with each other

## Core Docker Components

### 1. Docker Images
Images are read-only templates used to create containers. They contain everything needed to run an application: code, runtime, system tools, libraries, and settings.

```bash
# Pull an image from Docker Hub
docker pull nginx:latest

# List local images
docker images

# Remove an image
docker rmi nginx:latest
```

### 2. Docker Containers
Containers are running instances of Docker images. They're lightweight, executable packages that include everything needed to run an application.

```bash
# Run a container
docker run -d -p 80:80 nginx:latest

# List running containers
docker ps

# Stop a container
docker stop container_name

# Remove a container
docker rm container_name
```

### 3. Docker Engine
The core runtime that manages containers, images, networks, and volumes. It consists of:
- **Docker Daemon**: Background service that manages Docker objects
- **Docker CLI**: Command-line interface for interacting with Docker
- **REST API**: Interface for programmatic interaction

## Working with Dockerfiles

A Dockerfile is a text file containing instructions to build a Docker image. Each instruction creates a new layer in the image.

### Common Dockerfile Instructions

```dockerfile
# Use a base image
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Copy files
COPY package*.json ./
COPY . .

# Install dependencies
RUN npm install

# Expose port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production

# Define the command to run the application
CMD ["npm", "start"]
```

### Building Images

```bash
# Build an image from Dockerfile
docker build -t my-app:v1.0 .

# Build with custom Dockerfile name
docker build -f Dockerfile.prod -t my-app:prod .
```

## Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications using a YAML file.

### Basic docker-compose.yml Structure

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - database

  database:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  db_data:
```

### Common Docker Compose Commands

```bash
# Start services
docker-compose up -d

# View running services
docker-compose ps

# View logs
docker-compose logs web

# Stop services
docker-compose down

# Rebuild and start
docker-compose up --build
```

## Image Repositories

### Docker Hub
The default public registry for Docker images.

```bash
# Push to Docker Hub
docker tag my-app:latest username/my-app:latest
docker push username/my-app:latest

# Pull from Docker Hub
docker pull username/my-app:latest
```

### Private Registries
Organizations often use private registries for proprietary images.

```bash
# Tag for private registry
docker tag my-app:latest myregistry.com/my-app:latest

# Push to private registry
docker push myregistry.com/my-app:latest

# Pull from private registry
docker pull myregistry.com/my-app:latest
```

## Docker Networking

Docker provides several network drivers to handle different networking scenarios.

### Network Types

#### 1. Bridge Network (Default)
The default network driver. Containers on the same bridge network can communicate with each other.

```bash
# Default bridge network (automatic)
docker run -d --name web1 nginx
docker run -d --name web2 nginx

# Custom bridge network (recommended)
docker network create --driver bridge my-bridge
docker run -d --network my-bridge --name app1 nginx
docker run -d --network my-bridge --name app2 nginx
```

#### 2. Host Network
Container shares the host's networking namespace. No network isolation.

```bash
# Container uses host's network directly
docker run -d --network host nginx
# Nginx will be accessible on host's port 80 directly
```

#### 3. None Network
Container has no network access - completely isolated.

```bash
# No networking
docker run -d --network none my-app
```

#### 4. Overlay Network
Used for multi-host networking in Docker Swarm or Kubernetes environments.

```bash
# Create overlay network (requires swarm mode)
docker network create --driver overlay my-overlay
```

#### 5. Macvlan Network
Assigns a MAC address to container, making it appear as a physical device on the network.

```bash
# Create macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 my-macvlan

# Run container with macvlan
docker run -d --network my-macvlan --ip=192.168.1.100 nginx
```

### Network Management

```bash
# Inspect network details
docker network inspect my-bridge

# Connect running container to network
docker network connect my-network container_name

# Disconnect container from network
docker network disconnect my-network container_name

# Remove network
docker network rm my-network
```

### Docker Compose Networking

```yaml
version: '3.8'
services:
  frontend:
    image: nginx
    networks:
      - frontend-net
      - backend-net
  
  backend:
    image: my-api
    networks:
      - backend-net
      - database-net
  
  database:
    image: postgres
    networks:
      - database-net

networks:
  frontend-net:
    driver: bridge
  backend-net:
    driver: bridge
  database-net:
    driver: bridge
    internal: true  # No external access
```

## Docker Storage: Volumes, Bind Mounts, and tmpfs

Docker provides three ways to mount data into containers, each with different use cases.

### 1. Volumes (Recommended)
Managed by Docker, stored in Docker's area of the host filesystem. Best for production.

#### Named Volumes
```bash
# Create named volume
docker volume create my-data

# Use named volume
docker run -d -v my-data:/app/data nginx

# Multiple containers can share the same volume
docker run -d -v my-data:/var/log/nginx nginx:alpine
```

#### Anonymous Volumes
```bash
# Docker creates and manages anonymous volume
docker run -d -v /app/data nginx

# In Dockerfile
VOLUME ["/app/data"]
```

#### Volume Drivers
```bash
# Use different storage drivers
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfs-volume
```

Other drivers include `local-persist`, `rexray`, and cloud-specific drivers.

### 2. Bind Mounts
Mount a host directory or file directly into the container. Useful for development.

```bash
# Mount host directory to container
docker run -d -v /host/path:/container/path nginx

# Mount current directory (development)
docker run -d -v $(pwd):/app node:16

# Read-only bind mount
docker run -d -v /host/config:/app/config:ro nginx

# Mount specific file
docker run -d -v /host/nginx.conf:/etc/nginx/nginx.conf:ro nginx
```

### 3. tmpfs Mounts
Store data in host's memory. Data disappears when container stops.

```bash
# Create tmpfs mount
docker run -d --tmpfs /tmp nginx

# With size limit
docker run -d --tmpfs /tmp:noexec,nosuid,size=100m nginx
```

### Volume vs Bind Mount vs tmpfs Comparison

| Feature | Volumes | Bind Mounts | tmpfs |
|---------|---------|-------------|-------|
| Host location | Docker managed | User specified | Memory |
| Persistence | Yes | Yes | No |
| Performance | Good | Good | Excellent |
| Backup friendly | Yes | Yes | No |
| Docker CLI management | Yes | No | No |
| Works on all platforms | Yes | Limited | Linux only |

### Docker Compose Storage Examples

```yaml
version: '3.8'
services:
  # Named volume example
  database:
    image: postgres:13
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: secret

  # Bind mount example (development)
  web:
    image: nginx
    volumes:
      - ./html:/usr/share/nginx/html:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "80:80"

  # tmpfs example
  cache:
    image: redis:alpine
    tmpfs:
      - /data:noexec,nosuid,size=1g

  # Multiple mount types
  app:
    build: .
    volumes:
      # Bind mount for development
      - .:/app
      # Named volume for node_modules (prevents host override)
      - node_modules:/app/node_modules
      # tmpfs for temporary files
    tmpfs:
      - /app/tmp:size=50m

volumes:
  db_data:
    driver: local
  node_modules:
    driver: local
```

### Storage Best Practices

#### For Development
```bash
# Use bind mounts for code that changes frequently
docker run -d -v $(pwd):/app -v /app/node_modules node:16

# Exclude certain directories with anonymous volumes
# This prevents host files from overriding container files
```

#### For Production
```bash
# Use named volumes for data persistence
docker volume create app-data
docker run -d -v app-data:/data --name app my-app:latest

# Backup volumes
docker run --rm -v app-data:/source -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /source .

# Restore volumes
docker run --rm -v app-data:/target -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /target
```

#### Volume Drivers and External Storage
```yaml
# Using external storage systems
version: '3.8'
services:
  app:
    image: my-app
    volumes:
      - nfs-data:/data

volumes:
  nfs-data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=nfs-server.example.com,rw
      device: ":/path/to/data"
```

## Best Practices

### Dockerfile Optimization
- Use specific base image tags (avoid `latest` in production)
- Minimize layers by combining RUN commands
- Use multi-stage builds for smaller production images
- Copy only necessary files

```dockerfile
# Multi-stage build example
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["npm", "start"]
```

### Security Considerations
- Don't run containers as root user
- Use official base images
- Regularly update base images
- Scan images for vulnerabilities
- Use secrets management for sensitive data

### Resource Management
- Set memory and CPU limits
- Use health checks
- Implement proper logging
- Monitor container performance

```yaml
# Resource limits in docker-compose.yml
services:
  web:
    image: my-app
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Common Use Cases

1. **Development Environment Standardization**: Ensure all developers work with identical environments
2. **Microservices Architecture**: Deploy and manage individual services independently
3. **Continuous Integration/Deployment**: Build, test, and deploy applications consistently
4. **Application Modernization**: Containerize legacy applications for cloud migration
5. **Local Testing**: Test applications locally before deploying to production

## Next Steps

Once you're comfortable with these basics, explore:
- Container orchestration with Kubernetes
- Advanced networking configurations
- Docker security best practices
- Monitoring and logging strategies
- CI/CD integration with Docker

Docker's ecosystem is vast and powerful. Start with simple applications, experiment with different configurations, and gradually build your expertise through hands-on practice.