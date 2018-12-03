#!/bin/bash

LANGUAGE=${LANGUAGE}
export LANGUAGE

LANGUAGE_NAME=${LANGUAGE_NAME}
export LANGUAGE_NAME

SHRINK=${LANGUAGE_SHRINK}
export SHRINK

OVERSAMPLE=${LANGUAGE_OVERSAMPLE}
export OVERSAMPLE

# Get background data

mkdir -p /opt/model-builder/training/bg_data
cd /opt/model-builder/training/bg_data

for DATASET in ${DATASETS}; do

  wget -q http://opus.nlpl.eu/download/$DATASET/en-$LANGUAGE.txt.zip
  unzip en-$LANGUAGE.txt.zip
  rm en-$LANGUAGE.txt.zip

done

rm *.ids

# Get foreground data

# Get 'gold' data
mkdir -p /opt/model-builder/training/data
aws s3 sync s3://${GOLD_BUCKET_NAME}/${LANGUAGE}/ /opt/model-builder/training/data

# Get user contributions
mkdir -p /opt/model-builder/training/contributions
aws s3 sync s3://${USER_CONTRIBUTION_BUCKET_NAME}/ /opt/model-builder/training/contributions

java -cp /opt/model-builder/jars/filter.jar uk.gov.nca.remedi.filter.JsonFilter -i /opt/model-builder/training/contributions \
  -o /opt/model-builder/training/data/user-contributions -l ${LANGUAGE} -n ${LANGUAGE_NAME} -c 5

# Train Models
cd /opt/model-builder/training
./prepare_data.sh
./build_models.sh

# Upload S3 models
aws s3 cp /opt/model-builder/training/model.lm s3://${MODEL_BUCKET_NAME}/${LANGUAGE}_en.lm
aws s3 cp /opt/model-builder/training/model.rm s3://${MODEL_BUCKET_NAME}/${LANGUAGE}_en.rm
aws s3 cp /opt/model-builder/training/model.tm s3://${MODEL_BUCKET_NAME}/${LANGUAGE}_en.tm

# Tune Models
./tune_models.sh

# Upload tuning configuration
if [ -s /opt/tuning/server.cfg.best ]; then

sed -i 's/source_lang=Foreign/source_lang=${LANGUAGE_NAME}/g' /opt/tuning/server.cfg.best
aws s3 cp /opt/tuning/server.cfg.best s3://${MODEL_BUCKET_NAME}/${LANGUAGE}_en.cfg

fi

# Pause to give time for the logs to be copied onto Cloudwatch
sleep 60

# Shutdown (terminate)
sudo poweroff