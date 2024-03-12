#!/usr/bin/bash
max_counter=3
counter_file="/var/log/inet_check_cnt_file.txt"
script_counter_file="/var/log/inet_check_script_cnt_file.txt"
script_name="/var/opt/watchdog/reset_internet.py"
check_server="google.com"
counter=0
if [ -e $counter_file ]; then
	read counter < $counter_file;
else
	counter=0;
fi

if ping -c 4 $check_server ; then 
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
	  exec python $script_name
	else
	  echo $counter > $counter_file;
	fi
	 
fi

