library(dplyr)
library(RSQLite)
library(leaflet)
library(ggplot2)
library(showtext)
library(Cairo)
library(RCurl) # needed for showtext

font.add.google("Source Sans Pro", "Source Sans Pro")
showtext.auto()

source("flickr_api.R")

db <- src_sqlite("CollegeScorecard.sqlite")

# Mistakes were made...
options(shiny.table.class = "usa-table-borderless")

query_db <- function(query) {
  conn <- dbConnect(SQLite(), dbname = "CollegeScorecard.sqlite")
  on.exit(dbDisconnect(conn), add = TRUE)
  
  dbGetQuery(conn, query)
}

format_badge <- function(icon_name, label) {
  tagList(
    icon(icon_name, class = "fa-2x fa-fw"),
    br(),
    span(
      label
    )
  )
}

# Some names in the dataset are in ALL CAPS... gross. Convert to title case.
uncap <- function(str) {
  allcap <- str == toupper(str)
  str[allcap] <- stringr::str_to_title(str[allcap])
  str
}

function(input, output, session) {
  qs <- isolate(parseQueryString(session$clientData$url_search))
  
  rv <- reactiveValues(app_mode = "search")
  if (!is.null(qs$id)) {
    rv$schooldata <- query_db(sprintf("SELECT * FROM data WHERE id = %d ORDER BY year", as.numeric(qs$id))) %>%
      mutate(school.name = uncap(school.name), school.city = uncap(school.city))
    rv$schoolsummary <- tail(isolate(rv$schooldata), 1)
    rv$app_mode <- "details"
  }
  
  observeEvent(input$search_button, {
    rv$app_mode <- "search"
  })
  
  output$app_mode <- reactive({
    rv$app_mode
  })
  outputOptions(output, "app_mode", suspendWhenHidden = FALSE)
  
  search_results <- eventReactive(input$search_button, {
    req(input$search)
    validate(need(nchar(input$search) >= 3, "Please enter at least three characters"))
    
    results <- db %>% tbl("schoolnames") %>% arrange(school.name) %>% collect() %>%
      filter(
        grepl(tolower(input$search), tolower(school.name), fixed = TRUE) |
          grepl(tolower(input$search), tolower(school.city), fixed = TRUE)
      )
    results
  }, ignoreNULL = FALSE)
  
  output$search_results <- renderUI({
    sr <- search_results()

    total_rows <- nrow(sr)
    if (total_rows > 100) {
      sr <- head(sr, 100)
    }

    withTags(
      div(class = "usa-grid",
        div(class = "usa-width-one-whole",
          h2("Search results"),
          if (nrow(sr) == 0) {
            h6("No results")
          } else if (nrow(sr) == 1) {
            h6("One result found")
          } else if (total_rows != nrow(sr)) {
            h6("First ", nrow(sr), " of ", total_rows, " results shown")
          } else {
            h6(nrow(sr), " results found")
          },
          table(class = "usa-table-borderless",
            mapply(USE.NAMES = FALSE, SIMPLIFY = FALSE, function(id, name, city, state) {
              tr(
                td(
                  strong(a(href = paste0("?id=", id), target = "_top", name))
                ),
                td(
                  sprintf("%s, %s", city, state)
                )
              )
            }, sr$id, uncap(sr$school.name), uncap(sr$school.city), sr$school.state)
          )
        )
      )
    )
  })
  
  output$school_name <- renderText({
    rv$schoolsummary$school.name
  })
  output$school_city <- renderText({
    paste(
      rv$schoolsummary$school.city,
      rv$schoolsummary$school.state,
      sep = ", "
    )
  })
  output$school_size <- renderText({
    paste(
      format(rv$schoolsummary$student.size, big.mark = ","),
      "undergraduate students"
    )
  })
  output$school_url <- renderUI({
    url <- req(rv$schoolsummary$school.school_url)
    tags$a(href = paste0("http://", url), url)
  })
  output$degree_type <- renderUI({
    format_badge("graduation-cap", 
      if (req(rv$schoolsummary$school.degrees_awarded.predominant) == 3) {
        "Four year"
      } else if (rv$schoolsummary$school.degrees_awarded.predominant == 2) {
        "Two year"
      } else if (rv$schoolsummary$school.degrees_awarded.predominant == 1) {
        "Certificate"
      } else if (rv$schoolsummary$school.degrees_awarded.predominant == 4) {
        "Graduate"
      } else {
        "(Unknown)"
      }
    )
  })
  output$school_ownership <- renderUI({
    format_badge("university",
      if (req(rv$schoolsummary$school.ownership) == 2) {
        "Private"
      } else if (rv$schoolsummary$school.ownership == 1) {
        "Public"
      } else if (rv$schoolsummary$school.ownership == 3) {
        "For-profit"
      }
    )
  })
  output$school_locale <- renderUI({
    locale <- rv$schoolsummary$school.locale
    req(locale)

    format_badge("home", 
      # Codes defined here: https://nces.ed.gov/ccd/rural_locales.asp
      if (locale %in% c(1,2,11,12,13)) {
        "City"
      } else if (locale %in% c(3,4,21,22,23)) {
        "Suburb"
      } else if (locale %in% c(5,6,31,32,33)) {
        "Town"
      } else if (locale %in% c(7,8,41,42,43)) {
        "Rural"
      }
    )
  })
  output$school_size_class <- renderUI({
    size <- rv$schoolsummary$student.size
    req(size)
    
    format_badge("users",
      if (size < 2000)
        "Small"
      else if (size <= 15000)
        "Medium"
      else
        "Large"
    )
  })
  output$map <- renderLeaflet({
    lat <- rv$schoolsummary$location.lat
    lon <- rv$schoolsummary$location.lon
    
    req(lat, lon)
    
    if (lon > 0)
      lon <- -lon
    
    # Please use a different tile URL for your own apps--we pay for these!
    leaflet() %>% addTiles("//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png") %>%
      addMarkers(lng = lon, lat = lat)
  })
  output$cost <- renderText({
    cost <- tail(na.omit(rv$schooldata$cost.avg_net_price.overall), 1)
    if (length(cost) == 0)
      return("No data")
    
    paste0(
      "$",
      format(cost, big.mark = ",")
    )
  })
  output$admit_rate <- renderText({
    rate <- tail(na.omit(rv$schooldata$admissions.admission_rate.overall), 1)
    if (length(rate) == 0)
      return("No data")
    
    paste0(
      rate * 100,
      "%"
    )
  })
  output$salary <- renderText({
    salary <- tail(na.omit(rv$schooldata$earnings.10_yrs_after_entry.median), 1)
    if (length(salary) == 0)
      return("No data")
    
    paste0(
      "$",
      format(salary, big.mark = ",")
    )
  })
  
  output$cost_by_income <- renderTable({
    levels <- c(
      "$0 to $30,000" = "0.30000",
      "$30,001 to $48,000" = "30001.48000",
      "$48,001 to $75,000" = "48001.75000",
      "$75,001 to $110,000" = "75001.110000",
      "$110,001+" = "110001.plus"
    )
    value_for_level <- function(lvl) {
      priv <- rv$schooldata[[paste0("cost.net_price.private.by_income_level.", lvl)]]
      pub <- rv$schooldata[[paste0("cost.net_price.public.by_income_level.", lvl)]]
      combined <- ifelse(is.na(priv), pub, priv)
      val <- tail(na.omit(combined), 1)
      if (length(val) == 0) {
        "(No data)"
      } else {
        paste0("$", format(val, big.mark = ","))
      }
    }

    data.frame(
      Income = names(levels),
      Cost = vapply(levels, value_for_level, character(1)),
      stringsAsFactors = FALSE
    )    
  }, include.rownames = FALSE)
  
  output$cost_by_year <- renderPlot({
    cost <- rv$schooldata %>% select(year, cost.avg_net_price.overall) %>%
      mutate(year = factor(year, ordered = TRUE)) %>%
      filter(!is.na(cost.avg_net_price.overall))
    
    if (nrow(cost) == 0) {
      return(NULL)
    }
    
    cost %>%
      ggplot(aes(year, cost.avg_net_price.overall)) +
      geom_bar(stat = "identity", fill = "#5b616b", width = 0.5) + 
      scale_y_continuous(labels = scales::dollar, expand = c(0.1, 0)) +
      scale_x_discrete() +
      geom_text(
        aes(label=paste0("$", format(cost.avg_net_price.overall, big.mark = ","))),
        vjust=-0.8, color="white", size = 4.7, family = "Source Sans Pro", fontface = "bold") +
      theme(
        plot.background = element_rect(fill = "transparent", color = "transparent"),
        text = element_text(family = "Source Sans Pro", color = "white"),
        axis.text = element_text(family = "Source Sans Pro", color = "white", size = 11),
        axis.text.x = element_text(face = "bold", size = 14),
        axis.title = element_blank(),
        panel.background = element_rect(fill = "transparent"),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_line(color = "#5b616b"),
        panel.grid.major.x = element_blank()
      )
  }, bg = "transparent")
  
  output$extras <- renderUI({
    if (rv$app_mode == "search") {
      sr <- try(search_results(), silent = TRUE)
      if (inherits(sr, "try-error")) {
        tags$style(type="text/css",
          "footer { display: block; }",
          "@media screen and (min-height: 700px) { footer { position: fixed; bottom: 0; height: auto; left: 0; right: 0; } }"
        )
      }
    } else if (!is.null(rv$schoolsummary)) {
      tags$style(type="text/css",
        # Dynamically show flickr photo as background image, using school name
        # as search criteria
        sprintf(
          "header[role='banner'] { background-image: linear-gradient( rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.4) ), url(%s); }",
          flickr_photo_url(flickr_photos_search_one(api_key, rv$schoolsummary$school.name))
        ),
        "footer {display: block;}"
      )
    }
  })
}
