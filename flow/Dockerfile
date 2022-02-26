ARG OWNER=skaha
ARG BASE_CONTAINER=${OWNER}/ml-notebook
FROM ${BASE_CONTAINER}

USER ${NB_USER}

COPY env.yml .
COPY pinned .

RUN mamba env update -n base --file env.yml \
    && cat pinned >> ${CONDA_DIR}/conda-meta/pinned \
    && mamba clean --all --quiet --yes \
    && fix-permissions ${CONDA_DIR} \
    && fix-permissions /home/${NB_USER}
