#!/bin/bash

MOSES_PATH=/opt/model-builder/mosesdecoder
PROCESSOR_PATH=/opt/model-builder/jars/processor.jar
OVERSAMPLE=3
SHRINK=0.75

start=`date +%s`

##############

echo "Preparing BG files"

###

rm -Rf prep_bg_data clean_bg_data_1 clean_bg_data_2 shrunk_bg_data
mkdir prep_bg_data clean_bg_data_1 clean_bg_data_2 shrunk_bg_data

echo "Tokenising and transliterating BG files"

for f in bg_data/*; do

echo "Tokenising and transliterating BG file $f..."
java -Xmx50g -cp $PROCESSOR_PATH uk.gov.nca.remedi.PrepareTrainingData -t -i $f -o prep_$f

done

###

echo "Cleaning BG files"

for f in prep_bg_data/*.en; do

echo "Cleaning BG file $f..."
file_root=$(echo $f | cut -c 14- | rev | cut -c 4- | rev)
java -Xmx50g -cp $PROCESSOR_PATH uk.gov.nca.remedi.CleanParallelCorpus -i prep_bg_data/$file_root -o clean_bg_data_1/$file_root -l1 $LANGUAGE -l2 en
$MOSES_PATH/scripts/training/clean-corpus-n.perl clean_bg_data_1/$file_root en $LANGUAGE clean_bg_data_2/$file_root 1 100

done

###

echo "Shrinking BG files"

for f in clean_bg_data_2/*; do

echo "Shrinking BG file $f..."
file_root=$(echo $f | cut -c 17- | rev | cut -c 4- | rev)
java -Xmx50g -cp $PROCESSOR_PATH uk.gov.nca.remedi.ShrinkParallelCorpus -i clean_bg_data_2/$file_root -o shrunk_bg_data/$file_root -l1 $LANGUAGE -l2 en -p $SHRINK

done

###

echo "Done preparing BG files"

##############

echo "Preparing FG files"

###

rm -Rf prep_data clean_data_1 clean_data_2
mkdir prep_data clean_data_1 clean_data_2

echo "Tokenising and transliterating FG files"

for f in data/*; do

echo "Tokenising and transliterating FG file $f..."
java -Xmx50g -cp $PROCESSOR_PATH uk.gov.nca.remedi.PrepareTrainingData -t -i $f -o prep_$f

done

###

echo "Cleaning FG files"

for f in prep_data/*.en; do

echo "Cleaning FG file $f..."
file_root=$(echo $f | cut -c 11- | rev | cut -c 4- | rev)
java -Xmx50g -cp $PROCESSOR_PATH uk.gov.nca.remedi.CleanParallelCorpus -i prep_data/$file_root -o clean_data_1/$file_root -l1 $LANGUAGE -l2 en
$MOSES_PATH/scripts/training/clean-corpus-n.perl clean_data_1/$file_root en $LANGUAGE clean_data_2/$file_root 1 100

done

###

echo "Done preparing FG files"

##############

echo "Combining files"

###

echo "Combining and deduplicating BG files"

cat shrunk_bg_data/*.en > bg_data.en
cat shrunk_bg_data/*.$LANGUAGE > bg_data.$LANGUAGE

java -Xmx50g -cp $PROCESSOR_PATH uk.gov.nca.remedi.CleanParallelCorpus -i bg_data -o data -l1 $LANGUAGE -l2 en

rm -Rf bg_data.en
rm -Rf bg_data.$LANGUAGE

###

echo "Combining and deduplicating FG files"

cat clean_data_2/*.en > fg_data.en
cat clean_data_2/*.$LANGUAGE > fg_data.$LANGUAGE

java -Xmx50g -cp $PROCESSOR_PATH uk.gov.nca.remedi.CleanParallelCorpus -i fg_data -o fg_data_dedup -l1 $LANGUAGE -l2 en

rm -Rf fg_data.en
rm -Rf fg_data.$LANGUAGE

###

echo "Merging FG data with BG (with oversampling)"

for i in 1..$OVERSAMPLE; do

cat fg_data_dedup.en >> data.en
cat fg_data_dedup.$LANGUAGE >> data.$LANGUAGE

done

rm -Rf fg_data_dedup.en
rm -Rf fg_data_dedup.$LANGUAGE

###

echo "Finalising files"

cp data.en lm_data.en

echo "UNK" >> data.en
echo "<s>" >> data.en
echo "</s>" >> data.en

echo "UNK" >> data.$LANGUAGE
echo "<s>" >> data.$LANGUAGE
echo "</s>" >> data.$LANGUAGE

echo "Done combining files"

##############

end=`date +%s`
runtime=$((end-start))
echo "Finished preparing training data in $runtime seconds"
