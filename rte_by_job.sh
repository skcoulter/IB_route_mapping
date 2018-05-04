#!/bin/bash

#### functions ####
 
function ibroutes {

	for x in $args
	do
        	range="no"
        	if [[ $x == *[-]* ]]
        	then
                	range="yes"
        	fi
        	node=`echo ${x} | sed 's/-/ /'`

        	if [ $range == "no" ]
        	then
                	ibnetdiscover -p | grep "^CA" | grep $prefix${node} | awk '{print $2}' >> /tmp/lidlist.$$
        	else
                	for n in `seq -w $node`
                	do
                        	ibnetdiscover -p | grep "^CA" | grep $prefix${n} | awk '{print $2}' >> /tmp/lidlist.$$
                	done
        	fi
	done

# create lid pair file for ibtracert

	if [ $1 == "NOFN" ]
	then
		file="/tmp/lidlist.$$"
	else
		file="$1"
	fi

	for x in `cat /tmp/lidlist.$$`
	do
        	for y in `cat $file`
        	do
                	if [ $x != $y ]
                	then
                        	echo $x " " $y >> /tmp/lidpairs.$$
                	fi
        	done
	done

# run ibtracert and format output
# for now run modified ibtracert at path passed as argument
#    once patch is released as part of bundled ibtracert, this will not be necessary

	$2/ibtracert --ports-file /tmp/lidpairs.$$ >> /tmp/routes.$$ 2>/dev/null

	cat /tmp/routes.$$ | grep "switch port" | sed 's/^.* switch port //' | sed 's/\".*//' | sed 's/^.*\[//' | sed 's/\]/ /' | sed 's/ lid.*-//' | sort -k2 | uniq -c > /tmp/switchports.$$

}

function oparoutes {

	for x in $args
	do
        	range="no"
        	if [[ $x == *[-]* ]]
        	then
                	range="yes"
        	fi
        	node=`echo ${x} | sed 's/-/ /'`

        	if [ $range == "no" ]
        	then
                	echo $prefix${node}  >> /tmp/nodelist.$$
        	else
                	for n in `seq -w $node`
                	do
                        	echo $prefix${n} >> /tmp/nodelist.$$
                	done
        	fi
	done

# create node pair file

	if [ $1 == "NOFN" ]
	then
        	file="/tmp/nodelist.$$"
	else
        	file="$1"
	fi

	for x in `cat /tmp/nodelist.$$`
	do
		for y in `cat $file`
		do
			if [ $x != $y ]
			then
				echo "$x $y" >> /tmp/nodepairs.$$
			fi
		done
	done

# dump the routes for the nodes

	cat /tmp/nodepairs.$$ | while read line
	do
		src=`echo $line | awk '{print $1}'`
		dst=`echo $line | awk '{print $2}'`
		opareport -o route -S "node:$src hfi1_0" -D "node:$dst hfi1_0" >> /tmp/rawroutes.$$ 2>/dev/null
	done

# grok output to get summarized switch port usage

	cat /tmp/rawroutes.$$ | while read line
	do
        	case "$line" in
        	*Paths*)
                	ready=1
        	;;
		*Links[[:space:]]Traversed*)
			ready=0
		;;
        	*[[:space:]]SW[[:space:]]*)
			if [ $ready -eq 1 ]
			then
                		px=`echo $line | awk '{print $3}'`
                		sx=`echo $line | awk '{print $5}'`
				echo "$px $sx" >> /tmp/switchportall.$$
                	fi      
        	;;
        	esac

	done	

	cat /tmp/switchportall.$$ | sort -k2 | uniq -c > /tmp/switchports.$$
}

#### end of functions ####

#### mainline ####

# get job info

prefix=`hostname | cut -c1-2`
nodelist=`sacct -j $1 --format NodeList%200s | grep -m 1 $prefix`

# create node list

args=`echo $nodelist | sed 's/.*\[//' | sed 's/\]//' | xargs -d,`

# get routes and create switch port files depending on transport
# send file name if provided

case "$2" in
IB)
	ibroutes $5 $3
;;
OPA)
	oparoutes $5
;;
*)
	echo "$0: ERROR: Bad transport provided, $2"
esac

# read in formatted output and create gnu plot data file

echo "\"Spine Lid/Port\"" "\"Route Count\"" > /tmp/spine_plotdata.$$

cat /tmp/switchports.$$ | while read line
do

        num=`echo ${line} | awk '{print $1}'`
        port=`echo ${line} | awk '{print $2}'`
        lid=`echo ${line} | awk '{print $3}'`

        echo "$lid/$port $num" >> /tmp/spine_plotdata.$$
done

# save routes and clean up unless otherwise directed

cp /tmp/spine_plotdata.$$ /tmp/routes.job$1

if [ $4 == "remove" ]
then
	rm /tmp/*.$$
fi

exit

