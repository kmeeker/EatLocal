#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

source("EatLocal.R", local=TRUE)

csa <- read.csv("CSA_loc.csv", stringsAsFactors = FALSE)
csa_loc <- subset(csa, !is.na(lat) & !is.na(lon))

fm <- read.csv("FarmersMarkets_loc.csv", stringsAsFactors = FALSE)
fm_loc <- subset(fm, !is.na(lat) & !is.na(lon))

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
  output$distPlot <- renderPlot({
  
    if ("1" %in% input$id1) {
        csa=TRUE
    } else {
        csa=FALSE
    }
    if ("2" %in% input$id1) {
        fm=TRUE
    } else {
        fm=FALSE
    }
    
    plot_eat_local_map(input$date, csa, fm) 
    
    # map <- get_map(location = 'United States', zoom = 4) # zoom 0-21
    # map <- ggmap(map)
    # 
    # if ("1" %in% input$id1) {
    #     cur_csa <- subset(csa_loc, grepl(month,csa_loc$Available_Months))
    #     map <- map +
    #     geom_point(aes(x = lon, y = lat), data = cur_csa, colour="#006400")
    # }
    # map
  })
})
