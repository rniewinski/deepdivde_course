from django import forms
from django.urls import reverse_lazy
from django.utils.translation import gettext_lazy as _
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Submit, Field, Div

from .models import Lead


class LeadForm(forms.ModelForm):
    class Meta:
        model = Lead
        fields = ['email']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['email'].label = False
        self.helper = FormHelper()
        self.helper.form_action = reverse_lazy('marketing:signup')
        self.helper.form_method = 'post'
        self.helper.form_class = 'waitlist-form'
        self.helper.layout = Layout(
            Div(
                Field('email', placeholder=_('your@email.com')),
                Submit('submit', _('Join the waitlist'), css_class='btn btn-primary'),
                css_class='waitlist-field',
            )
        )
