from django.contrib import admin
from .models import Lead


@admin.register(Lead)
class LeadAdmin(admin.ModelAdmin):
    list_display = ['email', 'country', 'region', 'city', 'ip_address', 'created_at']
    ordering = ['-created_at']
