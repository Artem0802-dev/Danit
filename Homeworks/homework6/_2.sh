Boris devops киев, [05.03.2025 21:51]
#!/bin/bash

# Variables
USER="john"
SSH_PORT=2222
DEBUG_PORT=3333
SERVER_IP=$(hostname -I | awk '{print $1}')

# Function to print a separator
print_separator() {
    echo "--------------------------------------------------"
}

# Step 1: Create user john
echo "Creating user $USER..."
sudo adduser --quiet --disabled-password --gecos "" $USER
echo "$USER:password" | sudo chpasswd
echo "User $USER created."

# Step 2: Install SSH server
echo "Installing OpenSSH server..."
sudo apt update -qq > /dev/null
sudo apt install -qq -y openssh-server > /dev/null
echo "OpenSSH server installed."

# Step 3: Configure primary SSH server (port 2222)
echo "Configuring primary SSH server on port $SSH_PORT..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo bash -c "cat > /etc/ssh/sshd_config" <<EOF
Port $SSH_PORT
PermitRootLogin no
PasswordAuthentication no
AllowUsers $USER
EOF
sudo systemctl restart ssh
echo "Primary SSH server configured on port $SSH_PORT."

# Step 4: Configure debug SSH server (port 3333)
echo "Configuring debug SSH server on port $DEBUG_PORT..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_debug
sudo bash -c "cat >> /etc/ssh/sshd_config_debug" <<EOF
Port $DEBUG_PORT
PermitRootLogin no
PasswordAuthentication yes
LogLevel DEBUG
EOF
sudo /usr/sbin/sshd -f /etc/ssh/sshd_config_debug
echo "Debug SSH server configured on port $DEBUG_PORT."

# Step 5: Set up SSH key for user john
echo "Setting up SSH key for $USER..."
sudo -u $USER mkdir -p /home/$USER/.ssh
sudo -u $USER chmod 700 /home/$USER/.ssh
sudo -u $USER touch /home/$USER/.ssh/authorized_keys
sudo -u $USER chmod 600 /home/$USER/.ssh/authorized_keys
echo "Please paste your public SSH key below (then press Ctrl+D):"
sudo -u $USER tee /home/$USER/.ssh/authorized_keys > /dev/null
echo "SSH key configured for $USER."

# Step 6: Print connection instructions
print_separator
echo "Configuration complete!"
echo "Primary SSH server is running on port $SSH_PORT."
echo "Debug SSH server is running on port $DEBUG_PORT."
echo ""
echo "To connect to the primary SSH server (key authentication only):"
echo "  ssh $USER@$SERVER_IP -p $SSH_PORT"
echo ""
echo "To connect to the debug SSH server (password or key authentication):"
echo "  ssh $USER@$SERVER_IP -p $DEBUG_PORT"
echo ""
echo "To check the status of the primary SSH server:"
echo "  sudo systemctl status ssh"
echo ""
echo "To check the status of the debug SSH server:"
echo "  ps aux | grep sshd"
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