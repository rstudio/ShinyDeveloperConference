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
  # Assignment: Remove duplication of `selected` and `model`
  # code/calculations.
  
  output$plot <- renderPlot({
    
    selected <- iris[, c(input$xcol, input$ycol)]
    model <- lm(paste(input$ycol, "~", input$xcol), selected)
    
    plot(selected)
    abline(model)
  })
  
  output$modelInfo <- renderPrint({

    selected <- iris[, c(input$xcol, input$ycol)]
    model <- lm(paste(input$ycol, "~", input$xcol), selected)
    
    summary(model)
  })
  
  output$dataInfo <- renderPrint({

    selected <- iris[, c(input$xcol, input$ycol)]

    summary(selected)
  })
  
  output$table <- renderTable({
    
    selected <- iris[, c(input$xcol, input$ycol)]
    
    head(selected, input$rows)
  })
}

shinyApp(ui, server)
