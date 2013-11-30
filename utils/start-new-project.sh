#!/bin/bash
### Create a new Drupal project, using the project Labdoo as a
### template project.
###
### This new project, same as Labdoo, will contain a Drupal profile,
### make files for downloading all the needed modules, libraries,
### patches, etc. It will contain as well scripts for installing a
### minimal ubuntu server with all the packages and configurations
### needed for running a Drupal application. It will also contain
### scripts, modules, tools and docs that facilitate the development,
### including a dev-->test-->live workflow as well.
###
### The aim of this project is to be like a "Drupal-on-Rails" for
### simplifying the life of the experienced Drupal developers and for
### helping the new Drupal developers to get started.  Usually a huge
### number of skills is needed in order to complete successfully a
### Drupal project, like: server management, web stack management,
### database management, knowledge of drush, Drupal profiles,
### frequently used modules, common Drupal development patterns and
### paradigms, etc. A new Drupal developer cannot possibly get all
### this skills in a short time, so he is not able to finish properly
### a Drupal application or it will take him a very long time. This
### project offers them a Drupal solution that works out of the box,
### with reasonable settings and configurations, which they can use as
### a starting point for developing their application. This project
### can also simplify the life of the experienced Drupal developers,
### by allowing them to get started quickly, and then customizing the
### solution as they wish.
###
### This script works by renaming files and doing find/replace in
### them. There are two parameters that are used to customize the
### template project: the project name and the project prefix. In the
### template project they are represented by 'labdoo' and 'lbd', which
### are then replaced in the new project by the new project's name and
### prefix.  Why these strange names? Why not use something like
### 'example' and 'xmp', or 'sample' and 'smp', or 'template' and
### 'tmp' etc. The first reason is exactly that they are strange names
### and so there is no risk of collision with other names used in a
### project. For example 'xmp' or 'template' or 'tmp' maybe are used
### on the project for something else as well, and replacing them
### blindly with a new value may break the application. The second
### reason is that there is actually a real Drupal project with this
### name and prefix ('labdoo' and 'lbd'), and this helps to maintain
### the template project (any commit from the real project can be
### cherry picked and commited to the template project, and
### vice-versa).


### Output the usage of the script and stop it.
function usage {
    echo "
Usage: $0 [OPTIONS]

Create a new Drupal project, using the project Labdoo
as a template project.

    --project=P   the name of the new project
    --prefix=P    the prefix of the new project
    --source=S    source of the template project
                  (default https://github.com/dashohoxha/dbox)
    --branch=B    branch to be cloned (default oa - openatrium)
"
    exit 0
}


### Get options from the command line arguments.
### Set default values for missing options and get
### interactively any missing oftions that are required
function get_options {
    for opt in "$@"
    do
	case $opt in
            --project=*)  project=${opt#*=} ;;
            --prefix=*)   prefix=${opt#*=} ;;
            --source=*)   source=${opt#*=} ;;
	    --branch=*)   branch=${opt#*=} ;;
            -h|--help|*)  usage ;;
        esac
    done

    ### set default values for the missing options
    source=${source:-https://github.com/dashohoxha/dbox}
    #source=/var/chroot/Labdoo   # for testing
    branch=${branch:-oa}

    ### get the values of project and prefix, if not given
    if [ "$project" = '' ]; then read -p "Project: " project; fi
    if [ "$prefix" = '' ];  then read -p "Prefix:  " prefix; fi

    ### make sure that project and prefix are lowercase
    project=${project,,}
    prefix=${prefix,,}

    #echo "$source -- $branch -- $project -- $prefix" ; exit 0  # debug
}


### Get from git the code of the base project
### and remove any unnecessary files.
function get_template_project {
    ### get the template project
    rm -rf $project
    git clone --depth 1 --branch $branch $source $project

    ### swap the files README.org and README1.org
    mv $project/{README.org,README.org.bak}
    mv $project/{README1.org,README.org}
    mv $project/{README.org.bak,README1.org}

    ### clean up the template project
    rm -rf $project/.git
    rm -rf $project/modules/features/labdoo_objects/
    rm -rf $project/modules/custom/labdoolib/
}


### remove referencies to $branch, or change them to master
function rename_branch_to_master {
    sed -i $project/build-labdoo.make \
        -e "/\[branch\] = $branch/ s/^;*/;/"

    files="build-labdoo.make
           install/install-scripts/20-make-and-install-labdoo.sh"
    for file in $files
    do
         sed -i $project/$file \
             -e "s#/dashohoxha/dbox/$branch/#/dashohoxha/dbox/master/#g"
    done

    files="README.org dev/README.org
           install/install-scripts/30-git-clone-labdoo.sh"
    for file in $files
    do
         sed -i $project/$file -e "s/ --branch $branch//g"
    done
}


### rename_files $from $to
### The first argument is replaced with the second argument
### in all file and directory names.
function rename_all_files {
    from=$1
    to=$2

    files=$(find $project/ -name "*$from*")
    while test -n "$files"
    do
	for file in $files
	do
	    file1=${file/$from/$to}
            mv $file $file1 2> /dev/null
	done
	files=$(find $project/ -name "*$from*")
    done
}


### Replace the first argument with the second argument
### in all the files of the project.
function replace_in_all_files {
    from=$1
    to=$2

    for file in $(find $project/ -type f)
    do
        sed -i $file -e "s/$from/$to/g"
    done
}


### Build the new project.

get_options $@

get_template_project
rename_branch_to_master

rename_all_files labdoo $project
rename_all_files lbd $prefix

replace_in_all_files labdoo $project
replace_in_all_files Labdoo ${project^}
replace_in_all_files lbd $prefix
