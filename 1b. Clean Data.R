# Data Science Capstone
# Alan C. Bonnici - March 2015
# 1b. Clean Data

library(tm)
library(SnowballC)

# https://stackoverflow.com/questions/24191728/documenttermmatrix-error-on-corpus-argument
# https://stackoverflow.com/questions/24311561/how-to-use-stemdocument-in-r
# Function clean up the passed parameter leaving a cleaned up text
CleanUp <- function (corpus) {
    corpus <- tm_map(corpus, tolower)  
    corpus <- tm_map(corpus, removePunctuation)
    corpus <- tm_map(corpus, stripWhitespace)
    corpus <- tm_map(corpus, removeNumbers)
    corpus <- tm_map(corpus, removeWords,stopwords("english"))
    corpus <- tm_map(corpus, PlainTextDocument)
    corpus <- tm_map(corpus, stemDocument)
    
    return (corpus)
}

fileRData <- "data/dsscapstone-003-001.RData"
load(file = fileRData)
print(paste0("Using data originally downloaded on the ", dateDownloaded))

samplePerc <- 0.01
# sample samplePerc percent of the data from each data set. Given that the datasets are large this amount would suffice as a training set or 5,000 whichever is smaller (problem with Corpus function on twitter.)
dataNews <- sample(dataNews, min(round(length(dataNews) * samplePerc), 5000))
dataBlogs <- sample(dataBlogs, min(round(length(dataBlogs) * samplePerc), 5000))
dataTwitter <- sample(dataTwitter, min(round(length(dataTwitter) * samplePerc), 5000))

corpusBlogs <- Corpus(VectorSource(dataBlogs))
corpusNews <- Corpus(VectorSource(dataNews))
corpusTwitter <- Corpus(VectorSource(dataTwitter))

corpusData <- list(corpusBlogs, corpusNews, corpusTwitter)

# cleanup 
rm (dataBlogs, dataNews, dataTwitter)
rm (corpusBlogs, corpusNews, corpusTwitter)

# Clean up the data
for (i in 1: length(corpusData))
{
    corpusData[[i]] <- CleanUp(corpusData[[i]])
}

fileRData <- "data/dsscapstone-003-002.RData"
dateDownloaded <- date()
save(dateDownloaded, corpusData, file=fileRData)
