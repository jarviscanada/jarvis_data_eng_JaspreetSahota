#!/bin/sh

# ======================================================
# host_usage.sh
# Collects host resource usage statistics (memory, CPU, disk)
# and inserts them into the PostgreSQL database every minute.
# ======================================================

# Initialize argument variables
psql_host=$1      # PostgreSQL host (e.g., localhost)
psql_port=$2      # PostgreSQL port (e.g., 5432)
db_name=$3        # Database name (e.g., host_agent)
psql_user=$4      # PostgreSQL username (e.g., postgres)
psql_password=$5  # PostgreSQL password

# Check number of arguments
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <psql_host> <psql_port> <db_name> <psql_user> <psql_password>"
    exit 1
fi

# Collect system usage info
# Use vmstat to get memory and CPU stats in MB
vmstat_mb=$(vmstat --unit M)
# Hostname (fully qualified)
hostname=$(hostname -f | tr -d '\n')
# Memory free (in MB)
memory_free=$(echo "$vmstat_mb" | tail -n1 | awk '{print $4}' | xargs)
# CPU idle percentage
cpu_idle=$(echo "$vmstat_mb" | tail -n1 | awk '{print $15}' | xargs)
# CPU kernel percentage
cpu_kernel=$(echo "$vmstat_mb" | tail -n1 | awk '{print $14}' | xargs)
# Disk I/O (number of disk I/O)
disk_io=$(vmstat --unit M -d | tail -n1 | awk '{print $10}' | xargs)
# Available disk space for root (in MB)
disk_available=$(df -BM / | tail -n1 | awk '{print $4}' | grep -o '[0-9]*')
# Current UTC timestamp
timestamp=$(date -u +'%Y-%m-%d %H:%M:%S')

# Set PostgreSQL password environment variable
export PGPASSWORD=$psql_password

# Get host_id from host_info table
# This assumes host_info already contains the hostname
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

# Construct INSERT statement
insert_stmt="
INSERT INTO host_usage (
    timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available
)
VALUES (
    '$timestamp', $host_id, '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available'
);
"

# Execute INSERT statement using psql
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

# Exit script with psql return code
exit $?
