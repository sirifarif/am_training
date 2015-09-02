#!/bin/bash

bw='/usr/local/libexec/sphinxtrain/bw'
mllr_solve='/usr/local/libexec/sphinxtrain/mllr_solve'
map_adapt='/usr/local/libexec/sphinxtrain/map_adapt'
cur_dir=`pwd`

if [ "$#" -ne 1 ]; then
  echo "==================================="
  echo "Usage: $0 mllr OR $0 map" >&2
  echo "==================================="
  exit 1
fi

adapt=$1
fileids='etc/ellavator_train.fileids'
dic='etc/ellavator.dic'
trans='etc/ellavator_train.transcription'

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

if [ $adapt = mllr ]; then
echo "==================================="
echo "MLLR adaptation"
echo "==================================="
$mllr_solve -meanfn en-us/means -varfn en-us/variances -outmllrfn mllr_matrix -accumdir $cur_dir

fi

if [ $adapt = map ]; then

echo "==================================="
echo "MAP adaptation"
echo "==================================="
mkdir -p $cur_dir/en-us-adapt
$map_adapt -moddeffn en-us/mdef.txt -ts2cbfn .cont. -meanfn en-us/means -varfn en-us/variances \
		-mixwfn en-us/mixture_weights -tmatfn en-us/transition_matrices -accumdir $cur_dir -mapmeanfn en-us-adapt/means \
        -mapvarfn en-us-adapt/variances -mapmixwfn en-us-adapt/mixture_weights -maptmatfn en-us-adapt/transition_matrices
fi