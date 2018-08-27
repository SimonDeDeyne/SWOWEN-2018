# Description:
#
# Generate a cue x response table with strengths
#
# Note: the data included with this script cannot be distributed without prior consent
# Author: Simon De Deyne simon2d@gmail.com
# Last changed: 20 February 2018

source('settings.R')
require(igraph)
require(Matrix)

outputR1.file       = './output/strength.SWOW-EN.R1.csv'
outputR123.file     = './output/strength.SWOW-EN.R123.csv'

setwd('/media/simon/Data/Dropbox/Scripts/R/SWOWGIT/complete/')
source('./R/functions/importDataFunctions.R')

# Import the dataset for R1
dataFile          = './data/processed/SWOW-EN.R100.csv'
response          = 'R1' # Options: R1, R2, R3 or R123
X.R1              = importDataSWOW(dataFile,response)

strength.R1       = X.R1 %>% filter(!is.na(response)) %>%  group_by(cue,response) %>%
                    summarise(R1 = n()) %>% select(cue,response,R1)
total.R1          = strength.R1 %>% group_by(cue) %>% summarise(N = sum(R1))
strength.R1       = left_join(strength.R1,total.R1)
strength.R1       = strength.R1 %>% mutate(R1.Strength = R1 / N)
strength.R1       = strength.R1 %>% arrange(cue,-R1.Strength)

# Write cue - asso strength R1
write.table(strength.R1,outputR1.file,row.names = FALSE,sep = '\t',quote = FALSE)


# Import the dataset for R123
response          = 'R123'
X.R123            = importDataSWOW(dataFile,response)


strength.R123   = X.R123 %>% filter(!is.na(response)) %>%  group_by(cue,response) %>%
                      summarise(R123 = n()) %>% select(cue,response,R123)
total.R123        = strength.R123 %>% group_by(cue) %>% summarise(N = sum(R123))
strength.R123     = left_join(strength.R123,total.R123)
strength.R123     = strength.R123 %>% mutate(R123.Strength = R123 / N)
strength.R123     = strength.R123 %>% arrange(cue,-R123.Strength)

# Write cue - asso strength R1
write.table(strength.R123,outputR123.file,row.names = FALSE, sep = '\t', quote = FALSE)

