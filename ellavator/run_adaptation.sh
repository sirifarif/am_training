#!/bin/bash

bw='/usr/local/libexec/sphinxtrain/bw'
mllr_solve='/usr/local/libexec/sphinxtrain/mllr_solve'
map_adapt='/usr/local/libexec/sphinxtrain/map_adapt'

fileids='etc/ellavator_train.fileids'
dic='etc/ellavator.dic'
trans='etc/ellavator_train.transcription'

echo "Copying old model"
rm -rf en-us && cp -r wsj-mdl/en-us . || exit 1;
echo "==================================="
echo "Extract mfcc features from training data"
echo "==================================="
sphinx_fe -argfile etc/feat.params -samprate 16000 -c $fileids \
		-di . -do . -ei wav -eo mfc -mswav yes
		
echo "==================================="		
echo "Convert model to text format"
echo "==================================="
pocketsphinx_mdef_convert -text en-us/mdef en-us/mdef.txt

echo "==================================="
echo "Run baum welche algorithm"
echo "==================================="
$bw -hmmdir en-us -moddeffn en-us/mdef.txt -ts2cbfn .ptm. -feat 1s_c_d_dd  \
		-svspec 0-12/13-25/26-38 -cmn current -agc none -dictfn $dic \
		-ctlfn $fileids -lsnfn $trans -accumdir .

echo "==================================="
echo "MLLR adaptation"
echo "==================================="
$mllr_solve -meanfn en-us/means -varfn en-us/variances -outmllrfn mllr_matrix -accumdir .

echo "==================================="
echo "MAP adaptation"
echo "==================================="
$map_adapt -moddeffn en-us/mdef.txt -ts2cbfn .ptm. -meanfn en-us/means -varfn en-us/variances \
		-mixwfn en-us/mixture_weights -tmatfn en-us/transition_matrices -accumdir . -mapmeanfn en-us-adapt/means \
        -mapvarfn en-us-adapt/variances -mapmixwfn en-us-adapt/mixture_weights -maptmatfn en-us-adapt/transition_matrices
        
        