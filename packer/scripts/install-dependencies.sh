#!/bin/sh
set -e

echo "Updating apt and patching"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -f -yq --force-yes

apt-cache search openjdk

echo "Installing Java 11"
sudo apt-get install -y openjdk-11-jdk

echo "Installing Python/Pip"
sudo apt-get install -y python3-pip
sudo pip3 install pip --upgrade

echo "Installing awscli"
sudo pip3 install awscli --upgrade