#!/bin/bash
set -euxo pipefail

echo "Installing build tools for REMEDI"

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

sudo apt-get update

sudo apt-get install -y \
  make \
  git \
  curl

export PATH=$PATH:/usr/bin/cmake/bin

echo "Installing OCAML"

sudo mkdir -p /opt/build /opt/tuning
sudo chmod 777 /opt/build
sudo chmod 777 /opt/tuning
cd /opt/build

wget http://caml.inria.fr/pub/distrib/ocaml-4.04/ocaml-4.04.0.tar.gz
tar -zxvf ocaml-4.04.0.tar.gz
cd ocaml-4.04.0
./configure
make world
make opt
make opt.opt
sudo make install

echo "Downloading REMEDI source code"

cd /opt/build

git clone https://github.com/ivan-zapreev/Distributed-Translation-Infrastructure.git
cd Distributed-Translation-Infrastructure
git checkout a0bd0bd    # Pin to a specific release that we know works

# Currently requires commits that haven't been included in a formal release.
# Once they have, we can just download that release using the code below rather than using git.

#wget https://github.com/ivan-zapreev/Distributed-Translation-Infrastructure/archive/1.8.3.tar.gz
#tar -xzf 1.8.3.tar.gz
#mv Distributed-Translation-Infrastructure-1.8.3 Distributed-Translation-Infrastructure
#cd Distributed-Translation-Infrastructure

echo "Installing MegaM"

cd script/tuning/megam_0.92
make opt
cd ../../..

echo "Installing Perl dependencies for tuning scripts"
sudo apt-get install libperlio-gzip-perl

echo "Enabling Tuning Mode"
sed -i 's/IS_SERVER_TUNING_MODE false/IS_SERVER_TUNING_MODE true/g' inc/server/server_configs.hpp

echo "Building REMEDI"

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release ..
make -j 8