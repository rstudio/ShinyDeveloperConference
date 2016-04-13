library(shiny)

ui <- fillPage(
  plotOutput("plot", click = "click", height = "100%")
)

# Assignment: This app doesn't work! It's supposed to let
# the user click on the plot, and have a data point appear
# where the click occurs. But as written, the data point
# only appears for a moment before disappearing.
# 
# This happens because each time the plot is re-rendered,
# the value of input$click is reset to NULL, and thus
# userPoint() becomes NULL as well.
# 
# Can you get a single user-added data point to stay?
# 
# Bonus points: Can you include not just the single most
# recent click, but ALL clicks made by the user?
# 
# Hint: You'll need to replace reactive() with a combo
# of reactiveValues() and observeEvent().

server <- function(input, output, session) {
  # Either NULL, or a 1-row data frame that represents
  # the point that the user clicked on the plot
  userPoint <- reactive({
    # input$click will be either NULL or list(x=num, y=num)
    click <- input$click
    
    if (is.null(click)) {
      # The user didn't click on the plot (or the previous
      # click was cleared by the plot being re-rendered)
      return(NULL)
    }
    
    data.frame(speed = click$x, dist = click$y)
  })
  
  output$plot <- renderPlot({
    # Before plotting, combine the original dataset with
    # the user data. (rbind ignores NULL args.)
    df <- rbind(cars, userPoint())
    plot(df, pch = 19)
    
    model <- lm(dist ~ speed, df)
    abline(model)
  })
}

shinyApp(ui, server)
