###--------------------------------------------------------------------
mktmps () {
  tmp=()           # array of tmp files, refer to them as ${tmp[0]} thru ${tmp[tmps]}
                   # yes this always makes one extra tmp[0] as a spare intentionally
                   # change i=1 to change behavior to 0 to tmps-1
  for ((i=0; i<=tmps; i++));
  do
    tmpfile=$( mktemp /dev/shm/${tempkey}_${program}_tmp.XXXXXXXXXX )
    tmp+=($tmpfile)
  done
} #--------------------------------------------------------------------
cleanup () {
     #  Delete temporary files, then optionally exit given status.
     local status=${1:-'0'}
     rm -f ${tmp[@]}
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
