#!/bin/bash

for f in ./dev/scripts/*.sh; do . $f --source-only; done
CMD=$1
DIR=$(pwd)

if [ -f "./k8s/base/namespace.yaml" ]
then 
    NAMESPACE="$(yq r ./k8s/base/namespace.yaml metadata.name)"
elif [ $CMD != "init" ]
then 
    echo "Init project first"; 
    exit 0;
fi

if [ "$(LC_ALL=C type -t $1)" = function ]; then
    shift
    $CMD $@
else
    echo -e "\nCommand $1 not found."
fi