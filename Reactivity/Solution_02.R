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
  
  # Introduce reactive expression for each calculated value

  selected <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })
  
  model <- reactive({
    lm(paste(input$ycol, "~", input$xcol), selected())
  })
  
  # And now the outputs can just use the reactive expressions
    
  output$plot <- renderPlot({
    
    plot(selected())
    abline(model())
  })
  
  output$modelInfo <- renderPrint({

    summary(model())
  })
  
  output$dataInfo <- renderPrint({

    summary(selected())
  })
  
  output$table <- renderTable({
    
    head(selected(), input$rows)
  })
}

shinyApp(ui, server)
