#!/bin/bash

bw ='usr/local/libexec/sphinxtrain/bw'
mllr_solve='/usr/local/libexec/sphinxtrain/mllr_solve'
map_adapt='/usr/local/libexec/sphinxtrain/map_adapt'

fileids='etc/ellavator_train.fileids'
dic='etc/ellavator.dic'
trans='etc/ellavator_train.transcription'

echo "Extract mfcc features from training data"
sphinx_fe -argfile etc/feat.params -samprate 16000 -c $fileids \
		-di . -do . -ei wav -eo mfc -mswav yes
		
echo "Convert model to text format"
pocketsphinx_mdef_convert -text etc/mdef etc/mdef.txt

echo "Run baum welche algorithm"
$bw -hmmdir en-us -moddeffn en-us/mdef.txt -ts2cbfn .ptm. -feat 1s_c_d_dd  \
		-svspec 0-12/13-25/26-38 -cmn current -agc none -dictfn $dic \
		-ctlfn $fileids -lsnfn $trans -accumdir .

echo "MLLR adaptation"
$mllr_solve -meanfn en-us/means -varfn en-us/variances -outmllrfn mllr_matrix -accumdir .

echo "MAP adaptation"
$map_adapt -moddeffn etc/mdef.txt -ts2cbfn .ptm. -meanfn en-us/means -varfn en-us/variances \
		-mixwfn en-us/mixture_weights -tmatfn en-us/transition_matrices -accumdir . -mapmeanfn en-us-adapt/means \
        -mapvarfn en-us-adapt/variances -mapmixwfn en-us-adapt/mixture_weights -maptmatfn en-us-adapt/transition_matrices
        
        