# Docker Hub Publishing Setup

This document explains how to set up automated publishing to Docker Hub for `oobdev/azurinsight`.

## Prerequisites

1. Docker Hub account (username: `oobdev`)
2. GitHub repository with Actions enabled
3. Docker Hub access token

## Setup Instructions

### 1. Create Docker Hub Access Token

1. Log in to [Docker Hub](https://hub.docker.com/)
2. Go to Account Settings → Security → Access Tokens
3. Click "New Access Token"
4. Name: `github-actions-azurinsight`
5. Permissions: Read, Write, Delete
6. Copy the generated token (you won't see it again)

### 2. Configure GitHub Secrets

Add the following secrets to your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

- **Name**: `DOCKER_USERNAME`
  - **Value**: `oobdev`

- **Name**: `DOCKER_PASSWORD`
  - **Value**: `<your-docker-hub-access-token>`

### 3. Automated Publishing Workflow

The workflow (`.github/workflows/docker-publish.yml`) automatically:

#### On Push to `main` branch:
- Builds multi-platform images (linux/amd64, linux/arm64)
- Tags as `oobdev/azurinsight:latest`
- Tags as `oobdev/azurinsight:main`
- Publishes to Docker Hub
- Updates Docker Hub description

#### On Version Tags (v*.*.*):
- Builds multi-platform images
- Tags as `oobdev/azurinsight:1.0.0` (full version)
- Tags as `oobdev/azurinsight:1.0` (major.minor)
- Tags as `oobdev/azurinsight:1` (major)
- Tags as `oobdev/azurinsight:latest`
- Publishes to Docker Hub

#### On Pull Requests:
- Builds image (does not push)
- Validates Dockerfile and build process

### 4. Creating a Release

To publish a new version:

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

This triggers the workflow to build and publish with semantic versioning.

### 5. Manual Publishing (Optional)

If you need to publish manually:

```bash
# Build for multiple platforms
make build-multiarch

# Or using Docker Buildx directly
docker buildx build --platform linux/amd64,linux/arm64 \
  -t oobdev/azurinsight:latest \
  -t oobdev/azurinsight:1.0.0 \
  --push .
```

## Docker Hub Repository Settings

### Recommended Settings

1. **Repository Description**:
   ```
   Local emulator for Azure Application Insights - Run telemetry ingestion server locally without cloud dependencies
   ```

2. **README**: Automatically synced from `README.docker.md`

3. **Categories**:
   - Developer Tools
   - Monitoring

4. **Links**:
   - Source Repository: `https://github.com/yourusername/azurinsight`
   - Documentation: `https://github.com/yourusername/azurinsight#readme`

## Available Images

After setup, users can pull images using:

```bash
# Latest stable release
docker pull oobdev/azurinsight:latest

# Specific version
docker pull oobdev/azurinsight:1.0.0

# Major version (auto-updates with minor/patch releases)
docker pull oobdev/azurinsight:1

# Development (main branch)
docker pull oobdev/azurinsight:main
```

## Supported Platforms

- `linux/amd64` (x86_64)
- `linux/arm64` (ARM v8, Apple Silicon, AWS Graviton)

## Troubleshooting

### Build Fails on GitHub Actions

**Issue**: Multi-platform build fails
```
Solution: Check that QEMU and Buildx setup steps completed successfully
```

**Issue**: Docker login fails
```
Solution: Verify DOCKER_USERNAME and DOCKER_PASSWORD secrets are set correctly
```

### Rate Limiting

Docker Hub has pull rate limits. For production use, consider:
- Docker Hub Pro account (unlimited pulls)
- Use image digest instead of tags for deployments
- Configure registry mirrors

### Testing Before Release

Test the build locally before pushing tags:

```bash
# Build locally
make build

# Test the image
docker run --rm -p 5000:5000 oobdev/azurinsight:latest

# Verify health
curl http://localhost:5000/
```

## Maintenance

### Update Workflow

To modify the publishing workflow:
1. Edit `.github/workflows/docker-publish.yml`
2. Test with a pull request first
3. Merge to main to activate changes

### Security Scanning

Consider adding Docker security scanning:
- Snyk
- Trivy
- Docker Scout

Example Trivy scan:
```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image oobdev/azurinsight:latest
```

## Support

For issues with Docker Hub publishing:
1. Check GitHub Actions logs
2. Verify Docker Hub access token is valid
3. Ensure repository permissions allow Actions
