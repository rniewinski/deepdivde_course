#!/bin/sh
set -e
python manage.py migrate --noinput
exec uwsgi --ini uwsgi.ini
