# Compile a list of potential spelling mistakes
# https://github.com/ropensci/hunspell

require(tidyverse)
library(hunspell)
require(stringi)
require(stringr)
rm(list = ls())


data.file    = './data/raw/SWOW-EN.R100.csv'
output.file = './output/spellingsmistakes.csv'
X         = read.table(data.file, header = TRUE, sep=",", dec=".", quote = "\"",stringsAsFactors = FALSE)

# Convert to long
X           = gather(X,RPOS,response,R1,R2,R3,factor_key = FALSE)

responses   = X %>% group_by(response) %>% summarise(Freq = n()) %>% select(response,Freq) %>% arrange(desc(Freq))

# Remove words in the word list
Lexicon     = read.csv('./dictionaries/wordlist.txt', header = TRUE,stringsAsFactors = FALSE, encoding = 'UTF-8')

# Only keep responses not in the lexicon
responses = responses %>% filter(!response %in% Lexicon$Word)

# Indicate whether multiresponse or not: Count spaces in responses, but ignore missing responses (Unknown word, No more responses")
responses = responses %>% mutate(nWords = str_count(response,"\\S+") + str_count(response,",|;"))
responses = responses %>% mutate(isASCII = as.numeric((stri_trans_general(response,id='Latin-ASCII') == response)))


correct         = hunspell_check(responses$response)
spell.mistakes  = responses[!correct,]
#suggestions     = hunspell_suggest(spell.mistakes$response)

write.csv(x = spell.mistakes,outpfile = output.file)

# Find suggestions for incorrect words
#hunspell_suggest(spell.mistakes$response[1:3])
