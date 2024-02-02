FROM python:3.12
ENV POETRY_VIRTUALENVS_CREATE=false
RUN pip install poetry poetry-plugin-export
COPY pyproject.toml poetry.lock /tmp/project/
RUN cd /tmp/project \
  && poetry export -o /requirements.txt \
  && pip install -r /requirements.txt
