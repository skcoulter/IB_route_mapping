#!/bin/bash

basedir="/usr/projects/systems/route_maps"

cluster=`/usr/projects/hpcsoft/utilities/bin/sys_name`

set_title="set title "
title_text=" route plot for job "

set_output="set output "
output_text="$basedir/${cluster}_job$1.png"

plot="plot "
plot_datafile="/tmp/routes.job$1"
plot_text=" using 2 ti col fs solid lc rgb "
plot_number="#228B22"

# create gnuplot command file

cat $basedir/plot_template | while read line
do
        case "$line" in
	*TEMPLATE_TITLE*)
		echo $set_title \"$cluster$title_text$1\" >> /tmp/plotcmd.$$
	;;
	*TEMPLATE_XTICS*)
		cat /tmp/xtics.job$1 >> /tmp/plotcmd.$$
	;;
	*TEMPLATE_OUT*)
		echo $set_output \"$output_text\" >> /tmp/plotcmd.$$
	;;
	*TEMPLATE_PLOT*)
		echo $plot \"$plot_datafile\" $plot_text \"$plot_number\" >> /tmp/plotcmd.$$
	;;
	*)
		echo $line >> /tmp/plotcmd.$$
	;;
	esac

done

gnuplot /tmp/plotcmd.$$

# clean up unless otherwise directed

if [ $2 == "remove" ]
then
        rm /tmp/*.$$
fi

exit
