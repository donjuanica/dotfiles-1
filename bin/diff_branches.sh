#!/bin/bash

MODULES=( adminModule application_platform appservice drteeth kronos omniture phplib sitecatalyst suite );
WORKDIR=$HOME/work

if [ $# -lt "2" ]; then
	echo "Usage $0 <previous branch> <current branch>";
	exit 1;
fi

PREV=$1
CURR=$2

cd $WORKDIR;
echo $MODULES;

for i in ${MODULES[@]} ; do
	pushd $i >/dev/null ; 
	echo "Changes in $i" ;  
	git diff --stat origin/$PREV ... origin/$CURR | grep 'changed'
	popd >/dev/null;
done


