getCoverage <- function(G){
  s_out = as.data.frame(strength(G,mode='out'))
  colnames(s_out) <-c('coverage')
  
  X.coverage =tibble::rownames_to_column(s_out,var ='cue')
  return(X.coverage)
}

# Coverage refers to the proportion of tokens remaining in the cue x cue graph G.raw
# Note the corrections for the totals in calculating the coverage
# for R1, R12 or R123 (identified by Missing_R2,Missing_R3)
addCoverage <- function(G,Cues){
  X.coverage = getCoverage(G)
  M          = Cues$Unknown
  N          = 100
  
  if('Missing_R2' %in% colnames(Cues)){
    M = M + Cues$Missing_R2
    M = M + Cues$Unknown
    N = N + 100
  }
  
  if('Missing_R3' %in% colnames(Cues)){
    M = M  + Cues$Missing_R3
    M = M + Cues$Unknown
    N = N + 100
  }
  Cues$M  = M
  #colnames(M) <-c('N')
  tmp = merge(X.coverage,Cues)
  
  tmp$coverage =tmp$coverage / (N - tmp$M)
  return(tmp)
}

# might be usefull to plot as cumulative plot
plotCoverage <- function(V.coverage){
  
  p = ggplot(data=Cues,aes(Cues$coverage)) +
    geom_histogram(aes(y = ..density..),col="white",alpha=0.4) +
    geom_vline(data = Cues, aes(xintercept=median(coverage),colour='red'),linetype='solid',size=1) +
    labs(x="Response Coverage", y="density") +
    #xlim(c(30,100)) +
    theme(legend.position="none")
  
  return(p)
}
