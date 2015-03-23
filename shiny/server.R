#Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jdk1.7.0_05\\jre')

library(shiny)
library(data.table)
library(qdap)

set.seed(1234)

dict <- readRDS("dict.rds")
source("Predictor-lib.R")

shinyServer(function(input, output) {
    output$words <- renderText({
        input$submitButton
        
        isolate(paste(unlist(lapply(predictWord(input$text, dict)$Word[1:input$n], function(x) paste0("[", x, "]")))))
        })
    })

