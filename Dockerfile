FROM python:3.8-slim-bullseye

WORKDIR /app

# Install system dependencies (needed for OpenCV, dlib, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    libboost-all-dev \
    python3-dev \
    python3-distutils \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Copy and install Python dependencies
COPY requirements.txt /app/
RUN pip install -r requirements.txt

# Copy project files
COPY . /app/

# Expose Django port
EXPOSE 8000

# Run Django server
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]

