# Exercise 2
#
# 1. Open the gapModule.R file. Arrange for gapModule() to take a 
#    data set in its arguments
#
# 2. Use the new module to complete the app below. 
#    You will need to replace the comments in the code.

library(shiny)
library(gapminder)
library(dplyr)
source("gapModule.R")

# Note: This code creates data sets to use in each tab.
# It removes Kuwait since Kuwait distorts the gdp scale
all_data <- filter(gapminder, country != "Kuwait")
africa_data <- filter(gapminder, continent == "Africa")
americas_data <- filter(gapminder, continent == "Americas")
asia_data <- filter(gapminder, continent == "Asia", country != "Kuwait")
europe_data <- filter(gapminder, continent == "Europe")
oceania_data <- filter(gapminder, continent == "Oceania")

ui <- fluidPage(
  titlePanel("Gapminder"),
  tabsetPanel(id = "continent", 
    tabPanel("All", # A module that displays all countries),
    tabPanel("Africa", # A module that displays only African countries),
    tabPanel("Americas", # A module that displays only American countries),
    tabPanel("Asia", # A module that displays only Asian countries),
    tabPanel("Europe", # A module that displays only European countries),
    tabPanel("Oceania", # A module that displays only Oceanic countries)
  )
)

server <- function(input, output) {
  
  # Load the server logic for a module that displays all countries. 
  # What should you pass to the new data argument?
  
  # Load the server logic for a module that displays African countries.
  # What should you pass to the new data argument?
  
  # Load the server logic for a module that displays American countries.
  # What should you pass to the new data argument?
  
  # Load the server logic for a module that displays Asian countries.
  # What should you pass to the new data argument?
  
  # Load the server logic for a module that displays European countries.
  # What should you pass to the new data argument?
  
  # Load the server logic for a module that displays Oceanic countries.
  # What should you pass to the new data argument?
  
}

# Run the application 
shinyApp(ui = ui, server = server)

