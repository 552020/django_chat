.PHONY: help build_backend run_backend run_docker_compose clean

# Define a list of possible virtual environment directories
POSSIBLE_VENVS = venv .venv env myenv

# Allow passing VENV_PATH as an argument. If not passed, attempt to auto-detect.
VENV_PATH ?= $(shell for dir in $(POSSIBLE_VENVS); do \
                    if [ -d "$$dir" ]; then \
                        echo $$dir; \
                        break; \
                    fi; \
                 done)

# Show available commands
help:
	@echo "Available commands:"
	@echo "  make rundev                  - Start Django development server and Redis (Dockerized Redis)."
	@echo "                                Use VENV_PATH=<path> to specify a custom virtual environment path."
	@echo "                                Example: make rundev VENV_PATH=/path/to/your/venv"
	@echo "  make re-rundev               - Restart Django development server and Redis, removing all Redis data."
	@echo "  make up-dev             - Start the development environment (Docker Compose with development settings)"
	@echo "  make up-prod            - Start the production environment in detached mode"
	@echo "  make logs-prod          - View logs for the production environment"
	@echo "  make up-prod-non-det    - Start the production environment in non-detached mode (view logs)"
	@echo "  make down-dev           - Stop and remove containers in development"
	@echo "  make down-prod          - Stop and remove containers in production"
	@echo "  make build-nginx        - Build the Nginx Docker image"
	@echo "  make run-nginx          - Run the Nginx container with mounted SSL certificates"
	@echo "  make stop-nginx         - Stop and remove the Nginx container"
	@echo "  make check-live-server  - Check if live-server is installed"
	@echo "  make stop-live-server   - Stop the live-server process"
	@echo "  make clean              - Remove Docker containers and images"
	@echo "  make fclean          	 - Clean up Docker volumes, networks, and rebuild"
	@echo "  make re             	 - Rebuild and restart the containers"


load_env:
	@if [ -f .env ]; then \
		echo "Loading environment variables from .env"; \
		set -a; source .env; set +a; \
	fi


# Run Django development server and Redis (Dockerized Redis)
rundev: load_env check_venv install_dependencies check-live-server run_docker_redis run_docker_postgres migrate  run_backend start-live-server start-vite-dev-server

# Re-run the development environment with a clean Redis setup
re-rundev: stop_docker_redis_clean rundev

check_venv:
	@if [ -z "$(VENV_PATH)" ]; then \
		echo "It looks like the virtual environment was not found."; \
		echo "We checked for: $(POSSIBLE_VENVS)."; \
		echo "Please create a virtual environment with something like:"; \
		echo "python3 -m venv venv"; \
		echo "Alternatively, you can specify your virtual environment path when running the Makefile like this:"; \
		echo "make rundev VENV_PATH=path/to/your/venv"; \
		exit 1; \
	fi; \
	if [ -z "$$VIRTUAL_ENV" ]; then \
		echo "Error: The virtual environment is not activated."; \
		echo "Please activate it with:"; \
		echo "source $(VENV_PATH)/bin/activate"; \
		exit 1; \
	else \
		echo "Virtual environment activated at: $(VENV_PATH)"; \
	fi

# Apply migrations
migrate: check_venv
	@echo "Applying migrations..."
	$(VENV_PATH)/bin/python src/backend/manage.py migrate

# Install project dependencies inside virtual environment and upgrade pip before
install_dependencies: check_venv
	@echo "Upgrading pip..."
	$(VENV_PATH)/bin/pip install --upgrade pip
	@echo "Installing dependencies..."
	$(VENV_PATH)/bin/pip install -r src/backend/requirements.txt


# Run Django development server
run_backend: check_venv
	@echo "Starting Django development server with POSTGRES_HOST=localhost..."
# python src/backend/manage.py runserver 127.0.0.1:8000
	@export POSTGRES_HOST=localhost && $(VENV_PATH)/bin/python src/backend/manage.py runserver 127.0.0.1:8000


# Run PostgreSQL in Docker for Development
run_docker_postgres:
	@echo "Starting PostgreSQL server in Docker..."
	@if docker ps -a --filter "name=postgres-dev" | grep "postgres-dev"; then \
		echo "Postgres container already exists. Starting it..."; \
		docker start postgres-dev; \
	else \
		docker run --name postgres-dev -e POSTGRES_DB=$(POSTGRES_DB) \
			-e POSTGRES_USER=$(POSTGRES_USER) -e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
			-p 5432:5432 -d postgres:16; \
	fi
	@echo "Waiting for PostgreSQL to be ready..."
	@sleep 5  # Adjust this delay if necessary


# Start Redis in Docker for Development
run_docker_redis:
	@echo "Starting Redis server in Docker..."
	@if docker ps -a --filter "name=redis-dev" | grep "redis-dev"; then \
		echo "Redis container already exists. Starting it..."; \
		docker start redis-dev; \
	else \
		docker run --name redis-dev -p 6379:6379 -d redis; \
	fi

# Stop Redis Docker container and remove the data (volume is deleted)
stop_docker_redis_clean:
	@echo "Stopping Redis server in Docker and removing data..."
	docker stop redis-dev || true
	docker rm -v redis-dev || true


# Run for Development (it uses docker-compose.override.yml for dev)
up-dev:
# docker compose up --build
	@echo "Starting dockerized development environment..."
	docker compose up --build

# Stop and remove all containers for Development
down-dev:
	@echo "Stopping dockerized development environment..."
	docker compose down

# Run for Production (without override) in detached mode
up-prod:
	docker compose -f docker-compose.yml up --build -d


# View logs for Production
logs-prod:
	docker compose -f docker-compose.yml logs -f



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

# Run live-server for the frontend and Django runserver for the backend
start-live-server:
# Run live-server in the background (frontend)
	@echo "Starting live-server for frontend..."
	@cd src/frontend && live-server --port=8080 --proxy=/chat:http://localhost:8000/chat/ &

start-vite-dev-server:
# Run Vite dev server for Three.js (in the threejs folder)
# We will remove this later
	@echo "Starting Vite development server for Three.js..."
	@cd src/frontend/threejs/11-materials && npm install && npm run dev &



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
