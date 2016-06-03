library(shiny)

dedupe <- function(r) {
  # Assignment: Implement this function. The parameter is
  # a reactive expression. The return value should be a
  # reactive expression that, when invalidated, does *not*
  # invalidate its dependencies. In other words, the line
  # "Executing renderText" would get printed when x changes
  # from 9 to 10, but not get printed when it changes from
  # 8 to 9.
  
  r
}

ui <- fluidPage(
  numericInput("x", "x", 2),
  textOutput("msg")
)

server <- function(input, output, session) {
  rounded <- reactive({
    floor(input$x / 5) * 5
  })
  
  rounded <- dedupe(rounded)
  
  output$msg <- renderText({
    cat(as.character(Sys.time()), " Executing renderText\n")
    rounded()
  })
}

shinyApp(ui, server)