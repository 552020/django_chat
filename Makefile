.PHONY: help build_backend run_backend run_docker_compose clean

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make runserver-dev      - Start Django's runserver directly for faster development"
	@echo "  make up-dev             - Start the development environment (Docker Compose with development settings)"
	@echo "  make up-prod            - Start the production environment in detached mode"
	@echo "  make logs-prod          - View logs for the production environment"
	@echo "  make up-prod-non-det    - Start the production environment in non-detached mode (view logs)"
	@echo "  make down-dev           - Stop and remove containers in development"
	@echo "  make down-prod          - Stop and remove containers in production"
	@echo "  make build-nginx        - Build the Nginx Docker image"
	@echo "  make run-nginx          - Run the Nginx container with mounted SSL certificates"
	@echo "  make stop-nginx         - Stop and remove the Nginx container"
	@echo "  make clean              - Remove Docker containers and images"

# Run Django runserver directly for development (faster iteration)
runserver-dev:
	python src/backend/manage.py runserver 0.0.0.0:8000


# Run for Development (it uses docker-compose.override.yml for dev)
up-dev:
	docker compose up --build

# Run for Production (without override) in detached mode
up-prod:
	docker compose -f docker-compose.yml --profile production up --build -d


# View logs for Production
logs-prod:
	docker compose -f docker-compose.yml logs -f

# Stop and remove all containers for Development
down-dev:
	docker compose down

# Stop and remove all containers for Production
down-prod:
	docker compose -f docker-compose.yml down

# Run for Production (non-detached mode to view logs directly)
up-prod-non-det:
	docker compose -f docker-compose.yml --profile production up --build

# Build the Nginx image
build-nginx:
	docker build --no-cache -t django-nginx -f ./src/nginx/Dockerfile ./src

# Run the Nginx container
run-nginx:
	docker run --name django-nginx \
		-v /etc/letsencrypt/live/django.sldunit.xyz:/etc/ssl/certs/ \
		-v /etc/letsencrypt/archive/django.sldunit.xyz:/etc/letsencrypt/archive/django.sldunit.xyz \
		-p 80:80 \
		-p 443:443 \
		django-nginx

# Stop the Nginx container
stop-nginx:
	docker stop django-nginx || true
	docker rm django-nginx || true


# Clean up Docker containers and images
clean:
	docker system prune -f
