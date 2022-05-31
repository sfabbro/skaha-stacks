#!/bin/bash

PYTHON_VERSION=3.9.*
CUDA_VERSION=11.2
RAPIDS_VERSION=22.04

dir=${1}
env=$(basename ${dir%-gpu})

rm -rf ${dir}
mkdir ${dir}
cp Dockerfile.env ${dir}/Dockerfile

# make list of packages
for p in $(cat envs/${env}); do
    [[ -e pkg/${p}.channels ]] && grep -v \# pkg/${p}.channels >> ${dir}/channels.list
    [[ -e pkg/${p}.conda ]] && grep -v \# pkg/${p}.conda >> ${dir}/conda.list
    [[ -e pkg/${p}.pip ]]   && grep -v \# pkg/${p}.pip >> ${dir}/pip.list
done

# gpu hacks
if [[ ${dir} =~ gpu ]]; then
    echo "cudatoolkit=${CUDA_VERSION}*" >> ${dir}/conda.list
    echo "nccl" >> ${dir}/conda.list
    grep -q jupyter ${dir}/conda.list && \
	echo "jupyterlab-nvdashboard" >> ${dir}/conda.list
    sed -i -e "s|cpu|cu|g" ${dir}/conda.list

    # hack for the astroml to include rapids (gpu only)
    if [[ ${env} == astroml ]]; then
	echo "rapidsai" >> ${dir}/channels.list
	echo "nvidia" >> ${dir}/channels.list
	echo "rapids=${RAPIDS_VERSION}"  >> ${dir}/conda.list
    fi
    # sed -i -e "s|cpu|cuda|g" ${dir}/pip.list
    sed -i -e "s|\(CONDA_OVERRIDE_CUDA=\).*|\1${CUDA_VERSION}|" ${dir}/Dockerfile
    #CONDA_CUDA_VERSION="${CUDA_VERSION}"
fi
echo "conda-forge" >> ${dir}/channels.list

# make the conda environment file
echo >> ${dir}/env.yml "name: base"
echo >> ${dir}/env.yml "channels:"
cat ${dir}/channels.list \
    | sort | uniq \
    | sed -e 's|\(.*\)|  - \1|g' \
	  >> ${dir}/env.yml

# useless?
#echo >> ${dir}/env.yml "variables:"
#echo >> ${dir}/env.yml "  CONDA_OVERRIDE_CUDA: \"${CONDA_CUDA_VERSION}\""
#echo >> ${dir}/env.yml "  MKL_THREADING_LAYER: \"GNU\""

echo >> ${dir}/env.yml "dependencies:"
echo >> ${dir}/env.yml "  - python=${PYTHON_VERSION}"
echo >> ${dir}/env.yml "  - pip"
echo >> ${dir}/env.yml "  - pip-tools"

cat ${dir}/conda.list \
    | sort | uniq \
    | sed -e 's|\(.*\)|  - \1|g' \
	  >> ${dir}/env.yml

if [[ $(wc -l ${dir}/pip.list | awk '{print $1}') -gt 0 ]]; then
    echo "  - pip:" >> ${dir}/env.yml
    cat ${dir}/pip.list \
	| sort | uniq \
	| sed -e 's|\(.*\)|     - \1|g' \
	      >> ${dir}/env.yml
fi

# make the pinned file from the yml file
awk '/=/{print $2}' ${dir}/env.yml |  sed 's|=| |g' > ${dir}/pinned
