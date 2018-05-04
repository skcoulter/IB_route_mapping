#!/bin/bash

cluster=`/usr/projects/hpcsoft/utilities/bin/sys_name`

set_title="set title "
title_text=" route plot for job "

if [ $4 == "NOFN" ]
then
	title_suffix=" "
else
	title_suffix="- compute to IO"
fi

set_output="set output "
output_text="$2/${cluster}_job$1.png"

plot="plot "
plot_datafile="/tmp/routes.job$1"
plot_text=" using 2 ti col fs solid lc rgb "
plot_number="#228B22"

# create gnuplot command file

cat $2/plot_template | while read line
do
        case "$line" in
	*TEMPLATE_TITLE*)
		echo $set_title \"$cluster$title_text$1 $title_suffix\" >> /tmp/plotcmd.$$
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

if [ $3 == "remove" ]
then
        rm /tmp/*.$$
	rm /tmp/xtics.job$1
	rm /tmp/routes.job$1
fi

exit
