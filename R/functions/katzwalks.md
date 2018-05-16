

## Spreading activation implementation through weighted Katz walk

The following folder contains two scripts to illustrate a simple implementation of *spreading activation* which allows us to account for weak indirect paths when calculating the semantic similarity of two words.  This is loosely based on the Katz centrality measure discussed in Newman (2010) combined with a pointwise-mutual information weighting scheme to weigh informative edges and avoid frequency biases introduced by the Katz walks. For more information,  see De Deyne, Navarro, Perfors & Storms (2017).

At the moment, two implementations are available, one in R and one in Matlab. The R implementation is *slightly* less efficient and  takes on average 20x longer than the Matlab one. This is likely due to the implementation of the sparse matrix inverse in R, so any suggestions to speed this up in R would be greatly appreciated.

Both examples generate the full 12,000 x 12,000 cosine similarity matrix, which is memory-intensive. If your computer doesn't have  at least 16Gb of RAM, you might consider calculating cosines for individual vectors.

The use of spreading activation also depends on the density of the original graph. Not surprisingly, it will be more useful for the R1 graphs than the R123 because the former is much sparser.



### R implementation

The script [graphRandomWalk.R](graphRandomWalk.R) provides an example starting from the [SWOW-EN.R100.csv](../../data/processed/SWOW-EN.R100.csv) generated data after preprocessing by the [preprocessData](../preprocessData.R) script. 

The function weightMatrix from [similarityFunctions.R](similarityFunctions.R) will derive a cue x cue weighted adjacency matrix from the cue x response matrix using the largest strongest component.



### Matlab implementation

The [graphRandomWalk.m](graphRandomWalk.m) script was tested with Matlab 2017, but should be compatible with most recent versions. It requires a weighted adjacency file and file with corresponding labels. Both files can be easily generated with the writeAdjacency function from `writeAdjacency` in [networkFunctions.R](networkFunctions.R)



### References

[De Deyne, S., Navarro, D., Perfors, A. & Storms, G. (2016). Structure at  every scale: A semantic network account of the similarities between  unrelated concepts. *Journal of Experimental Psychology,  General*, 145, 1228-1254](https://simondedeyne.me/articles/2016.DeDeyneNavarroPerforsStorms.RemoteTriads.JEPGEN.pdf).



