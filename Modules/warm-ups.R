# 1
slider <- function() {
  sliderInput("slider", "Slide Me", 0, 100, 1)
}

ui <- fluidPage(
  slider(),
  textOutput("num")
)

server <- function(input, output) {
  output$num <- renderText({input$slider})
}

shinyApp(ui, server)


# 8
slider <- function() {
  sliderInput("slider", "Slide Me", 0, 100, 1)
}

ui <- fluidPage(
  slider(),
  textOutput("num1"),
  slider(),
  textOutput("num2")
)

server <- function(input, output) {
  output$num1 <- renderText({input$slider})
  output$num2 <- renderText({input$slider})
}

shinyApp(ui, server)


# 9
slider <- function(id) {
  sliderInput(id, "Slide Me", 0, 100, 1)
}

ui <- fluidPage(
  slider("slider1"),
  textOutput("num1"),
  slider("slider2"),
  textOutput("num2")
)

server <- function(input, output) {
  output$num1 <- renderText({input$slider1})
  output$num2 <- renderText({input$slider2})
}

shinyApp(ui, server)

# 1
foo <- function() {
  x <- 1
  y <- 2
  z <- 3
}

bar <- function() {
  print(x)
}

foo()
bar()


# 2
foo <- function() {
  x <- 1
  y <- 2
  z <- 3
  environment()
}

bar <- function(e) {
  x <- get("x", envir = e)
  print(x)
}

q <- foo()
bar(q)


# 3
foo <- function() {
  assign("x", value = 1, pos = 1)
  assign("y", value = 2, pos = 1)
  assign("z", value = 3, pos = 1)
}

bar <- function() {
  print(x)
}

foo()
bar()


# 4
e <- new.env()

foo <- function() {
  e$x <- 1
  e$y <- 2
  e$z <- 3
}

bar <- function() {
  print(e$x)
}

foo()
bar()


# 5
foo <- function() {
  x <- 1
  y <- 2
  z <- 3
  list(x = x, y = y, z = z)
}

bar <- function(a) {
  print(a$x)
}

q <- foo()
bar(q)






