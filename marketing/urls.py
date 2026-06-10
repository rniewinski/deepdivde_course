from django.urls import path
from . import views

app_name = 'marketing'

urlpatterns = [
    path('', views.signup, name='signup'),
    path('confirm/', views.confirm, name='confirm'),
]
