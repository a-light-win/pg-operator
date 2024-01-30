FROM python:3.12
ARG VERSION
COPY dist /tmp/dist
RUN pip install --no-cache-dir /tmp/dist/pg_operator-${VERSION}-py3-none-any.whl
CMD ["kopf", "run", "--all-namespaces", "-m", "a_light.pg_operator"]
