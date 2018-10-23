#!/bin/bash

LANGUAGE=${LANGUAGE}
export LANGUAGE

LANGUAGE_NAME=${LANGUAGE_NAME}
export LANGUAGE_NAME

# Get background data

mkdir -p /opt/model-builder/training/bg_data
cd /opt/model-builder/training/bg_data

for DATASET in Books DGT ECB EUbookshop EU Europarl GNOME GlobalVoices JRC-Acquis KDE4 KDEdoc News-Commentary11 OpenOffice OpenSubtitles2018 ParaCrawl PHP SETIMES2 Tatoeba TED2013 Tanzil Ubuntu WikiSource Wikipedia WMT-News; do

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

cd /opt/model-builder/training
./prepare_data.sh
./build_models.sh

# Upload S3 models
aws s3 cp /opt/model-builder/training/model.lm s3://${MODEL_BUCKET_NAME}/${LANGUAGE}_en.lm
aws s3 cp /opt/model-builder/training/model.rm s3://${MODEL_BUCKET_NAME}/${LANGUAGE}_en.rm
aws s3 cp /opt/model-builder/training/model.tm s3://${MODEL_BUCKET_NAME}/${LANGUAGE}_en.tm

# Shutdown (terminate)
sudo poweroff