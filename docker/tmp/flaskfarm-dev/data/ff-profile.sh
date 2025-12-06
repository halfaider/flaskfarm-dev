#!/bin/bash

declare -x FF_REPO="https://github.com/flaskfarm/flaskfarm"
declare -x FF_SRC="${FF_ROOT}/src"
declare -x FF_REQUIREMENTS_APT_INSTALL=true
declare -x FF_REQUIREMENTS_APT_LIST="
python3.10
python3-pip
redis-server
git
net-tools
unzip
"

##### parsing config.yaml #####

get_value(){
    exp="s#^${1}: (.*)\$#\1#p"
    echo $(sed -rn "${exp}" ${FF_DATA}/config.yaml) | tr -d '"'
}

keywords="
path_data
path_dev
plugin_update
use_gevent
use_celery
redis_port
port
debug
plugin_update
running_type
plugin_loading_only_devpath
plugin_loading_list
plugin_except_list
"
for keyword in ${keywords}; do
    declare -x FF_${keyword^^}="$(get_value ${keyword})"
done
unset keyword

declare -x FF_PORT=${FF_PORT:-9999}
declare -x FF_DEBUG=${FF_DEBUG:-true}
declare -x FF_PLUGIN_UPDATE=${FF_PLUGIN_UPDATE:-false}
declare -x FF_REDIS_PORT=${FF_REDIS_PORT:-6379}
declare -x FF_USE_CELERY=${FF_USE_CELERY:-true}
declare -x FF_USE_GEVENT=${FF_USE_GEVENT:-true}
declare -x FF_PLUGIN_LOADING_ONLY_DEVPATH=${FF_PLUGIN_LOADING_ONLY_DEVPATH:-true}
