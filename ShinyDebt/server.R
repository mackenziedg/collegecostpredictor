#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(readr)
library(dplyr)
library(data.table)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    ## Calculate the user's standardized_score from input data, need
    ## to know exactly how this was calculated for the college data
    ## and adjust here
    user_std_score <- reactive({(input$satScore/1600 + input$actScore/36)/2})
    
    cols <- c("INSTNM", "ADM_RATE", "standardized_score", "ACTCMMID",
              "SATVRMID", "SATMTMID", "C150_4", "CONTROL", "STABBR")
    df <- read_csv("../data/clean/2010-15_withscore.csv") %>%
        select(one_of(cols)) %>%

        mutate(SATTOTAL=SATVRMID+SATMTMID)

    ## Only show schools where the median standardized_score is some
    ## value above the user's value
    acceptable_scores <- reactive(user_std_score() * 1.1)


    ## Create a rendered table of the top results based on the input selected.
    ## Probably need to create an "any" option for some of the drop downs.
    
    output$table <- renderDataTable(
        df %>%
        ## Filter schools based on user input
        filter(standardized_score < acceptable_scores()) %>%
        filter(CONTROL == input$pub_priv) %>%
        filter(STABBR == input$state) %>%
        ## Adjust data for viewing---round values, select + rename columns etc.
        mutate(ADM_RATE=round(ADM_RATE, 3)) %>%
        select(one_of(c("INSTNM", "ADM_RATE", "ACTCMMID", "C150_4"))),
        options=list(pageLength=5)
    )

})
