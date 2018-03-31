from __future__ import absolute_import, unicode_literals
from celery import shared_task
from django.core.management import call_command
from StringIO import StringIO
import time

# etl processing
@shared_task(name='ptop.etl')
def etl(step):
    start_time = time.time() 
    out = StringIO()
    if step == '1':
        call_command('demographicsETL', stdout=out)
        return 'Demographics ' + out.getvalue() + ' in ' + str(time.time()-start_time) + 's'
    elif step == '2':
        call_command('enrollmentETL', stdout=out)
        return 'Enrollment ' + out.getvalue() + ' in ' + str(time.time()-start_time) + 's'
    else:
        return 'Invalid step'
