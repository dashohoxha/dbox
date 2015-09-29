#!/bin/bash -x

source ./config
ssh=${ssh:-2201}

docker stop $container
docker rm $container

if [ "$dev" = 'false' ]
then
    ### create a container for production
    docker create --name=$container --hostname=$hostname \
        -p 80:80 -p 443:443 -p $ssh:$ssh $image
else
    ### remove the directory labdoo/ if it exists
    if test -d labdoo/
    then
        cd labdoo/
        if test -n "$(git status --porcelain)"
        then
            echo "Directory labdoo/ cannot be removed because it has uncommited changes."
            exit 1
        fi
        cd ..
        rm -rf labdoo/
    fi

    ### create a container for development
    docker create --name=$container $image
    docker start $container
    docker cp $container:/var/www/lbd/profiles/labdoo $(pwd)/
    docker stop $container
    docker rm $container

    let ssh1=ssh+1
    docker create --name=$container --hostname=$hostname \
        -v $(pwd)/labdoo:/var/www/lbd/profiles/labdoo \
        -p 81:80 -p 444:443 -p $ssh1:$ssh \
        $image
fi
