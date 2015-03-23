library(tm); library(tau);

tokenize_ngrams <- function(x, n=3) return(rownames(as.data.frame(unclass(textcnt(as.character(x),method="string",n=n)))))

texts <- c("This is the first document.", "This is the second file.", "This is the third text.")
corpus <- Corpus(VectorSource(texts))
matrix <- DocumentTermMatrix(corpus,control=list(tokenize=tokenize_ngrams))