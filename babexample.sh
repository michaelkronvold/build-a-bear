#!/bin/bash

tempkey=6667       # set this to something unique to your scripts
tmps=3             # number of tmp files needed
DEBUG=

############ don't mess with these ###########
#
program=${0##*/}   # similar to using basename
confdir=$(dirname "$0")
[ $workdir ] || workdir=$confdir
[ -d $workdir ] || workdir=$confdir
[ -f $confdir/bab.conf ] && source $confdir/bab.conf || die "No config file found in default location $confdir/bab.conf" 10
[ -f $confdir/babfunc.sh ] && source $confdir/babfunc.sh || die "$confdir/babfunc.sh not found" 11
mktmps
#
###############################################





#main
echo "tmps=$tmps"
echo "tmp()=${tmp[@]}"
echo "tmp[0]=${tmp[0]}"
echo "tmp[1]=${tmp[1]}"
echo "tmp[2]=${tmp[2]}"
echo "tmp[3]=${tmp[3]}"


cleanup
