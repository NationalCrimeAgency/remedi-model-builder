#!/bin/bash

if [ -s /opt/model-builder/training/tuning.fl ]; then

cd /opt/tuning

echo "Starting tuning"
sudo /opt/build/Distributed-Translation-Infrastructure/script/tuning/run_tuning.sh --conf=server.cfg --src=/opt/model-builder/training/tuning.fl --src-language=Foreign --ref=/opt/model-builder/training/tuning.en --trg-language=English --no-parallel=16

echo "Selecting best configuration"
sudo /opt/build/Distributed-Translation-Infrastructure/script/tuning/tuning_progress.pl --conf=server.cfg --err=tuning.log --select=best

else

echo "No foreground data - skipping tuning"

fi

