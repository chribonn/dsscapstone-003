# Data Science Capstone
# Alan C. Bonnici - March 2015
# 2a. Clean Data (Word Cloud)

# A lot of information is available at:
# ** https://sites.google.com/site/miningtwitter/questions/talking-about/wordclouds/wordcloud1
# ** https://georeferenced.wordpress.com/2013/01/15/rwordcloud/

library(tm)
library(wordcloud)
library(RColorBrewer)
library(slam)

# allows code to be reproduced
set.seed(1234)

fileRData <- "data/dsscapstone-003-002.RData"
load(file = fileRData)
print(paste0("Using data originally downloaded on the ", dateDownloaded))

par(mfrow = c(1,3))
plotTitle <- c("Blogs", "News", "Twitter")

for(i in 1:3){
    tdm <- DocumentTermMatrix(corpusData[[i]])
    # plot word cloud
    wordcloud(words=colnames(tdm), freq=col_sums(tdm), scale=c(5,0.5), max.words=100, random.order=FALSE, rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8,"Dark2"))
    title(plotTitle[i])
}