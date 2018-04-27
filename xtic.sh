#!/bin/bash

# generate appropriate tics

dev="0"
tic=0
echo -n "set xtics (" > /tmp/xtics.$$

cat /tmp/routes.job$1 | while read line
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

fix=`cat /tmp/xtics.$$ | sed 's/,)/)/'`
echo $fix > /tmp/xtics.job$1

# clean up unless otherwise directed

if [ $3 == "remove" ]
then
        rm /tmp/*.$$
fi

exit
