## Modelling Function Library
## The reason the temporary files are retained is because it was taking too long to find a combination of NGram vs sample size at was functional and efficient

# http://cran.r-project.org/web/packages/tau/tau.pdf
tauTokenizer <- function(x, nGram) {
    return(rownames(as.data.frame(unclass(textcnt(as.character(x),method="string",n=nGram)))))
}

rwekaTokenizer <- function(x, nGram) {
    NGramTokenizer(x, Weka_control(min=nGram, max=nGram))
}

tdmTokenizer <- function(corpus, type, nGram, echo=FALSE, timing=FALSE) {
    if (echo) {
        print (paste0("Entering module: tdmTokenizer ('",type,"',",nGram,")"))
    }

    if (timing) {
        startTime <- Sys.time()
    }

    if (type == "r") {
        tdm <- TermDocumentMatrix(corpus, control=list(wordLengths = c(1, Inf),
                                                       tokenize=function(x) rwekaTokenizer(x, nGram)))
    } 
    else if (type == "t") {
        tdm <- TermDocumentMatrix(corpus, control=list(wordLengths = c(1, Inf),
                                                       tokenize=function(x) tauTokenizer(x, nGram)))
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
# https://stackoverflow.com/questions/15589362/produce-a-documenttermmatix-that-includes-given-terms-in-r
# Function cleans up the passed data returning a cleaned up text
cleanUp <- function(data, profaneV, echo=FALSE, timing=FALSE) {
    if (echo) {
        print ("Entering module: cleanUp")
    }
    
    if (timing) {
        startTime <- Sys.time()
    }
    
    # convert the data to ASCII
    data <- iconv(data, "UTF-8", "ASCII")
    
    # convert the amperstand to and. Add spaces to ensure it becomes a word in its own right
    data <- gsub(profaneV, " ", data)
    data <- gsub("&"," and ", data)
    
    corpus <- Corpus(VectorSource(data))
    corpus <- tm_map(corpus, removePunctuation)
    corpus <- tm_map(corpus, stripWhitespace)
    corpus <- tm_map(corpus, removeNumbers)
    corpus <- tm_map(corpus, removeWords,stopwords("english"))
    corpus <- tm_map(corpus, content_transformer(tolower))
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
        print (paste0("Entering module: loadCleanSave"))
    }
    
    if (timing) {
        startTime <- Sys.time()
    }

    cFileRData <- paste0("rds/",sampleSize,"-corpus",".rds")
    # if the cleaned corpus exists do not process it
    if (!file.exists(cFileRData)) {
        
        # The profane list must be applied to both the source data as well as inputtied string in order to get a match. Stop if the list does not exist.
        fileRData <- "data/profane.txt"
        if (!file.exists(fileRData)) {
            stop("Profanity list not found.")
        }
        
        profaneWords <- readLines(fileRData)
        profaneV <- paste(profaneWords, collapse='|')
        rm (profaneWords)  # Clean up
        
        data <- c(sample(readLines("final/en_US/en_US.blogs.txt"), sampleSize),
                  sample(readLines("final/en_US/en_US.news.txt", sampleSize)),
                  sample(readLines("final/en_US/en_US.twitter.txt", sampleSize)))
        
        corpus <- cleanUp(data, profaneV, echo, timing)
        rm (data)
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
buildCorpusSave <- function(sampleSize, nGram, echo=FALSE, timing=FALSE) {   
    if (echo) {
        print (paste0("Entering module: buildCorpusSave"))
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
        print (paste0("Module: buildCorpusSave time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: buildCorpusSave")
    }
}

# Generate Libraries of different corpa lengths for both the tau and the rweka algorithms
# Because of the time it takes retain the generated output.
buildCorpusLib <- function(sampleSize, nGram, echo=FALSE, timing=FALSE) {   
    if (echo) {
        print (paste0("Entering module: buildCorpusLib (",nGram,")"))
    }
    
    if (timing) {
        startTime <- Sys.time()
    }
    
    # only generate the files in necessary. These temporary files are necessary to avoid rerunning the process 
    # during debugging and to eventually choose a model that can be uploaded in the final project. Memory restrictions
    # as well performance factors need to be factored in.
    rFileRData <- paste0("rds/",sampleSize,"-",nGram,"-rweka.rds")
    tFileRData <- paste0("rds/",sampleSize,"-",nGram,"-tau.rds")
    if ((!file.exists(rFileRData)) || (!file.exists(rFileRData))) {
         
        corpus <- loadCleanSave(sampleSize, echo, timing)
        
        # Generate rweka data
        if (!file.exists(rFileRData)) {
            tdm <- tdmTokenizer(corpus, "r", nGram, echo, timing)
            tdm <- tokeniseTDM(tdm, echo, timing)
            saveRDS(tdm, rFileRData)
            rm (tdm)
        }
        else {
            print ("rWeka library not regenerated as it already exists.")
        }
        
        # Generate tau data
        if (!file.exists(tFileRData)) {
            tdm <- tdmTokenizer(corpus, "t", nGram, echo, timing)
            tdm <- tokeniseTDM(tdm, echo, timing)
            saveRDS(tdm, tFileRData)
            rm (tdm)
        }
        else {
            print ("tau library not regenerated as it already exists.")
        }
    }
    else {
        print ("rWeka and tau libraries not regenerated as they already exists.")
    }
    
    if (timing) {
        print (paste0("Module: buildCorpusLib time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: buildCorpusLib")
    }
}

# Take the tokenised corpus and compute frequency calculations. Then split up the phrase into the words making it up. 
tokeniseTDM <- function(tdm, echo=FALSE, timing=FALSE) {
    if (echo) {
        print ("Entering module: tokeniseTDM")
    }
    
    if (timing) {
        startTime <- Sys.time()
    }
    
    # summarise the columns for each nGram phrase
    tdm <- rollup(tdm, 2, na.rm = TRUE, FUN = sum)
    
    # take each nGram phrase and sum up its frequency
    tdm <- data.table(token = tdm$dimnames$Terms, count = tdm$v)
    setkey(tdm, token)
    # sort it by frequency
    tdm <- tdm[order(-count)]
    
    # split the phrase making up the nGram into seperate words 
    splitTDM <- data.table(do.call(rbind, strsplit(as.vector(tdm$token), split = " ")))
    setnames(splitTDM,c(paste0("token", 1:ncol(splitTDM))))
    finalTDM <- cbind(splitTDM, token = tdm$token, count = tdm$count)
    finalTDM <- data.table(finalTDM)
    
    if (timing) {
        print (paste0("Module: tokeniseTDM time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: tokeniseTDM")
    }
    
    return (finalTDM)
}

splitCorpusSave <- function(sampleSize, nGram, echo=FALSE, timing=FALSE) {   
    if (echo) {
        print (paste0("Entering module: splitCorpusSave (",nGram,")"))
    }
    
    if (timing) {
        startTime <- Sys.time()
    }
    
    FileRData <- paste0("rds/",sampleSize,"-",nGram,"-rweka.rds")
    loadTDM <- readRDS(FileRData)
    for(i in 1:nGram) {
        # process rweka
        tFileRData <- paste0("rds/",sampleSize,"-",i,"-rweka-split.rds")
        if (!file.exists(tFileRData)) {
            tdm <- tokeniseTDM(loadTDM, echo, timing)
            saveRDS(tdm, file=tFileRData)
            rm(tdm)
        }
    }
        
    FileRData <- paste0("rds/",sampleSize,"-",nGram,"-tau.rds")
    loadTDM <- readRDS(FileRData)
    for(i in 1:nGram) {
        # process tau
        tFileRData <- paste0("rds/",sampleSize,"-",i,"-tau-split.rds")
        if (!file.exists(tFileRData)) {
            tdm <- tokeniseTDM(loadTDM, echo, timing)
            saveRDS(tdm, file=tFileRData)
            rm(tdm)
        }
    }
    
    if (timing) {
        print (paste0("Module: splitCorpusSave time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: splitCorpusSave")
    }
}

# Assembles the dictionary from the various wreka and tau packages that have been assembled previously
buildDict <- function(sampleSize, nGram, echo=FALSE, timing=FALSE) {   
    if (echo) {
        print (paste0("Entering module: buildDict (",nGram,")"))
    }
    
    if (timing) {
        startTime <- Sys.time()
    }
    
    loaddictlist <- list()
    
    FileRData <- paste0("rds/",sampleSize,"-",nGram,"-rweka-dict.rds")
    if (!file.exists(FileRData)) {
        for(i in 1:nGram) {
            tFileRData <- paste0("rds/",sampleSize,"-",i,"-rweka-split.rds")
            dict <- readRDS(tFileRData)
            
            if((class(dict)[1]) != "data.table") {
                dict <- data.table(dict)
            }
            
            if (length(unique(Encoding(dict$token))) > 1) {
                dict$token <- iconv(dict$token, "UTF-8", "ASCII")
                dict$token1 <- iconv(dict$token1, "UTF-8", "ASCII")
                try(dict$token2 <- iconv(dict$token2, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token3 <- iconv(dict$token3, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token4 <- iconv(dict$token4, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token5 <- iconv(dict$token5, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token6 <- iconv(dict$token6, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token7 <- iconv(dict$token7, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token8 <- iconv(dict$token8, "UTF-8", "ASCII"), silent = TRUE)
                setkey(dict,token)
                dict <- dict[!is.na(token)]
            }
            loaddictlist <- c(loaddictlist, list(dict))
        }
        saveRDS(loaddictlist, file = FileRData)
    }
    
    FileRData <- paste0("rds/",sampleSize,"-",nGram,"-tau-dict.rds")
    if (!file.exists(FileRData)) {
        for(i in 1:nGram) {
            tFileRData <- paste0("rds/",sampleSize,"-",i,"-tau-split.rds")
            dict <- readRDS(tFileRData)
            
            if((class(dict)[1]) != "data.table") {
                dict <- data.table(dict)
            }
            
            if (length(unique(Encoding(dict$token))) > 1) {
                dict$token <- iconv(dict$token, "UTF-8", "ASCII")
                dict$token1 <- iconv(dict$token1, "UTF-8", "ASCII")
                try(dict$token2 <- iconv(dict$token2, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token3 <- iconv(dict$token3, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token4 <- iconv(dict$token4, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token5 <- iconv(dict$token5, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token6 <- iconv(dict$token6, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token7 <- iconv(dict$token7, "UTF-8", "ASCII"), silent = TRUE)
                try(dict$token8 <- iconv(dict$token8, "UTF-8", "ASCII"), silent = TRUE)
                setkey(dict, token)
                dict <- dict[!is.na(token)]
                
                # Remove those words with a count of 1. This will help keep the file size under control
                # at the expence of infrequently occuring words.
                setkey(dict, count)
                dict <- data.table(dict)[count > 1]
            }
            loaddictlist <- c(loaddictlist, list(dict))
        }
        saveRDS(loaddictlist, file = FileRData)
    }
    
    if (timing) {
        print (paste0("Module: buildCorpusLib time: ",(startTime <- Sys.time())))
    }
    
    if (echo) {
        print ("Exiting module: buildCorpusLib")
    }
}

main <- function(sampleSize, nGram, echo=FALSE, timing=FALSE) {
    loadCleanSave(sampleSize, echo, timing) 
    buildCorpusSave(sampleSize, nGram, echo, timing)
    splitCorpusSave(sampleSize, nGram, echo, timing)
    buildDict(sampleSize, nGram, echo, timing)
}
