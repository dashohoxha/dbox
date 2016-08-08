#!/bin/bash
### Simulate /sbin/init in docker containers

for service in /etc/rc3.d/S* ; do
    service=$(basename $service)
    service=${service:3}
    /etc/init.d/$service start
done

exec /sbin/init
