# Makefile for managing Docker builds, tests, and containers

.PHONY: help build_backend run_backend up down clean

# Show all available make commands
help:
	@echo "Available commands:"
	@echo "  make build_backend           - Build the backend Docker image"
	@echo "  make run_backend             - Run the backend container only"
	@echo "  make up                      - Bring up the full Docker Compose environment (Django + Redis)"
	@echo "  make down                    - Bring down the Docker Compose environment"
	@echo "  make clean                   - Remove Docker containers and images"

# Build the backend Docker image
build_backend:
	docker build -t django_chat ./src/backend

# Run the backend container only
run_backend: build_backend
	docker run -p 8000:8000 django_chat

# Bring up the full Docker Compose environment (Django + Redis)
up:
	docker compose up --build

# Bring down the Docker Compose environment
down:
	docker compose down

# Clean up Docker containers and images
clean:
	docker compose down
	docker system prune -f
