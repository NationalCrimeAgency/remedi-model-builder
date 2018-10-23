#!/bin/bash
set -euxo pipefail

echo "Installing build tools for Moses"
sudo apt-get install -y build-essential git-core pkg-config automake libtool wget zlib1g-dev python-dev libbz2-dev cmake libboost-all-dev zip

# Setup directories
cd /opt
sudo mkdir model-builder
sudo chmod 777 model-builder
cd model-builder

mkdir training

# Install Moses
echo "Downloading source for Moses"
git clone https://github.com/moses-smt/mosesdecoder.git
cd mosesdecoder

echo "Building Moses"
make -f contrib/Makefiles/install-dependencies.gmake

./compile.sh

# Install MGIZA
echo "Downloading source for MGiza"
cd ..
git clone https://github.com/moses-smt/mgiza.git
cd mgiza/mgizapp

echo "Building MGiza"
cmake .
make
make install

echo "Installing MGiza"
mv bin/symal bin/mgiza_symal
cp bin/* ../../mosesdecoder/bin
cp scripts/merge_alignment.py ../../mosesdecoder/bin