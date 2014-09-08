#!/bin/bash -x
### Install a new chrooted server from scratch, with debootstrap.

source_dir=$(dirname $(dirname $0))

function usage {
    echo "
Usage: $0 <settings> [options]
Install $source_dir inside a container.

    <settings>    file of installation/configuration settings
    --target=D    target dir where the system will be installed
    --arch=A      set the architecture to install (default i386)
    --suite=S     system to be installed (default precise)
    --mirror=M    source of the apt packages
                  (default http://archive.ubuntu.com/ubuntu)
    --opt_name=V  override any settings in the config file
"
    exit 0
}

### get the options
for opt in "$@"
do
    case $opt in
	--target=*)    target=${opt#*=} ;;
	--arch=*)      arch=${opt#*=} ;;
	--suite=*)     suite=${opt#*=} ;;
	--mirror=*)    apt_mirror=${opt#*=} ;;
	-h|--help)     usage ;;
        --*=*)
	    optvalue=${opt#*=}
	    optname=${opt%%=*}
	    optname=${optname:2}
	    eval export $optname="$optvalue"
	    ;;
	*)
	    if [ ${opt:0:1} = '-' ]; then usage; fi

	    settings=$opt
	    if ! test -f "$settings"
            then
		echo "File '$settings' does not exist."
		exit 1
	    fi
	    set -a;  source $settings;  set +a
	    ;;
    esac
done

### check that there was at least one settings file
if [ "$settings" = '' ]
then
    echo
    echo "Error: No settings file was given."
    usage
fi

### make sure that we are using the right version of install scripts
current_dir=$(pwd)
cd $source_dir/
source_dir=$(pwd)
git checkout $lbd_git_branch && git pull origin $lbd_git_branch
cd $current_dir

### make sure that docker is installed
docker=docker.io
test "$(which $docker)" || apt-get install -y $docker

### run the install script on the image ubuntu:14.04
source=$(basename $source_dir)
export code_dir=/usr/local/src/$source
cp $settings $source_dir/settings.sh
container=$source
test "$($docker ps | grep -w $target)" && $docker stop $target
test "$($docker ps -a | grep -w $target)" && $docker rm $target
test "$($docker ps | grep -w $container)" && $docker stop $container
test "$($docker ps -a | grep -w $container)" && $docker rm $container
$docker run -i -t --name=$container -v $source_dir:$code_dir ubuntu:14.04 \
    $code_dir/install/install-and-config.sh $code_dir/settings.sh

### save the new image
image=$container
test "$($docker images | grep -w $image)" && $docker rmi $image
$docker commit $container $image

### clean up the latest container
$docker rm $container

### run the new image and create a container
$docker run --name=$target -d \
    -p 80:80 -p 443:443 -p 2201:2201 \
    $image /usr/bin/supervisord -c /etc/supervisord.conf
    # -p $sshd_port:$sshd_port -p $httpd_port:$httpd_port \

### start the container on boot
if [ "$start_on_boot" = 'true' ]
then
    sed -i /etc/rc.local -e "/$docker start $target/ d" -e "/exit/ d"
    cat <<EOF >> /etc/rc.local
$docker start $target
exit 0
EOF
fi