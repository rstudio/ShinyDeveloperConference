library(shiny)

ui <- fluidPage(
  h1("Example app"),
  sidebarLayout(
    sidebarPanel(
      numericInput("nrows", "Number of rows", 10)
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output, session) {
  # Don't do this!
  observe({
    df <- head(cars, input$nrows)
    output$plot <- renderPlot(plot(df))
  })
}

shinyApp(ui, server)
