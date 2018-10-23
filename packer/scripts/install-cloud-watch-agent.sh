#!/bin/sh
set -e

echo "Installing dependencies for Amazon CloudWatch Agent"
sudo apt-get install unzip

echo "Downloading Amazon CloudWatch Agent Installer"
cd /tmp

sudo mkdir AmazonCloudWatchAgentInstaller

sudo chmod 777 ./AmazonCloudWatchAgentInstaller

cd ./AmazonCloudWatchAgentInstaller

sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip

sudo unzip AmazonCloudWatchAgent.zip

sudo rm -f AmazonCloudWatchAgent.zip

echo "Installing Amazon CloudWatch Agent"

sudo ./install.sh

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a stop

echo "Configuring Amazon CloudWatch Agent"

cd /tmp

sudo rm -f /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml
sudo rm -f /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sudo mv ./cloud-watch-agent-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sudo /opt/aws/amazon-cloudwatch-agent/bin/config-translator --input /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json --output /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml --mode ec2 --config /opt/aws/amazon-cloudwatch-agent/etc/common-config.toml

echo "Enabling Amazon CloudWatch Agent"
sudo systemctl enable amazon-cloudwatch-agent