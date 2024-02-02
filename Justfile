
docker_cmd := "podman"
image_path := "registry.home.2204.win/a-light-win/pg-operator"
dev_tag := "dev-latest"
builder_image_path := "ghcr.io/a-light-win/pg-operator/builder"
# image_path := "ghcr.io/a-light-win/pg-operator"

builder:
  #!/usr/bin/env bash
  HASH_BUILDER_DOCKERFILE=$(sha256sum Dockerfile.builder | cut -c 1-16)
  HASH_POETRY_LOCK_FILE=$(sha256sum poetry.lock | cut -c 1-16)
  BUILDER_TAG=${HASH_BUILDER_DOCKERFILE}-${HASH_POETRY_LOCK_FILE}

  {{ docker_cmd }} build -t {{ builder_image_path }}:${BUILDER_TAG} -f Dockerfile.builder .

  TAG_IN_DOCKER=$(sed -n 's%.*/builder:\([^ ]\+\).*%\1%p' Dockerfile)
  {{ docker_cmd }} tag {{ builder_image_path }}:${BUILDER_TAG} {{ builder_image_path }}:${TAG_IN_DOCKER}


image: builder
  #!/usr/bin/env bash
  version=$(poetry version -s)
  {{ docker_cmd }} build -t {{ image_path }}:{{ dev_tag }} .

publish: image
  {{ docker_cmd }} push {{ image_path }}:{{ dev_tag }}

deploy: publish
  #!/usr/bin/env bash

  if ! kubectl get namespace database-dev; then
    kubectl create namespace database-dev;
  fi

  kubectl apply -k k8s/dev
