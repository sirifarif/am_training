#!/bin/bash

# This (ele_proj) is the directory of the Ellavator project on the github.
# Change the ele_proj path below to your own project.
# The (etcdir) is the direcotry inside the am_training/ellavator repository
# Change this to your own path.

ele_proj='/Users/arif/workspace/Ellavator_Dir/Ellavator'
etcdir='/Users/arif/workspace/am_training/ellavator/etc'

if [ "$#" -ne 1 ]; then
  echo "==================================="
  echo "Usage: $0 close OR $0 noise OR $0 both" >&2
  echo "==================================="
  exit 1
fi

adapt_data=$1
etcdir='/Users/arif/workspace/am_training/ellavator/etc'

if [ $adapt_data = both ]; then
adapt_data='noise|close'
fi

ln -s $ele_proj/prompts/build/resources/data/ wav

cd wav 

txtids=`ls *.txt | grep 'en' | grep -E $adapt_data | cut -d . -f 1`

echo "==================================="
echo "adaptation on $adapt_data data"
echo "==================================="
fileids=`ls *.wav | grep 'en' | grep -E $adapt_data | cut -d . -f 1`

echo "making fileids file"
rm -rf $etcdir/ellavator_train.fileids
for f in $fileids;do `echo $f >> $etcdir/ellavator_train.fileids`;done;

echo "making training transcription file"
rm -rf $etcdir/ellavator_train.transcription
for f in $txtids;do echo "<s> `cat $f.txt | tr [:upper:] [:lower:]` </s> (${f})" \
>> $etcdir/ellavator_train.transcription;done;

cd ..

echo "data preparation done"