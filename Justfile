
docker_cmd := "podman"

builder_image_path := "ghcr.io/a-light-win/pg-operator/builder"

_dist_dir:
  mkdir -p dist

builder: _dist_dir
  #!/usr/bin/env bash
  HASH_BUILDER_DOCKERFILE=$(sha256sum Dockerfile.builder | cut -c 1-16)
  HASH_POETRY_LOCK_FILE=$(sha256sum poetry.lock | cut -c 1-16)
  BUILDER_TAG=${HASH_BUILDER_DOCKERFILE}-${HASH_POETRY_LOCK_FILE}

  # Do not build again if the builder image is already built
  PRE_BUILDER_TAG=$(cat dist/.builder_tag 2>/dev/null)
  if [ "$BUILDER_TAG" = "$PRE_BUILDER_TAG" ] ;then
    echo "Builder image is already built"
    exit 0
  fi

  {{ docker_cmd }} build -t {{ builder_image_path }}:${BUILDER_TAG} -f Dockerfile.builder . || exit $?

  echo "$BUILDER_TAG" > dist/.builder_tag

  TAG_IN_DOCKER=$(sed -n 's%.*/builder:\([^ ]\+\).*%\1%p' Dockerfile)
  {{ docker_cmd }} tag {{ builder_image_path }}:${BUILDER_TAG} {{ builder_image_path }}:${TAG_IN_DOCKER}


build: builder
  #!/usr/bin/env bash

  version=$(poetry version -s)
  DEV_TAG=$(sha256sum dist/pg_operator-${version}-py3-none-any.whl| cut -c 1-32)
  
  if [ ! -e k8s/local-dev ] ; then
    cp -a k8s/dev k8s/local-dev
  fi

  sed -i "s%namespace: .*%namespace: ${DEV_NAMESPACE}%g" k8s/local-dev/kustomization.yaml
  sed -i "s%newName: .*%newName: ${IMAGE_PATH}%g" k8s/local-dev/kustomization.yaml
  sed -i "s%newTag: .*%newTag: ${DEV_TAG}%g" k8s/local-dev/kustomization.yaml

  # Do not build again if the image is already built
  if [ "$DEV_TAG" = "$(cat dist/.dev_tag 2>/dev/null)" ] ;then
    echo "pg-operator image is already built"
    exit 0
  fi

  {{ docker_cmd }} build -t ${IMAGE_PATH}:${DEV_TAG} . || exit $?
  echo "$DEV_TAG" > dist/.dev_tag

  {{ docker_cmd }} push ${IMAGE_PATH}:${DEV_TAG} || exit $?

deploy: build
  #!/usr/bin/env bash

  if ! kubectl get namespace ${DEV_NAMESPACE} &>/dev/null ; then
    kubectl create namespace ${DEV_NAMESPACE}
  fi

  kubectl apply -k k8s/local-dev
