#!/bin/bash

DEBUG=
program=${0##*/}   #  similar to using basename
tempkey=7008
tmp1=$( mktemp /dev/shm/${tempkey}_${program}_tmp.XXXXXXXXXX )
tmp2=$( mktemp /dev/shm/${tempkey}_${program}_tmp.XXXXXXXXXX )

cleanup () {
     #  Delete temporary files, then optionally exit given status.
     local status=${1:-'0'}
     rm -f $tmp1 $tmp2
     [ $status = '-1' ] ||  exit $status      #  thus -1 prevents exit.
} #--------------------------------------------------------------------
debug () {
     #  Message with DEBUG: to stderr.          Usage: debug "message"
     [ $DEBUG ] && echo -e "\n !! DEBUG: $1 "  >&2
} #--------------------------------------------------------------------
warn () {
     #  Message with basename to stderr.          Usage: warn "message"
     echo -e "\n !!  ${program}: $1 "  >&2
} #--------------------------------------------------------------------
die () {
     #  Exit with status of most recent command or custom status, after
     #  cleanup and warn.      Usage: command || die "message" [status]
     local status=${2:-"$?"}
     cleanup -1  &&   warn "$1"  &&  exit $status
} #--------------------------------------------------------------------
trap "die 'SIG disruption, but cleanup finished.' 114" 1 2 3 15
#    Cleanup after INTERRUPT: 1=SIGHUP, 2=SIGINT, 3=SIGQUIT, 15=SIGTERM


# read config and set some defaults
confdir=$(dirname "$0")
[ $workdir ] || workdir=$confdir
[ -d $workdir ] || workdir=$confdir
[ -f $confdir/bab.conf ] && source $confdir/bab.conf || die "No config file found in default location $confdir/bab.conf" 10
[ $listdir ] || die "No listdir found in config" 10
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
    "--dc="* )
      work=dc
      dc="${opt#*=}";;
    "--tkg="* )
      work=tkg
      tkg="${opt#*=}";;
    "--env="* )
      work=tkg
      tkg="${opt#*=}";;
    "--tkc="* )
      work=tkc
      tkc="${opt#*=}";;
    "--cluster="* )
      work=tkc
      tkc="${opt#*=}";;
    "--tns="* )
      work=tns
      tns="${opt#*=}";;
    "--app="* )
      work=tns
      tns="${opt#*=}";;
    *)
    #   erm.  nothing here.
    ;;
  esac
  shift
done

if [ $DEBUG ]; then
  debug "DEBUG=$DEBUG"
  debug "confdir=$confdir"
  debug "workdir=$workdir"
  debug "listdir=$listdir"
  debug "work=$work"
  debug "dc=$dc"
  debug "tkg=$tkg"
  debug "tkc=$tkc"
  debug "tns=$tns"
  debug "DRYRUN=$DRYRUN"
  [ $BREAKPOINT ] && die "DEBUG BREAKPOINT" 99
fi

case "$work" in
  "dc" )
    # check for duplicate in dc.list or add to dc.list
    [ $dc ] || die "no dc given" 20
    debug "running mkdc $dc"
    unset exist && exist=$(grep -c "$dc" $listdir/dc.list) && debug "exist=$exist"
    [ $exist -gt 0 ] && die "$dc already on dc.list" 30 || [ $DRYRUN ] && echo "echo $dc >> $listdir/dc.list" || echo $dc >> $listdir/dc.list
    ;;
  "tkg" )
    # check for duplicate in tkg.list or add to tkg.list
    [ $dc ] || die "no dc-name given" 20
    [ $tkg ] || die "no tkg-name given" 20
    debug "running mktkg $dc $tkg"
    unset exist && exist=$(grep -c "$tkg" $listdir/tkg.list) && debug "exist=$exist"
    [ $exist -gt 0 ] && die "$tkg already on tkg.list" 30 || [ $DRYRUN ] && echo "echo $tkg >> $listdir/tkg.list" || echo $tkg >> $listdir/tkg.list
    # check for folder $dc-$tkg-tkg or create
    [ -d $workdir/$dc-$tkg-tkg ] && die "$dc-$tkg-tkg already exists" 40 || [ $DRYRUN ] && echo "mkdir $workdir/$dc-$tkg-tkg" || mkdir $workdir/$dc-$tkg-tkg
    # read the tkg-reqs.list and mktkc each
    [ -f $listdir/tkg-reqs.list ] && cat $listdir/tkg-reqs.list || die "no tkg-reqs.list found" 50
    ;;
  "tkc" )
    # check for duplicate in tkc.list or add to tkc.list
    [ $dc ] || die "no dc-name given" 20
    [ $tkg ] || die "no tkg-name given" 20
    [ $tkc ] || die "no tkc-name given" 20
    debug "running mktkg $dc $tkg $tkc"
    unset exist && exist=$(grep -c "$tkc" $listdir/tkc.list) && debug "exist=$exist"
    [ $exist -gt 0 ] && die "$tkc already on tkg.list" 30 || [ $DRYRUN ] && echo "echo $tkc >> $listdir/tkc.list" || echo $tkc >> $listdir/tkc.list
    # check for folder $dc-$tkg-tkg/$dc-$tkg-$tkc or create
    [ -d $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc ] && die "$dc-$tkg-$tkc already exists" 40 || [ $DRYRUN ] && echo "mkdir $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc" || $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc
    # copy cluster policies from skeleton
    #cp $skeldir/stuff
    # tmc?
    # opa?
    # monitoring?
    # read the tkc-reqs.list and mktns each
    [ -f $listdir/tkc-reqs.list ] && cat $listdir/tkc-reqs.list || die "no tkc-reqs.list found" 50
    # do config for each
    ;;
  "tns" )
    # check for duplicate in tns.list or add to tns.list
    [ $dc ] || die "no dc-name given" 20
    [ $tkg ] || die "no tkg-name given" 20
    [ $tkc ] || die "no tkc-name given" 20
    [ $tns ] || die "no tns-name given" 20
    debug "running mktns $dc $tkg $tkc $tns"
    unset exist && exist=$(grep -c "$tns" $listdir/tns.list) && debug "exist=$exist"
    [ $exist -gt 0 ] && die "$tns already on tns.list" 30 || [ $DRYRUN ] && echo "echo $tns >> $listdir/tns.list" || echo $tns >> $listdir/tns.list
    # check for folder $dc-$tkg-tkg/$dc-$tkg-$tkc-$tns or create
    [ -d $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns ] && die "$dc-$tkg-$tkc-$tns already exists" 40 || [ $DRYRUN ] && echo "mkdir $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns" || mkdir $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns
    # copy policies, namespace limits, etc
    # read the tns-reqs.list and run each
    [ -f $listdir/tns-reqs.list ] && cat $listdir/tns-reqs.list || die "no tns-reqs.list found" 50
    ;;
  *)
    die "nothing to make" 100
    ;;
esac
