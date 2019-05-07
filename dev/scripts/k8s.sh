#!/bin/bash

k8s() {
    local OPTIND d
    while getopts "d:" option
    do
        case "${option}" in
            h)
                echo "Microservices cli arquiteture: 'k8s'"
                echo "Usage: ./cli k8s -d <appName> [command]"
                echo ""
                echo "    k8s is a tool related to k8s commands"
                echo ""
                echo "    Some of the options include:"
                echo "     -h                      Display this help message."
                echo "     -d appDirectory         Directory of the microservice."
                echo ""
                echo "    Some of the commands include:"
                echo "     prepare                 Create k8s files"
                echo "     build                   Apply k8s files"
                exit 0
                ;;

            d) 
                local DIRECTORY=${OPTARG};;
        esac
    done
    shift $((OPTIND -1))

    local CMD=$1
    local configData="$(cat $DIRECTORY/microservice.json)"
    local K8S_DIR="./dev/k8s/$(echo $configData | jq -r '.template')/"
    local REGISTRY="$(echo $configData | jq -r '.registry')"
    local IMAGE_TAG="$(echo $configData | jq -r '.imageTag')"
    local VERSION="$(echo $configData | jq -r '.version')"
    local DOCKER_IMAGE=$REGISTRY/$IMAGE_TAG:$VERSION
    local K8S_FILES=$(find $K8S_DIR -name '*.yaml' | sed "s|$K8S_DIR||")
    local NAME="$(echo $configData | jq -r '.k8s.name')"

    if [ "$CMD" = "prepare" ]
    then
        mkdir -p $DIRECTORY/k8s

        for file in $K8S_FILES; do
            mkdir -p "$DIRECTORY/k8s/$(dirname $file)"
            $(export NAME=$NAME NAMESPACE=$NAMESPACE DOCKER_IMAGE=$DOCKER_IMAGE DIR=$(pwd)/$NAME; 
                envsubst < $K8S_DIR/$file > $DIRECTORY/k8s/$file)
        done
        
        if [ -d "$K8S_DIR/base/config" ]; then cp -R $K8S_DIR/base/config $DIRECTORY/k8s/base/config; fi
    fi

    if [ "$CMD" = "build" ]
    then
        kubectl apply -k $DIRECTORY/k8s/
    fi
}