FROM python:3.12
ENV POETRY_VIRTUALENVS_CREATE=false
RUN pip install poetry
COPY pyproject.toml poetry.lock /tmp/project/
RUN cd /tmp/project \
  && poetry install --no-interaction --no-root
