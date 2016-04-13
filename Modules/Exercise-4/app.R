# Exercise 4 
#
# 1. Open downloadModule.R and finish the downloadModule() function
#
# 2. Finish the call to callModule() below

library(shiny)
source("uploadModule.R")
source("downloadModule.R")

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      uploadModuleInput("datafile"),
      tags$hr(),
      checkboxInput("row.names", "Append row names"),
      downloadModuleInput("download")
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
  
  callModule(downloadModule, "download", # pass datafile and input$row.names to downloadModule(), but how?)
}

shinyApp(ui, server)