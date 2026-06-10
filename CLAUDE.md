# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Django 6.0.5 project managed with Poetry, using Python 3.14. It is a course/learning project in its initial state — only the default Django project scaffold exists; no custom apps have been added yet.

## Commands

### Setup

```bash
poetry install
```

### Run development server

```bash
python manage.py runserver
```

### Run with uWSGI

```bash
poetry run uwsgi --ini uwsgi.ini
```

### Database migrations

```bash
python manage.py makemigrations
python manage.py migrate
```

### Run tests

```bash
python manage.py test
```

Run a single test module:

```bash
python manage.py test <app_label>.tests.<TestClass>.<test_method>
```

### Django shell

```bash
python manage.py shell
```

## Architecture

- **`deepdive_course/`** — Django project package (settings, root URL config, WSGI/ASGI entrypoints). This is the configuration layer, not where application logic lives.
- **`deepdive_course/settings.py`** — SQLite database, `DEBUG=True`, no custom apps installed yet.
- **`deepdive_course/urls.py`** — Only the admin URL is wired; new app URL patterns should be `include()`d here.
- **`manage.py`** — Standard Django management entrypoint; `DJANGO_SETTINGS_MODULE` is set to `deepdive_course.settings`.

New Django apps should be created with `python manage.py startapp <name>` and registered in `INSTALLED_APPS` in `settings.py`.
