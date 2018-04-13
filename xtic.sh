#!/bin/bash

if [ $# -lt 2 ]
then
        echo " "
        echo "$0: ERROR: Not enough parameters provided"
        echo "$0: USAGE: $0 <filename> <IB or OPA>"
	echo "              - the order of the parameters must be accurate"
        echo " "
        exit
fi

if [[ $2 -ne "IB" && $2 -ne "OPA" ]]
then
        echo "$0: ERROR: Bad transport provided, $2"
fi

# generate appropriate tics

dev="0"
tic=0
echo -n "set xtics (" > /tmp/xtics.$$

cat $1 | while read line
do
        case "$line" in
        *Spine*)
                tic=1
        ;;
        *)
                dx=`echo $line | sed 's/\/.*//'`
                px=`echo $line | sed 's/.*\///' | sed 's/ .*//'`
		desc=$dx

		if [ $2 == "IB" ]
		then
			if [ $dev -ne $dx ]
			then
				desc=`ibnetdiscover | grep Switch | grep "lid $dx "| awk '{print $8}' | sed 's/"//'`
				echo -n "\""$desc"\"" $tic"," >> /tmp/xtics.$$;
                        fi
		else
			if [ $dev != $dx ]
			then
				echo -n "\""$desc"\"" $tic"," >> /tmp/xtics.$$;
			fi	
		fi

                dev=$dx 
		let "tic = $tic + 1"
        ;;
        esac
done
echo ")" >> /tmp/xtics.$$

fn=`echo $1 | sed 's/.*routes/routes/'`
fix=`cat /tmp/xtics.$$ | sed 's/,)/)/'`
echo $fix > /tmp/xtics.$fn
echo File containing xtics is /tmp/xtics.$fn

