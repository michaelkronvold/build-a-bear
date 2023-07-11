#!/bin/bash

#set a default workdir and read config from the
confdir=$(dirname "$0")
workdir=$(pwd)
source $confdir/bab.conf



# check for duplicate in dc.list or add to dc.list

[ $1 ] || die "Usage: $0 [dc]"

[ -d ]