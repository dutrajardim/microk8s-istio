#!/bin/bash

init() {
    local OPTIND d
    while getopts "n:h" option
    do
        case "${option}" in
            h)
                echo "Microservices cli arquiteture: 'init'"
                echo "Usage: ./cli init -n <namespace>"
                echo ""
                echo "    init is a command to create k8s files to ini the project"
                echo ""
                echo "    Some of the options include:"
                echo "     -h                      Display this help message."
                echo "     -n namespace            Namespace's project. It'll create a new namespace file"
                exit 0
                ;;

            n) 
                local NAMESPACE=${OPTARG};;
        esac
    done
    shift $((OPTIND -1))
    
    local K8S_DIR=./dev/k8s/common
    local K8S_FILES=$(find $K8S_DIR -name '*.yaml' | sed "s|$K8S_DIR||")

    for file in $K8S_FILES; do
        mkdir -p "./k8s/$(dirname $file)"
        $(export NAME=$NAME NAMESPACE=$NAMESPACE DOCKER_IMAGE=$DOCKER_IMAGE DIR=$(pwd)/$NAME; 
            envsubst < $K8S_DIR/$file > ./k8s/$file)
    done
}