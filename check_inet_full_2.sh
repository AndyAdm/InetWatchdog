#!/usr/bin/bash
max_counter=3
counter_file="/var/log/inet_check_cnt_file.txt"
script_counter_file="/var/log/inet_check_script_cnt_file.txt"
script_date_file="/var/log/inet_check_script_date_file.txt"
script_name="/opt/watchdog/reset_internet.py"
check_server="google.com"
send_alert_script="/opt/watchdog/send_alert_email.sh" 
counter=0

timestamp=`date +%Y-%m-%d_%H-%M-%S` 

skript_name=$(basename "$0")


#logger "$skript_name: started"

if [ -e $counter_file ]; then
	read counter < $counter_file;
else
	counter=0;
fi

server_ip="$(curl ifconfig.co)"

# echo $server_ip

dns_server_ip="$(dig egmond176.ddns.net +short)"
# echo $dns_server_ip

found_errors=0

if [ $server_ip != $dns_server_ip ]; then
#	echo "error found"
	found_errors=$((found_errors+1))
#	echo $found_errors
	logger "$skript_name: server IP ($server_ip) is not the same as DNS Server ($dns_server_ip)"
fi  

if ping -c 4 $check_server ; then 
    dummy=""
else
	found_errors=$((found_errors+1))
	logger "$skript_name: Ping to server ($check_server) does not work"
	
	#echo $found_errors
fi 




if [ $found_errors -eq 0 ];  then 
	# write only if the last status was not zero
	if [ $counter -ne 0 ]; then
		counter=0 ;
		echo "0" > $counter_file  ;
	fi 
else 
	counter=$((counter+1))
	

	if [ $counter -gt $max_counter ] ; then
	 
	  counter=0;
	  echo $counter > $counter_file;
	  script_cnt=0;
	  
	  if [ -e $script_counter_file ]; then
	  	read script_cnt < $script_counter_file
	  fi 
	  script_cnt=$((script_cnt+1))
	  echo $script_cnt > $script_counter_file;
	  echo $timestamp >> $script_date_file;
	  logger "$skript_name: send email notification"
	  echo "send email $send_alert_script"
	  $send_alert_script
	  logger "$skript_name: Activate the emegrency script"
	  echo "exec script $script_name"
	  exec python3 $script_name
	else
	  echo $counter > $counter_file;
	fi
	 
fi

