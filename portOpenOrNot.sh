#!/bin/bash
# Get list of ports opened for particular IP.

#java -jar /d/nwIssue/NetworkHelper.jar 10.187.77.126 2 5
#java -jar /d/nwIssue/NetworkHelper.jar 10.187.77.126 2 5 > $tempFile
#java -jar /d/nwIssue/NetworkHelper.jar 10.187.77.126 2 5 > $tempFile


portListFile="/d/nwIssue/portList.txt" #given by Jerry
ipListFile="/d/nwIssue/ipList.csv"
tempFile="/d/nwIssue/tmpFile.txt"
openedPortListFile="/d/nwIssue/openedPortList.txt"
networkHelperJar="/d/nwIssue/NetworkHelper.jar"


FUN_GET_PORT_LIST(){
echo "Reading file $portListFile"
i=0
while read line ; do
	port=$(echo $line | awk '{print $1}')
    portList[$i]="$port"
    i=$(($i+1))
	#echo ${portList[@]}
done < $portListFile
}


FUN_MAKE_IP_LIST(){
echo "Reading file $ipListFile"
i=0
while read line ; do
    ip=$(echo $line | grep -v "Not found" | grep [0-9] |awk -F"," '{print $2}')
    ipList[$i]=$([ ! -z $ip ] && echo "$ip")
    i=$(($i+1))
	#echo ${ipList[@]}
done < $ipListFile
}


FUN_GET_PORTS_OPENED(){

#i=0
while read line 
do
echo $ipListFile
    ipadd=$(echo $line | grep -v "Not found" | grep [0-9] |awk -F"," '{print $2}')
	[ ! -z $ip ] && ip="$ipadd" || ip="none";
	echo here $ip
	if [ $ip != "none" ]
	then
	
			domain=$(echo $line | grep -v "Not found" | grep [0-9] |awk -F"," '{print $1}')
		#    ipList[$i]=$([ ! -z $ip ] && echo "$ip")
		#    i=$(($i+1))
			#echo ${ipList[@]}


			for port in ${portList[@]}
				do
		#			for ip in ${ipList[@]}
		#				do
							echo "Checking --> $ip:$port"
							echo java -jar $networkHelperJar "$ip $port" 5 
							count=`java -jar $networkHelperJar $ip $port 5 | grep "open" | wc -l`
							[ $count -gt 0 ] && echo $domain,$ip,$port >> $openedPortListFile
							#sleep 2 
		#				done
				done
	fi
done < $ipListFile
}

FUN_GET_PORT_LIST;
#FUN_MAKE_IP_LIST;
FUN_GET_PORTS_OPENED;