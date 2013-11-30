#!/bin/bash
### Create a new git repository on GitHub and push there the new
### project.  Change the github url to point to the new project.

### make sure that hub is installed (http://hub.github.com/)
if ! test -f /bin/hub
then
    echo "==> Installing hub (http://hub.github.com/)..."
    set -x
    sudo curl http://hub.github.com/standalone -sLo /bin/hub
    sudo chmod +x /bin/hub
    sudo apt-get install ruby
    set +x
fi
hub config --global hub.protocol https

### ptint help
if [ "$1" = '-h' -o "$1" = '--help' ]
then
    # print usage instructions and exit
    echo "
Usage: $0 [<project_dir>]

<project_dir> is the directory of the project that will be
imported to GitHub. If missing, then the project containing
the script will be imported. The name of the GitHub repository
that will be created will be the same name as the name
of the project directory.
"
    exit 0
fi

### go to the project directory
if [ "$1" = '' ]
then
    # import the project containing this script
    cd $(dirname $0)
    cd ..
else
    # import the project directory given as argument
    project_dir=$1
    if ! test -d $project_dir
    then
	echo -e "\nError: directory '$project_dir' does not exist.\n"
	exit 1
    fi
    cd $project_dir
fi

### get the name of the project
project=$(ls *.profile)
project=${project/.profile}

### create a git repository and push it to GitHub
git init
git add . && git commit -m "Initial commit of $project"
echo "==> Creating a new repository for $project on GitHub..."
hub create
git push -u origin master

### correct the git url of the project
old_path='/dashohoxha/dbox'   # https://github.com/dashohoxha/bdox.git
new_url=$(git config --get remote.origin.url)
new_path=${new_url#https://github.com}
new_path=${new_path/.git}
files="README.org README1.org dev/README.org
       build-$project.make
       install/install-scripts/20-make-and-install-$project.sh
       install/install-scripts/30-git-clone-$project.sh
       utils/start-new-project.sh"
for file in $files
do
    sed -i $file -e "s#$old_path#$new_path#"
done

### commit and push the modifications of urls and paths
git commit -a -m 'Changed the github url of the project.'
git push