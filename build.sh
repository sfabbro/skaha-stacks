#!/bin/bash -eux

OWNER="images.canfar.net/skaha"
TAG=$(date +%y.%m)
CONTAINERS=( astroml astrotorch astroflow astroml-gpu astrotorch-gpu astroflow-gpu )

pushd base
docker build --rm --force-rm -t ${OWNER}/base:${TAG} --build-arg OWNER=${OWNER} .
popd

mkdir -p build
for container in "${CONTAINERS[@]}"; do
    ./make-container.sh build/${container}
    pushd build/${container}
    docker build --rm --force-rm \
	   -t ${OWNER}/${container}:${TAG} \
	   --build-arg TAG=${TAG} \
	   --build-arg OWNER=${OWNER} . | tee build.log
    popd
    docker push ${OWNER}/${container}:${TAG}
done
