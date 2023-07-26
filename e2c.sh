#!/bin/bash

tempkey=7008       # set this to something unique to your scripts
tmps=1             # number of tmp files needed
DEBUG=

############ don't mess with these ###########
#
program=${0##*/}   # similar to using basename
confdir=$(dirname "$0")
[ $workdir ] || workdir=$confdir/workdir
[ -d $workdir ] || mkdir -p $workdir
[ -f $confdir/bab.conf ] && source $confdir/bab.conf || die "No config file found in default location $confdir/bab.conf" 10
[ -f $confdir/babfunc.sh ] && source $confdir/babfunc.sh || die "$confdir/babfunc.sh not found" 11
mktmps
ls-tree () { find ${1:-.} | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"; }
#
###############################################

# check the config
[ $listdir ] || die "No listdir found in config" 10
[ -d $listdir ] || mkdir -p $listdir
dclist=$listdir/dc.list
tkglist=$listdir/tkg.list
tkclist=$listdir/tkc.list
tnslist=$listdir/tns.list
tkgreqs=$listdir/tkg.reqs
tkcreqs=$listdir/tkc.reqs
tnsreqs=$listdir/tns.reqs
lists="$dclist $tkglist $tkclist $tnslist $tkgreqs $tkcreqs $tnsreqs"


while [[ $# -gt 0 ]] && [[ "$1" == "--"* ]] ;
do
  opt=${1}
  case "${opt}" in
    "--" )
      break 2;;
    "--cleaneverything" )
      work=cleanstart
      break 2;;
    "--dry" ) DRYRUN=1;;
    "--dryrun" ) DRYRUN=1;;
    "--test" ) DRYRUN=1;;
    "--debug" ) DEBUG=1 ;;
    "--break" ) BREAKPOINT=1;;
    "--show" )
      work=show;;
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

for listfile in $lists;
do
  debug "listfile=$listfile"
  [ -f $listfile ] && debug "$listfile exists" || dryrun "touch $listfile"
done
[ $BREAKPOINT ] && die "DEBUG BREAKPOINT" 99


case "$work" in
  "cleanstart" )
    # remove all lists and directories and their contents
    rm -rf $workdir/*-tkg $lists
    ;;
  "show" )
    # Show everything
    ls-tree $workdir
    for list in $lists;
    do
      echo "--- $list -----"
      cat $list
      echo "---------------------------------------"
    done
    ;;
  "dc" )
    # check for duplicate in dc.list or add to dc.list
    [ $dc ] || die "no dc given" 20
    debug "running mkdc $dc"
    unset exist && exist=$(grep -c "$dc" $dclist) && debug "exist=$exist"
    [ $exist -gt 0 ] && die "$dc already on dc.list" 30 || [ $DRYRUN ] && echo " -- DRYRUN: echo $dc >> $dclist" || echo $dc >> $dclist
    ;;
  "tkg" )
    # check for duplicate in tkg.list or add to tkg.list
    [ $dc ] || die "no dc-name given" 20
    [ $tkg ] || die "no tkg-name given" 20
    debug "running mktkg $dc $tkg"
    unset exist && exist=$(grep -c "$tkg" $tkglist) && debug "exist=$exist"
    [ $exist -gt 0 ] && die "$tkg already on tkg.list" 30 || [ $DRYRUN ] && echo " -- DRYRUN: echo $tkg >> $tkglist" || echo $tkg >> $tkglist
    # check for folder $dc-$tkg-tkg or create
    [ -d $workdir/$dc-$tkg-tkg ] && die "$dc-$tkg-tkg already exists" 40 || dryrun "mkdir $workdir/$dc-$tkg-tkg"
        # [ $DRYRUN ] && echo " -- DRYRUN: mkdir $workdir/$dc-$tkg-tkg" || mkdir $workdir/$dc-$tkg-tkg
    # read the tkg-reqs.list and mktkc each
    [ -f $tkgreqs ] && cat $tkgreqs || die "no $tkgreqs found" 50
    ;;
  "tkc" )
    # check for duplicate in tkc.list or add to tkc.list
    [ $dc ] || die "no dc-name given" 20
    [ $tkg ] || die "no tkg-name given" 20
    [ $tkc ] || die "no tkc-name given" 20
    debug "running mktkg $dc $tkg $tkc"
    unset exist && exist=$(grep -c "$tkc" $tkclist) && debug "exist=$exist"
    [ $exist -gt 0 ] && die "$tkc already on tkc.list" 30 || [ $DRYRUN ] && echo " -- DRYRUN: echo $tkc >> $tkclist" || echo $tkc >> $tkclist
    # check for file $dc-$tkg-tkg/$dc-$tkg-$tkc-tkc.yaml or create
    [ -f $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-tkc.yaml ] && die "$dc-$tkg-$tkc-tkc.yaml already exists" 40 || dryrun "touch $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-tkc.yaml"
        # [ $DRYRUN ] && echo " -- DRYRUN: touch $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-tkc.yaml" || touch $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-tkc.yaml
    # copy cluster policies from skeleton
    #cp $skeldir/stuff
    # tmc?
    # opa?
    # monitoring?
    # read the tkc-reqs.list and mktns each
    [ -f $tkcreqs ] && cat $tkcreqs || die "no $tkcreqs found" 50
    # do config for each
    ;;
  "tns" )
    # check for duplicate in tns.list or add to tns.list
    [ $dc ] || die "no dc-name given" 20
    [ $tkg ] || die "no tkg-name given" 20
    [ $tkc ] || die "no tkc-name given" 20
    [ $tns ] || die "no tns-name given" 20
    debug "running mktns $dc $tkg $tkc $tns"
    unset exist && exist=$(grep -c "$tns" $tnslist) && debug "exist=$exist"
    [ $exist -gt 0 ] && die "$tns already on tns.list" 30 || [ $DRYRUN ] && echo " -- DRYRUN: echo $tns >> $tnslist" || echo $tns >> $tnslist
    # check for file $dc-$tkg-tkg/$dc-$tkg-$tkc-$tns-tns.yaml or create
    [ -f $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns-tns.yaml ] && die "$dc-$tkg-$tkc-$tns-tns.yaml already exists" 40 || dryrun "mkdir $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns-tns.yaml"
        # [ $DRYRUN ] && echo " -- DRYRUN: mkdir $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns-tns.yaml" || mkdir $workdir/$dc-$tkg-tkg/$dc-$tkg-$tkc-$tns-tns.yaml
    # copy policies, namespace limits, etc
    # read the tns-reqs.list and run each
    [ -f $tnsreqs ] && cat $tnsreqs || die "no $tnsreqs found" 50
    ;;
  *)
    die "nothing to make" 100
    ;;
esac

cleanup
