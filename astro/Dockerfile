ARG OWNER=skaha
ARG BASE_CONTAINER=${OWNER}/base
FROM ${BASE_CONTAINER}

USER root

# install latest stilts
RUN wget --quiet http://www.star.bris.ac.uk/~mbt/stilts/stilts.jar \
	-O /usr/local/bin/stilts.jar \
	&& wget --quiet http://www.star.bris.ac.uk/~mbt/stilts/stilts \
	-O /usr/local/bin/stilts \
	&& chmod +x /usr/local/bin/stilts

USER ${NB_USER}


COPY env.yml .
RUN mamba env update -n base --file env.yml \
    && jupyter lab build \
    && mamba clean --all --quiet --yes \
    && fix-permissions ${CONDA_DIR} \
    && fix-permissions /home/${NB_USER}

RUN npm cache clean --force \
    && rm -rf /home/${NB_USER}/.cache/yarn \
    && jupyter lab clean
