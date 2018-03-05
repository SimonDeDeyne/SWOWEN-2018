
createGraph <- function(X){
  # Generate graphs
  ## Create a bipartite (digraph) graph
  Edges       = computeEdgeTable(X)
  G.digraph   = graph_from_data_frame(d = Edges, directed = T)

  ## Transform the bipartite graph to a unipartite graph by removal of nodes with outdegree = 0
  G.raw       = delete_vertices(G.digraph,igraph::V(G.digraph)[degree(G.digraph,mode = 'out') ==0])
  G.raw       = simplify(G.raw,remove.multiple = F, remove.loops = T)

  return(G.raw)
}

# normalize the edge weights to strengths
normalizeEdgeWeights =  function(G){
  E(G)$weight = E(G)$weight / strength(G, mode="out")[get.edgelist(G)[,1]]
  return(G)
}

computeEdgeTable <- function(X){
  if('Freq' %in% colnames(X))
    Edges = X %>% select(cue,response,Freq)
  else{
    Edges = X %>% filter(complete.cases(response)) %>% group_by(cue,response) %>% summarise(weight = n()) %>% select(cue,response,weight)
  }

  colnames(Edges) = c('source','target','weight')
  return(Edges)
}

extractComponent <- function(G,mode = c("weak","strong")){

  comp            = components(G, mode = mode)
  maxComp         = which(comp$csize==max(comp$csize))
  maxSize         = max(comp$csize)
  componentSizes  = comp$csize
  removedVertices = names(which(comp$membership!=maxComp))
  subGraph        = delete_vertices(G,which(comp$membership != maxComp ))

  result = list("maxComp" = maxComp, "maxSize" = maxSize,
                "componentSizes" = componentSizes,"removedVertices" = removedVertices,
                "subGraph" = subGraph)
  return(result)

}

# Summarise network (Note: many of these functions differ in terms of being weighted or not)
getNetworkStats <- function(G){
  networkstats                 = list()
  networkstats['transitivity'] = transitivity(G,'global')
  networkstats['diameter']     = diameter(G,weights=NA) # 41 for R1
  networkstats['mDist']        = mean_distance(G, directed = TRUE, unconnected = TRUE)
  networkstats['density']      = edge_density(G,loops=F)*100
  networkstats['reciprocity']  = reciprocity(G)
  networkstats['issimple']     = is.simple(G)
  networkstats['ecount']       = ecount(G)
  networkstats['vcount']       = vcount(G)
  networkstats['directed']     = is.directed(G)


  networkstats['k_in']         = mean(degree(G, v = V(G), mode = "in", loops = FALSE, normalized = FALSE))
  networkstats['k_out']        = mean(degree(G, v = V(G), mode = "out", loops = FALSE, normalized = FALSE))
  networkstats['s_in']         = mean(strength(G, v = V(G), mode = "in", loops = FALSE))
  networkstats['s_out']        = mean(strength(G, v = V(G), mode = "out", loops = FALSE))

  ## Add community detection
  cl.walktrap   = cluster_walktrap(G, steps = 5)
  networkstats['modularity_walktrap']   = modularity(cl.walktrap)

  # Get the number of components and the size of the largest strongly connected component
  C = components(G,mode='strong')
  networkstats['n_strong_comp'] = C$no
  networkstats['max_strong_comp'] = max(C$csize)

  return(networkstats)
}


# Get the entropy of the responses over the cue distribution
getEntropy <- function(X,type){

  if(!"Freq" %in% colnames(X)){
    X  = X %>% filter(complete.cases(response)) %>% group_by(cue,response)  %>% summarise (Freq = n())
  }

  X$cue           = factor(X$cue)
  X$response      = factor(X$response)
  S               = sparseMatrix(i = as.numeric(X$cue),j = as.numeric(X$response), x = X$Freq)

  switch(type,
         cues = {
           H           = pbapply(S,1,entropy,simplify = F)
           labels      = X %>% group_by(cue) %>% summarise()
         },
         response ={
           H          = pbapply(S,2,entropy,simplify = F)
           labels     = X %>% group_by(response) %>% summarise()
         })
  H           = cbind(labels,H)
  return(H)
}

thresholdStrength = function(G,minStrength,maxStrength){
  G2 <- delete.edges(G, which(E(G)$weight < minStrength))
  G2 <- delete.edges(G2, which(E(G2)$weight > maxStrength))
  G2 <- delete.vertices(G2,which(degree(G2)<1))

  return(G2)
}

writeAdjacency = function(G,dataset){
  labs                = igraph::V(G)$name
  rc                  = as_edgelist(G,names=F)
  df                  = cbind(rc,E(G)$weight)
  write.table(df,file = paste(dataset,'_adj.tsv',sep=''),sep = '\t',row.names = F,col.names = F)
  write.table(labs,file = paste(dataset,'_labels.txt',sep=''),sep = '\t',row.names = F,col.names = F, quote = F)
}
