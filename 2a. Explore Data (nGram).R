# Data Science Capstone
# Alan C. Bonnici - March 2015
# 2b. Clean Data (nGramTokenizer)

# A lot of information is available at:
# ** http://tm.r-forge.r-project.org/faq.html
#Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jdk1.7.0_05\\jre') - required when Rweka can't find Java
library(RWeka)
library(tm)

# allows code to be reproduced
set.seed(1234)

fileRData <- "data/dsscapstone-003-002.RData"
load(file = fileRData)
print(paste0("Using data originally downloaded on the ", dateDownloaded))

Titles <- c("Blogs", "News", "Twitter")

# Calculate word freqencies
for(i in 1:3) {
    tdm <- TermDocumentMatrix(corpusData[[i]])
    wordFreq <- findFreqTerms(tdm, lowfreq=200)
    print (paste0("Word frequency for ", Titles[i]))
    print (wordFreq[1:20])
}

# CleanUp
rm (tdm, wordFreq)

par(mfrow = c(3,1))
for(i in 1:3) {
    # For each item compute an analysis of different token lengths
    dtm <- DocumentTermMatrix(corpusData[[i]])
    freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)[1:25]
    
    bar <- barplot(freq, axes=FALSE, axisnames=FALSE, ylab="Frequency", main=paste0("Frequency of 1-Grams  for ",Titles[i]))
    text(bar, par("usr")[3], labels=names(freq), srt=60, adj=c(1.1,1.1), xpd=TRUE, cex=0.9)
    axis(2)
}

BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
par(mfrow = c(3,1))
for(i in 1:3) {
    # For each item compute an analysis of different token lengths
    dtm <- DocumentTermMatrix(corpusData[[i]], control=list(tokenize=BigramTokenizer))
    freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)[1:25]
    
    bar <- barplot(freq, axes=FALSE, axisnames=FALSE, ylab="Frequency", main=paste0("Frequency of 2-Grams for ",Titles[i]))
    text(bar, par("usr")[3], labels=names(freq), srt=60, adj=c(1.1,1.1), xpd=TRUE, cex=0.9)
    axis(2)
}

TrigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
par(mfrow = c(3,1))
for(i in 1:3) {
    # For each item compute an analysis of different token lengths
    dtm <- DocumentTermMatrix(corpusData[[i]], control=list(tokenize=TrigramTokenizer))
    freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)[1:25]
    
    bar <- barplot(freq, axes=FALSE, axisnames=FALSE, ylab="Frequency", main=paste0("Frequency of 3-Grams for ",Titles[i]))
    text(bar, par("usr")[3], labels=names(freq), srt=60, adj=c(1.1,1.1), xpd=TRUE, cex=0.9)
    axis(2)
}

QurgramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 4, max = 4))
par(mfrow = c(3,1))
for(i in 1:3) {
    # For each item compute an analysis of different token lengths
    dtm <- DocumentTermMatrix(corpusData[[i]], control=list(tokenize=QurgramTokenizer))
    freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)[1:25]
    
    bar <- barplot(freq, axes=FALSE, axisnames=FALSE, ylab="Frequency", main=paste0("Frequency of 4-Grams for ",Titles[i]))
    text(bar, par("usr")[3], labels=names(freq), srt=60, adj=c(1.1,1.1), xpd=TRUE, cex=0.9)
    axis(2)
}
