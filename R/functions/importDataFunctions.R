
# mulitiple relplacement function
#source('./R/functions/mgsub.R')

# Convert to long format and translate British to American or remove British ones if American exists
importDataSWOW <- function(dataFile,response) {
  X       = read.csv(dataFile, header = TRUE, sep=",", dec=".",quote = "\"",encoding = "UTF-8",stringsAsFactors = FALSE)

  # Convert to a long (tall) format
  X       = gather(X,RPOS,response,R1,R2,R3,factor_key = FALSE)

  # Remove the brexit words
  X       = brexitWords(X)

  # Decide which responses to keep
  switch(response,
         R1 = { X = filter(X,RPOS =='R1') },
         R2 = { X = filter(X,RPOS =='R2') },
         R3 = { X = filter(X,RPOS =='R3') },
         R12 = { X = filter(X,RPOS %in% c('R1','R2')) },
         R123 = { X = X })

  return(X)
}

importDataEAT <- function(dataFile){
  X         = read.csv(dataFile, header = TRUE, sep=",", dec=".",encoding = "UTF-8",stringsAsFactors = FALSE)
  X$RPOS    = 'R1'
  return(X)

}

# Note: the original file uses underscores to separate two tokens, here we replace by
# a space to make it conform to the other datasets
importDataUSF <- function(dataFile){
  X         = read.csv(dataFile, header = TRUE, sep=",", dec=".",quote = "\"",encoding = "UTF-8",stringsAsFactors = FALSE)
  X$RPOS    = 'R1'
  return(X)
}

countResponses <- function(X){
  C     = X %>% select(cue,response) %>% group_by(cue,response)  %>% summarise (Freq = n())
  return(C)
}


# Remove a list of words that occur twice in the database as different variants (due to British variants also
# present as an American form or due to simple spelling mistakes, such as tresspass or hotdog)
# Apart from British words, this also includes alternative spellings
brexitWords <- function(X){
  #message(': Removing UK and spelling variants\n',"\r",appendLF=FALSE)
  UKwords = c('aeroplane', 'arse', 'ax', 'bandana', 'bannister', 'behaviour', 'bellybutton', 'centre',
              'cheque', 'chequered', 'chilli', 'colour', 'colours', 'corn-beef', 'cosy', 'doughnut',
              'extravert', 'favour', 'fibre', 'hanky', 'harbour', 'highschool', 'hippy', 'honour',
              'hotdog', 'humour', 'judgment', 'labour', 'light bulb', 'lollypop', 'neighbour',
              'neighbourhood', 'odour', 'oldfashioned', 'organisation', 'organise', 'paperclip',
              'parfum', 'phoney', 'plough', 'practise', 'programme', 'pyjamas',
              'racquet', 'realise', 'recieve', 'saviour', 'seperate', 'theatre', 'tresspass',
              'tyre', 'verandah', 'whisky', 'WIFI', 'yoghurt','tinfoil','smokey','seat belt','lawn mower',
              'coca-cola','cell phone','breast feeding','break up','bubble gum','black out')

  return(filter(X, !cue %in% UKwords))
}
