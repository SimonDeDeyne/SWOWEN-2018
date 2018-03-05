# SWOWAnalysis
Import, preprocessing and basic analysis pipeline for Small World of Words data.

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


## Functions
* `importdata`: import the raw data and convert to a graph
* `similarityFunctions`: calculate distributional overlap measures
* `assoWeightFunctions`: calculate associative strength measures

## Analyses
### Network analysis
Calculate basic network statistics
* Network diameter
* Network average path length

# SWOWEN-2018
