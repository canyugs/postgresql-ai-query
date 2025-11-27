# Building and Publishing Guide

This guide explains how to build the Docker image and publish it to a container registry.

## Prerequisites

- Docker installed and running
- Docker Hub or GitHub Container Registry account
- `docker login` completed for your registry

## Quick Build

### Local Testing Build

```bash
cd postgresql-ai-query

# Build the image
docker build -t postgres-ai-query:latest .

# Test locally
docker run -d \
  --name postgres-ai-test \
  -e POSTGRES_PASSWORD=testpass \
  -e OPENAI_API_KEY=your-key \
  -p 5432:5432 \
  postgres-ai-query:latest

# Test connection
psql "postgresql://postgres:testpass@localhost:5432/mydb" \
  -c "CREATE EXTENSION IF NOT EXISTS pg_ai_query;" \
  -c "SELECT generate_query('show all tables');"

# Cleanup
docker stop postgres-ai-test
docker rm postgres-ai-test
```

## Publishing to Docker Hub

### 1. Build and Tag

```bash
# Replace 'yourusername' with your Docker Hub username
DOCKER_USERNAME="yourusername"
IMAGE_NAME="postgres-ai-query"
VERSION="1.0.0"

# Build for multiple platforms (recommended)
docker buildx create --use --name multiarch-builder
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} \
  -t ${DOCKER_USERNAME}/${IMAGE_NAME}:latest \
  --push \
  .
```

### 2. Update Template

After pushing, update `zeabur-template-postgresql-ai.yaml`:

```yaml
spec:
  source:
    image: yourusername/postgres-ai-query:latest
```

## Publishing to GitHub Container Registry

### 1. Login to GHCR

```bash
# Create a Personal Access Token with 'write:packages' scope
# https://github.com/settings/tokens

echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

### 2. Build and Push

```bash
GITHUB_USERNAME="yourusername"
IMAGE_NAME="postgres-ai-query"
VERSION="1.0.0"

# Build and push
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/${GITHUB_USERNAME}/${IMAGE_NAME}:${VERSION} \
  -t ghcr.io/${GITHUB_USERNAME}/${IMAGE_NAME}:latest \
  --push \
  .
```

### 3. Update Template

```yaml
spec:
  source:
    image: ghcr.io/yourusername/postgres-ai-query:latest
```

## CI/CD with GitHub Actions

Create `.github/workflows/docker-build.yml`:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository_owner }}/postgres-ai-query

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: ./postgresql-ai-query
          platforms: linux/amd64,linux/arm64
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Build Time Optimization

The build process can take 10-20 minutes due to compilation. Here are optimization tips:

### 1. Use BuildKit Cache

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with cache
docker build \
  --cache-from postgres-ai-query:latest \
  -t postgres-ai-query:latest \
  .
```

### 2. Multi-stage Build (Future Optimization)

Consider splitting the Dockerfile into build and runtime stages:

```dockerfile
# Build stage
FROM postgres:17-alpine AS builder
# ... build pg_ai_query ...

# Runtime stage
FROM postgres:17-alpine
COPY --from=builder /usr/local/lib/postgresql/*.so /usr/local/lib/postgresql/
COPY --from=builder /usr/local/share/postgresql/extension/* /usr/local/share/postgresql/extension/
```

## Versioning Strategy

### Semantic Versioning

- `1.0.0` - Major version
- `1.0.1` - Patch version
- `1.1.0` - Minor version

### Tag Strategy

```bash
# Tag with version
docker tag postgres-ai-query:latest postgres-ai-query:1.0.0

# Tag with major version
docker tag postgres-ai-query:latest postgres-ai-query:1

# Always maintain 'latest' tag
docker tag postgres-ai-query:latest postgres-ai-query:latest
```

## Testing the Published Image

### Test from Registry

```bash
# Pull and test
docker pull yourusername/postgres-ai-query:latest

docker run -d \
  --name postgres-ai-prod-test \
  -e POSTGRES_PASSWORD=testpass \
  -e OPENAI_API_KEY=your-key \
  -p 5432:5432 \
  yourusername/postgres-ai-query:latest

# Run tests
psql "postgresql://postgres:testpass@localhost:5432/mydb" << EOF
CREATE EXTENSION IF NOT EXISTS pg_ai_query;
SELECT generate_query('show all tables');
SELECT get_database_tables();
EOF

# Cleanup
docker stop postgres-ai-prod-test
docker rm postgres-ai-prod-test
```

## Image Size Optimization

Current image size is approximately 450-500 MB. Here are tips to reduce it:

1. **Use Alpine base**: Already implemented ✅
2. **Clean build artifacts**: Already implemented ✅
3. **Multi-stage builds**: Future improvement
4. **Remove unnecessary dependencies**: Review and optimize

Check image size:
```bash
docker images postgres-ai-query:latest
```

## Troubleshooting

### Build fails during git clone
```bash
# Ensure submodules are cloned
git submodule update --init --recursive
```

### Extension not found after build
```bash
# Verify extension files are installed
docker run --rm postgres-ai-query:latest ls -la /usr/local/lib/postgresql/
docker run --rm postgres-ai-query:latest ls -la /usr/local/share/postgresql/extension/
```

### Platform-specific issues
```bash
# Build for specific platform
docker build --platform linux/amd64 -t postgres-ai-query:latest .
```

## Next Steps

After publishing:

1. ✅ Update `zeabur-template-postgresql-ai.yaml` with the correct image URL
2. ✅ Test deployment on Zeabur
3. ✅ Update documentation with the registry URL
4. ✅ Create release notes
5. ✅ Monitor image pulls and issues

## Registry URLs

After publishing, your image will be available at:

- **Docker Hub**: `docker.io/yourusername/postgres-ai-query:latest`
- **GHCR**: `ghcr.io/yourusername/postgres-ai-query:latest`

Update the template accordingly!
