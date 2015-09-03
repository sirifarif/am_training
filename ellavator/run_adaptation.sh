#!/bin/bash

# the executables required for adapting the acoustic model
bw='/usr/local/libexec/sphinxtrain/bw'
mllr_solve='/usr/local/libexec/sphinxtrain/mllr_solve'
map_adapt='/usr/local/libexec/sphinxtrain/map_adapt'

# This (ele_proj) is the directory of the Ellavator project on the github.
# Change the ele_proj path below to your own project.
# The (etcdir) is the direcotry inside the am_training/ellavator repository
# Change this to your own path.

cur_dir=`pwd`
ele_proj='/Users/arif/workspace/Ellavator_Dir/Ellavator'
ac_dir=$ele_proj/'src/main/resources/en-us-adapt/'
etcdir=$cur_dir/'etc'

if [ "$#" -ne 2 ]; then
  echo "==================================="
  echo "Usage: $0 mllr|map close|noise|both " >&2
  echo " "
  echo "Please choose either mllr or map as adaptation method" >&2
  echo "and close, noise or both as data options to use in adaptation" >&2
  echo "==================================="
  exit 1
fi

adapt_method=$1
adapt_data=$2

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

cd $cur_dir

echo "==================================="
echo "data preparation done"
echo "==================================="

fileids=$etcdir/'ellavator_train.fileids'
dic=$etcdir/'ellavator.dic'
trans=$etcdir/'ellavator_train.transcription'

if [ ! -f cmusphinx-en-us-5.2.tar.gz ]; then
rm -rf $cur_dir/en-us && echo "Deleting old model"
echo "Getting the model"
wget http://sourceforge.net/projects/cmusphinx/files/\
Acoustic%20and%20Language%20Models/US%20English%20Generic%20Acoustic%20Model/cmusphinx-en-us-5.2.tar.gz
echo "extracting archive"
tar -xvf cmusphinx-en-us-5.2.tar.gz
mv cmusphinx-en-us-5.2 en-us
fi

echo "==================================="
echo "Extract mfcc features from training data"
echo "==================================="
sphinx_fe -argfile en-us/feat.params -samprate 16000 -c $fileids -di $cur_dir/wav -do $cur_dir/etc -ei wav -eo mfc -mswav yes
		
echo "==================================="		
echo "Convert model to text format"
echo "==================================="
pocketsphinx_mdef_convert -text en-us/mdef en-us/mdef.txt

echo "==================================="
echo "Run baum welche algorithm"
echo "==================================="
 
$bw -hmmdir en-us -moddeffn en-us/mdef.txt -ts2cbfn .cont. -feat 1s_c_d_dd \
		-cmn current -agc none -lda en-us/feature_transform -cepdir etc -dictfn $dic \
		-ctlfn $fileids -lsnfn $trans -accumdir $cur_dir

if [ $adapt_method = mllr ]; then
echo "==================================="
echo "MLLR adaptation"
echo "==================================="
$mllr_solve -meanfn en-us/means -varfn en-us/variances -outmllrfn mllr_matrix -accumdir $cur_dir

fi

if [ $adapt_method = map ]; then

echo "==================================="
echo "MAP adaptation"
echo "==================================="
mkdir -p $cur_dir/en-us-adapt
$map_adapt -moddeffn en-us/mdef.txt -ts2cbfn .cont. -meanfn en-us/means -varfn en-us/variances \
		-mixwfn en-us/mixture_weights -tmatfn en-us/transition_matrices -accumdir $cur_dir -mapmeanfn en-us-adapt/means \
        -mapvarfn en-us-adapt/variances -mapmixwfn en-us-adapt/mixture_weights -maptmatfn en-us-adapt/transition_matrices
fi

cp en-us/feat.params en-us/mdef en-us-adapt/ || exit 1;

cp -r en-us-adapt/. $ac_dir

echo "adapted model ready for use"