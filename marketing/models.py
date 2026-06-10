from django.db import models
from django.utils.translation import gettext_lazy as _


class Lead(models.Model):
    email = models.EmailField(unique=True, error_messages={
        'unique': _("This email is already on the waitlist."),
    })
    created_at = models.DateTimeField(auto_now_add=True)

    # Request metadata
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    http_referer = models.CharField(max_length=2048, blank=True)
    accept_language = models.CharField(max_length=255, blank=True)

    # IP geolocation
    country = models.CharField(max_length=100, blank=True)
    region = models.CharField(max_length=100, blank=True)
    city = models.CharField(max_length=100, blank=True)

    def __str__(self):
        return self.email
