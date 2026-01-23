# GitVersion Setup and Usage Guide

This project uses [GitVersion](https://gitversion.net/) for automated semantic versioning based on Git history.

## How It Works

GitVersion automatically calculates version numbers based on:
- Git commit history
- Branch names
- Git tags
- Commit messages (with conventional commits)

### Version Calculation

**Main Branch** (`main` or `master`):
- Starts at version `0.0.1` (configured in GitVersion.yml)
- Each merge increments **patch** version (z in x.y.z)
- Examples: `0.0.1` → `0.0.2` → `0.0.3`
- Tags: `0.0.1`, `0.0`, `0`, `latest`

**Develop Branch** (`develop`):
- Increments **minor** version (y in x.y.z)
- Adds `alpha` pre-release tag
- Examples: `0.1.0-alpha.1`, `0.1.0-alpha.2`
- Tags: `0.1.0-alpha.1`, `develop`

**Feature Branches** (`feature/*`):
- Increments **minor** version (y in x.y.z)
- Adds `beta` pre-release tag
- Examples: `0.1.0-beta.1`, `0.1.0-beta.2`
- Tags: `0.1.0-beta.1`, `feature-name`

**Hotfix Branches** (`hotfix/*`):
- Increments **patch** version (z in x.y.z)
- No pre-release tag
- Examples: `0.0.2`, `0.0.3`
- Tags: `0.0.2`

**Release Branches** (`release/*`):
- No version increment
- Adds `rc` pre-release tag
- Examples: `0.1.0-rc.1`, `0.1.0-rc.2`
- Tags: `0.1.0-rc.1`

## Branch Workflow Examples

### Regular Development

```bash
# On main - v0.0.1 (initial version)
git checkout main

# Create feature
git checkout -b feature/new-api
# Version: 0.1.0-beta.1

# Commit changes
git commit -m "feat: add new API endpoint"
# Version: 0.1.0-beta.2

# Merge to develop
git checkout develop
git merge feature/new-api
# Version: 0.1.0-alpha.1

# Merge to main (increments patch)
git checkout main
git merge develop
# Version: 0.0.2

# Continue development
# Each merge to main: 0.0.2 → 0.0.3 → 0.0.4 → ...

# When ready for minor release, manually tag:
git tag v0.1.0
git push origin v0.1.0
# Version: 0.1.0
```

### Hotfix Workflow

```bash
# On main - v0.0.5
git checkout main

# Create hotfix
git checkout -b hotfix/critical-bug
# Version: 0.0.6

# Fix and commit
git commit -m "fix: resolve critical bug"

# Merge to main (increments patch)
git checkout main
git merge hotfix/critical-bug
# Version: 0.0.6
```

### Release Workflow

```bash
# On develop - v0.1.0-alpha.5
git checkout develop

# Create release branch
git checkout -b release/0.1.0
# Version: 0.1.0-rc.1

# Final testing and bug fixes
git commit -m "fix: minor adjustments"
# Version: 0.1.0-rc.2

# Merge to main for release
git checkout main
git merge release/0.1.0
# Version: 0.1.0 (manual tag overrides patch increment)

# Or let patch continue: 0.0.6 → 0.0.7
# Then manually tag when ready: v0.1.0
```

## Conventional Commits (Optional Enhancement)

GitVersion works better with conventional commits:

```bash
# Feature commits
git commit -m "feat: add user authentication"

# Bug fixes
git commit -m "fix: resolve login timeout"

# Breaking changes (increments major version)
git commit -m "feat!: redesign API endpoints

BREAKING CHANGE: Old endpoints removed"

# Other types
git commit -m "docs: update README"
git commit -m "chore: update dependencies"
git commit -m "refactor: simplify error handling"
```

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

## Local Development

### Install GitVersion CLI

**macOS** (Homebrew):
```bash
brew install gitversion
```

**Linux**:
```bash
dotnet tool install --global GitVersion.Tool
```

**Windows** (Chocolatey):
```bash
choco install gitversion.portable
```

**npm** (cross-platform):
```bash
npm install -g gitversion
```

### Check Current Version

```bash
# Show current version
gitversion

# Show specific variable
gitversion -showvariable SemVer

# Show JSON output
gitversion -output json

# Use in Makefile
make version
```

### Docker Build with Version

```bash
# Version is automatically determined
make build

# Or manually
VERSION=$(gitversion -showvariable SemVer)
docker build -t oobdev/azurinsight:$VERSION .
```

## GitHub Actions Integration

The project includes automated GitVersion integration:

### Automatic Versioning

Every push to `main` or `develop`:
1. GitVersion calculates version from Git history
2. Docker images are tagged with calculated version
3. Published to Docker Hub automatically

### Manual Release Tagging

Create a release tag manually:

```bash
# Using GitHub Actions
# Go to: Actions → Create Version Tag → Run workflow
# Leave version empty to use GitVersion, or specify (e.g., 1.2.0)
```

Or locally:
```bash
# Get version from GitVersion
VERSION=$(gitversion -showvariable SemVer)

# Create and push tag
git tag v$VERSION
git push origin v$VERSION
```

## Version Override

To override GitVersion and set a specific version:

### Method 1: Git Tag

```bash
git tag v2.0.0
git push origin v2.0.0
```

### Method 2: Workflow Dispatch

Use GitHub Actions workflow `Create Version Tag` with manual version input.

### Method 3: Update GitVersion.yml

```yaml
next-version: 2.0.0
```

## Troubleshooting

### Version Not Incrementing

**Issue**: Version stays at 0.0.1
```bash
# Solution: This is expected for the first version
# Each merge to main will increment: 0.0.1 → 0.0.2 → 0.0.3

# To jump to a specific version, create a tag:
git tag v0.1.0
git push origin v0.1.0
# Next merge will be 0.1.1
```

### Wrong Version on Feature Branch

**Issue**: Feature branch shows wrong version
```bash
# Solution: Ensure branch naming convention
git checkout -b feature/my-feature  # Correct
git checkout -b my-feature          # Wrong - won't be detected
```

### GitVersion Not Found

```bash
# Check installation
which gitversion
gitversion --version

# Reinstall if needed
npm install -g gitversion
```

### Version Conflicts

**Issue**: Multiple version tags on same commit
```bash
# Solution: Delete incorrect tags
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

## Best Practices

1. **Use conventional commits** for better version control
2. **Tag releases** on main branch for clarity
3. **Merge feature branches** to develop first, then main
4. **Create release branches** for major releases
5. **Use hotfix branches** for urgent production fixes
6. **Don't manually edit versions** - let GitVersion handle it
7. **Fetch all tags** before calculating versions: `git fetch --tags`

## Docker Hub Tags

Based on GitVersion output, Docker images are tagged as:

| Branch | Example Version | Docker Tags |
|--------|----------------|-------------|
| main/master | 0.0.1 → 0.0.2 → 0.0.3 | `0.0.3`, `0.0`, `0`, `latest` |
| develop | 0.1.0-alpha.5 | `0.1.0-alpha.5`, `develop` |
| feature/new | 0.1.0-beta.1 | `0.1.0-beta.1`, `feature-new` |
| hotfix/bug | 0.0.4 | `0.0.4`, `0.0`, `0` |
| release/0.1.0 | 0.1.0-rc.2 | `0.1.0-rc.2`, `release-0-1-0` |

## Configuration Files

- **GitVersion.yml** - Main configuration
- **.github/workflows/docker-publish.yml** - CI/CD with GitVersion
- **.github/workflows/version-tag.yml** - Manual version tagging

## References

- [GitVersion Documentation](https://gitversion.net/docs/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
