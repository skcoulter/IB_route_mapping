#!/bin/bash

if [ $# -lt 1 ]
then 
        echo " "
        echo "$0: ERROR: No job number provided"
        echo "$0: USAGE: $0 <jobnum> [save] - the save option will retain working files in /tmp"
        echo " "
	exit
fi    

action="remove"
if [ $# -eq 2 ]
then
	action=$2
fi

# get job info

prefix=`hostname | cut -c1-2`
nodelist=`sacct -j $1 --format NodeList%200s | grep -m 1 $prefix`

# create lid list

args=`echo $nodelist | sed 's/.*\[//' | sed 's/\]//' | xargs -d,`

for x in $args
do
        range="no"
        if [[ $x == *[-]* ]]
        then
                range="yes"
        fi
        node=`echo ${x} | sed 's/-/ /'`

# If we get the ability to do this for OPA:
# opaextractlids 2> /dev/null | grep gr0007 | sed 's/.*0x//'

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

for x in `cat /tmp/lidlist.$$`
do
	for y in `cat /tmp/lidlist.$$`
	do
		if [ $x != $y ]
		then
			echo $x " " $y >> /tmp/lidpairs.$$
		fi
	done
done

# run ibtracert and format output

/users/markus/git/get_route_as_function/src/ibtracert --ports-file /tmp/lidpairs.$$ >> /tmp/routes.$$ 2>/dev/null

cat /tmp/routes.$$ | grep "switch port" | sed 's/^.* switch port //' | sed 's/\".*//' | sed 's/^.*\[//' | sed 's/\]/ /' | sed 's/ lid.*-//' | sort -k2 | uniq -c > /tmp/switchports.$$

# read in formatted output and create gnu plot data file

echo "\"Spine Lid/Port\"" "\"Route Count\"" > /tmp/spine_plotdata.$$

cat /tmp/switchports.$$ | while read line
do

	num=`echo ${line} | awk '{print $1}'`
	port=`echo ${line} | awk '{print $2}'`
	lid=`echo ${line} | awk '{print $3}'`
	
	echo "$lid/$port $num" >> /tmp/spine_plotdata.$$
done
	 
# clean up unless otherwise directed

cp /tmp/spine_plotdata.$$ /tmp/routes.job$1
echo Switch port routes for job $1 can be found in /tmp/routes.job$1

if [ $action == "remove" ]
then
	rm /tmp/*.$$
fi

exit
