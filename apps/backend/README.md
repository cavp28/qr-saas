# QR Code SaaS Backend

This is the backend service for the QR Code SaaS platform, built with FastAPI and SQLAlchemy. It provides APIs for managing user accounts, generating static and dynamic QR codes, tracking scan events, and retrieving analytics. The backend is designed to be scalable and supports a high volume of transactions per minute.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Environment Variables](#environment-variables)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Running Tests](#running-tests)

---

## Features

- **User Management**: Register, login, and manage user accounts.
- **QR Code Generation**: Create static and dynamic QR codes with data like URLs, contact info, and Wi-Fi details.
- **Dynamic URL Redirects**: Update URLs for dynamic QR codes, enabling campaigns to adjust over time.
- **Scan Tracking**: Track when and where QR codes are scanned, for analytics.
- **Subscription Management**: Track free and premium user plans.

## Tech Stack

- **FastAPI**: For building high-performance APIs.
- **SQLAlchemy**: ORM for managing database interactions.
- **PostgreSQL**: Primary database for data storage.
- **Alembic**: For managing database migrations.
- **Docker**: Containerization for development and deployment.

---

## Getting Started

### Prerequisites

- [Python 3.9+](https://www.python.org/downloads/)
- [Docker](https://www.docker.com/get-started) (optional for containerized development)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/cavp28/qr-saas.git
   cd apps/backend 
    ```

2. **Create a virtual environment**:
    ```bash
    python3 -m venv venv
    source venv/bin/activated
    ```

3. **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

4. **Set up enviroment variables**:
- Create a `.env` file in the root directory or use the provided `/config/dev.env` for local development.
- Configure necessary environment variables as described in the [Environment Variables](#environment-variables) section.

---

## Project Structure
```bash
/backend
├── /app
│   ├── /api
│   │   ├── /endpoints                   # API route definitions
│   │   │   ├── __init__.py
│   │   │   ├── qr_code.py               # Routes related to QR codes
│   │   │   ├── user.py                  # Routes related to user actions
│   │   │   └── scan_event.py            # Routes for analytics
│   │   └── __init__.py
│   │
│   ├── /core                            # Core configuration, security, and dependencies
│   │   ├── __init__.py
│   │   ├── config.py                    # App-wide configurations (loading env vars, constants)
│   │   ├── security.py                  # Authentication and security logic (JWT, password hashing)
│   │   └── dependencies.py              # Dependency injection (e.g., database session management)
│   │
│   ├── /db                              # Database setup, models, and migrations
│   │   ├── __init__.py
│   │   ├── base.py                      # Base model definition, metadata, and ORM configurations
│   │   ├── session.py                   # Database session creation and management
│   │   ├── /migrations                  # Alembic migration scripts
│   │   └── /models                      # SQLAlchemy ORM models (your schema design goes here)
│   │       ├── __init__.py              # Import all models here for easy access
│   │       ├── user.py                  # User model
│   │       ├── qr_code.py               # QR code model
│   │       ├── scan_event.py            # Scan event model
│   │       └── subscription.py          # Subscription model (optional)
│   │
│   ├── /schemas                         # Pydantic models for request validation and response schemas
│   │   ├── __init__.py
│   │   ├── user.py                      # User request/response schemas
│   │   ├── qr_code.py                   # QR code request/response schemas
│   │   ├── scan_event.py                # Scan event request/response schemas
│   │   └── subscription.py              # Subscription schemas
│   │
│   ├── /services                        # Business logic and service layer
│   │   ├── __init__.py
│   │   ├── qr_code_service.py           # QR code-related business logic
│   │   ├── user_service.py              # User-related business logic
│   │   └── analytics_service.py         # Analytics-related business logic
│   │
│   ├── /utils                           # Helper functions and utility modules
│   │   ├── __init__.py
│   │   ├── qr_code_generator.py         # QR code generation logic
│   │   ├── geolocation.py               # Geolocation lookup utilities
│   │   └── pagination.py                # Pagination utilities for large result sets
│   │
│   ├── main.py                          # FastAPI app instantiation and router registration
│   └── alembic.ini                      # Alembic configuration file for migrations
│
├── .env                                 # Environment variables for local development
├── Dockerfile                           # Dockerfile for the backend service
├── requirements.txt                     # Python dependencies
└── README.md
```

---

## Enviroment Variables

The application requires the following environment variables. You can place them in a .env file in the root directory:

- **APP_ENV**: The environment name (`development`, `production`, `test`)
- **DATABASE_URL**: URL for connecting to the database (e.g., `postgresql://user:password@localhost/db_name`)
- **SECRET_KEY**: A secret key for JWT and password hashing
- **REDIS_URL**: URL for Redis instance (for caching if applicable)
- **BROKER_URL**: URL for the message broker (e.g., RabbitMQ, Kafka, if used for async tasks)

	__*Note*__: See the `/config` directory for example environment files.

---

## Running the Application

**Using Docker (recommended for development)**

1. Build and run the Docker container:
    ```bash
    docker-compose up --build
    ```

2. Access the API at http://localhost:8000.

**Without Docker**

1. Run database migrations:
    ```bash
    alembic upgrade head
    ```

2. Start the FastAPI server:
    ```bash
    uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ```

3. Access the API at http://localhost:8000.
