# SWOWEN-2018
Import, preprocessing, and basic analysis pipeline for the English [Small World of Words project](https://smallworldofwords.org/project/)




## Getting started
In addition to the scripts, you will need to retrieve the word association data.
These can be found on the Small World of Words [research page](https://smallworldofwords.org/project/research/). Choose the English data (the Dutch data still need to be updated to be used with an R pipeline).


## Participant data
The datafile consists of participant information about age, gender, native language and location.
For a subset of the data, we also provided information about education (we only started collecting this later on).

* `participantID`: unique identifier for the participant
* `age`: age of the participant
* `gender`: gender of the participant (female / male / X)
* `nativeLanguage`: native language (from dropdown menu)
* `education`: native language (from dropdown menu)
* `city`: native language (from dropdown menu)
* `region`: native language (from dropdown menu)
* `country`: native language (from dropdown menu)




## Word association data
The raw data consist of the original responses and spell checked responses. The spell-checked was performed at the server side and for now this script is not included in the current repository.
However, you can find a list spelling corrections and English capitalized words in the `./data` subdirectory.

* `cue`: cue word
* `response`: participant response (includes Unknown and Missing responses)
* `section`: identifier for the snowball iteration (e.g. set2017)



## Data format
The csv file consists of the following columns:
* `participantID`: unique identifier for the participant
* `age`: age of the participant
* `gender`: gender of the participant (female / male / X)
* `cue`: cue word
* `response`: participant response (includes Unknown and Missing responses)
* `nativeLanguage`: native language (from dropdown menu)
* `section`: identifier for the snowball iteration (e.g. set2017)
* `RPOS`: Response position (first response R1, second response R2, or third response R3)


## Pipeline
* `importdata`: import the raw data and convert to a graph
* `similarityFunctions`: calculate distributional overlap measures
* `assoWeightFunctions`: calculate associative strength measures
