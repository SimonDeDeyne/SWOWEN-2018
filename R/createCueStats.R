# Compute cue-level statistics either on the cue-by-response or
# the cue-by-cue matrix
#
# This script computes:
# 1. % known cues
# 2. % Missing responses (for R2 or R3)
# 2. Total number of cues
# 3. Coverage of cues (i.e. how many of the responses are also cues) based on R1 or R123
# 4. Entropy of the responses given the cues: E(R|C)
#
# Author: Simon De Deyne simon.dedeyne@adelaide.edu.au
# Date: 2 October 2017

require(tidyverse)
require(Matrix)
require(pbapply)
require(entropy)

source('settings.R')
results = list()
source('./R/functions/importDataFunctions.R')
source('./R/functions/networkFunctions.R')

dataFile.SWOWEN           = './data/processed/SWOW-EN.R100.csv'
results.file.SWOWEN.R1    = './output/cueStats.SWOW-EN.R1.csv'
results.file.SWOWEN.R123  = './output/cueStats.SWOW-EN.R123.csv'
report.file               = './output/reports/cueStats.SWOW-EN.rds'

# Load the removed vertices from the strongly connected components
components = readRDS('./output/reports/components.SWOW-EN.rds')

## SWOW-R1 statistics
X.R1              = importDataSWOW(dataFile.SWOWEN,'R1')

# Remove cues not in the component
X.R1  = X.R1 %>% filter(!cue %in% components$R1$removeVertices)

# Calculate coverage
Cues.known        = X.R1 %>% filter(complete.cases(response)) %>% group_by(cue) %>% summarise(cue.Tokens = n())
Cues.N            = X.R1 %>% group_by(cue) %>% summarise(N = n())
Cues.covered      = X.R1 %>% filter(response %in% cue) %>% group_by(cue) %>% summarise(cue.Covered = n())
coverage.R1       = left_join(Cues.known,Cues.covered, by = 'cue') %>% mutate(coverage = cue.Covered / cue.Tokens  * 100) %>% select(cue,coverage)

results$coverage$R1$mean    = mean(coverage.R1$coverage)
results$coverage$R1$median  = median(coverage.R1$coverage)
results$coverage$R1$sd      = sd(coverage.R1$coverage)
results$coverage$R1$min     = min(coverage.R1$coverage)
results$coverage$R1$max     = max(coverage.R1$coverage)
results$coverage$R1min_examples = coverage.R1 %>% top_n(-10,coverage)


# Calculate entropy H
message('Calculating entropy R1')
H.R1              = getEntropy(X.R1,'cues')

results$H$R1$mean         = mean(H.R1$H)
results$H$R1$sd           = sd(H.R1$H)
results$H$R1$min          = min(H.R1$H)
results$H$R1$max          = max(H.R1$H)
results$H$R1$min_examples = H.R1 %>% top_n(-10,H)
results$H$R1$max_examples = H.R1 %>% top_n(10,H)


# Calculate unknown
xR1               = X.R1 %>% group_by(cue) %>% summarise(unknown = sum(is.na(response)))
cueStats.R1       = as.data.frame(left_join(coverage.R1,H.R1,by = 'cue') %>% left_join(.,xR1,by = 'cue') %>% left_join(.,Cues.N,by = 'cue'))


## SWOW-R123 statistics
X.R123    = importDataSWOW(dataFile.SWOWEN,'R123')

# Remove cues not in the component
X.R123      = X.R123 %>% filter(!cue %in% components$R123$removeVertices)


# Calculate coverage
Cues.known        = X.R123 %>% filter(complete.cases(response)) %>% group_by(cue) %>% summarise(cue.Tokens = n())
Cues.N            = X.R123 %>% group_by(cue) %>% summarise(N = n())
Cues.covered      = X.R123 %>% filter(response %in% cue) %>% group_by(cue) %>% summarise(cue.Covered = n())
coverage.R123     = left_join(Cues.known,Cues.covered, by = 'cue') %>% mutate(coverage = cue.Covered / cue.Tokens  * 100) %>% select(cue,coverage)

results$coverage$R123$mean = mean(coverage.R123$coverage)
results$coverage$R123$median = median(coverage.R123$coverage)
results$coverage$R123$sd   = sd(coverage.R123$coverage)
results$coverage$R123$min  = min(coverage.R123$coverage)
results$coverage$R123$max  = max(coverage.R123$coverage)
results$coverage$R123min_examples = coverage.R123 %>% top_n(-10,coverage)


# Calculate entropy H
message('Calculating entropy R123')
H.R123           = getEntropy(X.R123,'cues')
#H.R123$cue       = as.character(H.R123$cue)

results$H$R123$mean         = mean(H.R123$H)
results$H$R123$sd           = sd(H.R123$H)
results$H$R123$min          = min(H.R123$H)
results$H$R123$max          = max(H.R123$H)
results$H$R123$min_examples = H.R123 %>% top_n(-10,H)
results$H$R123$max_examples = H.R123 %>% top_n(10,H)


# Calculate unknown
xR1   = X.R123 %>% group_by(cue) %>% summarise(unknown = sum(is.na(response[RPOS=='R1'])))

# Calculate missing (R2,R3)
xR2               = X.R123 %>% group_by(cue) %>% summarise(xR2 = sum(is.na(response[RPOS=='R2'])))
xR2$xR2           = xR2$xR2 - xR1$unknown
xR3               = X.R123 %>% group_by(cue) %>% summarise(xR3 = sum(is.na(response[RPOS=='R3'])))
xR3$xR3           = xR3$xR3 - xR2$xR2 - xR1$unknown

cueStats.R123       = as.data.frame(left_join(coverage.R123,H.R123,by = 'cue') %>% left_join(.,xR1,by = 'cue') %>%
                      left_join(.,xR2, by = 'cue') %>% left_join(.,xR3, by = 'cue') %>% left_join(.,Cues.N, by = 'cue'))

#message('Percentage unknown: ', round(mean(cueStats.R1$unknown),1),', range [',min(cueStats.R1$unknown),',', max(cueStats.R1$unknown),']')
#message('Percentage R2 missing: ', round(mean(cueStats.R123$xR2),1),', range [',min(cueStats.R123$xR2),',', max(cueStats.R123$xR2),']')
#message('Percentage R3 missing: ', round(mean(cueStats.R123$xR3),1),', range [',min(cueStats.R123$xR3),',', max(cueStats.R123$xR3),']')

results$unknown$mean    = mean(cueStats.R1$unknown)
results$unknown$min     = min(cueStats.R1$unknown)
results$unknown$max     = max(cueStats.R1$unknown)

results$R2missing$mean  = mean(cueStats.R123$xR2)
results$R2missing$min   = min(cueStats.R123$xR2)
results$R2missing$max   = max(cueStats.R123$xR2)

results$R3missing$mean  = mean(cueStats.R123$xR3)
results$R3missing$min   = min(cueStats.R123$xR3)
results$R3missing$max   = max(cueStats.R123$xR3)

# Write the results to file
write.csv(cueStats.R1,file = results.file.SWOWEN.R1)
write.csv(cueStats.R123,file = results.file.SWOWEN.R123)

# Write a summary of the output to an rds file
saveRDS(results,report.file,ascii=TRUE)
