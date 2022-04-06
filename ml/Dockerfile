ARG OWNER=skaha
ARG BASE_CONTAINER=${OWNER}/astro
FROM ${BASE_CONTAINER}

USER ${NB_USER}

# install conda environment on top of the base one
COPY env.yml .

RUN mamba env update -n base --file env.yml \
    && mamba clean --all --quiet --yes \
    && fix-permissions ${CONDA_DIR} \
    && fix-permissions /home/${NB_USER}
