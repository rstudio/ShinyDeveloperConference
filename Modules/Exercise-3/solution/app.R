# Exercise 3 - solution

library(shiny)
source("uploadModule.R")

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      uploadModuleInput("datafile")
    ),
    mainPanel(
      dataTableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  
  datafile <- callModule(uploadModule, "datafile")

  output$table <- renderDataTable({
    datafile()
  })
}

shinyApp(ui, server)