#!/bin/bash -eux

OWNER="images.canfar.net/skaha"
TAG=$(date +%y.%m)

CONTAINERS=( astroml astrojax astroflow astrotorch astroml-gpu astrojax-gpu astrotorch-gpu astroflow-gpu )

# build base container
mkdir -p build
cp -r base build/base
pushd build/base
docker build --rm --force-rm \
       --tag ${OWNER}/base:${TAG} \
       --build-arg TAG=${TAG} \
       --build-arg OWNER=${OWNER} . | tee build.log
popd

# build all other ones
for container in "${CONTAINERS[@]}"; do
    ./make-container.sh build/${container}
    pushd build/${container}
    docker build --rm --force-rm \
	   --tag ${OWNER}/${container}:${TAG} \
	   --build-arg TAG=${TAG} \
	   --build-arg OWNER=${OWNER} . | tee build.log
    popd
done
