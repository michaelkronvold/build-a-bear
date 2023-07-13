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

# check the config
[ $listdir ] || warn "No listdir found in config" 10
[ -d $listdir ] || listdir=$(pwd)

while [[ $# -gt 0 ]] && [[ "$1" == "--"* ]] ;
do
  opt=${1}
  case "${opt}" in
    "--" )
      break 2;;
    "--dry" ) DRYRUN=1;;
    "--dryrun" ) DRYRUN=1;;
    "--test" ) DRYRUN=1;;
    "--debug" ) DEBUG=1 ;;
    "--break" ) BREAKPOINT=1;;
    "--df="* )
      work=df
      df="${opt#*=}";;
    "--du="* )
      work=du
      du="${opt#*=}";;
    "--ls="* )
      work=ls
      ls="${opt#*=}";;
    *)
    #   erm.  nothing here.
    ;;
  esac
  shift
done



#main
debug "tmps=$tmps"
debug "tmp()=${tmp[@]}"
debug "tmp[0]=${tmp[0]}"
debug "tmp[1]=${tmp[1]}"
debug "tmp[2]=${tmp[2]}"
debug "tmp[3]=${tmp[3]}"
[ $BREAKPOINT ] && die "DEBUG BREAKPOINT" 99

case "$work" in
  "df" )
    debug "attempting to run df $df"
    [ $df ] || die "no path given" 20     # validate input
    [ ! -e "$df" ] && die "$df does not exist" 30 || [ $DRYRUN ] && echo "df $df" || df $df
    ;;
  "du" )
    debug "attempting to run du $du"
    [ $du ] || die "no path given" 20     # validate input
    [ ! -e "$du" ] && die "$du does not exist" 30 || [ $DRYRUN ] && echo "du $du" || du $du
    ;;
  "ls" )
    debug "attempting to run ls $ls"
    [ $ls ] || die "no path given" 20     # validate input
    [ ! -e "$ls" ] && die "$ls does not exist" 30 || [ $DRYRUN ] && echo "ls $ls" || ls $ls
    ;;
  *)
    die "nothing to do" 100
    ;;
esac

cleanup
