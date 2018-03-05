# SWOWEN-2018
Import, preprocessing, and basic analysis pipeline for the English Small World of Words project




## Getting started
In addition to the scripts, you will need to retrieve the word association data.
These can be found on the Small World of Words [research page](https://smallworldofwords.org/project/research/). Choose the English data (the Dutch data still need to be updated to be used with an R pipeline).


## File format
Raw data is found under ./EN/raw
* participantID: unique identifier for the participant
* age: age of the participant
* gender: gender of the participant (female / male / X)
* cue: cue word
* response: participant response (includes Unknown and Missing responses)
* nativeLanguage: native language (from dropdown menu)
* section: identifier for the snowball iteration (e.g. set2017)
* RPOS: Response position (first response R1, second response R2, or third response R3)


## Pipeline
* `importdata`: import the raw data and convert to a graph
* `similarityFunctions`: calculate distributional overlap measures
* `assoWeightFunctions`: calculate associative strength measures
