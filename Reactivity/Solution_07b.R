library(shiny)

# Simple version. Works, unless the `r` reactive can error.
dedupe <- function(r) {
  rv <- reactiveValues(value = isolate(try(r(), silent = TRUE)))
  
  observe({
    rv$value <- try(r(), silent = TRUE)
  })
  
  reactive({
    if (inherits(rv$value, "try-error"))
      stop(attr(rv$value, "condition"))
    
    rv$value
  })
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