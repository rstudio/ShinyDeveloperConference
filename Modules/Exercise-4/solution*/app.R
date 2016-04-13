# Exercise 4 - solution

library(shiny)

uploadModuleInput <- function(id) {
  ns <- NS(id)

  tagList(
    fileInput(ns("file"), "Select a csv file"),
    checkboxInput(ns("heading"), "Has header row"),
    checkboxInput(ns("strings"), "Coerce strings to factors"),
    textInput(ns("na.string"), "NA symbol", value = "NA")
  )
}

uploadModule <- function(input, output, session, ...) {

  userFile <- reactive({
    # If no file is selected, don't do anything
    req(input$file)
  })

  # The user's data, parsed into a data frame
  reactive({
    read.csv(userFile()$datapath,
      header = input$heading,
      stringsAsFactors = input$strings,
      na.string = input$na.string,
      ...)
  })
}

downloadModuleInput <- function(id) {
  ns <- NS(id)

  tagList(
    textInput(ns("filename"), "Save as", value = "data.csv"),
    downloadButton(ns("save"), "Save")
  )
}

downloadModule <- function(input, output, session, data, rnames) {
  output$save <- downloadHandler(
    filename = function() input$filename,
    content = function(file) {
      if (rnames())
         write.csv(data(), file)
      else
         write.csv(data(), file, row.names = FALSE)
    }
  )
}

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