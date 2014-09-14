#!/bin/bash
### Accessh the shell of a running docker container.

if [ "$1" = '' ]
then
    echo "Usage: $0 <container_name>"
    exit 1
fi

container=$1
container_id=$(docker ps | grep $container | awk '{print $1}')

if [ "$container_id" = '' ]
then
    echo "Could not find the container."
    exit 2
fi

rootfs=$(echo /var/lib/docker/devicemapper/mnt/$container_id*/rootfs | cut -d' ' -f1)
chroot $rootfs
