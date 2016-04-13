# Shiny demo app: College Scorecard

This app is an example of Shiny's [HTML templates](http://shiny.rstudio.com/articles/templates.html) feature. It uses R and Shiny to present interesting information from the [College Scorecard Data](https://collegescorecard.ed.gov/data/) and is styled based on the [U.S. Web Design Standards](https://playbook.cio.gov/designstandards/).

Live app here: https://beta.rstudioconnect.com/jcheng/scorecard-app/

### Instructions

To run this app yourself, you'll need the following CRAN packages:

```r
install.packages(c("shiny", "dplyr", "RSQLite", "leaflet", "ggplot2",
  "showtext", "Cairo", "RCurl", "stringr", "scales"))
```

You'll also need to download this [CollegeScorecard.sqlite database](https://www.dropbox.com/s/rw846tfjj73eqin/CollegeScorecard.sqlite?dl=0) and put it in the scorecard-app directory.

### License

All content under `www/assets` is licensed according to [this page](https://github.com/18F/web-design-standards/blob/18f-pages-staging/LICENSE.md).

All R code and `www/index.html` are [CC0](https://creativecommons.org/publicdomain/zero/1.0/) (public domain). However, I do request that you not reuse the Flickr API key or MapBox (Leaflet) tile URL that are included in the code.