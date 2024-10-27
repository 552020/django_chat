.PHONY: help build_backend run_backend run_docker_compose clean

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make up-dev             - Start the development environment (Docker Compose with development settings)"
	@echo "  make up-prod            - Start the production environment in detached mode"
	@echo "  make logs-prod          - View logs for the production environment"
	@echo "  make up-prod-non-det    - Start the production environment in non-detached mode (view logs)"
	@echo "  make down-dev           - Stop and remove containers in development"
	@echo "  make down-prod          - Stop and remove containers in production"
	@echo "  make build-nginx        - Build the Nginx Docker image"
	@echo "  make run-nginx          - Run the Nginx container with mounted SSL certificates"
	@echo "  make stop-nginx         - Stop and remove the Nginx container"
	@echo "  make run-dev            - Run both Django runserver and live-server for development"
	@echo "  make check-live-server  - Check if live-server is installed"
	@echo "  make install-live-server- Install live-server globally using npm"
	@echo "  make stop-live-server   - Stop the live-server process"
	@echo "  make clean              - Remove Docker containers and images"
	@echo "  make fclean          	 - Clean up Docker volumes, networks, and rebuild"
	@echo "  make re             	 - Rebuild and restart the containers"


# Run for Development (it uses docker-compose.override.yml for dev)
up-dev:
# docker compose up --build
	docker compose up --build

# Run for Production (without override) in detached mode
up-prod:
	docker compose -f docker-compose.yml up --build -d


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
	docker compose -f docker-compose.yml up --build

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

# Run Nginx container for development
run-nginx-dev:
	docker rm -f django-nginx-dev || true
	docker build --no-cache -t django-nginx-dev -f ./src/nginx/Dockerfile ./src --build-arg ENVIRONMENT=development-nginx
	docker run --name django-nginx-dev \
		-p 8080:80 \
		django-nginx-dev

# Stop the Nginx container for development
stop-nginx-dev:
	docker stop django-nginx-dev || true
	docker rm django-nginx-dev || true



# Check for live-server
check-live-server:
	@which live-server > /dev/null || (echo "Error: live-server is not installed. Install it with 'npm install -g live-server'"; exit 1)

# Install live-server if it's not installed globally (optional)
install-live-server:
	@npm install -g live-server

# Run live-server for the frontend and Django runserver for the backend
run-dev: check-live-server
	# Run live-server in the background (frontend)
	@echo "Starting live-server for frontend..."
	@cd src/frontend && live-server --port=3001 --proxy=/chat:http://localhost:8000/chat/ &

	# Run Vite dev server for Three.js (in the threejs folder)
	@echo "Starting Vite development server for Three.js..."
	@cd src/frontend/threejs/11-materials && npm install && npm run dev &

	# Start Redis in Docker (if not already running)
	@echo "Starting Redis in Docker..."
	docker run --name redis-dev -p 6379:6379 -d redis:latest || echo "Redis is already running."
	
	# Run Django's development server (backend)
	@echo "Starting Django development server..."
	python src/backend/manage.py runserver 0.0.0.0:8000

# Stop live-server (optional: in case you want to control stopping processes)
stop-live-server:
	@pkill -f live-server || true

# Clean and stop all running dev servers
stop-dev: stop-live-server
	@pkill -f runserver || true



# Clean everything (including volumes and networks)
fclean:
	docker compose down --volumes --remove-orphans
	docker system prune --volumes -f

# Rebuild and restart everything
re: fclean up-prod

# Clean up Docker containers and images
clean:
	docker system prune -f
