#!/bin/bash

create() {
    while getopts "n:T:t:r:hl" option
    do
        case "${option}" in
            h)
                echo "Microservices cli arquiteture: 'create'"
                echo "Usage: ./cli create [options] <appName>"
                echo ""
                echo "    create is a tool to init a new microservice"
                echo ""
                echo "    Some of the options include:"
                echo "     -h                      Display this help message."
                echo "     -t template             Create a microservice from a given template."
                echo "     -r registry             Change the url to default docker registry."
                echo "     -T imageTag             The name of the image used to build."
                echo "     -n namespace            k8s namespace"
                exit 0
                ;;

            t) 
                local TEMPLATE=${OPTARG};;
            r) 
                local REGISTRY=${OPTARG};;
            T)  
                local IMAGE_TAG=${OPTARG};;
            n)
                local NAMESPACE=${OPTARG};;
        esac
    done
    shift $((OPTIND -1))

    local NAME=$1
    local USER_NAME=$(whoami)
    local DIR=$(pwd)

    if [ $TEMPLATE = "lumen" ]
    then
        # Install lumen
        echo "Installing lumen..."
        ctr --namespace cli.io run --net-host --rm \
            --mount type=bind,src=$DIR,dst=/app,options=rbind:rw \
            docker.io/library/composer:latest composer \
            composer create-project --prefer-dist laravel/lumen $NAME
        sudo chown -R $USER_NAME.$USER_NAME ./$NAME

        # Coping dockerfile
        echo "Coping dockerfile..."
        cp ./dev/container-context/Dockerfile-lumen $NAME/Dockerfile
        
        # Prepare microservice file
        echo "Prepering microservice file..."
        local configData="$(cat ./dev/config/microservice.json)"

        configData="$(echo $configData | jq --tab --arg NAME $NAME '.k8s.name=$NAME')"
        configData="$(echo $configData | jq --tab --arg TEMPLATE $TEMPLATE '.template=$TEMPLATE')"
        if [ -n "$REGISTRY" ]; then configData="$(echo $configData | jq --tab --arg REGISTRY $REGISTRY '.registry=$REGISTRY')"; fi
        if [ -n "$IMAGE_TAG" ]; then configData="$(echo $configData | jq --tab --arg IMAGE_TAG $IMAGE_TAG '.imageTag=$IMAGE_TAG')"; fi
        echo "$configData" > $NAME/microservice.json

        # Prepare k8s
        echo "Prepering k8s files..."
        k8s -d ./$NAME prepare

    elif [ $TEMPLATE = "php" ]
    then

        # Install php
        echo "Installing php..."
        git clone https://github.com/dutrajardim/php.git $NAME
        sudo chown -R $USER_NAME.$USER_NAME ./$NAME
        
        ctr --namespace cli.io run --net-host --rm \
            --mount type=bind,src="$DIR/$NAME",dst=/app,options=rbind:rw \
            docker.io/library/composer:latest composer \
            composer install

        # Coping dockerfile
        echo "Coping dockerfile..."
        cp ./dev/container-context/Dockerfile-php $NAME/Dockerfile

        # Prepare microservice file
        echo "Prepering microservice file..."
        local configData="$(cat ./dev/config/microservice.json)"

        configData="$(echo $configData | jq --tab --arg NAME $NAME '.k8s.name=$NAME')"
        configData="$(echo $configData | jq --tab --arg TEMPLATE $TEMPLATE '.template=$TEMPLATE')"
        if [ -n "$REGISTRY" ]; then configData="$(echo $configData | jq --tab --arg REGISTRY $REGISTRY '.registry=$REGISTRY')"; fi
        if [ -n "$IMAGE_TAG" ]; then configData="$(echo $configData | jq --tab --arg IMAGE_TAG $IMAGE_TAG '.imageTag=$IMAGE_TAG')"; fi
        echo "$configData" > $NAME/microservice.json

        # Prepare k8s
        echo "Prepering k8s files..."
        k8s -d ./$NAME prepare

    elif [ $TEMPLATE = "mariadb" ]
    then

        mkdir -p $NAME

        # Prepare microservice file
        echo "Prepering microservice file..."
        local configData="$(cat ./dev/config/microservice.json)"

        # Prepare microservice file
        echo "Prepering microservice file..."
        local configData="$(cat ./dev/config/microservice.json)"

        configData="$(echo $configData | jq --tab --arg NAME $NAME '.k8s.name=$NAME')"
        configData="$(echo $configData | jq --tab --arg TEMPLATE $TEMPLATE '.template=$TEMPLATE')"
        if [ -n "$REGISTRY" ]; then configData="$(echo $configData | jq --tab --arg REGISTRY $REGISTRY '.registry=$REGISTRY')"; fi
        if [ -n "$IMAGE_TAG" ]; then configData="$(echo $configData | jq --tab --arg IMAGE_TAG $IMAGE_TAG '.imageTag=$IMAGE_TAG')"; fi
        echo "$configData" > $NAME/microservice.json

        # Prepare k8s
        echo "Prepering k8s files..."
        k8s -d ./$NAME prepare

    elif [ $TEMPLATE = "node" ]
    then

        # Install node
        echo "Installing node..."
        git clone https://github.com/dutrajardim/node.git $NAME
        sudo chown -R $USER_NAME.$USER_NAME ./$NAME
        
        ctr --namespace cli.io run --net-host --rm \
            --mount type=bind,src="$DIR/$NAME",dst=/app,options=rbind:rw \
            --cwd /app \
            docker.io/library/node:latest node \
            npm install

        # Coping dockerfile
        echo "Coping dockerfile..."
        cp ./dev/container-context/Dockerfile-node $NAME/Dockerfile

        # Prepare microservice file
        echo "Prepering microservice file..."
        local configData="$(cat ./dev/config/microservice.json)"

        configData="$(echo $configData | jq --tab --arg NAME $NAME '.k8s.name=$NAME')"
        configData="$(echo $configData | jq --tab --arg TEMPLATE $TEMPLATE '.template=$TEMPLATE')"
        if [ -n "$REGISTRY" ]; then configData="$(echo $configData | jq --tab --arg REGISTRY $REGISTRY '.registry=$REGISTRY')"; fi
        if [ -n "$IMAGE_TAG" ]; then configData="$(echo $configData | jq --tab --arg IMAGE_TAG $IMAGE_TAG '.imageTag=$IMAGE_TAG')"; fi
        echo "$configData" > $NAME/microservice.json

        # Prepare k8s
        echo "Prepering k8s files..."
        k8s -d ./$NAME prepare

    fi
}