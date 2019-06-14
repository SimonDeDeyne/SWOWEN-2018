# Calculate network statistics 
#
# Two output files are created, one for the network with all three associative responses (R123)
# and one with only the first response.
#
# Datafiles are not part of this distribution and should be downloaded from the SWOW website
# https://smallworldofwords.org/project/research/
#
# Last changed 10/05/2019, Simon De Deyne (simon2d@gmail.com)


require(tidyverse)
require(igraph)
require(Matrix)
source('./R/functions/importDataFunctions.R')
source('./R/functions/networkFunctions.R')

SWOWDir           = '../complete/data/processed'
dataFile           = paste0(SWOWDir,'/2018/SWOW-EN.R100.csv','')
outputFile.R123    = '../complete/output/2019/SWOW-EN.R123.networkstatsB.csv'
outputFile.R1      = '../complete/output/2019/SWOW-EN.R1.networkstatsB.csv'
compFile.R123      = '../complete/output/2019/SWOW-EN.R123.strongcomponent.removedvertices.csv'

# R123 (All three responses, equally weighted)
# Read the data
X.R123 = importDataSWOW(dataFile,'R123')

# Extract unimodal graph (strong component)
G = list(); compResults = list(); results = list()

G$R123            = createGraph(X.R123)
compResults$R123  = extractComponent(G$R123,'strong')
G$R123.strong     = compResults$R123$subGraph
write.csv(compResults$R123$removedVertices,compFile.R123)

results$R123$removeVertices = compResults$R123$removedVertices
results$R123$maxSize = compResults$R123$maxSize

# Convert frequencies to strengths
G$R123.strong = normalizeEdgeWeights(G$R123.strong)

# Calculate network centrality measures
networkstats       = list()
networkstats$k_in  = degree(G$R123.strong, v = V(G$R123.strong), mode = "in", loops = FALSE, normalized = FALSE)
networkstats$s_in  = strength(G$R123.strong, v = V(G$R123.strong), mode = "in", loops = FALSE)

# Betweenness considers weights to be distances, so we need to inverse these...
G2 = list();
G2$R123.strong = G$R123.strong
E(G2$R123.strong)$weight = 1 - E(G2$R123.strong)$weight
networkstats$between = betweenness(G2$R123.strong,directed = TRUE,normalized = TRUE)


networkstats$cue = names(networkstats$k_in)
networkstats = as.tibble(networkstats)
networkstats = networkstats %>% select(cue,k_in,s_in,between)
write.csv(networkstats,outputFile.R123)

# R1 (First response only)
X.R1 = importDataSWOW(dataFile,'R1')

# Extract unimodal graph (strong component)
G = list(); compResults = list()

G$R1            = createGraph(X.R1)
compResults$R1  = extractComponent(G$R1,'strong')
G$R1.strong     = compResults$R1$subGraph

results$R1$removeVertices = compResults$R1$removedVertices
results$R1$maxSize = compResults$R1$maxSize

# Convert frequencies to strengths
G$R1.strong = normalizeEdgeWeights(G$R1.strong)


# Calculate network centrality measures
networkstats       = list()
networkstats$k_in  = degree(G$R1.strong, v = V(G$R1.strong), mode = "in", loops = FALSE, normalized = FALSE)
networkstats$s_in  = strength(G$R1.strong, v = V(G$R1.strong), mode = "in", loops = FALSE)

# Betweenness considers weights to be distances, so we need to convert these...
G2 = list();
G2$R1.strong = G$R1.strong
E(G2$R1.strong)$weight = 1 - E(G2$R1.strong)$weight
networkstats$between = betweenness(G2$R1.strong,directed = TRUE,normalized = TRUE)


networkstats$cue = names(networkstats$k_in)
networkstats = as.tibble(networkstats)
networkstats = networkstats %>% select(cue,k_in,s_in,between)

write.csv(networkstats,outputFile.R1)


