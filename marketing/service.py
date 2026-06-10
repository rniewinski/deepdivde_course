import json
from urllib.error import URLError
from urllib.request import urlopen

from .models import Lead


def _get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        return x_forwarded_for.split(',')[0].strip()
    return request.META.get('REMOTE_ADDR')


def _get_geo(ip):
    if not ip or ip in ('127.0.0.1', '::1'):
        return {}
    try:
        url = f'http://ip-api.com/json/{ip}?fields=status,country,regionName,city'
        with urlopen(url, timeout=2) as resp:
            data = json.loads(resp.read())
        if data.get('status') == 'success':
            return {'country': data.get('country', ''), 'region': data.get('regionName', ''), 'city': data.get('city', '')}
    except (URLError, Exception):
        pass
    return {}


def create_lead(email, request):
    ip = _get_client_ip(request)
    geo = _get_geo(ip)
    return Lead.objects.create(
        email=email,
        ip_address=ip,
        user_agent=request.META.get('HTTP_USER_AGENT', ''),
        http_referer=request.META.get('HTTP_REFERER', ''),
        accept_language=request.META.get('HTTP_ACCEPT_LANGUAGE', ''),
        **geo,
    )
