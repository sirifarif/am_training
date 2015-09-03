## Acoutic model adaptation recipe using sphinx 
####(the instructions in this readme file are valid for Mac and *nix OS). For detail instructions [see here](http://cmusphinx.sourceforge.net/wiki/tutorialam)

## Preparatioin:
1. After checking out this repository you have to get the contents of three submoodules i.e sphinxtrain, sphinxbase and pocketsphinx

2. Inside am_training dir, use the command

    1. `git submodule update --init `
    
3. Now you have to install all the three submodules. For Mac/*nix systems, its the following commads.
    1. `./autogen.sh`
    2. `./configure.sh`
    3. `make`
    4. `make install`
4. If you get errors for any of these commands, then consult the **README** file in the corresponding direcotry/submodule.

5. Before running the **adaptation** commnad in next step, please run the following commands in the EllaVator project. This is for getting the audio data. 

    `./gradlew extractAudio`
    
     `./gradlew extractNoisyAudio`   

  
7. cd to **elevator** direcotry inside **am_training** direcotory and run the following scripts.
    1. `./run_adaptation map both`

8. We can use either **map** or **mllr** as adaptation method and **noise** **close** or **both** for choosing the data for adaptation.

8. But the **map** method is currently working correctly with our data. 

