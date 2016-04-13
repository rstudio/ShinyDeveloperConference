# Exercise 1 - solution

library(shiny)
library(gapminder)
library(dplyr)
source("gapModule.R")

ui <- fluidPage(
  gapModuleUI("all")
)

server <- function(input, output) {
  callModule(gapModule, "all")
}

# Run the application 
shinyApp(ui = ui, server = server)
