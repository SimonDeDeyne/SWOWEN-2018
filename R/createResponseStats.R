# Description:
# Calculate response statistics for SWOW-EN
# Obtain number of types, tokens and Hapax legoma and write them to an output file.
# Save the summary statistics to be included in later report.
#
# Author: Simon De Deyne simon2d@gmail.com
# Date: 5 July 2018

source('settings.R')
results = list()

source('./R/functions/importDataFunctions.R')

data.file           = './data/processed/SWOW-EN.R100.csv'
output.file         = './output/responseStats.SWOW-EN.csv'
report.file         = './output/reports/responseStats.SWOW-EN.rds'

# Response frequencies for SWOW-EN R123
response            = 'R123'
SWOWEN              = importDataSWOW(data.file,response)

# Calculate unknown and missing results
results$unknown   = SWOWEN %>% filter(RPOS == 'R1',is.na(response)) %>% nrow() / (SWOWEN %>% nrow()/3) * 100
results$missing.R2 = SWOWEN %>% filter(RPOS == 'R2',is.na(response)) %>% nrow() / (SWOWEN %>% nrow()/2) * 100
results$missing.R3 = SWOWEN %>% filter(RPOS == 'R3',is.na(response)) %>% nrow() / (SWOWEN %>% nrow()) * 200

SWOWEN              = SWOWEN %>% filter(complete.cases(response))
Freq.SWOW.R123      = SWOWEN %>%
                      group_by(response) %>%
                      summarise(Freq.R123 = n()) %>%
                      arrange(desc(Freq.R123))

Types.SWOW.R123     = SWOWEN %>%
                      group_by(response,cue) %>%
                      summarise(Types.R123 = n()) %>%
                      arrange(desc(Types.R123))

#message('Number of types R123: ',Freq.SWOW.R123 %>% nrow())
results$types$count$R123  = Freq.SWOW.R123 %>% nrow()
Hapax.R123          = Freq.SWOW.R123 %>% filter(Freq.R123==1) %>% nrow()
#message('Hapax legoma tokens R123: ',Hapax.R123,' (',round(Hapax.R123 / sum(Freq.SWOW.R123$Freq.R123)*100),'%)')
#message('Hapax legoma types R123: ',round(Hapax.R123 / Freq.SWOW.R123 %>% nrow() *100),'%')
results$tokens$hapaxCount$R123  = Hapax.R123
results$tokens$hapax$R123  = Hapax.R123 / sum(Freq.SWOW.R123$Freq.R123) * 100
results$types$hapax$R123   = Hapax.R123 / Freq.SWOW.R123 %>% nrow() *100

Types.SWOW.R123     = Types.SWOW.R123 %>% group_by(response) %>% summarise(Types.R123 = n())
Freq.SWOW.R123      = left_join(Freq.SWOW.R123,Types.SWOW.R123, by = 'response')

# Response frequencies for SWOW-EN R1
response            = 'R1'
SWOWEN              = importDataSWOW(data.file,response)
SWOWEN              = SWOWEN %>% filter(complete.cases(response))
Freq.SWOW.R1        = SWOWEN %>%
                        group_by(response) %>%
                        summarise(Freq.R1 = n()) %>%
                        arrange(desc(Freq.R1))

Types.SWOW.R1       = SWOWEN %>%
                        group_by(response,cue) %>%
                        summarise(Types.R1 = n()) %>%
                        arrange(desc(Types.R1))
Types.SWOW.R1       = Types.SWOW.R1 %>% group_by(response) %>% summarise(Types.R1 = n())

Hapax.R1 = Freq.SWOW.R1 %>% filter(Freq.R1==1) %>% nrow()
#message('Number of types R1: ',Types.SWOW.R1 %>% nrow())

results$tokens$hapaxCount$R1  = Hapax.R1
results$types$count$R1 = Freq.SWOW.R1 %>% nrow()
#message('Hapax legoma tokens  R1: ',Hapax.R1,' (',round(Hapax.R1 / sum(Freq.SWOW.R1$Freq.R1)*100),'%)')
results$tokens$hapax$R1 = (Hapax.R1 / sum(Freq.SWOW.R1$Freq.R1)) * 100
#message('Hapax legoma types R1: ',round(Hapax.R1 / Freq.SWOW.R1 %>% nrow() *100),'%')
results$types$hapax$R1  = Hapax.R1 / Freq.SWOW.R1 %>% nrow() *100

Freq.SWOW.R1        = left_join(Freq.SWOW.R1,Types.SWOW.R1,by = 'response')
Freq.SWOW           = right_join(Freq.SWOW.R1,Freq.SWOW.R123,by = 'response',suffix = c('.R1','.R123'))


# Create a table with the 10 most common response types and tokens for R1 and R123
results$top10 = as.data.frame(cbind(
                  Freq.SWOW.R1 %>% top_n(10,Types.R1) %>% mutate(Types.R1 = response) %>% select(Types.R1),
                  Freq.SWOW.R123 %>% top_n(10,Types.R123) %>% mutate(Types.R123 = response) %>% select(Types.R123),
                  Freq.SWOW.R1 %>% top_n(10,Freq.R1) %>% mutate(Tokens.R1 = response) %>% select(Tokens.R1),
                  Freq.SWOW.R123 %>% top_n(10,Freq.R123) %>% mutate(Tokens.R123 = response) %>% select(Tokens.R123)
              ))


# Write the response statistics for both R1 and R123
write.csv(Freq.SWOW,output.file)

# Write a summary of the output to an rds file
saveRDS(results,report.file,ascii=TRUE)

# Clean up
rm(list = ls())



