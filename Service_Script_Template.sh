#!/bin/bash
# Exit on error
set -e

echo "Updating the system..."
sudo yum update -y

echo "Creating system user..."
sudo useradd -m -s /sbin/nologin myservice
sudo passwd -d myservice

echo "Preparing installation directories..."
sudo mkdir -p /opt/myservice /opt/myservice-data
sudo chown -R myservice:myservice /opt/myservice /opt/myservice-data

echo "Downloading application..."
cd /opt
sudo curl -L -o myapp.tar.gz https://example.com/myapp.tar.gz

echo "Extracting files..."
sudo tar -xvzf myapp.tar.gz -C /opt/myservice --strip-components=1
sudo chown -R myservice:myservice /opt/myservice

echo "Setting environment variables..."
echo 'run_as_user="myservice"' | sudo tee /opt/myservice/bin/myapp.rc

echo "Creating systemd service..."
sudo tee /etc/systemd/system/myservice.service > /dev/null <<EOF
[Unit]
Description=My Service
After=network.target

[Service]
Type=forking
User=myservice
ExecStart=/opt/myservice/bin/start.sh
ExecStop=/opt/myservice/bin/stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Starting the service..."
sudo chmod +x /opt/myservice/bin/start.sh
sudo systemctl daemon-reload
sudo systemctl enable myservice
sudo systemctl start myservice

echo "Installation complete. Check the app at http://<your-ip>:<port>"