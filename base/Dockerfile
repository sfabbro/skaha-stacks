ARG ROOT_CONTAINER=jupyter/scipy-notebook:latest
FROM ${ROOT_CONTAINER}

LABEL maintainer="CANFAR Project <support@canfar.net>"

# Add RUN statements to install packages as the $NB_USER defined in the base images.

# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
# change file permissions, etc.

# If you do switch to root, always be sure to add a "USER $NB_USER" command at the end of the
# file to ensure the image runs as a unprivileged user by default.
USER root

# this is a hack to remove the jovyan:users to jovyan:jovyan on /opt/conda
# skaha has group 100 and this bypass it
# change /opt/conda out of users group (100)
# for users to do pip and conda environments
# in their persistant home directory rather than /opt/conda
ENV NB_GID=jovyan
RUN groupadd jovyan \
    && usermod -G jovyan -a jovyan \
    && fix-permissions ${CONDA_DIR} \
    && fix-permissions /home/${NB_USER}

RUN apt-get update --yes --quiet --fix-missing \
    && apt-get upgrade --yes --quiet

COPY packages.apt .
RUN apt-get install --yes --quiet $(cat packages.apt)
RUN apt-get clean --yes \
    && apt-get autoremove --purge --quiet --yes \
    && rm -rf /var/lib/apt/lists/* /var/tmp/*

# nsswitch for correct sss lookup
ADD nsswitch.conf /etc/

# start terminal in home on filesystem and ensure jupyter home directories
RUN mkdir /usr/local/bin/start-notebook.d/
COPY skaha-hook.sh /usr/local/bin/start-notebook.d/

USER ${NB_UID}

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
