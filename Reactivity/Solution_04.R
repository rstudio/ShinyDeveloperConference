library(shiny)

ui <- fluidPage(
  h1("Example app 4"),
  sidebarLayout(
    sidebarPanel(
      actionButton("rnorm", "Normal"),
      actionButton("runif", "Uniform")
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output, session) {
  v <- reactiveValues(data = runif(100))
  
  observeEvent(input$runif, {
    v$data <- runif(100)
  })
  
  observeEvent(input$rnorm, {
    v$data <- rnorm(100)
  })  
  
  output$plot <- renderPlot({
    hist(v$data)
  })
}

shinyApp(ui, server)
