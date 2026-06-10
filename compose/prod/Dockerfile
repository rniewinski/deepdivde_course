FROM python:3.14-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc python3-dev libpq-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install poetry
RUN poetry config virtualenvs.in-project true

WORKDIR /app
COPY ../../pyproject.toml poetry.lock ./
# --no-update: resolve new deps without upgrading existing ones
RUN poetry lock --no-update && poetry install --no-root --no-interaction


FROM python:3.14-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        libexpat1 libpq5 \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

COPY --from=builder /app/.venv /app/.venv
COPY ../.. .

# collectstatic is safe at build time (no DB needed)
RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Entrypoint runs migrations at container startup, then launches uWSGI
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
