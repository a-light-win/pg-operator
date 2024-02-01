
docker_cmd := "podman"
image_path := "registry.home.2204.win/a-light-win/pg-operator"
# image_path := "ghcr.io/a-light-win/pg-operator"

build:
  poetry build

image: build
  #!/usr/bin/env bash
  version=$(poetry version -s)
  {{ docker_cmd }} build -t {{ image_path }}:${DEV_TAG} --build-arg VERSION=${version} .

publish: image
  {{ docker_cmd }} push {{ image_path }}:${DEV_TAG}

deploy: publish
  #!/usr/bin/env bash

  if ! kubectl get namespace database-dev; then
    kubectl create namespace database-dev;
  fi

  kubectl apply -k k8s/dev
