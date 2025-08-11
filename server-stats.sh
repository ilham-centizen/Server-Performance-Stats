#!/bin/bash

# server-stats.sh
# Basic server performance stats

echo "==================== Server Stats Report ===================="

# OS Version
echo -e "\nOS Version:"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$PRETTY_NAME"
else
    uname -a
fi

# Uptime
echo -e "\nUptime:"
uptime -p

# Load Average
echo -e "\nLoad Average (1, 5, 15 min):"
uptime | awk -F'load average:' '{ print $2 }'

# Logged in users
echo -e "\nLogged in users:"
who | wc -l

# CPU Usage
echo -e "\nTotal CPU Usage:"
top -bn1 | grep "Cpu(s)" | \
    awk '{print "Used: " 100-$8 "%, Idle: " $8 "%"}'

# Memory Usage
echo -e "\nMemory Usage:"
free -h | awk '/^Mem:/ {print "Used: "$3" / "$2" ("$3*100/$2"% used)"}'

# Disk Usage
echo -e "\nDisk Usage (root partition):"
df -h / | awk 'NR==2{print "Used: "$3" / "$2" ("$5" used)"}'

# Top 5 processes by CPU usage
echo -e "\nTop 5 Processes by CPU Usage:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6

# Top 5 processes by Memory usage
echo -e "\nTop 5 Processes by Memory Usage:"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6

# Stretch: Failed login attempts (last 24h)
echo -e "\nFailed login attempts (last 24h):"
if command -v journalctl &> /dev/null; then
    journalctl _COMM=sshd --since "24 hours ago" | grep "Failed password" | wc -l
elif [ -f /var/log/auth.log ]; then
    grep "Failed password" /var/log/auth.log | wc -l
else
    echo "Log file not found or unsupported system."
fi

echo "============================================================"
