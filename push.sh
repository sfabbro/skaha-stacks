#!/bin/bash -eux

OWNER="images.canfar.net/skaha"
TAG=$(date +%y.%m)

CONTAINERS=( astroml astrojax astroflow astrotorch astroml-gpu astrojax-gpu astrotorch-gpu astroflow-gpu )

for container in "${CONTAINERS[@]}"; do
    docker push ${OWNER}/${container}:${TAG}
done
