from __future__ import absolute_import, unicode_literals
from celery import shared_task
from django.core.management import call_command
from StringIO import StringIO

# etl processing
@shared_task(name='ptop.etl')
def etl(step):
    if step == '1':
        out = StringIO()
        call_command('demographicsETL', stdout=out)
        return out.getvalue()
    elif step == '2':
        out = StringIO()
        call_command('enrollmentETL', stdout=out)
        return out.getvalue()
    else:
        return 'invalid step'
