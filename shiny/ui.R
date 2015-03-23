shinyUI(fluidPage(
    titlePanel("Data Science Capstone (dsscapstone-003)",
               "Alan C. Bonnici"),
    fluidRow(
        column(4, wellPanel(
            sliderInput("n", "Suggestions to be returned:",
                        min = 1, max = 10, value = 5, step = 1),
            
            textInput("text", "Phrase to complete:", "What a nice"),
            
            br(),
            actionButton("submitButton", "Submit")
        )),
        column(8,
               h4("Suggestions"),
               textOutput("words")
        ),
    fluidRow(
        column(12,
               h1("Thank you"),
               p("I would like to thank"),
               tags$div(
                   tags$ul(
                       tags$li("Drs Leek, Peng and Caffo for designing the course"),
                       tags$li("The many people on StackExchange who helped out with R realted matters"),
                       tags$li("The people on Coursera forums who directed me to right sources"),
                       tags$li("Google search - nothing else need be said"))
               )
        )
    )
)))
