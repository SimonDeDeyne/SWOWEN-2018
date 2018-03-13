# Short explanation about the measures included in the summary files

## responseStats.SWOW-EN.csv
*Response*: the spelling-corrected Americanized response

*Freq.R1*: the number of occurrences of all first (R1) responses summed over all cues 

*Types.R1*: the number of unique cues for which the first (R1) response is generated

*Freq.R123*: the number of occurrences of all first, second and third (R123) responses summed over all cues 

*Types.R123*: the number of unique cues for which the responses (R123) is generated

## cueStats.SWOW-EN.R1.csv
Note: the cue statistics are calculated for cues that are part of the largest connected component.
This excludes a small number of cues. More information is available in the submitted article.
All cue statistics are based on exactly 100 R1 responses given for each individual cue.

*Coverage*: Percentage of responses that are retained in the unimodal cue x cue graph. This number reflects the loss of 
data when responses that do not appear as a cue are removed. It thus reflects the degree of censoring for a particular cue

*H*: Shannon entropy for the response distribution of a particular cue.

*Unknown*: number of times a word was indicated as unknown (out of 100)

*N*: the total number of responses

## cueStats.SWOW-EN.R123.csv
Similar to above, except that all metrics are calculated over R123 (i.e. exactly 300 responses per cue).
More cues are included in this file as the one above reflecting slight differences in the size of the connected component.

*xR2*: The number of times no R2 or R3 were given. Participants indicated this by pressing a "No more responses" button. This can be taken as an indication of the depth of knowledge for this cue.

*xR3*: The number of times no R3 were given. The interpretation is similar as above.