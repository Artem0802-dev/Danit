Boris devops киев, [05.03.2025 21:58]
#!/bin/bash

# Configurable threshold (percentage)
THRESHOLD=$1

# Validate threshold input
if [[ -z "$THRESHOLD" || ! "$THRESHOLD" =~ ^[0-9]+$ || "$THRESHOLD" -gt 100 || "$THRESHOLD" -lt 1 ]]; then
    echo "Error: Please provide a valid threshold percentage (1-100)."
    exit 1
fi

# Get disk utilization percentage for / volume
USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

# Log file
LOG_FILE="/var/log/disk.log"

# Check if usage exceeds threshold
if [[ "$USAGE" -gt "$THRESHOLD" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - WARNING: Disk usage is ${USAGE}% (threshold: ${THRESHOLD}%)" >> "$LOG_FILE"
fi

Boris devops киев, [05.03.2025 22:01]
#!/bin/bash

# Monit configuration file for Nginx
MONIT_CONF="/etc/monit/conf.d/nginx.conf"


# Function to print a separator
print_separator() {
    echo "--------------------------------------------------"
}

# Step 1: Install Monit
echo "Installing Monit..."
if ! command -v monit &> /dev/null; then

    sudo apt update -qq > /dev/null
    sudo apt install -qq -y monit > /dev/null
    echo "Monit installed."
else
    echo "Monit is already installed."
fi

# Step 2: Create Monit configuration for Nginx
echo "Configuring Monit for Nginx monitoring..."
sudo bash -c "cat > $MONIT_CONF" <<EOF
check process nginx with pidfile /var/run/nginx.pid
    start program = "/etc/init.d/nginx start"
    stop program = "/etc/init.d/nginx stop"
    if failed port 80 protocol http then alert
    if 7 restarts within 7 cycles then unmonitor
EOF

echo "Monit configuration file created at $MONIT_CONF."

# Step 3: Start and enable Monit
echo "Starting and enabling Monit..."
sudo systemctl start monit
sudo systemctl enable monit > /dev/null
echo "Monit started and enabled."

# Step 4: Reload Monit to apply configuration
echo "Reloading Monit..."
sudo monit reload
echo "Monit reloaded."

# Step 5: Print Monit status for Nginx
print_separator
echo "Monit configuration for Nginx is complete!"
echo "Checking Monit status for Nginx:"
sudo monit status | grep -A 5 "Process 'nginx'"
print_separator