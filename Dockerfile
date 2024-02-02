FROM ghcr.io/a-light-win/pg-operator/builder:main-latest as builder
COPY . /app/
WORKDIR /app/
RUN poetry build \
  && site_packages_dir=$(python -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])') \
  && bin_dir=$(python -c 'import sysconfig; print(sysconfig.get_paths()["scripts"])') \
  && pip install /app/dist/pg_operator-*-py3-none-any.whl --target root/${site_packages_dir} \
  && pip install -r /requirements.txt --target root/${site_packages_dir} \
  && mv root/${site_packages_dir}/bin root/${bin_dir}

FROM python:3.12
COPY --from=builder /app/root/usr/ /usr/
CMD ["kopf", "run", "--all-namespaces", "-m", "a_light.pg_operator"]
