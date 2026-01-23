# Versioning Strategy

## Overview

This project uses **GitVersion** for automated semantic versioning with the following strategy:

- **Initial Version**: `0.0.1`
- **Patch Increment**: On every merge to `main`/`master` (z in x.y.z)
- **Minor/Major Bumps**: Manual via Git tags

## Version Format: x.y.z

- **x** (major): Breaking changes - Manual tag required
- **y** (minor): New features - Manual tag required
- **z** (patch): Bug fixes, improvements - **Auto-incremented on merge to main**

## How It Works

### Automatic Patch Increments

Every merge to `main` automatically increments the patch version:

```bash
# First merge to main
0.0.1

# Second merge to main
0.0.2

# Third merge to main
0.0.3

# And so on...
0.0.4 → 0.0.5 → 0.0.6 → ...
```

### Manual Minor/Major Bumps

When you want to increment minor or major versions, create a Git tag:

```bash
# Bump to minor version (0.1.0)
git tag v0.1.0
git push origin v0.1.0

# Next merge will be: 0.1.1, 0.1.2, 0.1.3...

# Bump to next minor (0.2.0)
git tag v0.2.0
git push origin v0.2.0

# Bump to major version (1.0.0)
git tag v1.0.0
git push origin v1.0.0

# Next merge will be: 1.0.1, 1.0.2, 1.0.3...
```

## Branch-Based Versioning

### Main Branch (`main` or `master`)
- **Behavior**: Auto-increment patch on merge
- **Format**: `x.y.z`
- **Examples**: `0.0.1`, `0.0.2`, `0.1.5`, `1.0.3`
- **Docker Tags**: `latest`, `0.0.2`, `0.0`, `0`

### Develop Branch (`develop`)
- **Behavior**: Minor increment + alpha suffix
- **Format**: `x.y.0-alpha.n`
- **Examples**: `0.1.0-alpha.1`, `0.1.0-alpha.2`
- **Docker Tags**: `develop`, `0.1.0-alpha.1`

### Feature Branches (`feature/*`)
- **Behavior**: Minor increment + beta suffix
- **Format**: `x.y.0-beta.n`
- **Examples**: `0.1.0-beta.1`, `0.1.0-beta.2`
- **Docker Tags**: `feature-name`, `0.1.0-beta.1`

### Hotfix Branches (`hotfix/*`)
- **Behavior**: Patch increment
- **Format**: `x.y.z`
- **Examples**: `0.0.4`, `0.1.2`
- **Docker Tags**: `0.0.4`, `0.0`, `0`

### Release Branches (`release/*`)
- **Behavior**: Release candidate
- **Format**: `x.y.z-rc.n`
- **Examples**: `0.1.0-rc.1`, `1.0.0-rc.2`
- **Docker Tags**: `release-x-y-z`, `0.1.0-rc.1`

## Development Workflow

### Typical Flow (Patch Increments)

```bash
# Start at 0.0.1
git checkout main

# Create feature
git checkout -b feature/add-logging
git commit -m "feat: add structured logging"
git push

# Merge to main (auto-increments to 0.0.2)
git checkout main
git merge feature/add-logging
git push
# → Docker Hub: 0.0.2, 0.0, 0, latest

# Another feature
git checkout -b feature/improve-perf
git commit -m "perf: optimize queries"
git push

# Merge to main (auto-increments to 0.0.3)
git checkout main
git merge feature/improve-perf
git push
# → Docker Hub: 0.0.3, 0.0, 0, latest
```

### Minor Version Release

```bash
# After several patches (0.0.1 → 0.0.2 → ... → 0.0.15)
# Ready for minor release with new features

git checkout main
git tag v0.1.0 -m "Release 0.1.0: New features"
git push origin v0.1.0
# → Docker Hub: 0.1.0, 0.1, 0, latest

# Next merge auto-increments patch: 0.1.1
git merge feature/new-thing
git push
# → Docker Hub: 0.1.1, 0.1, 0, latest
```

### Major Version Release (1.0.0)

```bash
# When ready for production/breaking changes
git checkout main
git tag v1.0.0 -m "Release 1.0.0: Production ready"
git push origin v1.0.0
# → Docker Hub: 1.0.0, 1.0, 1, latest

# Next merge: 1.0.1, 1.0.2, 1.0.3...
```

## Version Timeline Example

```
0.0.1  ← Initial version (GitVersion.yml)
  ↓
0.0.2  ← Merge #1 to main (auto)
  ↓
0.0.3  ← Merge #2 to main (auto)
  ↓
0.0.4  ← Merge #3 to main (auto)
  ↓
[Manual Tag: v0.1.0]
  ↓
0.1.0  ← Tagged release
  ↓
0.1.1  ← Merge #4 to main (auto)
  ↓
0.1.2  ← Merge #5 to main (auto)
  ↓
[Manual Tag: v0.2.0]
  ↓
0.2.0  ← Tagged release
  ↓
0.2.1  ← Merge #6 to main (auto)
  ↓
[Manual Tag: v1.0.0]
  ↓
1.0.0  ← Major release
  ↓
1.0.1  ← Merge #7 to main (auto)
  ↓
1.0.2  ← Merge #8 to main (auto)
```

## Docker Hub Tags

Each version creates multiple Docker tags:

| Version | Docker Tags |
|---------|-------------|
| 0.0.1 | `0.0.1`, `0.0`, `0`, `latest` |
| 0.0.2 | `0.0.2`, `0.0`, `0`, `latest` |
| 0.1.0 | `0.1.0`, `0.1`, `0`, `latest` |
| 0.1.5 | `0.1.5`, `0.1`, `0`, `latest` |
| 1.0.0 | `1.0.0`, `1.0`, `1`, `latest` |
| 1.0.1 | `1.0.1`, `1.0`, `1`, `latest` |

**Note**: Major/minor tags (`0.1`, `1`) always point to the latest patch.

## When to Tag

### Patch Increment (0.0.z)
**No tag needed** - Automatic on merge to main
- Bug fixes
- Minor improvements
- Documentation updates
- Dependency updates

### Minor Increment (0.y.0)
**Manual tag required**
- New features (backward compatible)
- Significant enhancements
- New API endpoints
- Feature milestones

### Major Increment (x.0.0)
**Manual tag required**
- Breaking changes
- Major refactors
- API redesigns
- Production releases

## FAQ

**Q: Why does every merge increment the version?**
A: This ensures every Docker image has a unique, traceable version tied to Git history.

**Q: How do I skip a version increment?**
A: You can't skip automatic patch increments. Use pre-release branches (feature/*, develop) for work-in-progress.

**Q: Can I use conventional commits to auto-bump minor/major?**
A: Not in the current configuration. Minor/major bumps require explicit tags to maintain control.

**Q: What happens if I don't push tags?**
A: Versions continue incrementing patches (0.0.1 → 0.0.2 → 0.0.3...) until you tag.

**Q: How do I revert to an older version?**
A: Pull the specific version tag:
```bash
docker pull oobdev/azurinsight:0.0.5
```

**Q: Can I see the version in the container?**
A: Yes, it's in the image labels:
```bash
docker inspect oobdev/azurinsight:latest | grep version
```

## Summary

✅ **Automatic**: Patch version (z) increments on every merge to main
✅ **Manual**: Minor (y) and major (x) bumps via Git tags
✅ **Traceable**: Every version maps to a Git commit
✅ **Flexible**: Use tags to control minor/major milestones

For detailed GitVersion usage, see [GITVERSION_GUIDE.md](GITVERSION_GUIDE.md).
