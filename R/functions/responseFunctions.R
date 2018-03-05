
missingResponses <- function(X,missing,unknown){

  X$cue       = factor(X$cue)
  V           = filter(X, response == unknown & RPOS == 'R1') %>% group_by(cue)  %>% summarise(Unknown = n()) %>% complete(cue) %>% select(cue,Unknown)

  if('R2' %in% levels(X$RPOS)){
    X.Missing_R2 = filter(X, response == missing & RPOS == 'R2') %>% group_by(cue)  %>% summarise(Missing_R2 = n()) %>% complete(cue) %>% select(cue,Missing_R2)
    V = merge(V,X.Missing_R2)
  }

  if('R3' %in% levels(X$RPOS)){
    X.Missing_R3 = filter(X, response == missing & RPOS == 'R3') %>% group_by(cue)  %>% summarise(Missing_R3 = n()) %>% complete(cue) %>% select(cue,Missing_R3)
    V = merge(V,X.Missing_R3)
  }

  V[is.na(V)] = 0

  return(V)
}

getFrequencyTable <- function(X,unknownToken,noMoreToken){
  X          = filter(X, response != unknownToken & response != noMoreToken)
  X$cue      = factor(X$cue)
  X$response = factor(X$response)
  words      = unique(c(levels(X$cue),levels(X$response)))
  X$cue      = factor(X$cue,levels = words)
  X$response = factor(X$response,levels = words)

  # Create a network based on R1, R2 and R3
  Freq      = X %>% select(cue,response,RPOS) %>% group_by(cue,response,RPOS)  %>% summarise (Freq = n())
  Freq      = tidyr::spread(Freq,RPOS,Freq,fill=0)
  return(Freq);
}

countResponses <- function(X){
  C     = X %>% select(cue,response) %>% group_by(cue,response)  %>% summarise (Freq = n())
  return(C)
}


# Get the unique hapax legoma or idiosyncratic responses from C
getHapaxResponses <- function(C){
  X.hapax   = filter(C, Freq == 1) %>% group_by(cue)  %>% summarise(Hapax = n())    %>% select(cue,Hapax)
  return(X.hapax)
}

# Convenience function
addHapaxResponses <- function(X,Cues){
  C = countResponses(X)
  X.hapax = getHapaxResponses(C)
  return(merge(Cues,X.hapax))
}

# Note todo: get trimmed sd
# Note RTS are based on the first response only. They use a  trimmed mean, although the SD is not trimmed.
getAverageRT <- function(C,unknownToken,noMoreToken){
  X.RT   = X %>% filter(!is.na(RT), response != unknownToken & response != noMoreToken & RPOS == 'R1') %>%
                group_by(section,cue) %>%
                summarise(mRT = mean(RT,na.rm=TRUE,trim = 0.10),sdRT = sd(RT,na.rm=TRUE),nRT = n()) %>%
                select(cue,section,mRT,sdRT,nRT)
  return (X.RT)
}

addAverageRT <- function(X,Cues,unknownToken,noMoreToken){
  C     = countResponses(X)
  X.RT  = getAverageRT(C,unknownToken,noMoreToken)
  return(merge(Cues,X.RT))
}


getEntropyResponses <- function(X,unknownToken,noMoreToken){

  if("F" %in% names(X)){
      C = X %>% group_by(cue,response) %>% rename(Freq = F)
  }
  else{
    X           = filter(X, response != unknownToken & response != noMoreToken)
    X$cue       = factor(X$cue)
    X$response  = factor(X$response)
    C           = X %>% select(cue,response) %>% group_by(cue,response)  %>% summarise (Freq = n())

  }
  cueLabels   = C %>% select(cue) %>% group_by(cue) %>% summarise()

  S           = sparseMatrix(i = as.numeric(C$cue),j = as.numeric(C$response), x = C$Freq)
  rownames(S) = cueLabels$cue
  tmp         = pbapply(S,1,entropy)
  H           = data.frame('cue' = names(tmp),'H' = as.vector(tmp))
  return(H)
}



addEntropyResponses <- function(X,Cues,unknownToken,noMoreToken){
  Cues$H = getEntropyResponses(X,unknownToken,noMoreToken)
  return(Cues)
  #return(merge(Cues,H))
}

