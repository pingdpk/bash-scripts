#!/bin/bash
# Get list of ports opened for particular IP.

portListFile="/d/nwIssue/portList.txt" #given by Jerry
ipListFile="/d/nwIssue/ipList.csv"
tempFile="/d/nwIssue/tmpFile.txt"
openedPortListFile="/d/nwIssue/URL_vs_IP_vs_PORT_Expedia.csv" #last output
networkHelperJar="/d/nwIssue/NetworkHelper.jar"
domainListFile="/d/nwIssue/domainList.csv"

FUN_EXTRACT_IP_FROM_GIVEN_LIST(){
# Step 1 : Remove list of IPs file if exists.
[ -f $ipListFile ] && rm $ipListFile

# Step 1 : Read file and get domain list (assuming domain list is in first column - separated by tab/space)
echo "Reading file $domainListFile"
i=0
while read line ; do
	domain=$(echo $line | awk '{print $1}')
    domainList[$i]="$domain"
    i=$(($i+1))
done < $domainListFile


# Step 2 : Total number of domains in the list.
totalDomains=${#domainList[@]}
echo "Total number of domains in $domainListFile : $totalDomains"


# Step 3. Domains in the list needs a trim - http://domainName/abcd/something will become domainName
echo "Making exact domain name list for resolving IP."
i=0
for fulladdress in ${domainList[@]}
do
	withHttp=$(echo $fulladdress | grep http | wc -l) ;
	if [ $withHttp -eq 1 ] ; then 
		domain=$(echo $fulladdress  | awk -F"/" '{print $3}') ; 
	else  
		domain=$(echo $fulladdress  | awk -F"/" '{print $1}') ; 
	fi
	
	withPort=$(echo $domain | grep ":" | wc -l) ;
	if [ $withPort -eq 1 ] ; then 
		domain=$(echo $domain | awk -F":" '{print $1}') ; 
	fi
	
	domainNewList[$i]="$domain" ;
	
	i=$(($i+1))
done
	
	
# Step : make array uniq
domainUniqList=$(echo "${domainNewList[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
	
# Step 4 : Get IP address for each domain names 
echo -e "Getting each domain's IP list.\n"
for newDomain in ${domainUniqList[@]}
do
	echo "Getting for : $newDomain"
	echo -n "$newDomain  , "  >> $ipListFile ;
	ipAddress=$(ping -n 1 $newDomain | grep "Ping stati" | awk '{sub(/\:/,"");print $NF}') ;
	[ ! -z $ipAddress ] && ipAddress=$ipAddress || ipAddress="Not found"
	echo $ipAddress  >> $ipListFile ;
done

echo "$ipListFile generated with Domain_address Vs IP list."
}



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

FUN_EXTRACT_IP_FROM_GIVEN_LIST;
FUN_GET_PORT_LIST;
FUN_GET_PORTS_OPENED;