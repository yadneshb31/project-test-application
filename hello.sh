#!/bin/bash
echo "Hello from Jenkins!"
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx