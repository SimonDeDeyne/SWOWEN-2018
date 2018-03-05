# SWOWEN-2018
Import, preprocessing, and basic analysis pipeline for the English [Small World of Words project](https://smallworldofwords.org/project/)




## Getting started
In addition to the scripts, you will need to retrieve the word association data.
These can be found on the Small World of Words [research page](https://smallworldofwords.org/project/research/). Choose the English data (the Dutch data still need to be updated to be used with an R pipeline).


## Participant data
The datafile consists of participant information about age, gender, native language and location.
For a subset of the data, we also provided information about education (we only started collecting this later on).

* `participantID`: unique identifier for the participant
* `created_at`: time and date of participation
* `age`: age of the participant
* `nativeLanguage`: native language (from dropdown menu)
* `gender`: gender of the participant (Female / Male / X)
* `education`: native language (from dropdown menu)
* `city`: native language (from dropdown menu)
* `country`: native language (from dropdown menu)



## Word association data

### Raw data
The raw data consist of the original responses and spell checked responses. The spell-checked was performed at the server side and for now this script is not included in the current repository.
However, you can find a list spelling corrections and English capitalized words in the `./data` subdirectory.

* `cue`: cue word
* `R1Raw`: raw primary associative response
* `R2Raw`: raw secondary associative response
* `R3Raw`: raw tertiary associative response
* `R1`: corrected primary associative response
* `R2`: corrected secondary associative response
* `R3`: corrected tertiary associative response
* `section`: identifier for the snowball iteration (e.g. set2017)


### Preprocessed data


## Output

## Pipeline
* `importdata`: import the raw data and convert to a graph
* `similarityFunctions`: calculate distributional overlap measures
* `assoWeightFunctions`: calculate associative strength measures
