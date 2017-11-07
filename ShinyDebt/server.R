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


### Income-based variables are mapped here for bulk inclusion at the
### end of the server function
LO_INC_COLS <- c("LO_INC_DEBT_MDN", "LO_INC_RPY_7YR_RT")
MED_INC_COLS <- c("MD_INC_DEBT_MDN", "MD_INC_RPY_7YR_RT")
HI_INC_COLS <- c("HI_INC_DEBT_MDN", "HI_INC_RPY_7YR_RT")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    ## Calculate the user's standardized_score from input data, need
    ## to know exactly how this was calculated for the college data
    ## and adjust here
    user_std_score <- reactive({max(input$satScore/1600, input$actScore/36)})
    
    cols <- c("INSTNM", "ADM_RATE", "standardized_score", "ACTCMMID", "UGDS",
              "SATVRMID", "SATMTMID", "MD_EARN_WNE_P6", "CONTROL", "STABBR",
              LO_INC_COLS, MED_INC_COLS, HI_INC_COLS)
              
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
          df <- mutate(df, SchoolType=mapvalues(CONTROL, c(1, 2, 3), c("Public", "Private", "For-profit"))) %>%
              rename(c("SchoolType"="School Type"))
          cols <- c(cols, "School Type")
      }
      if (input$state != "ANY")
          df <-  filter(df, STABBR == input$state)
      else
          cols <- c(cols, "STABBR") 
      df <-  mutate(df, ADM_RATE=round(ADM_RATE, 2),
                    MD_EARN_WNE_P6=round(MD_EARN_WNE_P6, 0),
                    UGDS=round(UGDS, 0),
                    LO_INC_RPY_7YR_RT=round(LO_INC_RPY_7YR_RT, 2),
                    MD_INC_RPY_7YR_RT=round(MD_INC_RPY_7YR_RT, 2),
                    HI_INC_RPY_7YR_RT=round(HI_INC_RPY_7YR_RT, 2),
                    LO_INC_DEBT_MDN=round(LO_INC_DEBT_MDN, 0),
                    MD_INC_DEBT_MDN=round(MD_INC_DEBT_MDN, 0),
                    HI_INC_DEBT_MDN=round(HI_INC_DEBT_MDN, 0))
      
      if(input$size != "ANY"){
          if (input$size == "small")
              df <- filter(df, UGDS <= 5000)
          else if (input$size == "med")
              df <- filter(df, (UGDS > 5000) & (UGDS <= 15000))
          else if (input$size == "large")
              df <- filter(df, UGDS > 15000)
      }
      ## Append columns which always get shown here
      cols <- c(cols, "ADM_RATE", "MD_EARN_WNE_P6", "UGDS")
      
      if(input$income == "low")
          cols <- c(cols, LO_INC_COLS)
      else if(input$income == "medium")
          cols <- c(cols, MED_INC_COLS)
      else if(input$income == "high")
          cols <- c(cols, HI_INC_COLS)

      df <-  select(df, one_of(cols))
      df = rename(df, c("INSTNM"="Institution", "ADM_RATE"="Admission rate", "STABBR"="State",
                        "MD_EARN_WNE_P6"="Post-grad wage", "UGDS"="Students",
                        "LO_INC_DEBT_MDN"="Post-grad debt", "LO_INC_RPY_7YR_RT"="Repayment rate",
                        "MD_INC_DEBT_MDN"="Post-grad debt", "MD_INC_RPY_7YR_RT"="Repayment rate",
                        "HI_INC_DEBT_MDN"="Post-grad debt", "HI_INC_RPY_7YR_RT"="Repayment rate"))
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
