# Exercise 2 - solution

library(shiny)
library(gapminder)
library(dplyr)

gapModuleUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    plotOutput(ns("plot")),
    sliderInput(ns("year"), "Select Year", value = 1952, 
                min = 1952, max = 2007, step = 5,  
                animate = animationOptions(interval = 500))
  )
}

gapModule <- function(input, output, session, data) {
  
  # collect one year of data
  ydata <- reactive({
    filter(data, year == input$year)
  })
  
  xrange <- range(data$gdpPercap)
  yrange <- range(data$lifeExp)
  
  output$plot <- renderPlot({
    
    # draw background plot with legend
    plot(data$gdpPercap, data$lifeExp, type = "n", 
         xlab = "GDP per capita", ylab = "Life Expectancy", 
         panel.first = {
           grid()
           text(mean(xrange), mean(yrange), input$year, 
                col = "grey90", cex = 5)
         })
    
    legend("bottomright", legend = levels(data$continent), 
           cex = 1.3, inset = 0.01, text.width = diff(xrange)/5,
           fill = c("#E41A1C99", "#377EB899", "#4DAF4A99", 
                    "#984EA399", "#FF7F0099"))
    
    # Determine bubble colors
    cols <- c("Africa" = "#E41A1C99",
              "Americas" = "#377EB899",
              "Asia" = "#4DAF4A99",
              "Europe" = "#984EA399",
              "Oceania" = "#FF7F0099")[ydata()$continent]
    
    # add bubbles
    symbols(ydata()$gdpPercap, ydata()$lifeExp, circles = sqrt(ydata()$pop),
            bg = cols, inches = 0.5, fg = "white", add = TRUE)
  })
}




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
    tabPanel("All", gapModuleUI("all")),
    tabPanel("Africa", gapModuleUI("africa")),
    tabPanel("Americas", gapModuleUI("americas")),
    tabPanel("Asia", gapModuleUI("asia")),
    tabPanel("Europe", gapModuleUI("europe")),
    tabPanel("Oceania", gapModuleUI("oceania"))
  )
)

server <- function(input, output) {
  callModule(gapModule, "all", all_data)
  callModule(gapModule, "africa", africa_data)
  callModule(gapModule, "americas", americas_data)
  callModule(gapModule, "asia", asia_data)
  callModule(gapModule, "europe", europe_data)
  callModule(gapModule, "oceania", oceania_data)    
}

# Run the application 
shinyApp(ui = ui, server = server)

