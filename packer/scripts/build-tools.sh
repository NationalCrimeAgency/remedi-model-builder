#!/bin/bash
set -euxo pipefail

echo "Installing build tools for REMEDI Tools"
sudo apt-get install -y maven

echo "Downloading REMEDI Tools source code"

sudo mkdir -p /opt/build
sudo chmod 777 /opt/build
cd /opt/build

git clone https://github.com/NationalCrimeAgency/remedi-tools.git

echo "Building tools"
cd remedi-tools
mvn clean package

echo "Installing tools"

sudo mkdir -p /opt/model-builder/jars
sudo chmod 777 /opt/model-builder/jars

cp filter/target/filter-*.jar /opt/model-builder/jars/filter.jar
cp processor/target/processor-*.jar /opt/model-builder/jars/processor.jar
cp stanford-truecaser/target/stanford-truecaser-*.jar /opt/model-builder/jars/stanford-truecaser.jar