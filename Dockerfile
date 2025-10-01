# Usa Python 3.7 (Django 1.11 es compatible hasta 3.7)
FROM python:3.7-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Dependencias del sistema para psycopg2 y WeasyPrint 0.40
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libffi-dev \
    libcairo2 \
    libpango-1.0-0 \
    libpangoft2-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf-2.0-0 \
    libjpeg62-turbo \
    zlib1g \
    libfreetype6 \
    libharfbuzz0b \
    libfribidi0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt /app/

# Celery 3.x requiere pip antiguo para evitar el error de metadatos
RUN python -m pip install --upgrade "pip<24.1"

# (opcional) constraints para blindar Celery 3.x
# COPY constraints.txt /app/
# RUN pip install -r requirements.txt -c constraints.txt

RUN pip install -r requirements.txt
COPY . /app/

ENV PORT=8000
CMD gunicorn microfinance.wsgi:application --bind 0.0.0.0:${PORT}
