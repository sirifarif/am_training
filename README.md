# Acoutic model training using sphinx (valid for Mac and *nix OS)
***
> For detail instructions [see here](http://cmusphinx.sourceforge.net/wiki/tutorialam)

## Preparatioin:
1. After chekking out this repository you have to get the contents of three submoodules i.e sphinxtrain, sphinxbase and pocketsphinx

2. Inside am_training dir, use the command

    git submodule update --init 
    
3. Now you have to install all the three submodules. For Mac/*nix systems, its the following commads.
    1. `./autogen.sh`
    2. `./configure.sh`
    3. `make`
    4. `make install`
  
4. Now for running the training scripts, run the following commands inside am_traning dir.
    1. `sphinxtrain -t ellavator setup`

## Running training
5. cd to "am_training/ellavator" dir and run the following command
    6. `sphinxtrain run`    //The training should starts now, takes time for large corpus in "wav" dir
