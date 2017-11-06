#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(plyr)
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


    apply_settings_to_df <- function(df){
      cols <- c("INSTNM")
      df <- filter(df, standardized_score < acceptable_scores())
      if (input$pub_priv != "ANY")
          df <- filter(df, CONTROL == input$pub_priv)
      else{
          df <- mutate(df, SchoolType=mapvalues(CONTROL, c(1, 2, 3), c("Public", "Private", "For-profit")))
          cols <- c(cols, "SchoolType")
      }
      if (input$state != "ANY")
          df <-  filter(df, STABBR == input$state)
      else
          cols <- c(cols, "STABBR") 
      df <-  mutate(df, ADM_RATE = round(ADM_RATE, 3))

      ## Append columns which always get shown here
      cols <- c(cols, "ADM_RATE")
      df <-  select(df, one_of(cols))
      return(df)
    }
    
    output$table <- renderDataTable(
      apply_settings_to_df(df),
        options = list(pageLength=5)
    )
    
    output$plot1 <- renderPlot({
      plot(df$standardized_score)
    })
    
    output$plot2 <- renderPlot({
      plot(df$ADM_RATE)
    })

})
