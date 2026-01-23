# Azurinsight Docker Management
DOCKER_IMAGE := oobdev/azurinsight

# Get version from GitVersion (requires gitversion installed)
VERSION := $(shell gitversion -showvariable SemVer 2>/dev/null || echo "dev")

.PHONY: help build push run stop clean logs test version

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

version: ## Show current version from GitVersion
	@echo "Version: $(VERSION)"
	@gitversion 2>/dev/null || echo "Install GitVersion: https://gitversion.net/docs/usage/cli/installation"

build: ## Build Docker image locally
	docker build -t $(DOCKER_IMAGE):latest -t $(DOCKER_IMAGE):$(VERSION) .

build-multiarch: ## Build multi-architecture image (requires buildx)
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t $(DOCKER_IMAGE):latest \
		-t $(DOCKER_IMAGE):$(VERSION) \
		--push .

push: build ## Build and push to Docker Hub
	docker push $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):$(VERSION)

run: ## Run with docker-compose (builds locally)
	docker-compose up -d

run-prod: ## Run with docker-compose (pulls from Docker Hub)
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

stop: ## Stop running containers
	docker-compose down

clean: ## Stop and remove containers, volumes, and images
	docker-compose down -v
	docker rmi $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):$(VERSION) 2>/dev/null || true

logs: ## View container logs
	docker-compose logs -f

test: ## Test the built image
	docker run --rm $(DOCKER_IMAGE):latest node --version
	@echo "✓ Image test passed"

shell: ## Open shell in running container
	docker-compose exec azurinsight sh

db-backup: ## Backup SQLite database
	docker run --rm -v azurinsight-data:/data -v $$(pwd):/backup alpine \
		tar czf /backup/azurinsight-backup-$$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
	@echo "✓ Backup created"

db-restore: ## Restore SQLite database (requires BACKUP_FILE env var)
	@test -n "$(BACKUP_FILE)" || (echo "Error: Set BACKUP_FILE=/path/to/backup.tar.gz" && exit 1)
	docker run --rm -v azurinsight-data:/data -v $$(pwd):/backup alpine \
		sh -c "cd /data && tar xzf /backup/$(BACKUP_FILE)"
	@echo "✓ Database restored from $(BACKUP_FILE)"

health: ## Check container health
	@docker inspect azurinsight-server --format='{{.State.Health.Status}}' 2>/dev/null || echo "Container not running"

status: ## Show container status
	docker-compose ps
