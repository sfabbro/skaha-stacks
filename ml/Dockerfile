ARG OWNER=skaha
ARG BASE_CONTAINER=${OWNER}/astro-notebook
FROM ${BASE_CONTAINER}

USER ${NB_UID}

COPY env.yml .

RUN mamba env update -n base --file env.yml \
    && mamba clean --all --quiet --yes \
    && fix-permissions ${CONDA_DIR} \
    && fix-permissions /home/${NB_USER}
