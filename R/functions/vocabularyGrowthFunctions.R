
getVGC = function(response){
  # Derive the vocabulary growth curve
  n         = ceiling(nrow(response)/1000)
  V         = rep(1,n)
  for (i in 1:n){
    rn = 1000*i
    V[i] =  nrow(filter(response,between(row_number(),1,rn)) %>% group_by(response) %>% summarise(F = n()))
  }
  response.vgc   = vgc(N = (1:n)*1000,V = V)
  return(response.vgc)
}
