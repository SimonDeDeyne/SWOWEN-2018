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
* `nativeLanguage`: native language from a short list of common languages
* `gender`: gender of the participant (Female / Male / X)
* `education`: Highest level of education:  1 = None, 2 = Elementary school, 3 = High School, 4 = College or University Bachelor, 5 = College or University Master
* `city`: city (city location when tested, might be an approximation)
* `country`: country (countr location when tested)



## Word association data

### Raw data
The raw data consist of the original responses and spell checked responses. The spell-checked was performed at the server side and for now this script is not included in the current repository.
However, you can find a list spelling corrections and English capitalized words in the `./data` subdirectory.

* `section`: identifier for the snowball iteration (e.g. set2017)
* `cue`: cue word
* `R1Raw`: raw primary associative response
* `R2Raw`: raw secondary associative response
* `R3Raw`: raw tertiary associative response
* `R1`: corrected primary associative response
* `R2`: corrected secondary associative response
* `R3`: corrected tertiary associative response


### Preprocessed data
The preprocessed data consist of normalizations of cues and responses by spell-checking them, correcting capitalization and Americanizing. This file is generated by the `preprocessData.R` script.

In addition to normalizing cues and responses, this script will also extract a balanced dataset, in which each cue is judged by exactly 100 participants. Because each participant generated three responses, this means each cue has 300 associations. The participants were selected to favor native speakers.


## Graphs
Use `createSWOWENGraph.R` to extract the largest strongly connected component  for graphs based on the first response (R1) or all responses (R123). The results are written to `output/adjacencyMatrices` and consist of a file with labels and a sparse file consisting of three values corresponding to row- and column-indices followed by the association frequencies.
In most cases, associative frequencies will need to be converted to associative strengths by dividing with the sum of all strengths for a particular cue.
Vertices that are not part of the largest connected component are listed in a report in the `output/reports` subdirectory.


## Derived statistics
### Response statistics
Use `createResponseStats.R` to calculate a number of response statistics. Currently the script calculates the number of types, tokens and hapax legomena responses (responses that only occur once). The results can be found in the `output` directory.
### Cue statistics
Use `createCueStats.R` to calculate cue statistics. Only words that are part of the strongly connected component are considered. Results are provided for the R1 graph and the graph with all responses (R123). The file includes the following:

* `coverage`: (how many of the responses are retained in the graph after removing those words that aren't a cue or aren't part of the strongest largest component).
* `H`: Shannon entropy of response distributions for each cue
* `unknown`: the number of unknown responses
* `x.R2`: the number of missing R2 responses
* `x.R3`: the number of missing R3 responses

A histogram of the response coverage for R1 and R123 graphs can be obtained from the script `plotCoverage.R`. Vocabulary growth curves can be obtained with `plotVocabularyGrowth.R`.

### R1 - R2 response chaining
Later responses can be affected by the previous response a participant gave. In general, this is quite rare, but for some cues this effect can be more pronounced. To investigate response chaining, we compare the conditional probabilities of the second response when preceeded with a mediated R1 response with conditional probabilities when R2 is not preceeded by this mediator. 
An example of this analysis is available in `calculateR12ResponseChaining.R`.

## Spelling and lexica
We tried to check the spelling of the most common responses (those occurring at least two times in the data), but it's quite likely that some corrections can be improved and some misspellings are missed. This is where git can make our lives a bit easier. If you find errors, please check the correction file and submit a pull request with additional or ammended corrections.

The spelling list is merged with SUBTLEX-US and words from the VARCON list to obtain an English lexicon file. This file is used check responses at the individual level and remove participants who provide predominantly non-English responses in the `preprocessData.R` script.

