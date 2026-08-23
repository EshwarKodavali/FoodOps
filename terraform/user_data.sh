#!/bin/bash

# Update system
dnf update -y

# Install required packages
dnf install -y git python3.11 python3.11-pip nginx certbot python3-certbot-nginx

# Go to home directory
cd /home/ec2-user

# Clone FoodOps
git clone https://github.com/EshwarKodavali/FoodOps.git

# Change ownership
chown -R ec2-user:ec2-user /home/ec2-user/FoodOps

# Go into application
cd /home/ec2-user/FoodOps

# Create virtual environment using Python 3.11
python3.11 -m venv venv

# Install Python dependencies
/home/ec2-user/FoodOps/venv/bin/python -m pip install -r requirements.txt

# --------------------------------------------------
# Create systemd service for Flask
# --------------------------------------------------

cat > /etc/systemd/system/foodops.service <<'EOF'
[Unit]
Description=FoodOps Flask Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/FoodOps
Environment="PATH=/home/ec2-user/FoodOps/venv/bin"
ExecStart=/home/ec2-user/FoodOps/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable foodops
systemctl start foodops

# --------------------------------------------------
# Configure Nginx
# --------------------------------------------------

cat > /etc/nginx/conf.d/foodops.conf <<'EOF'
server {
    listen 80;
    server_name foodops.eshwar.fun;

    location / {
        proxy_pass http://127.0.0.1:5000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Test Nginx
nginx -t

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Ensure application files belong to ec2-user
chown -R ec2-user:ec2-user /home/ec2-user/FoodOps