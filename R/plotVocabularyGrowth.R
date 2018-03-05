require(tidyverse)
require(svglite)
require(zipfR)

rm(list = ls())
source('./R/functions/importDataFunctions.R')
data.file   = './data/processed/SWOW-EN.R100.csv'


# Derive the vocabulary growth curve
getVGC = function(response){
  n         = ceiling(nrow(response)/10000)
  V         = rep(1,n)
  for (i in 1:n){
    rn = 10000*i
    V[i] =  nrow(filter(response,between(row_number(),1,rn)) %>% group_by(response) %>% summarise(Freq = n()))
  }
  response.vgc   = vgc(N = (1:n)*10000,V = V)
  return(response.vgc)
}


## Load data and shuffle response order
X.R1              = importDataSWOW(data.file,'R1')
X.R1              = X.R1 %>% filter(!is.na(response))
X.R1$response     = X.R1$response[sample(nrow(X.R1))]

# Obtain a frequency spectrum
R1.F          = X.R1 %>%  group_by(response) %>% summarise(Freq = n()) %>% group_by(Freq) %>% summarise(FF = n())
R1.spc        = spc(Vm = R1.F$FF,m=R1.F$Freq)

# Fit the finite zipfian mandelbrot model
R1.fzm        = lnre("fzm", R1.spc, exact = FALSE)
R1.fzm.spc    = lnre.spc(R1.fzm, N(R1.fzm))
summary(R1.fzm)

# Do the same thing for R123
X.R123            = importDataSWOW(data.file,'R123')
X.R123            = X.R123 %>% filter(!is.na(response))
X.R123$response   = X.R123$response[sample(nrow(X.R123))]

# Obtain a frequency spectrum
R123.F        = X.R123 %>%  group_by(response) %>% summarise(Freq = n()) %>% group_by(Freq) %>% summarise(FF = n())
R123.spc      = spc(Vm = R123.F$FF,m=R123.F$Freq)

R123.fzm      = lnre("fzm", R123.spc, exact = TRUE,verbose = TRUE,m.max=11)
R123.fzm.spc  = lnre.spc(R123.fzm, N(R123.fzm))
summary(R123.fzm)

# Obtain empirical growth curve
R1.vgc        = getVGC(X.R1)
R123.vgc      = getVGC(X.R123)

# Plot the empirical VGC against the estimated curve for a maximum of k responses
k             = 5e6
n.R1          = ceiling(nrow(X.R1)/1000)
n.R123        = ceiling(nrow(X.R123)/1000)

R1.fzm.vgc    = lnre.vgc(R1.fzm, (1:n.R1) * ceiling(k/n.R1))
R123.fzm.vgc  = lnre.vgc(R123.fzm, (1:n.R123) * ceiling(k/n.R123))

# Check the legend
svglite('./figures/VocGrowth.svg',width=8,height=6)
plot(R1.fzm.vgc,R1.vgc,R123.fzm.vgc,R123.vgc, N0=c(N(R1.fzm),N(R123.fzm)),
     legend = c('Zipf-Mandelbrot R1','Observed R1','Zipf-Mandelbrot  R123','Observed R123'),bw = TRUE,xlab = "Number of tokens",ylab = "Number of types")
dev.off()

#save(X.R1,X.R123,R1.fzm.vgc,R123.fzm.vgc,R1.vgc,R123.vgc,R1.fzm,R123.fzm,R1.spc,R123.spc,file='./reports/plots/VocGrowth.RData')

