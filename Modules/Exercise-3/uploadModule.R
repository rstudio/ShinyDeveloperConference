# Exercise 3
#
# 1. Arrange for uploadModuleInput() to return its output objects 
#    in the correct format for a module ui function
#
# 2. Arrange for uploadModule() to return the parsed data frame 
#    in the correct output format for a module server function 

uploadModuleInput <- function(id) {
  ns <- NS(id)

  fileInput(ns("file"), "Select a csv file")
  checkboxInput(ns("heading"), "Has header row")
  checkboxInput(ns("strings"), "Coerce strings to factors")
  textInput(ns("na.string"), "NA symbol", value = "NA")
}

uploadModule <- function(input, output, session, ...) {

  userFile <- reactive({
    # If no file is selected, don't do anything
    req(input$file)
  })

  # The user's data, parsed into a data frame
  read.csv(userFile()$datapath,
    header = input$heading,
    stringsAsFactors = input$strings,
    na.string = input$na.string,
    ...)
}