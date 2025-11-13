# Docker Guide for Spring Boot Hello World

## Dockerfile Overview

The Dockerfile uses a **multi-stage build** approach for optimal image size and security:

### Stage 1: Builder
- Base: `maven:3.9-eclipse-temurin-17`
- Downloads dependencies (cached layer)
- Builds the application

### Stage 2: Runtime
- Base: `eclipse-temurin:17-jre-alpine` (minimal JRE)
- Runs as non-root user for security
- Only contains the JAR file and JRE
- Includes health check

## Building the Image

### Using Make (Recommended)
```bash
make docker-build
```

### Using Docker directly
```bash
docker build -t spring-boot-helloworld:latest .
```

### Build with custom tag
```bash
docker build -t spring-boot-helloworld:v1.0.0 .
```

## Running the Container

### Using Make
```bash
# Start container
make docker-run

# Stop container
make docker-stop
```

### Using Docker directly
```bash
# Run in detached mode
docker run -d -p 8080:8080 --name spring-boot-helloworld spring-boot-helloworld:latest

# Run in interactive mode (see logs)
docker run -it -p 8080:8080 --name spring-boot-helloworld spring-boot-helloworld:latest

# Run with environment variables
docker run -d -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e JAVA_OPTS="-Xmx512m" \
  --name spring-boot-helloworld \
  spring-boot-helloworld:latest
```

## Testing the Application

```bash
# Check if container is running
docker ps

# View logs
docker logs spring-boot-helloworld

# Follow logs
docker logs -f spring-boot-helloworld

# Test the endpoint
curl http://localhost:8080

# Check health
curl http://localhost:8080/actuator/health
```

## Pushing to Registry

### Docker Hub
```bash
# Login
docker login

# Tag
docker tag spring-boot-helloworld:latest your-username/spring-boot-helloworld:latest

# Push
docker push your-username/spring-boot-helloworld:latest
```

### Private Registry
```bash
# Tag
docker tag spring-boot-helloworld:latest registry.example.com/spring-boot-helloworld:latest

# Push
docker push registry.example.com/spring-boot-helloworld:latest
```

### Using Make (Update Makefile first)
```bash
# Edit Makefile and update registry URL
make docker-push
```

## Docker Compose (Optional)

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
```

Run with:
```bash
docker-compose up -d
```

## Image Optimization

### Current Image Size
```bash
docker images spring-boot-helloworld:latest
```

Expected size: ~200-250 MB (thanks to multi-stage build and Alpine)

### Further Optimization Options

1. **Use JLink for custom JRE** (advanced):
   - Can reduce image to ~100 MB
   - Requires custom Dockerfile

2. **Use Spring Boot Layered JARs**:
   - Better caching of dependencies
   - Faster rebuilds

3. **Use Distroless images**:
   - Even more minimal than Alpine
   - No shell, package manager

## Security Best Practices

✅ **Already Implemented:**
- Multi-stage build (no build tools in final image)
- Non-root user
- Minimal base image (Alpine)
- Health check
- .dockerignore to exclude unnecessary files

🔒 **Additional Recommendations:**
```bash
# Scan for vulnerabilities
docker scan spring-boot-helloworld:latest

# Run with read-only filesystem
docker run -d -p 8080:8080 --read-only \
  --tmpfs /tmp \
  spring-boot-helloworld:latest

# Limit resources
docker run -d -p 8080:8080 \
  --memory="512m" \
  --cpus="1.0" \
  spring-boot-helloworld:latest
```

## Troubleshooting

### Container exits immediately
```bash
# Check logs
docker logs spring-boot-helloworld

# Run interactively to see errors
docker run -it spring-boot-helloworld:latest
```

### Port already in use
```bash
# Use different port
docker run -d -p 8081:8080 spring-boot-helloworld:latest
```

### Out of memory
```bash
# Increase memory limit
docker run -d -p 8080:8080 --memory="1g" spring-boot-helloworld:latest
```

### Build fails
```bash
# Clean build
docker build --no-cache -t spring-boot-helloworld:latest .

# Check Docker daemon
docker info
```

## Jenkins Integration

The Docker build is already integrated in your Makefile's `after-build` hook:

```makefile
after-build:
	@make test
	@make docker-build
```

This means every successful build will automatically create a Docker image!

## Kubernetes Deployment (Optional)

Create `k8s/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-boot-helloworld
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spring-boot-helloworld
  template:
    metadata:
      labels:
        app: spring-boot-helloworld
    spec:
      containers:
      - name: app
        image: spring-boot-helloworld:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 40
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: spring-boot-helloworld
spec:
  selector:
    app: spring-boot-helloworld
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

Deploy:
```bash
kubectl apply -f k8s/deployment.yaml
```

## Quick Reference

```bash
# Build
make docker-build

# Run
make docker-run

# Stop
make docker-stop

# View logs
docker logs -f spring-boot-helloworld

# Test
curl http://localhost:8080

# Clean up
docker stop spring-boot-helloworld
docker rm spring-boot-helloworld
docker rmi spring-boot-helloworld:latest
```

## Next Steps

1. ✅ Dockerfile created
2. ✅ .dockerignore created
3. ✅ Makefile updated with docker targets
4. 🔄 Build and test: `make docker-build && make docker-run`
5. 🔄 Push to registry: Update `docker-push` in Makefile
6. 🔄 Deploy to Kubernetes (optional)
