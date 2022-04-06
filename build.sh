#!/bin/bash -eux

DEVICES="cpu gpu"

OWNER="images.canfar.net/skaha"
TAG=$(date +%y.%m)

deviceit() {
    local dir=$1 device=${2}
    [[ -e ${dir}/env.yml.in ]] && \
	sed -e "s|%%DEVICE%%|${device}|g" ${dir}/env.yml.in > ${dir}/env.yml
    [[ -e ${dir}/pinned.in ]] && \
	sed -e "s|%%DEVICE%%|${device}|g" ${dir}/pinned.in > ${dir}/pinned
    if [[ ${device} == cu ]]; then
	sed -e "s|#- cudatoolkit|- cudatoolkit|" \
	    -e "s|#- jupyterlab-nvdashboard|- jupyterlab-nvdashboard|" \
	    -i ${dir}/env.yml
    fi
}

for d in ${DEVICES}; do
    
    if [[ ${d} == gpu ]]; then
	c=cu
	ext="-${d}"
	deviceit rapids ${c}
	make -C rapids  TAG=${TAG} IMAGE=${OWNER}/rapids${ext} build
    else
	c=cpu
	ext=
    fi
    
    deviceit base ${c}
    make -C base  TAG=${TAG} IMAGE=${OWNER}/base${ext} build
    deviceit astro ${c}
    make -C astro TAG=${TAG} IMAGE=${OWNER}/astro${ext} DARGS="--build-arg BASE_CONTAINER=${OWNER}/base${ext}:${TAG}" build
    deviceit ml ${c}
    make -C ml    TAG=${TAG} IMAGE=${OWNER}/astroml${ext} DARGS="--build-arg BASE_CONTAINER=${OWNER}/astro${ext}:${TAG}" build
    deviceit torch ${c}
    make -C torch TAG=${TAG} IMAGE=${OWNER}/astrotorch${ext} DARGS="--build-arg BASE_CONTAINER=${OWNER}/astroml${ext}:${TAG}" build
    deviceit flow ${c}
    make -C flow  TAG=${TAG} IMAGE=${OWNER}/astroflow${ext} DARGS="--build-arg BASE_CONTAINER=${OWNER}/astroml${ext}:${TAG}" build
done
