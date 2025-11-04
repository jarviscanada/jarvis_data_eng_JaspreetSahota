#!/bin/sh

# ======================================================
# host_info.sh
# Collects host hardware specifications and inserts
# them into a PostgreSQL database.
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

# Collect hardware info
# Capture all CPU info in one variable to avoid multiple lscpu calls
lscpu_out=$(lscpu)
# Fully qualified hostname
hostname=$(hostname -f | tr -d '\n')
# Number of CPUs
cpu_number=$(echo "$lscpu_out" | awk -F: '/^CPU\(s\):/ {print $2}' | xargs)
# CPU architecture (e.g., x86_64)
cpu_architecture=$(echo "$lscpu_out" | awk -F: '/Architecture:/ {print $2}' | xargs)
# CPU model name (first 5 words of Model name)
cpu_model=$(echo "$lscpu_out" | awk -F: '/Model name:/ {print $2}' | xargs | awk '{print $1,$2,$3,$4,$5}')
# CPU speed in MHz (take first CPU entry)
cpu_mhz=$(grep "MHz" /proc/cpuinfo | head -n 1 | awk -F: '{print $2}' | xargs)
# Extract only the numeric part of L2 cache (in KB)
l2_cache=$(echo "$lscpu_out" | awk -F: '/L2 cache:/ {gsub(/[^0-9]/,"",$2); print $2}')
# Total memory in MB
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
# Current UTC timestamp
timestamp=$(date -u +'%Y-%m-%d %H:%M:%S')

# Step 3: Set PostgreSQL password environment variable
export PGPASSWORD=$psql_password

# Construct INSERT statement
insert_stmt="
INSERT INTO host_info (
    hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp
)
VALUES (
    '$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz', '$l2_cache', '$total_mem', '$timestamp'
);
"

# Execute INSERT statement using psql
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

# Exit script with psql return code
exit $?
