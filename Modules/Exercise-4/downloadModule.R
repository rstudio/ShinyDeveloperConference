# Exercise 4
#
# 1. Add two arguments to downloadModule() to collect 
#    the values of datafile and input$row.names
# 
# 2. Finish the code in downloadModule() so that 
#    downloadModule() correctly calls the values of datafile 
#    and input$row.names. Consider which type of object each 
#    is when downloadModule() receives it

downloadModuleInput <- function(id) {
  ns <- NS(id)

  tagList(
    textInput(ns("filename"), "Save as", value = "data.csv"),
    downloadButton(ns("save"), "Save")
  )
}

downloadModule <- function(input, output, session) {
  output$save <- downloadHandler(
    filename = function() input$filename,
    content = function(file) {
      if (# check if input$row.names is true, but how?)
         write.csv(# call datafile(), but how?, file)
      else
         write.csv(# call datafile(), but how?, file, row.names = FALSE)
    }
  )
}