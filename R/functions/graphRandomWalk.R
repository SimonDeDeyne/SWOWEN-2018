## Spreading activation using Katz walks
# The following script computes a random walk similar to the Katz 
# centrality procedure (see for example Newman (2010) "Networks An Introduction"
# to provide a simple implementation of spreading activation.
# It depends on a single paramter alpha, which determines the contribution
# of longer paths (values of alpha should be > 0 and < 1). 
#
# It will create a path-augmented graph G.rw, which include weighted sum
# of all potential paths. This new graph can then be used to derive
# similarities from.  Pointwise mutual information is used to weigh 
# associative response frequency. 
# For more information see De Deyne, Navarro, Perfors &  Storms (2018).
#
# Input: 
# The input should be an adjacency file formatted as i j f, where i and j 
# refer to a cue and response coordinate, and f to the frequency of 
# response j to cue i
# In addition, a file with labels should also be provided where the labels
# correspond to the indices i and j in the adjacency file
#
# Typically the graph corresponding to the adjacency matrix is restricted 
# to the largest strongly connected component and loops are removed
# Output: 
# G.rw: graph with indirect paths, renormalized and ppmi weighted
# S.rw: dense similarity matrix for the graph. 
#
# Notes:
# Alpha. Throughout most experiments alpha = .75 performs reasonably well. 
# To control degrees of freedom this has been taken as a default.
#
# PPMI. PPMI is known to have a bias for rare events, which does not affect
# typical word associations graphs with n < 12,000 words, but becomes
# a concern for larger graphs (Turney & Pantel, 2010). 
# In such cases, weighted PPMI versions can be considered (see for example
# Levy,Goldberg & Dagan, 2015, p 215)
#
# S.rw: calculating the cosine similarity for all possible pairwise combinations
# is memory intensive, only consider doing this when your system has
# sufficient RAM. Otherwise, consider multiplying vectors instead.
#
# Total processing time on an i7 with 32Gb is about 96 seconds.
#
# References:
# De Deyne, S., Navarro, D., Perfors, A., Storms, G. (2016). Structure at 
# every scale: A semantic network account of the similarities between 
# unrelated concepts. Journal of Experimental Psychology. 
# General, 145, 1228-1254.
#
# Levy, O., Goldberg, Y., & Dagan, I. (2015). Improving distributional 
# similarity with lessons learned from word embeddings. Transactions of the 
# Association for Computational Linguistics, 3, 211-225.
#
# Newman, M. (2010). Networks: an introduction. Oxford university press.
#
# Turney, P. D., & Pantel, P. (2010). From frequency to meaning: 
# Vector space models of semantics. Journal of artificial intelligence 
# research, 37, 141-188.
#
# Questions / comments: 
# Simon De Deyne, simon2d@gmail.com
# Last changed: 16/05/2018
#
# See creataeRandomWalk.m for a more efficient version

require(Matrix)
require(tictoc)
require(tidyverse)
require(igraph)


rm(list = ls())
setwd("/media/simon/Data/Dropbox/Scripts/R/SWOWGIT/SWOWEN-2018/")
source('./R/functions/importDataFunctions.R')
source('./R/functions/networkFunctions.R')
source('./R/functions/similarityFunctions.R')


# Construct similarity matrices for SWOW based on the primary (R1) responses 
# or choose 'R123' to include all responses

# default value for alpha 
alpha = 0.75

# Load the data 
dataFile.SWOWEN     = './data/processed/SWOW-EN.R100.csv'
SWOW.R1             = importDataSWOW(dataFile.SWOWEN,'R1')

# Generate the weighted graphs
G                   = list()
G$R1$Strength       = weightMatrix(SWOW.R1,'strength')
G$R1$PPMI           = weightMatrix(SWOW.R1,'PPMI')

tic()
G$R1$RW             = weightMatrix(SWOW.R1,'RW',alpha)
toc()

# Compute the cosine similarity matrix
S = cosineMatrix(G$R1$PPMI)

