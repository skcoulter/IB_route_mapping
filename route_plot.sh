#!/bin/bash

basedir="/usr/projects/systems/route_maps"

if [ $# -lt 2 ]
then
        echo " "
        echo "$0: ERROR: Not enough parameters provided"
        echo "$0: USAGE: $0 <filename> <IB or OPA> [save]"
        echo "              - the order of the parameters must be accurate"
	echo "              - the save option will retain working files in /tmp"
        echo " "
        exit
fi

if [[ $2 != "IB" && $2 != "OPA" ]]
then
        echo "$0: ERROR: Bad transport provided, $2"
fi

action="remove"
if [ $# -eq 3 ]
then
        action=$3
fi

$basedir/rte_by_job.sh $1 $2 $action

$basedir/xtic.sh $1 $2 $action

$basedir/plot_cmd.sh $1 $basedir

