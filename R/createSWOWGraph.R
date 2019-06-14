# Description:
#
# Load English Small world of words data (https://smallworldofwords.org/)
# The input file consists of responses after spell checking and normalizing the tokens (Americanized)
# This script also removes cues that are British variants when an American one is available
#
# For each cue a total of 300 responses are available, consisting of 100 first, 100 second and 100 third responses
#
# The edge weights in the unimodal graph G.raw
# correspond to associative strength p(response|cue) after removing missing and unknown word responses
#
# Note: the data included with this script cannot be distributed without prior consent
# Author: Simon De Deyne simon2d@gmail.com
# Last changed: 13 June 2019


library('igraph')
library('Matrix')

results = list()

output.file         = './output/2018/adjacencyMatrices/SWOW-EN.'
report.file         = './output/2018/reports/components.SWOW-EN.rds'

source('settings.R')
source('./R/functions/importDataFunctions.R')
source('./R/functions/networkFunctions.R')


# Import the dataset for R1
dataFile          = './data/2018/processed/SWOW-EN.R100.csv'
response          = 'R1' # Options: R1, R2, R3 or R123
X.R1              = importDataSWOW(dataFile,response)

# Extract unimodal graph (strong component)
G.R1              = createGraph(X.R1)
compResults.R1    = extractComponent(G.R1,'strong')
G.R1.strong       = compResults.R1$subGraph

results$R1$removeVertices = compResults.R1$removedVertices
results$R1$maxSize = compResults.R1$maxSize

# Write adjacency and label files for G.raw
writeAdjacency(G.R1.strong, paste(output.file,response,sep=''))

# Import the dataset for R123
response          = 'R123' # Options: R1, R2, R3 or R123
X.R123            = importDataSWOW(dataFile,response)

# Extract unimodal graph (strong component)
G.R123            = createGraph(X.R123)
compResults.R123  = extractComponent(G.R123,'strong')
G.R123.strong     = compResults.R123$subGraph
results$R123$removeVertices = compResults.R123$removedVertices
results$R123$maxSize = compResults.R123$maxSize



# Write weighted adjacency file
writeAdjacency(G.R123.strong, paste(output.file,response,sep=''))

# Write a summary of the output to an rds file
saveRDS(results,report.file,ascii=TRUE)

# Clean up
rm(list = ls())
