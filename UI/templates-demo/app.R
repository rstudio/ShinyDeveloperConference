ui <- htmlTemplate("template.html",
  plot = plotOutput("dist"),
  slider = sliderInput("num", "Number of points", 1, 100, 50)
)

server <- function(input, output) {
  output$dist <- renderPlot({
    x <- rnorm(input$num)
    y <- rnorm(input$num)
    plot(x, y)
  })
}

shinyApp(ui, server)