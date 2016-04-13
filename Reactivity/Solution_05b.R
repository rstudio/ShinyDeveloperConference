library(shiny)

ui <- fillPage(
  plotOutput("plot", click = "click", height = "100%")
)

server <- function(input, output, session) {
  rv <- reactiveValues(userPoints = NULL)
  
  # Same as Solution_05a.R, but instead of keeping
  # track of the single most recent point, we accumulate
  # all previous points using rbind().
  observeEvent(input$click, {
    if (!is.null(input$click)) {
      thisPoint <- data.frame(
        speed = input$click$x,
        dist = input$click$y
      )
      rv$userPoints <- rbind(rv$userPoints, thisPoint)
    }
  })
  
  output$plot <- renderPlot({
    df <- rbind(cars, rv$userPoints)
    plot(df, pch = 19)
    
    model <- lm(dist ~ speed, df)
    abline(model)
  })
}

shinyApp(ui, server)
