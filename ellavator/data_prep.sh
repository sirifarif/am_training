#!/bin/bash

# This (ele_proj) is the directory of the Ellavator project on the github.
ele_proj='/Users/arif/workspace/Ellavator_Dir/Ellavator'

ln -s $ele_proj/prompts/build/resources/data/ wav

cd wav 

etcdir='/Users/arif/workspace/am_training/ellavator/etc'
txtids=`ls *.txt | grep 'en' | cut -d . -f 1`
fileids=`ls *.wav | grep 'close' | grep 'en' | cut -d . -f 1`

echo "making fileids file"
rm -rf $etcdir/ellavator_train.fileids
for f in $fileids;do `echo $f >> $etcdir/ellavator_train.fileids`;done;

echo "making training transcription file"
rm -rf $etcdir/ellavator_train.transcription
for f in $txtids;do echo "<s> `cat $f.txt | tr [:upper:] [:lower:]` </s> (${f}_close_16)" \
>> $etcdir/ellavator_train.transcription;done;

cd ..

echo "data preparation done"





