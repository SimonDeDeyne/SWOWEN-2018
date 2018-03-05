# Preprocessing pipeline for the English Small World of Words project (SWOWEN-2018)
# Author: Simon De Deyne (simon2d@gmail.com)
#
# Each file is self-contained, but the entire pipeline can be executed here
#
# Last changed: 5 March 2018

# Settings
source('settings.R')

# Compile an English word list to use for participant language checks
source('./R/createWordlist.R')

# Preprocess the data and generate participant statistics
source('./R/preprocessData.R')

# Create datafiles with response statistics (types, tokens)
# Note: at this level we remove British variants if an American alternative exists
# to avoid inflating the counts
source('./R/createResponseStats.R')

# Create the SWOWEN graph which will inform us on the strongly connected
# component, which will be considered when calculating cue stats coverage
source('./R/createSWOWENGraph.R')

# Create datafiles with cue statistics (# responses, unknown, missing, H)
source('./R/createCueStats.R')

# Generate coverage plot
source('./R/plotCoverage.R')

# Generate vocabulary growth plot by fitting a Zipf Mandbrot model
# (Might get stuck depending on default options, see script)
source('./R/plotVocabularyGrowth.R')

# Predict chaining (warning: slow)
source('./R/calculateR12ResponseChaining.R')

