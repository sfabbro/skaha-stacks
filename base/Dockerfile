ARG ROOT_CONTAINER=jupyter/scipy-notebook:latest
FROM ${ROOT_CONTAINER}

LABEL maintainer="CANFAR Project <support@canfar.net>"

# Add RUN statements to install packages as the $NB_USER defined in the base images.

# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
# change file permissions, etc.

# If you do switch to root, always be sure to add a "USER $NB_USER" command at the end of the
# file to ensure the image runs as a unprivileged user by default.
USER root

RUN apt-get update --yes --quiet --fix-missing \
    && apt-get upgrade --yes --quiet

COPY packages.apt .
RUN apt-get install --yes --quiet $(cat packages.apt)
RUN apt-get clean --yes \
    && apt-get autoremove --purge --quiet --yes \
    && rm -rf /var/lib/apt/lists/* /var/tmp/*

# nsswitch for correct sss lookup
ADD nsswitch.conf /etc/

USER ${NB_USER}

COPY condarc .
RUN cat condarc >> ${CONDA_DIR}/.condarc

# modify basic environment from jupyter/scipy-notebook
COPY env.yml .
COPY pinned .
RUN rm ${CONDA_DIR}/conda-meta/pinned

RUN mamba update --all --yes --quiet
RUN mamba remove nomkl --yes

RUN mamba env update -n base --file env.yml \
    && mamba clean --all --quiet --yes \
    && cat pinned > ${CONDA_DIR}/conda-meta/pinned \
    && fix-permissions ${CONDA_DIR} \
    && fix-permissions /home/${NB_USER}
