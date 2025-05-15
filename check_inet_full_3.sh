#!/usr/bin/bash

max_counter=3
counter_file="/var/log/inet_check_cnt_file.txt"
script_counter_file="/var/log/inet_check_script_cnt_file.txt"
script_date_file="/var/log/inet_check_script_date_file.txt"
script_name="/opt/watchdog/reset_internet.py"
send_alert_script="/opt/watchdog/send_alert_email.sh" 
skript_name=$(basename "$0")
timestamp=$(date +%Y-%m-%d_%H-%M-%S)

# Serverliste
check_servers=("8.8.8.8" "1.1.1.1" "9.9.9.9")

# Initialisierung
counter=0
found_errors=0

# Lade bisherigen Fehlerzähler
if [ -e "$counter_file" ]; then
    read counter < "$counter_file"
fi

# Externe IP (optional)
server_ip="$(curl -s --max-time 5 ifconfig.co)"
dns_server_ip="$(dig +short egmond176.ddns.net @1.1.1.1)"

if [[ -z "$server_ip" || -z "$dns_server_ip" ]]; then
    logger -t "$skript_name" "Fehler beim Ermitteln der IP-Adressen"
    found_errors=$((found_errors + 1))
elif [[ "$server_ip" != "$dns_server_ip" ]]; then
    logger -t "$skript_name" "Server IP ($server_ip) unterscheidet sich von DNS IP ($dns_server_ip)"
    found_errors=$((found_errors + 1))
fi

# Ping-Test zu mehreren Servern
success=false
for server in "${check_servers[@]}"; do
    if ping -c 2 -W 2 "$server" > /dev/null; then
        logger -t "$skript_name" "Ping erfolgreich zu $server"
        success=true
        break
    else
        logger -t "$skript_name" "Ping zu $server fehlgeschlagen"
    fi
done

if ! $success; then
    found_errors=$((found_errors + 1))
fi

# Auswertung
if [ "$found_errors" -eq 0 ]; then
    if [ "$counter" -ne 0 ]; then
        echo 0 > "$counter_file"
    fi
else
    counter=$((counter + 1))
    if [ "$counter" -gt "$max_counter" ]; then
        counter=0
        echo "$counter" > "$counter_file"

        script_cnt=0
        if [ -e "$script_counter_file" ]; then
            read script_cnt < "$script_counter_file"
        fi
        script_cnt=$((script_cnt + 1))
        echo "$script_cnt" > "$script_counter_file"
        echo "$timestamp" >> "$script_date_file"

        logger -t "$skript_name" "Maximale Fehleranzahl überschritten – sende Alarm"
        echo "send email $send_alert_script"
        "$send_alert_script"

        logger -t "$skript_name" "Notfallskript wird ausgeführt"
        echo "exec script $script_name"
        exec python3 "$script_name"
    else
        echo "$counter" > "$counter_file"
    fi
fi