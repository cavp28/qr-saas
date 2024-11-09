# Dockerfile for Backend Service

# Use an official Python runtime as a parent image
FROM python:3.12.6

# Set the working directory in the container
WORKDIR /app

# Copy the requirements files
COPY requirements.txt requirements-dev.txt ./

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install development dependencies only in dev environment
ARG ENV=production
RUN if [ "$ENV" = "development" ]; then pip install --no-cache-dir -r requirements-dev.txt; fi

# Copy the rest of the application code
COPY . .

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]