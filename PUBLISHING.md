# Publishing Azurinsight to Docker Hub

## Automated Publishing (Recommended)

The project uses **GitVersion** + **GitHub Actions** for automated semantic versioning and Docker Hub publishing.

### Setup (One-time)

1. **Add GitHub Secrets** (Settings → Secrets → Actions):
   - `DOCKER_USERNAME` = `oobdev`
   - `DOCKER_PASSWORD` = Your Docker Hub access token

2. **GitHub Actions automatically publish** on every push:
   - **main branch** → `oobdev/azurinsight:latest`, `1.2.3`, `1.2`, `1`
   - **develop branch** → `oobdev/azurinsight:1.3.0-alpha.5`, `develop`
   - **feature branches** → `oobdev/azurinsight:1.3.0-beta.1`, `feature-name`

### How Versioning Works

**GitVersion** calculates versions automatically from Git history:
- **Initial version**: `0.0.1` (configured in GitVersion.yml)
- **main/master**: Patch increment on each merge (0.0.1 → 0.0.2 → 0.0.3)
- **develop**: Minor increment with alpha tag (0.1.0-alpha.1)
- **feature/***: Minor increment with beta tag (0.1.0-beta.1)
- **hotfix/***: Patch increment (0.0.2, 0.0.3, etc.)

See [GITVERSION_GUIDE.md](.github/GITVERSION_GUIDE.md) for detailed workflow examples.

### Creating a Release

#### Option 1: Automatic (GitVersion)

Just merge to main - version is calculated automatically:

```bash
# Merge feature to develop
git checkout develop
git merge feature/new-api
git push

# Merge develop to main (increments patch: 0.0.1 → 0.0.2)
git checkout main
git merge develop
git push

# GitHub Actions automatically:
# 1. Calculates version with GitVersion (e.g., 0.0.2)
# 2. Builds multi-platform images (amd64, arm64)
# 3. Tags: latest, 0.0.2, 0.0, 0
# 4. Pushes to Docker Hub

# Each subsequent merge increments patch: 0.0.2 → 0.0.3 → 0.0.4...

# When ready for minor version (0.1.0), manually tag:
git tag v0.1.0
git push origin v0.1.0
```

#### Option 2: Manual Tag

Create explicit version tag:

```bash
# Using GitHub Actions workflow
# Go to: Actions → "Create Version Tag" → Run workflow
# Leave version empty for GitVersion, or specify (e.g., 1.2.0)
```

Or locally:
```bash
git tag v1.2.0
git push origin v1.2.0
```

## Manual Publishing

### Prerequisites

```bash
# Install Docker Buildx (if not already installed)
docker buildx create --use

# Login to Docker Hub
docker login -u oobdev
```

### Option 1: Using Makefile

```bash
# Build multi-architecture and push
make build-multiarch

# Or build locally and push single platform
make build
make push
```

### Option 2: Using Docker Commands

```bash
# Multi-platform build and push
docker buildx build --platform linux/amd64,linux/arm64 \
  -t oobdev/azurinsight:latest \
  -t oobdev/azurinsight:1.0.0 \
  --push .

# Single platform (faster for testing)
docker build -t oobdev/azurinsight:dev .
docker push oobdev/azurinsight:dev
```

## Version Strategy

### Semantic Versioning

- **Major (1.0.0)**: Breaking changes, major features
- **Minor (1.1.0)**: New features, backward compatible
- **Patch (1.0.1)**: Bug fixes, minor improvements

### Tag Format

```
v1.0.0 creates:
  - oobdev/azurinsight:1.0.0 (patch)
  - oobdev/azurinsight:1.0   (minor)
  - oobdev/azurinsight:1     (major)
  - oobdev/azurinsight:latest
```

## Pre-Release Checklist

Before publishing a new version:

- [ ] Update version in `packages/server/package.json`
- [ ] Update CHANGELOG.md
- [ ] Test locally: `make run-dev`
- [ ] Verify health: `curl http://localhost:5000/`
- [ ] Test with Application Insights SDK
- [ ] Run security scan: `docker scout cves oobdev/azurinsight:latest`
- [ ] Review Dockerfile and dependencies

## Testing Published Image

```bash
# Pull and test
docker pull oobdev/azurinsight:latest
docker run --rm -p 5000:5000 oobdev/azurinsight:latest

# Health check
curl http://localhost:5000/
# Expected: "AppInsights-ite Emulator Running"

# Send test telemetry
curl -X POST http://localhost:5000/v2.1/track \
  -H "Content-Type: application/json" \
  -d '{"name":"test","iKey":"test-key","data":{"baseType":"MessageData"}}'
```

## Rollback

If a published version has issues:

```bash
# Re-tag previous good version as latest
docker pull oobdev/azurinsight:1.0.0
docker tag oobdev/azurinsight:1.0.0 oobdev/azurinsight:latest
docker push oobdev/azurinsight:latest
```

## Docker Hub Repository Settings

### Repository Overview

- **Name**: oobdev/azurinsight
- **Visibility**: Public
- **Description**: Local emulator for Azure Application Insights
- **Categories**: Developer Tools, Monitoring

### Auto-Update README

The GitHub Action automatically updates the Docker Hub README from `README.docker.md` on every push to main.

## Security

### Access Tokens

- Use Personal Access Tokens (PAT) instead of passwords
- Set minimal required scopes (Read, Write)
- Rotate tokens regularly
- Never commit tokens to git

### Image Scanning

Enable Docker Scout or Snyk for vulnerability scanning:

```bash
# Scan with Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image oobdev/azurinsight:latest

# Scan with Docker Scout
docker scout cves oobdev/azurinsight:latest
```

## Monitoring

### Docker Hub Metrics

Check at https://hub.docker.com/r/oobdev/azurinsight:

- Pull statistics
- Version distribution
- Platform usage (amd64 vs arm64)

### GitHub Actions

Monitor build status:
- https://github.com/[your-org]/azurinsight/actions

## Troubleshooting

### Build Fails in GitHub Actions

1. Check Action logs for specific errors
2. Verify secrets are set correctly
3. Test build locally: `make build`
4. Check Dockerfile syntax

### Multi-platform Build Issues

```bash
# Reset buildx
docker buildx rm mybuilder
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap

# Try build again
make build-multiarch
```

### Push Failures

```bash
# Re-authenticate
docker logout
docker login -u oobdev

# Check rate limits
docker pull oobdev/azurinsight:latest
```

## Support

For publishing issues:
1. Check GitHub Actions logs
2. Verify Docker Hub credentials
3. Test local build: `make build`
4. Open issue on GitHub
