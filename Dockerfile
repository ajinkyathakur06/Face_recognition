FROM python:3.8-slim-bullseye

# Working directory
WORKDIR /app

# -------------------------------
# Install system dependencies 
# Needed for OpenCV, dlib, face_recognition, mysqlclient, etc.
# -------------------------------
RUN apt-get update && apt-get install -y --fix-missing \
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
    default-libmysqlclient-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Install Python dependencies
# -------------------------------
COPY requirements.txt /app/
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# -------------------------------
# Copy project files
# -------------------------------
COPY . /app/

# -------------------------------
# Collect static files (optional)
# -------------------------------
RUN python manage.py collectstatic --noinput || true

# -------------------------------
# Expose Django/Gunicorn Port
# -------------------------------
EXPOSE 8000

# -------------------------------
# Production Command
# -------------------------------
CMD ["sh", "-c", "python manage.py migrate && gunicorn Attendence_System.wsgi:application --bind 0.0.0.0:8000"]
