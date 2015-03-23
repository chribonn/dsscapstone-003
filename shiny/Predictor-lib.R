# Cleans up the string and transforms it so that it can be processed
cleanUp <- function(string) {
    string <- gsub("&"," and ", string)
    string <- tolower(replace_contraction(string))
    
    return (string)
}

# Takes the passed string and  splits it into individual words. with the respective columns named w<position>.
# If the number of words exceed the tokens in the dictionary that the inputted string is reduced
reduceString <- function(string, dictlist){
    string <- strsplit(string, split = " ")[[1]]
    chkWords <- min(length(string), length(dictlist)-1)
    string <- tail(string, chkWords)
    names(string) <- paste("w", 1:length(string), sep = "")
    return(string)
}

# Returns words that can can be aresult: a vector of split words that are candidate "next words" to a string, based on bigrams
wordList <- function(string, tokenTot, dictlist) {
    # split the string into it component words
    if (length(grep(" ", string)) > 0) {
        string <- strsplit(string, split = " ")[[1]]
    }
    
    # Generate a dt of all those entries whose first token is the same as the last token of the inputted string
    dt <- dictlist[[2]][token1 == string[length(string)]]
    
    # Generate a sorted vector of the 2nd token sorted by frequency count
    retVal <-  dt[order(-count)][1:tokenTot]$token2
    return(retVal)
}

# This is the main module
predictWord <- function(string, dictlist) {
    # the number of words that will be generated to get to the result
    #print(string)
    
    tokenTot <- 100
    string <- cleanUp(string)
    
    success <- FALSE
    while (!success) {
        wordList <- wordList(string, tokenTot, dictlist)
        # if nothing has been returned than no further processing is possible.
        if (is.na(wordList[1])) {
            # try shorting the string and checking again
            chkString <- unlist(strsplit(string, split = " "))
            # Reduce the string only if there is something to reduce
            if (length(chkString) > 1) {
                string <- paste(chkString[2:length(chkString)], collapse=" ")
            }
            else {
                print("Error: No suggestions")
                return(NULL)
            }
        }
        else {
            success <- TRUE            
        }
    }
    
    # Create dt for top n candidates
    results <- c()
    results.names <- c()
    
    # Take each word and ..
    for (i in (1:tokenTot)) {
        chkWord <- wordList[i]
        chkString <- paste(string, chkWord, collapse = " ")
        chkString <- reduceString(chkString, dictlist)
        score <- nrow(dictlist[[2]][token2 == tail(chkString,1),]) / nrow(dictlist[[2]])
        results <- c(results, score)
        results.names <- c(results.names, wordList[i])
    }
    
    dt <- data.table("Word"=results.names, "score"=results)
    return(dt[order(-score)])
}

## debug
#dictlist <- readRDS("dict.rds")
#ans <- predictWord("What a nice", dictlist)
