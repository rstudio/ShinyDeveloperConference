# Exercise 3
#
# 1. Open uploadModule.R. Finish updloadModuleInput() and uploadModule() 
# so that each returns an object in the correct format to use below.
#
# 2. Finish the app below so that 
#    a. The uploadModule input objects appear in the sidebar, and
#    b. The uploaded data appears in output$dataTable

library(shiny)
source("uploadModule.R")

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      # Hint: Place input objects here, but how?
    ),
    mainPanel(
      dataTableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  
  # Hint: Make datafile here, but how?

  output$table <- renderDataTable({
    datafile()
  })
}

shinyApp(ui, server)