#!/bin/bash

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


# set a default workdir and read config from the
confdir=$(dirname "$0")
[ -d $workdir ] || workdir=$(pwd)
[ -f $confdir/bab.conf ] && source $confdir/bab.conf || die "No config file found in default location $confdir/bab.conf"
[ $listdir ] || die "No listdir found in config"
[ -d $listdir ] || workdir=$(pwd)

case $work in
  "dc" )
    # check for duplicate in dc.list or add to dc.list
    [ $dc ] || die "no dc given"
    echo "mkdc $dc"
    grep "$dc" $listdir/dc.list
    ;;
  "tkg" )
    # check for duplicate in tkg.list or add to tkg.list
    [ $dc ] || die "no dc-name given"
    [ $tkg ] || die "no tkg-name given"
    echo "mktkg $dc $tkg"
    # check for folder $dc-$tkg-tkg or create
    [ -d $workdir/$dc-$tkg-tkg ] && die "$dc-$tkg-tkg already exists" || echo "mkdir $workdir/$dc-$tkg-tkg"
    # read the tkg-reqs.list and mktkc each
    [ -f $listdir/tkg-reqs.list ] && cat $listdir/tkg-reqs.list || die "no tkg-reqs.list found"
    ;;
  "tkc" )
    # check for duplicate in tkc.list or add to tkc.list
    [ $dc ] || die "no dc-name given"
    [ $tkg ] || die "no tkg-name given"
    [ $tkc ] || die "no tkc-name given"
    echo "mktkg $dc $tkg $tkc"
    # check for folder $dc-$tkg-tkg/$dc-$tkg-$tkc or create
    [ -d $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc ] && die "$dc-$tkg-$tkc already exists" || echo "mkdir $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc"
    # copy cluster policies from skeleton
    #cp $skeldir/stuff
    # tmc?
    # opa?
    # monitoring?
    # read the tkc-reqs.list and mktns each
    [ -f $listdir/tkc-reqs.list ] && cat $listdir/tkc-reqs.list || die "no tkc-reqs.list found"
    # do config for each
    ;;
  "tns" )
    # check for duplicate in tns.list or add to tns.list
    [ $dc ] || die "no dc-name given"
    [ $tkg ] || die "no tkg-name given"
    [ $tkc ] || die "no tkc-name given"
    [ $tns ] || die "no tns-name given"
    echo "mktns $dc $tkg $tkc $tns"
    # check for folder $dc-$tkg-tkg/$dc-$tkg-$tkc-$tns or create
    [ -d $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns ] && die "$dc-$tkg-$tkc-$tns already exists" || echo "mkdir $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns"
    # copy policies, namespace limits, etc
    # read the tns-reqs.list and run each
    [ -f $listdir/tns-reqs.list ] && cat $listdir/tns-reqs.list || die "no tns-reqs.list found"
    ;;
  *)
    die "nothing to make"
    ;;
esac
