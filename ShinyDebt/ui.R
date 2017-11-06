#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(data.table)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("College Cost Predictor"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       numericInput("satScore",
                   "Sat Score:",
                   min = 400,
                   max = 1600,
                   value = 1100,
                   step = 50),
       
       numericInput("actScore",
                   "ACT Score:",
                   min = 1,
                   max = 36,
                   value = 21),
       
       selectInput("state", "Choose a state:",
                   list(`Any` = c("ANY"),
                        "AL", "AK", "AZ", "AR", "CA", "CO",
                        "CT", "DE", "FL", "GA", "HI", "ID",
                        "IL", "IN", "IA", "KS", "KY", "LA",
                        "ME", "MD", "MA", "MI", "MN", "MS",
                        "MO", "MT", "NE", "NV", "NH", "NJ",
                        "NM", "NY", "NC", "ND", "OH", "OK",
                        "OR", "PA", "RI", "SC", "SD", "TN",
                        "TX", "UT", "VT", "VA", "WA", "WV",
                        "WI", "WY")),
       
       selectInput("pub_priv", "Public or Private?",
                   c("Public" = 1,
                     "Private" = 2,
                     "Not sure" = "ANY")),
       
       selectInput("size", "Size of School?",
                   c("Any" = "ANY",
                     "Small" = "small",
                     "Medium" = "med",
                     "Large" = "large")),

       selectInput("income", "Family Income?",
                   c("<$30,000" = "low",
                     "$30,000-$75,000" = "medium",
                     ">$75,000" = "high"))
    ),
    
        
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Table", dataTableOutput('table')),
        tabPanel("Plot1", plotOutput('plot1')),
        tabPanel("Plot2", plotOutput('plot2'))
      )
    )
  )
))
