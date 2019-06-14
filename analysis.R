# Preprocessing pipeline for the English Small World of Words project (SWOWEN-2018)
# Author: Simon De Deyne (simon2d@gmail.com)
#
# Each file is self-contained, but the entire pipeline can be executed here
# Make sure the working directory is set to this file's directory
#
# Last changed: 13 July 2019

library('here')

# Compile an English word list to use for participant language checks
source('./R/createWordlist.R')

# Preprocess the data and generate participant statistics
source('./R/preprocessData.R')

# Create datafiles with response statistics (types, tokens)
# Note: at this level we remove British variants if an American alternative exists
# to avoid inflating the counts
source('./R/createResponseStats.R')

# Create cue- response associative strength table (optional)
source('./R/createAssoStrengthTable.R')


# Create the SWOWEN graph which will inform us on the strongly connected
# component, which will be considered when calculating cue stats coverage
source('./R/createSWOWGraph.R')

# Create datafiles with cue statistics (# responses, unknown, missing, H)
source('./R/createCueStats.R')

# Generate coverage plot for the strongest connected components of G_R1 and G_R123
source('./R/plotCoverage.R')

# Generate vocabulary growth plot by fitting a Zipf Mandbrot model
# (Might get stuck depending on default options, see script)
source('./R/plotVocabularyGrowth.R')

# Predict chaining (warning: slow)
source('./R/calculateR12ResponseChaining.R')

# Generate Random Walk similarity (warning: slow in R)

