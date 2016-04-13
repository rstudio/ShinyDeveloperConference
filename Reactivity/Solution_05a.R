library(shiny)

ui <- fillPage(
  plotOutput("plot", click = "click", height = "100%")
)

server <- function(input, output, session) {
  # Instead of a reactive expression for userPoint, we
  # use a reactive value. This gives us more control
  # over when userPoint gets updated.
  rv <- reactiveValues(userPoint = NULL)
  
  observeEvent(input$click, {
    # Replace rv$userPoint, but only if input$click isn't NULL
    if (!is.null(input$click)) {
      rv$userPoint <- data.frame(
        speed = input$click$x,
        dist = input$click$y
      )
    }
  })
  
  output$plot <- renderPlot({
    # Now refers to rv$userPoint instead of userPoint().
    df <- rbind(cars, rv$userPoint)
    plot(df, pch = 19)
    
    model <- lm(dist ~ speed, df)
    abline(model)
  })
}

shinyApp(ui, server)
