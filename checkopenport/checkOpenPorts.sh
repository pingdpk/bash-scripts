#!/bin/bash
#This will print "IP:port" if any port is opened in the given IP addresses.
#To get running application instances.
#@auther : deepak dot edakkott at orbitz dot com
#s-version : 1.1

args=`echo ${@}`

alias grep='grep --color=tty'
if [ ! -z $1 ] ; then
 PORT="$1"
else
PORT="8585
7007"
fi

op_port="/tmp/open_ports"
tempFile="$op_port/tempFile.txt"
openedPort="$op_port/OpenedPort.txt"
IPsAlone="$op_port/IPsAlone.txt"
ipRegex="[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"


FUN_NOTES(){
echo -e "A script to check the entered port is in use or not.\n--------------------------------------"
echo "Note:"
echo "If it is sticking on any IP (may be in debug mode) and you want to check it manually , just press ctrl+c" | grep "ctrl+c"
echo "Run the script with -a argument to check 192.168.70.1 to 192.168.70.255"
echo "Run the script with port number as the argument to check that port alone , but the it should be the first argument"
echo "Run the script with -h for this help"
echo ""
[[ $args == *-h* ]] && exit 0;
}

FUN_DOWNLOAD_FILE(){
#Download new list from server
echo -e "\n# Downloading new list of IP and users from server..."
wget -P $op_port -q "http://192.168.70.70/infra/machines2.xml"
xmlFile=$op_port/machines2.xml 
if [[ $args == *-a* ]];
then
IP=`for z in \`seq 1 255\` ; do echo "192.168.71.$z" ; done`
else
IP="`cat $xmlFile | grep -iE "OFB|OBI|OLB"  | grep -v "!" |grep -v "\-\-" | grep -oP $ipRegex | sort | uniq`"
fi
echo -e "# If you need the newly downloaded list , check here : $xmlFile"
}


FUN_DELETE_TEMP_FILES(){
[ ! -d $op_port ] && mkdir $op_port
[ -f $tempFile ] && rm $tempFile -f
[ -f $openedPort ] && rm $openedPort -f
[ -f $IPsAlone ] && rm $IPsAlone -f
}

FUN_PRINT_USER_NAME(){
echo -e "\nIP , Seat and Usernames.\n====================="
cat $openedPort | awk -F":" '{print $1}' >> $IPsAlone
while read myIp ;do while read thisLine ; do echo $thisLine | grep $myIp ; done < $xmlFile ; done < $IPsAlone| awk '{$1=""; $NF="";print }' | grep -v "^$" | sort | uniq | grep -P $ipRegex
}

FUN_GET_PORTS_OPENED(){
for port in $PORT
do
	for ip in $IP
		do
			echo "Checking --> $ip:$port"
			echo "open $ip $port"| telnet  > $tempFile 2>&1
			count=`grep "Connected to" $tempFile | wc -l`
			[ $count -gt 0 ] && echo $ip:$port >> $openedPort
			#sleep 2 
		done
done
}

#-----------start------------[
FUN_NOTES;
echo -e "\nChecking the following IPs whether are in use or not.\nPlease wait..\n"
FUN_DELETE_TEMP_FILES;
FUN_DOWNLOAD_FILE;
FUN_GET_PORTS_OPENED;
echo -e "\nList of IPs using $PORT are:\n====================="
_ports=`echo $PORT | sed 's/ /|/g'`
[ -f $openedPort ] && grep -E ":|$_ports" $openedPort || echo "No IPs found with given Ports opened."
FUN_PRINT_USER_NAME;
FUN_DELETE_TEMP_FILES;
#-----------End---------------]
