# Use the official Python image
FROM python:3.12-slim

# Set environment variables to prevent bytecode creation and buffer outputs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file
COPY requirements.txt /app/

# Install dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy the entire project directory to the container
COPY . /app/

# Expose the port on which Django will run
# EXPOSE 8000
EXPOSE 80
EXPOSE 443

# Command to run the application using Daphne (ASGI server for WebSockets) with SSL #Fallback: overriden by docker-compose
# CMD ["sh", "-c", "python manage.py migrate && daphne -b 0.0.0.0 -p 443 --ssl-key /ejc/ssl/certs/privkey.pem --ssl-cert /etc/ssl/certs/fullchain.pem websocket_demo.asgi:application"]
CMD ["sh", "-c", "python manage.py migrate && daphne -e ssl:443:privateKey=/etc/ssl/certs/privkey.pem:certKey=/etc/ssl/certs/fullchain.pem websocket_demo.asgi:application"]
