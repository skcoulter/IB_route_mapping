#!/bin/bash

if [ $# -lt 1 ]
then
        echo " "
        echo "$0: ERROR: No file name provided"
        echo "$0: USAGE: $0 <filename> - the filename containing route data"
        echo " "
        exit
fi

lid="0"
tic=0
echo -n "set xtics (" > /tmp/xtics.$$

cat $1 | while read line
do
        case "$line" in
        *Spine*)
                tic=1
        ;;
        *)
                lx=`echo $line | sed 's/\/.*//'`
                px=`echo $line | sed 's/.*\///' | sed 's/ .*//'`

                if [ $lid -ne $lx ]
                then    
                        desc=`ibnetdiscover | grep Switch | grep "lid $lx "| awk '{print $8}' | sed 's/"//'`
                        echo -n "\""$desc"\"" $tic"," >> /tmp/xtics.$$;
                fi      
                lid=$lx 
		let "tic = $tic + 1"
        ;;
        esac

done
echo ")" >> /tmp/xtics.$$

fn=`echo $1 | sed 's/.*routes/routes/'`
fix=`cat /tmp/xtics.$$ | sed 's/,)/)/'`
echo $fix > /tmp/xtics.$fn
echo File containing xtics is /tmp/xtics.$fn

