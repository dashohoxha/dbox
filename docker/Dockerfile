FROM ubuntu:16.04
ENV container docker
RUN echo '#!/bin/bash\n\
        for service in /etc/rc3.d/S* ; do\n\
            service=$(basename $service)\n\
            service=${service:3}\n\
            /etc/init.d/$service start\n\
        done\n\
        exec /sbin/init\n'\
    > /usr/local/sbin/init.sh
RUN chmod +x /usr/local/sbin/init.sh
CMD ["/usr/local/sbin/init.sh"]

### Install packages.
COPY install/packages.sh /tmp/
RUN DEBIAN_FRONTEND=noninteractive /tmp/packages.sh

### Copy the source code and install.
COPY . /usr/local/src/labdoo/
ENV code_dir /usr/local/src/labdoo
WORKDIR /usr/local/src/labdoo/
RUN ["install/install.sh"]

### Set the default dir to the code of the application.
WORKDIR /var/www/lbd/profiles/labdoo
