#!/bin/bash

# Update system and install dependencies
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk git

# Clone the repository
sudo -u $APP_USER git clone https://github.com/spring-projects/spring-petclinic.git $PROJECT_DIR

# Build the application
cd $PROJECT_DIR
sudo -u $APP_USER ./mvnw package

# Move the JAR file to APP_DIR
sudo -u $APP_USER cp $PROJECT_DIR/target/*.jar $APP_DIR/

# Create a systemd service to run the application
cat <<EOF | sudo tee /etc/systemd/system/petclinic.service
[Unit]
Description=PetClinic Application
After=network.target

[Service]
User=$APP_USER
EnvironmentFile=/etc/environment
ExecStart=/usr/bin/java -jar $APP_DIR/spring-petclinic-*.jar
SuccessExitStatus=143
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable petclinic
sudo systemctl start petclinic