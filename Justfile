
docker_cmd := "podman"

build:
  poetry build

image: build
  #!/usr/bin/env bash
  version=$(poetry version -s)
  {{ docker_cmd }} build -t pg_operator:${version} --build-arg VERSION=${version} .
