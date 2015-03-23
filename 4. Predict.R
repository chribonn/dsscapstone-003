Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jdk1.7.0_05\\jre')
# allows code to be reproduced

options(stringsAsFactors = FALSE)

# Special thanks to Stack exchange
#   https://stackoverflow.com/questions/8161167/what-algorithm-i-need-to-find-n-grams

set.seed(1234)

# load library of functions used by this module
source("4. Predict-lib.R")

#library(stringi)
library(tm)
library(SnowballC)
library(slam)
library(RWeka)
library(tau)
library(qdap)
library(data.table)

# R was crashing when all the data was read
sampleSize <- 1000

main(sampleSize, 8, TRUE, TRUE)
