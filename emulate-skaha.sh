#!/bin/bash
image=$1

# user and home can be any, but with belong to group 100 (users)
user="sfabbro"
uid="$(id -u ${user})"
home="/home/${user}"
token="dummy"
sessionid="123456"

passwd="$(grep ${user} /etc/passwd)"

sudo docker run --rm \
     -p 8888:8888 \
     --user ${user}:100 \
     -v /home/${user}:/home/${user} \
     -v /mnt/scratch:/scratch \
     -e JUPYTER_TOKEN="${token}" \
     -e JUPYTER_CONFIG_DIR="${home}" \
     -e JUPYTER_PATH="${home}" \
     -e NB_USER="${user}" \
     -e NB_UID="${uid}" \
     -e HOME="${home}" \
     -e PWD="${home}" \
     -e XDG_CACHE_HOME="${home}" \
     ${image} \
     start-notebook.sh \
     --NotebookApp.base_url=notebook/${sessionid} \
     --NotebookApp.notebook_dir=/ \
     --NotebookApp.allow_origin="*"
