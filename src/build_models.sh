#!/bin/bash

MOSES_PATH=/opt/model-builder/mosesdecoder

start=`date +%s`

##############

echo "Building language model"

$MOSES_PATH/bin/lmplz -o 5 -S 80% -T /tmp < lm_data.en > model.lm

echo "Done building language model"


##############

echo "Building reordering and translation model"

language_model=$(realpath model.lm)

$MOSES_PATH/scripts/training/train-model.perl -root-dir . -external-bin-dir $MOSES_PATH/bin --corpus data --f $LANGUAGE --e en --mgiza --lm 0:5:$language_model --reordering-smooth 0.5 --reordering distance,msd-bidirectional-fe

echo "Done building reordering and translation model"

##############

echo "Extracting models"

gunzip -k model/reordering-table.wbe-msd-bidirectional-fe.gz
mv model/reordering-table.wbe-msd-bidirectional-fe model.rm

gunzip -k model/phrase-table.gz
mv model/phrase-table model.tm

echo "Done extracting models"

##############

end=`date +%s`
runtime=$((end-start))
echo "Finished building in $runtime seconds"
