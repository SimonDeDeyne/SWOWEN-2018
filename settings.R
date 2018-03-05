require(rstudioapi)
require(stringr)
require(tidyverse)

rm(list = ls())

# Set your working direct
current_path = getActiveDocumentContext()$path
setwd(dirname(current_path ))
message('Current working directory: ', getwd() )

# Determine unknown and missing response tokens
unknown.Token = 'Unknown word'
missing.Token = 'No more responses'

listlength.Min = 14
listlength.Max = 18
listlength.default = 14
age.Min        = 16

# Participants who tested the experiments (will be excluded)
testsubjects = c(1,2,71,7334,7336,36869,60804,76083,76308,83324,89552,89569,99569,100429,112713,122019,122857)

# Languages considered native
nativeLanguages = c('United States','Canada','Australia','New Zealand','Puerto Rico','Ireland',
                    'United Kingdom','South Africa','Jamaica')

responseCountTreshold = 300


# Criteria for removing participants with
# 1. over 60% missing or unknown responses
criteria.X = 0.6

# 2. less than 60% of responses in English lexicon
criteria.English = 0.6

# 3. more than 20% of responses not unique (sex,sex,sex)
criteria.Repeat = 0.2

# 4. more than 30% of responses are multi-word
criteria.Ngram = 0.3
