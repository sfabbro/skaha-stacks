ARG ROOT_CONTAINER=jupyter/scipy-notebook:latest
FROM ${ROOT_CONTAINER}

LABEL maintainer="CANFAR Project <support@canfar.net>"

# Add RUN statements to install packages as the $NB_USER defined in the base images.

# Add a "USER root" statement followed by RUN statements to install system packages using apt-get,
# change file permissions, etc.

# If you do switch to root, always be sure to add a "USER $NB_USER" command at the end of the
# file to ensure the image runs as a unprivileged user by default.
USER root
WORKDIR /tmp

# update base
RUN apt-get update --yes --quiet --fix-missing \
    && apt-get upgrade --yes --quiet

# install bunch of packages
COPY packages.apt .
RUN apt-get install --yes --quiet $(cat packages.apt)
RUN apt-get clean --yes \
    && apt-get autoremove --purge --quiet --yes \
    && rm -rf /var/lib/apt/lists/* /var/tmp/*

# install latest stilts
RUN wget --quiet http://www.star.bris.ac.uk/~mbt/stilts/stilts.jar -O /usr/local/bin/stilts.jar \
    && wget --quiet http://www.star.bris.ac.uk/~mbt/stilts/stilts -O /usr/local/bin/stilts \
    && chmod +x /usr/local/bin/stilts

# nsswitch for correct sss lookup
ADD nsswitch.conf /etc/

# modify basic environment from jupyter/scipy-notebook
COPY env.yml .

USER ${NB_USER}

RUN mamba remove nomkl --yes
RUN rm ${CONDA_DIR}/conda-meta/pinned

RUN mamba env update --quiet -n base --file env.yml \
    && mamba update --quiet --all --yes \
    && mamba clean --all --quiet --force --yes \
    && fix-permissions ${CONDA_DIR} \
    && fix-permissions /home/${NB_USER}

USER root
ADD pinned ${CONDA_DIR}/conda-meta/pinned
COPY condarc .
RUN cat condarc >> ${CONDA_DIR}/.condarc
RUN fix-permissions ${CONDA_DIR}


WORKDIR ${HOME}
