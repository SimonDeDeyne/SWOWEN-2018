# The following script evaluates the effect of chaining of the first response (R1) on  the
# second response (R2) in a continued word association task.
# It's based on an analysis of contingency tables for each cue in a dataset of over 12,000 cues
# and takes into account sampling without replacement (a participant cannot repeat the same response)
#
# More detail about sampling assumptions and BF calcuations are available in
# Jamil, T., Ly, A., Morey, R., Love, J., Marsman, M., & Wagenmakers, E.-J. (2017). Default
# Gunel and Dickey Bayes factors for contingency tables. Manuscript submitted for publication.
#
# Outstanding issues: script slows down, might be some looping / memory issue
# Author: Simon De Deyne, simon2d@gmail.com
# Last changed 2 February, 2018

require(tidyverse)
require(BayesFactor)
require(pbapply)

rm(list = ls())
source('./R/functions/importDataFunctions.R')

dataFile        = './data/processed/SWOW-EN.R100.csv'
outputFile      = './output/responseR12ChainingSWOW-EN.csv'
summaryFile     = './output/responseR12ChainingSummary.csv'
response        = 'R123'
X               = importDataSWOW(dataFile,response)
X               = X %>% filter(complete.cases(response),RPOS %in% c('R1','R2')) %>% select(participantID,cue,response,RPOS)

# co-worker and coworker lead to identical responses for 1 pp who happened to have
# been presented these results. Remove
X = X[-c(324232,1507272), ]
X = spread(X,RPOS,response)



# Iterate over each cue to obtain BF
result  = data.frame(stringsAsFactors = FALSE)
result  = data.frame(cue = character(),R1 = character(),R2 = character(),
                    fR2R1 = double(),fR2nR1 = double(),fnR2R1 = double(),
                    fnR2nR1 = double(),myBF = double(),stringsAsFactors = FALSE )

calculateChaining <- function(tt){
  result  = data.frame(stringsAsFactors = FALSE)
  result  = data.frame(cue = character(),R1 = character(),R2 = character(),
                       fR2R1 = double(),fR2nR1 = double(),fnR2R1 = double(),
                       fnR2nR1 = double(),myBF = double(),stringsAsFactors = FALSE )

    for(i in 1:dim(tt)[1]){

    # select R2 responses with freq > 1
    for(j in 1:dim(tt)[2]){
      if(tt[i,j] > 0){

        fR2R1   = tt[i,j]
        fR2nR1  = sum(tt[,j]) - fR2R1
        fnR2R1  = sum(tt[i,]) - fR2R1
        fnR2nR1 = sum(tt) - fnR2R1 - fR2R1 - fR2nR1

        data    = matrix(c(fR2R1,fR2nR1,fnR2R1,fnR2nR1),c(2,2))
        BFI_10  = contingencyTableBF(data,sampleType = "jointMulti",
                                     priorConcentration = 1)

        # Standard reported: log_10(BF); convert
        myBF    = exp(BFI_10@bayesFactor$bf)

        # Print some strong examples (with R1 occuring at least 4 times)
        # if(fR2R1 > 4){
        #   print(noquote(sprintf("%g: cue: %s: R1: %s - R2: %s: %g %g %g %g, BF =  %f",c,
        #                         cues[c],rownames(tt)[i],colnames(tt)[j],fR2R1,
        #                         fR2nR1,fnR2R1,fnR2nR1,myBF)))
        # }
        v = cbind(cue = cues[c],R1 = rownames(tt)[i] ,R2 = colnames(tt)[j],fR2R1, fR2nR1,fnR2R1,fnR2nR1,BF = myBF)
        result = rbind(result,v)
      }
    }
  }


  return(result)
}

cues    = unique(X$cue)
start.time <- Sys.time()
for(c in 1:length(cues)){
  # show progress
  if(c %% 200 == 0){
    message('.',appendLF = FALSE)
  }

  C = X %>% filter(cue==cues[c])
  C$R1 = factor(C$R1)
  C$R2 = factor(C$R2)
  tt      = xtabs( ~ R1 + R2, C)
  res = calculateChaining(tt)
  result = rbind(result,res)
  }
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken


# Write the results
result$BF = as.numeric(as.vector(result$BF))
write.csv(x = result,file = outputFile)

# Investigate the degree of chaining over responses
# This could be used for subsequent analysis to investigate cue factors (e.g. out-degree, familiarity, etc.)
# affecting degree of chaining
resultSummary = result %>% group_by(cue) %>% summarise(M = mean(BF))
write.csv(x = resultSummary, file = summaryFile)

# Convert BF to posterior probability and display histogram
hist(result$BF/(result$BF +1),12,main = 'Histogram chaining R2|R1',xlab = 'Probability',col = 'grey')
hist(log(result$BF),main = 'Histogram chaining R2|R1',xlab = 'log(BF_{10})',freq = FALSE, col = 'grey')
