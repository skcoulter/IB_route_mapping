#!/bin/bash

basedir="/usr/projects/systems/route_maps"

if [ $# -lt 2 ]
then
        echo " "
        echo "$0: ERROR: Not enough parameters provided"
        echo "$0: USAGE: $0 <-j|--jobnum jobnumber> <-t|--transport IB or OPA> [--save] [-f|--iofile filename]"
        echo "              - the first 2 parameters are required"
	echo "              - the --save option will retain working files in /tmp"
	echo "              - without the --iofile option, the map will show the routes between all the compute nodes allocated to the job"
	echo "              - with the --iofile option, the map will show the routes between the compute nodes and the nodes listed in the file"
	echo "              - the --iofile option is meant to contain the lids of IO nodes, but it could be any subset of nodes"
        echo " "
        exit
fi

action="remove"

while [[ $# -gt 0 ]]
do
opt="$1"

	case $opt in
	-j|--jobnum)
		JN="$2"
		shift
		shift
	;;
	-t|--transport)
		TP="$2"
		shift
		shift
	;;
	-f|--iofile)
		FN="$2"
		shift
		shift
	;;
	-s|--save)
		action="save"
		shift
	;;
	*)    
		echo "$0: WARN: Extraneous data ignored"	
		shift
	;;
esac
done

if [[ $TP != "IB" && $TP != "OPA" ]]
then
        echo "$0: ERROR: Bad transport provided, $TP"
	exit
fi

if [ -z "$FN" ]
then
	$basedir/rte_by_job.sh $JN $TP $basedir $action NOFN
	$basedir/xtic.sh $JN $TP $action
	$basedir/plot_cmd.sh $JN $basedir $action NOFN
else
	$basedir/rte_by_job.sh $JN $TP $basedir $action $FN
	$basedir/xtic.sh $JN $TP $action
	$basedir/plot_cmd.sh $JN $basedir $action $FN
fi


