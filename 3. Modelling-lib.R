## Modelling Function Library

# http://cran.r-project.org/web/packages/tau/tau.pdf
tauTokenizer <- function(x, nGram) {
    return(rownames(as.data.frame(unclass(textcnt(as.character(x),method="string",n=nGram)))))
}

rwekaTokenizer <- function(x, nGram) {
    NGramTokenizer(x, Weka_control(min=nGram, max=nGram))
}

tdmTokenizer <- function(corpus, type, nGram, echo=FALSE, timing=FALSE) {
    if (echo) {
        print ("Entering module: tdmTokenizer")
    }

    if (timing) {
        startTime <- Sys.time()
    }

    if (type == "r") {
        tdm <- TermDocumentMatrix(corpus, control=list(tokenize=function(x) rwekaTokenizer(x, nGram), wordLengths = c(1, Inf)))
    } 
    else if (type == "t") {
        tdm <- TermDocumentMatrix(corpus, control=list(tokenize=function(x) tauTokenizer(x, nGram), wordLengths = c(1, Inf)))
    }
    else {
        stop("Invalid tokenizer specified.")        
    }
    
    if (timing) {
        print (paste0("Module: tdmTokenizer time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: tdmTokenizer")
    }
    
    return(tdm)
}

# https://stackoverflow.com/questions/24191728/documenttermmatrix-error-on-corpus-argument
# https://stackoverflow.com/questions/24311561/how-to-use-stemdocument-in-r
# Function cleans up the passed data returning a cleaned up text
cleanUp <- function(data, profaneV, echo=FALSE, timing=FALSE) {
    if (echo) {
        print ("Entering module: cleanUp")
    }
    
    if (timing) {
        startTime <- Sys.time()
    }

    # convert the amperstand to and. Add spaces to ensure it becomes a word in its own right
    data <- gsub("\\s?&\\s?"," and ", data)
    data <- gsub("\\s{2,}", " ", data)
    
    data <- stri_replace_all_regex(data, "\u2019|`", "'")
    data <- stri_replace_all_regex(data, "\u201c|\u201d|u201f|``", '"')
    data <- gsub(profaneV, " ", data)
    corpus <- Corpus(VectorSource(data))
    corpus <- tm_map(corpus, content_transformer(tolower))
    corpus <- tm_map(corpus, removePunctuation)
    corpus <- tm_map(corpus, stripWhitespace)
    corpus <- tm_map(corpus, removeNumbers)
    corpus <- tm_map(corpus, removeWords,stopwords("english"))
    corpus <- tm_map(corpus, stemDocument)
    corpus <- tm_map(corpus, PlainTextDocument)
    
    if (timing) {
        print (paste0("Module: cleanUp time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: cleanUp")
    }
    
    return (corpus)
}

loadCleanSave <- function(sampleSize, echo=FALSE, timing=FALSE) {
    if (echo) {
        print ("Entering module: loadCleanSave")
    }
    
    if (timing) {
        startTime <- Sys.time()
    }

    cFileRData <- paste0("rds/dict-",sampleSize,".rds")
    # if the cleaned corpus exists do not process it
    if (!file.exists(cFileRData)) {
        
        #if the processed 
        # The profane list must be applied to both the source data as well as inputtied string in order to get a match. Stop if the list does not exist.
        fileRData <- "data/profane.txt"
        if (!file.exists(fileRData)) {
            stop("Profanity list not found.")
        }
        
        profaneWords <- readLines(fileRData, encoding="UTF-8")
        profaneV <- paste(profaneWords, collapse='|')
        rm (profaneWords)  # Clean up
        
        # ignore 'incomplete final line found' warning - all lines have been loaded
        # the nul error can be sorted by reading the file as binary
        # import the news dataset in binary mode
        data <- readLines("final/en_US/en_US.blogs.txt", encoding="UTF-8")
        
        con <- file("final/en_US/en_US.news.txt", open="rb")
        data1 <- readLines(con, encoding="UTF-8")
        close(con)
        rm(con)

        data <- c(data , data1)
        rm (data1)
        
        data1 <- readLines("final/en_US/en_US.twitter.txt", encoding="UTF-8")
        # remove characters that are not UTF-8
        data1 <- iconv(data1, from="latin1", to="UTF-8", sub="byte")

        data <- c(data , data1)
        rm (data1)
        
        # Generate the required sample size
        data <- sample(data, sampleSize)
        
        corpus <- cleanUp(data, profaneV, echo, timing)
        # save the file so that if it is called up in the future it does not need to be processed again
        saveRDS(corpus, file=cFileRData)
    }   
    else {
        corpus <- readRDS(cFileRData)
        print ("Cleaned corpus not regenerated as it already exists.")       
    }
    
    if (timing) {
        print (paste0("Module: loadCleanSave time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: loadCleanSave")
    }

    return (corpus)
}

# Generate Libraries of different corpa lengths for both the tau and the rweka algorithms
# Because of the time it takes retain the generated output.
buildCorpusLib <- function(sampleSize, nGram, echo=FALSE, timing=FALSE) {   
    if (echo) {
        print ("Entering module: buildCorpusLib")
    }
    
    if (timing) {
        startTime <- Sys.time()
    }
    
    # only generate the files in necessary
    rFileRData <- paste0("rds/",sampleSize,"-",nGram,"-rweka.rds")
    tFileRData <- paste0("rds/",sampleSize,"-",nGram,"-tau.rds")
    if ((!file.exists(rFileRData)) || (!file.exists(rFileRData))) {
         
        corpus <- loadCleanSave(sampleSize, echo, timing)
        
        # Generate rweka data
        if (!file.exists(rFileRData)) {
            tdm <- tdmTokenizer(corpus, "r", nGram, echo, timing)
            saveRDS(tdm, rFileRData)
            rm (tdm)
        }
        else {
            print ("rWeka library not regenerated as it already exists.")
        }
        
        # Generate tau data
        if (!file.exists(tFileRData)) {
            tdm <- tdmTokenizer(corpus, "t", nGram, echo, timing)
            saveRDS(tdm, tFileRData)
        }
        else {
            print ("tau library not regenerated as it already exists.")
        }
    }
    else {
        print ("rWeka and tau libraries not regenerated as they already exists.")
    }
    
    if (timing) {
        print (paste0("Module: loadCleanSave time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: loadCleanSave")
    }
}

