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

# Command to run the application using Daphne (ASGI server for WebSockets)
CMD ["sh", "-c", "python manage.py migrate && daphne -b 0.0.0.0 -p 80 websocket_demo.asgi:application"]
