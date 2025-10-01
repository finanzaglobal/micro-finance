# Django 1.11 funciona mejor con Python 3.7
FROM python:3.7-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Dependencias del sistema (WeasyPrint 0.40 y psycopg2)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libffi-dev \
    libcairo2 \
    pango-graphite \
    libpango-1.0-0 \
    libpangoft2-1.0-0 \
    libpangocairo-1.0-0 \
    libjpeg62-turbo \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt /app/

# 👇 Clave: pip < 24.1 para que acepte Celery 3.1.x
RUN python -m pip install --upgrade "pip<24.1"

# (opcional pero recomendable) Evitar celery 3.1.26.post2
# Puedes usar constraints si prefieres:
# RUN echo "celery==3.1.26.post1\nkombu==3.0.37\namqp==1.4.9\nbilliard==3.3.0.23\npytz<2024.0" > constraints.txt
# RUN pip install -r requirements.txt -c constraints.txt
RUN pip install -r requirements.txt

COPY . /app/

# Collect static (si aplicara)
# RUN python manage.py collectstatic --noinput

# Railway expone $PORT
ENV PORT=8000
CMD gunicorn microfinance.wsgi:application --bind 0.0.0.0:${PORT}
