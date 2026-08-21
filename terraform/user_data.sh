#!/bin/bash

# Update system
dnf update -y

# Install required packages
dnf install -y git python3.11 python3.11-pip

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

# Ensure application files belong to ec2-user
chown -R ec2-user:ec2-user /home/ec2-user/FoodOps