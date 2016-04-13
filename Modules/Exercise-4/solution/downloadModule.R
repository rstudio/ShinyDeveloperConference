# Exercise 4 - solution

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