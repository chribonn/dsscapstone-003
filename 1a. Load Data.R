# Data Science Capstone
# Alan C. Bonnici - March 2015
# 1a Load Data

library(stringi)

# allows code to be reproduced
set.seed(1234)

fileRData <- "data/dsscapstone-003-001.RData"

# Prepare the directory
if (!file.exists("data")) {
    dir.create("data")
}

if (!file.exists(fileRData)) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
    zipFile <- paste0("data/",basename(fileUrl))
    download.file(fileUrl, zipFile)
    
    # extract the contents of the downloaded archive
    unzip(zipFile)
    
    # cleanup the folder that will not be used in this analysis
    unlink("final/de_DE", recursive = TRUE)
    unlink("final/fi_FI", recursive = TRUE)
    unlink("final/ru_RU", recursive = TRUE)

    # Load the profane words
    profaneWords <- readLines("data/profane.txt", encoding="UTF-8")
    profaneV <- paste(profaneWords, collapse='|')
             
    # load the data en_US data
    #ignore 'incomplete final line found' warning - all lines have been loaded
    # the nul error can be sorted by reading the file as binary
    # import the news dataset in binary mode
    con <- file("final/en_US/en_US.news.txt", open="rb")
    dataNews <- readLines(con, encoding="UTF-8")
    close(con)
    rm(con)
    # clean up profane words
    dataNews <- gsub(profaneV, " ", dataNews)
    
    dataBlogs <- readLines("final/en_US/en_US.blogs.txt", encoding="UTF-8")
    # clean up profane words
    dataBlogs <- gsub(profaneV, " ", dataBlogs)
    
    dataTwitter <- readLines("final/en_US/en_US.twitter.txt", encoding="UTF-8")
    # remove characters that are not UTF-8
    dataTwitter <- iconv(dataTwitter, from="latin1", to="UTF-8", sub="byte")
    dataTwitter <- stri_replace_all_regex(dataTwitter, "\u2019|`", "'")
    dataTwitter <- stri_replace_all_regex(dataTwitter, "\u201c|\u201d|u201f|``", '"')
    # clean up profane words
    dataTwitter <- gsub(profaneV, " ", dataTwitter)
    
    # cleanup
    rm (profaneWords, profaneV)
    
    # record the date the archive was downloaded
    dateDownloaded <- date()
    save(dateDownloaded, dataNews, dataBlogs, dataTwitter, file = fileRData)        
} else {
    load(file = fileRData)
    
    print(paste0("Using data originally downloaded on the ", dateDownloaded))
}

# https://stackoverflow.com/questions/8920145/count-the-number-of-words-in-a-string-in-r

print (paste0("Blogs: Lines read: ",length(dataBlogs)))
n <- sum(sapply(gregexpr("\\W+", dataBlogs), length) + 1)
print (paste0("Blogs: Words in file: ", n))

print (paste0("News: Lines read: ",length(dataNews)))
n <- sum(sapply(gregexpr("\\W+", dataNews), length) + 1)
print (paste0("News: Words in file: ", n))

print (paste0("Twitter: Lines read: ",length(dataTwitter)))
n <- sum(sapply(gregexpr("\\W+", dataTwitter), length) + 1)
print (paste0("Twitter: Words in file: ", n))   
