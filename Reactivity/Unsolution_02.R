library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput("xcol", "X variable", names(iris)),
      selectInput("ycol", "Y variable", names(iris), names(iris)[2]),
      numericInput("rows", "Rows to show", 10)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data", br(),
          tableOutput("table")
        ),
        tabPanel("Summary", br(),
          verbatimTextOutput("dataInfo"),
          verbatimTextOutput("modelInfo")
        ),
        tabPanel("Plot", br(),
          plotOutput("plot")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # Don't do this!
  
  # Introduce reactive value for each calculated value
  values <- reactiveValues(selected = NULL, model = NULL)
  
  # Use observers to keep the values up-to-date
  observe({
    values$selected <- iris[, c(input$xcol, input$ycol)]
  })
  
  observe({
    values$model <- lm(paste(input$ycol, "~", input$xcol), values$selected)
  })

  # The outputs all use the reactive values
  
  output$plot <- renderPlot({
    
    plot(values$selected)
    abline(values$model)
  })
  
  output$modelInfo <- renderPrint({
    
    summary(values$model)
  })
  
  output$dataInfo <- renderPrint({
    
    summary(values$selected)
  })
  
  output$table <- renderTable({
    
    head(values$selected, input$rows)
  })
}

shinyApp(ui, server)
