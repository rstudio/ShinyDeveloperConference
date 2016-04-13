# Exercise 4 - solution

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
  
  callModule(downloadModule, "download", datafile, reactive(input$row.names))
}

shinyApp(ui, server)