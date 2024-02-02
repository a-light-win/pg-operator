FROM ghcr.io/a-light-win/pg-operator/builder:main-latest as builder
COPY . /app/
WORKDIR /app/
RUN poetry build

FROM python:3.12
COPY --from=builder /app/dist/pg_operator-*-py3-none-any.whl /tmp/dist/
RUN pip install --no-cache-dir /tmp/dist/pg_operator-*-py3-none-any.whl
CMD ["kopf", "run", "--all-namespaces", "-m", "a_light.pg_operator"]
