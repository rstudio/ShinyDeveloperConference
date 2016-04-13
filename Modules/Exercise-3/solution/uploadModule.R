# Exercise 3 - solution

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