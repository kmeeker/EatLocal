#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("EatLocal - Shop Community Supported Agricuture and Farmer's Markets"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
        h4('Select items to display for date open'),
        checkboxGroupInput("id1", "Display:",
                           c("CSA" = "1",
                             "Farmers Markets" = "2")),
        dateInput("date", "Date Open:")
        #h4('You entered'),
        #verbatimTextOutput("oid1")

    ),
    
    # Show a plot of the generated distribution
    mainPanel(
 
       plotOutput("distPlot")
    )
  )
))
