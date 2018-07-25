# Weight graph based on strength, PPMI or Katz Walks (RW using PPMI)
weightMatrix = function(X,weight,alpha){
  G     = createGraph(X)
  comp  = extractComponent(G,'strong')
  G     = comp$subGraph
  P     = as_adjacency_matrix(G,attr='weight',names = TRUE)
  P     = normalize(P,'l1')

  switch(weight,
         strength = {
           #message('calculating strength')
         },
         PPMI = {
           #message('calculating PPMI')
           P     = PPMI(P)
           P     = normalize(P,'l1')
         },
         RW   = {
           #message('calculating RW')
           P     = PPMI(P)
           P     = normalize(P,'l1')
           P     = katzWalk(P,alpha)
           P     = PPMI(P)
           P     = normalize(P,'l1')
         }
  )

  return(P)
}


# Normalize sparse matrices (to use with random walk representations)
# taken from https://github.com/dselivanov/text2vec/blob/master/R/utils_matrix.R
normalize = function(m, norm = c("l1", "l2", "none")) {
  norm = match.arg(norm)

  if (norm == "none")
    return(m)

  norm_vec = switch(norm,
                    l1 = 1 / rowSums(m),
                    l2 = 1 / sqrt(rowSums(m ^ 2))
  )
  # case when sum row elements == 0
  norm_vec[is.infinite(norm_vec)] = 0

  if(inherits(m, "sparseMatrix"))
    Diagonal(x = norm_vec) %*% m
  else
    m * norm_vec
}

PPMI = function(P){
  N   = dim(P)[1]
  D   = Diagonal(x = 1/(colSums(P)/N))
  P   = P %*% D
  P@x = log2(P@x)
  P2  = pmax(P,0)
  return(P2)
}


# Add indirect paths using Katz walks
# Note: this function is very slow in R! Use matlab script instead
katzWalk = function(G,alpha){
  I = diag(1, dim(G)[1]);
  K = solve(I - alpha*G)
  K@Dimnames = G@Dimnames
  return(K)
}

# Matrix cosine similarity
cosineMatrix = function(G){
  if(class(G) == 'dgeMatrix' || class(G) == 'dgCMatrix'){
    Gn = normalize(G,norm = 'l2')
    S = tcrossprod(Gn)
    S = as.array(S)
    return(S)
  }
  else{
    warning('G should be a dgeMatrix or a dgCMatrix')
  }
}

# For large matrices consider calculating cosine similarity for pairs of rows
cosineRows = function(a,b){
  s = (a/norm(as.matrix(a),type = 'f')) %*% (b/norm(as.matrix(b),type = 'f'))
  return(s)
}

constructSimilarityMatrix = function(X,weight,alpha){
  G     = createGraph(X)
  comp  = extractComponent(G,'strong')
  G     = comp$subGraph
  P     = as_adjacency_matrix(G,attr='weight',names = TRUE)
  P     = normalize(P,'l1')

  switch(weight,
         strength = {
           #message('calculating strength')
         },
         PPMI = {
           #message('calculating PPMI')
           P     = PPMI(P)
           P     = normalize(P,'l1')
         },
         RW   = {
           #message('calculating RW')
           P     = PPMI(P)
           P     = normalize(P,'l1')
           P     = katzWalk(P,alpha)
           P     = PPMI(P)
           P     = normalize(P,'l1')
         }
  )

  S     = cosineMatrix(P)
  return(S)
}

lookupSimilarityMatrix = function(S,X){
  v = rep(NaN,dim(X)[1])
  labels = dimnames(S)[[1]]

  for( i in 1:dim(X)[1]) {
    w_a = X$WordA[i]
    w_b = X$WordB[i]
    if(w_a %in% labels && w_b %in% labels){
      v[i] =  S[w_a,w_b]
    }
  }
  return(v)
}

