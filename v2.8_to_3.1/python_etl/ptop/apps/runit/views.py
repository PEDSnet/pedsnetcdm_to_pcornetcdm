from django import forms
from django.views.generic import FormView
from django.core.urlresolvers import reverse_lazy
from django.contrib import messages
from ptop.celery import app

class RunItFormDummy(forms.Form):
    ETLSTEPS = (
        ('1', 'Person Visit'),
        ('2', 'Demographics'),
        ('3', 'Enrollment'),
        ('4', 'Death'),
        ('5', 'Death Cause'),
    ) 
    etl_step = forms.ChoiceField(choices=ETLSTEPS, required=True, label='ETL Step' )


class RunItView(FormView):
    form_class = RunItFormDummy
    template_name = 'runit/runit.html'
    success_url = reverse_lazy('home')

    def form_valid(self, form):
        r = app.send_task('ptop.etl', args=(
            form.cleaned_data.get('etl_step'),))         

        messages.info(
            self.request,
            "Job submitted with id <a href='{}' target='_blank'>{}</a>".format(
                reverse_lazy("admin:django_celery_results_taskresult_changelist"), # NOQA
                r.id))
        return super(RunItView, self).form_valid(form)
