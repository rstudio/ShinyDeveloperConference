library(shiny)

# Simple version. Works, unless the `r` reactive can error.
dedupe <- function(r) {
  rv <- reactiveValues(value = isolate(r()))
  
  observe({
    # Takes advantage of a little-known feature: reactive
    # values ignore assignment if the new value is identical
    # to the current value. If you didn't know that, you
    # could achieve the equivalent behavior with:
    # if (identical(isolate(rv$value), r()))
    #   rv$value <- r()
    rv$value <- r()
  })
  reactive({
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