#Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jdk1.7.0_05\\jre')
# allows code to be reproduced

options(stringsAsFactors = FALSE)

# Special thanks to Stack exchange
#   https://stackoverflow.com/questions/8161167/what-algorithm-i-need-to-find-n-grams

set.seed(1234)

library(stringi)
library(tm)
library(SnowballC)
library(slam)
library(RWeka)
library(tau)
library(qdap)

options(stringsAsFactors = FALSE)

# load library of functions used by this module
source("3. Modelling-lib.R")

buildCorpusLib(500000, 5, echo=TRUE, timing=TRUE)
