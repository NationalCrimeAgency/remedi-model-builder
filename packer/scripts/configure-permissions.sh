#!/bin/bash

echo "Making scripts executable"

sudo chmod +x /opt/model-builder/training/prepare_data.sh
sudo chmod +x /opt/model-builder/training/build_models.sh
sudo chmod +x /opt/model-builder/training/tune_models.sh