library(shiny)

ui <- fluidPage(
  h1("Example app"),
  sidebarLayout(
    sidebarPanel(
      numericInput("nrows", "Number of rows", 10)
    ),
    mainPanel(
      plotOutput("plot"),
      tableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  # Don't do this!

  rv <- reactiveValues(df = NULL)
  
  observeEvent(input$nrows, {
    rv$df <- head(cars, input$nrows)
  })
  
  output$plot <- renderPlot({
    plot(rv$df)
  })
  
  output$table <- renderTable({
    rv$df
  })
}

shinyApp(ui, server)
