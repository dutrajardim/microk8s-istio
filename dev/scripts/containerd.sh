#!/bin/bash

containerd() {
    local OPTIND d
    while getopts "d:h" option
    do
        case "${option}" in
            h)
                echo "Microservices cli arquiteture: 'containerd'"
                echo "Usage: ./cli contanerd -d <appName> [command]"
                echo ""
                echo "    contanerd is a tool related to container commands"
                echo ""
                echo "    Some of the options include:"
                echo "     -h                      Display this help message."
                echo "     -d appDirectory         Directory of the microservice."
                echo ""
                echo "    Some of the commands include:"
                echo "     build                   Build a image of the microservice"
                echo "     increment               Increment the version of image"
                exit 0
                ;;

            d) 
                local DIRECTORY=${OPTARG};;
        esac
    done
    shift $((OPTIND -1))

    local CMD=$1
    local configData="$(cat $DIRECTORY/microservice.json)"
    local REGISTRY="$(echo $configData | jq -r '.registry')"
    local IMAGE_TAG="$(echo $configData | jq -r '.imageTag')"
    local VERSION="$(echo $configData | jq -r '.version')"
    local DOCKER_IMAGE=$REGISTRY/$IMAGE_TAG:$VERSION

    if [ "$CMD" = "build" ]
    then
        ctr --namespace cli.io run --net-host --rm \
            --mount type=bind,src="$DIR/$DIRECTORY",dst=/usr/build,options=rbind:rw \
            gcr.io/kaniko-project/executor:latest kaniko executor \
            --dockerfile Dockerfile \
            --context /usr/build/ \
            --destination $DOCKER_IMAGE \
            --force \
            --insecure \
            --cleanup
    fi

    if [ "$CMD" = "increment" ]
    then
        echo "Increasing version"
        local NEW_VERSION=$(increment_version $VERSION 3)

        if [ -n "$NEW_VERSION" ]; then configData="$(echo $configData | jq --tab --arg NEW_VERSION $NEW_VERSION '.version=$NEW_VERSION')"; fi
        echo "$configData" > $DIRECTORY/microservice.json
    fi
}
