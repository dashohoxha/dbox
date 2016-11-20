#!/bin/bash -x

### configure the host for running systemd containers
if [[ -z $(nsenter --mount=/proc/1/ns/mnt -- mount | grep /sys/fs/cgroup/systemd) ]]; then
  [[ ! -d /sys/fs/cgroup/systemd ]] && mkdir -p /sys/fs/cgroup/systemd
  nsenter --mount=/proc/1/ns/mnt -- mount -t cgroup cgroup -o none,name=systemd /sys/fs/cgroup/systemd
fi

### go to the docker directory
cd $(dirname $0)/../

### load the config file
if ! test -f config
then
    echo "File $(pwd)/config is missing."
    exit 1
fi
source ./config

### stop and remove the container if it exists
docker stop $container 2>/dev/null
docker rm $container 2>/dev/null

### Remove the given directory if it exists.
function remove_dir() {
    local dir=$1
    if test -d $dir/
    then
        cd $dir/
        if test -n "$(git status --porcelain)"
        then
            echo "Directory $dir/ cannot be removed because it has uncommited changes."
            exit 1
        fi
        cd ..
        rm -rf $dir/
    fi
}

docker_create() {
    docker create --name=$container --hostname=$hostname \
        --cap-add SYS_ADMIN \
        --tmpfs /run --tmpfs /run/lock \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        "$@" $ports $image
}

dev=false
if [ "$dev" = 'false' ]
then
    ### create a container for production
    docker_create \
        --restart=unless-stopped \
        -v $(pwd)/downloads:/var/www/downloads
else
    ### remove the directory labdoo/ if it exists
    remove_dir labdoo

    ### copy the directory labdoo/ from the image to the host
    docker create --name=$container $image
    docker start $container
    docker cp $container:/var/www/lbd/profiles/labdoo $(pwd)/
    docker stop $container
    docker rm $container

    ### create a container for development
    docker_create \
        -v $(pwd)/labdoo:/var/www/lbd/profiles/labdoo
fi
