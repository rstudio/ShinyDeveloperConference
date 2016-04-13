library(shiny)

ui <- fluidPage(
  h1("Example app"),
  sidebarLayout(
    sidebarPanel(
      numericInput("nrows", "Number of rows", 10),
      actionButton("save", "Save")
    ),
    mainPanel(
      plotOutput("plot"),
      tableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  df <- reactive({
    head(cars, input$nrows)
  })
  
  output$plot <- renderPlot({
    plot(df())
  })
  
  output$table <- renderTable({
    df()
  })
  
  # Assignment: Add logic so that when the "save" button
  # is pressed, the data is saved to a CSV file called
  # "data.csv" in the current directory.
}

shinyApp(ui, server)
