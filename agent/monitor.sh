#!/bin/bash
# File: agent/monitor.sh
# Description: System health monitoring agent that collects server metrics
#              and securely transmits them to a centralized REST API.

# --- AGENT CONFIGURATION ---
API_URL="http://35.158.84.123:8000/api/v1/metrics"
API_KEY="test-token-123" # Must match the registered key in the database

echo "[*] Gathering system metrics..."

# 1. CPU Usage (percentage)
# Extracts the idle percentage from 'top' and subtracts it from 100
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# 2. Load Average (1-minute average)
LOAD_AVG=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | awk '{$1=$1};1')

# 3. Memory Free (in Megabytes)
MEM_FREE=$(free -m | awk '/Mem:/ {print $4}')

# 4. Disk Free (in Gigabytes, for the root partition '/')
DISK_FREE=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')

# 5. IO Wait (disk wait percentage)
IOWAIT=$(top -bn1 | grep "Cpu(s)" | awk -F'wa' '{print $1}' | awk '{print $NF}')

# --- FORMAT DATA AS JSON ---
JSON_PAYLOAD=$(cat <<EOF
{
  "cpu_usage_percent": $CPU_USAGE,
  "load_average": $LOAD_AVG,
  "memory_free_mb": $MEM_FREE,
  "disk_free_gb": $DISK_FREE,
  "iowait_percent": $IOWAIT
}
EOF
)

echo "[*] Payload prepared:"
echo "$JSON_PAYLOAD"
echo "[*] Transmitting data to the API..."

# --- TRANSMIT DATA ---
# Using curl in silent mode (-s) to prevent progress bar output in cron logs
curl -s -X POST "$API_URL" \
     -H "Content-Type: application/json" \
     -H "X-API-Key: $API_KEY" \
     -d "$JSON_PAYLOAD"

echo -e "\n[*] Transmission complete."