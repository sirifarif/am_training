## Acoutic model training using sphinx 
####(the instructions in this readme file are valid for Mac and *nix OS). For detail instructions [see here](http://cmusphinx.sourceforge.net/wiki/tutorialam)

## Preparation:
1. After checking out this repository you have to get the contents of three submoodules i.e sphinxtrain, sphinxbase and pocketsphinx

2. Inside am_training dir, use the command

    1. `git submodule update --init `
    
3. Now you have to install all the three submodules. For Mac/*nix systems, its the following commads.
    1. `./autogen.sh`
    2. `./configure.sh`
    3. `make`
    4. `make install`
4. If you get errors for any of these commands, then consult the **README** file in the corresponding direcotry/submodule.

## Running training

1. cd to "am_training/ellavator" dir and run the following commands
    1. `sphinxtrain -t ellavator setup`
    2. `sphinxtrain run`    //The training should starts now, takes time for large corpus in "wav" dir
