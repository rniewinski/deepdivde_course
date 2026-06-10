# ── Stage 1: builder ─────────────────────────────────────────────────────────
# Installs all Python dependencies into an in-project .venv.
# This stage is discarded after the build; only .venv is carried forward.
FROM python:3.14-slim AS builder

# Install C build tools and the PostgreSQL client headers needed to compile
# compiled Python extensions (e.g. psycopg2).
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc python3-dev libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry (the dependency manager) into the builder's system Python.
RUN pip install poetry

# Tell Poetry to create the virtualenv inside the project directory (.venv/)
# so we can copy it as a single folder into the final image.
RUN poetry config virtualenvs.in-project true

WORKDIR /app

# Copy only the dependency manifests first so Docker can cache this layer —
# poetry install only re-runs when pyproject.toml or poetry.lock changes.
COPY pyproject.toml poetry.lock ./

# Install production dependencies only (--only main skips dev extras).
# --no-root skips installing the project package itself (not needed here).
RUN poetry install --no-root --no-interaction --only main


# ── Stage 2: runtime ─────────────────────────────────────────────────────────
# Lean production image — no build tools, only the compiled .venv from above.
FROM python:3.14-slim

# Install shared runtime libraries that compiled extensions link against at
# runtime (libpq5 for psycopg2, libexpat1 pulled in as a dependency).
RUN apt-get update && apt-get install -y --no-install-recommends \
        libexpat1 libpq5 \
    && rm -rf /var/lib/apt/lists/*

# PYTHONDONTWRITEBYTECODE — don't write .pyc files (not useful in a container).
# PYTHONUNBUFFERED     — flush stdout/stderr immediately (better for logs).
# PATH                 — put the virtualenv's bin/ first so `python` and all
#                        installed commands resolve to the venv, not system Python.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH"

WORKDIR /app

# Copy application source code into the image.
COPY . .

# Copy the pre-built virtualenv from the builder stage.
# This must come AFTER `COPY . .` so it isn't overwritten by a local .venv folder.
COPY --from=builder /app/.venv /app/.venv

# Collect static files into STATIC_ROOT at build time.
# Safe to run here because collectstatic doesn't touch the database.
RUN python manage.py collectstatic --noinput

# Document the port the application listens on (uWSGI binds to 8000).
EXPOSE 8000

# Copy the entrypoint script that runs migrations and starts uWSGI at container startup.
COPY compose/prod/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
