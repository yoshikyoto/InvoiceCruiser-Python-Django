FROM python:3

RUN mkdir -p /opt
COPY requirements.txt /opt/requirements.txt
WORKDIR /opt
RUN pip install -r requirements.txt

COPY app /opt/app
WORKDIR app
CMD python manage.py runserver
