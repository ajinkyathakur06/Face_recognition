FROM python:3.8-bullseye
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    g++ \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    libboost-python-dev \
    python3-dev \
    python3-distutils \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy the project files
COPY . /app/

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
FROM python:3.8-slim-bullseye

WORKDIR /app

# Install system dependencies including Boost.Python
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
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Copy and install Python dependencies
COPY requirements.txt /app/
RUN pip install -r requirements.txt

# Copy project files
COPY . /app/

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
