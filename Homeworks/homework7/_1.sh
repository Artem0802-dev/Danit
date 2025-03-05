Boris devops киев, [05.03.2025 21:56]
#!/bin/bash

# Variables
USERS=("dev1" "dev2" "dev3")
GROUPS=("developers" "webmasters")
SHARED_DIR="/home/web_project"
LOG_FILE="/home/my.log"


# Function to print a separator
print_separator() {
    echo "--------------------------------------------------"
}

# Step 1: Create groups
echo "Creating groups..."
for group in "${GROUPS[@]}"; do
    if ! getent group "$group" > /dev/null; then
        sudo groupadd "$group"
        echo "Group $group created."
    else
        echo "Group $group already exists."
    fi
done

# Step 2: Create users and assign to groups
echo "Creating users and assigning to groups..."
for user in "${USERS[@]}"; do
    if ! id "$user" > /dev/null 2>&1; then
        sudo useradd -m -s /bin/bash -G developers "$user"
        echo "User $user created and added to 'developers' group."
    else
        echo "User $user already exists."
    fi
done

# Assign dev3 to webmasters group
sudo usermod -aG webmasters dev3
echo "User dev3 added to 'webmasters' group."

# Set default group for all developers
for user in "${USERS[@]}"; do
    sudo usermod -g developers "$user"
    echo "Default group for $user set to 'developers'."
done

# Step 3: Clone home directory of dev1 for backupdev
echo "Creating user backupdev and cloning home directory of dev1..."
if ! id "backupdev" > /dev/null 2>&1; then
    sudo useradd -m -s /bin/bash -G developers backupdev
    sudo rsync -a /home/dev1/ /home/backupdev/
    sudo chown -R backupdev:developers /home/backupdev
    echo "User backupdev created and home directory cloned from dev1."
else
    echo "User backupdev already exists."
fi

# Step 4: Create shared project directory
echo "Creating shared project directory..."
sudo mkdir -p "$SHARED_DIR"
sudo chgrp developers "$SHARED_DIR"
sudo chmod 2775 "$SHARED_DIR" # Set group sticky bit for shared directory
echo "Shared project directory created at $SHARED_DIR with group 'developers'."

# Step 5: Create immutable log file
echo "Creating immutable log file..."
sudo touch "$LOG_FILE"
sudo chmod a+rw "$LOG_FILE" # Allow everyone to read and append
sudo chattr +a "$LOG_FILE"  # Set append-only attribute
echo "Log file created at $LOG_FILE with append-only permissions."

# Step 6: Print summary
print_separator
echo "Configuration complete!"
echo "Users created: ${USERS[*]}"
echo "Groups created: ${GROUPS[*]}"
echo "Shared project directory: $SHARED_DIR"
echo "Immutable log file: $LOG_FILE"
print_separator

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