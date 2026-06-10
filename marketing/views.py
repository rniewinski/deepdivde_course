from django.shortcuts import render, redirect
from django.urls import reverse

from .forms import LeadForm
from .service import create_lead


def signup(request):
    if request.method == 'POST':
        form = LeadForm(request.POST)
        if form.is_valid():
            create_lead(form.cleaned_data['email'], request)
            return redirect(reverse('marketing:signup') + '?confirmed=1#waitlist')
    else:
        if request.GET.get('confirmed') == '1':
            return render(request, 'marketing/landingpage.html', {'confirmed': True})
        form = LeadForm()
    return render(request, 'marketing/landingpage.html', {'form': form})


def confirm(request):
    return render(request, 'marketing/landingpage.html', {'confirmed': True})
