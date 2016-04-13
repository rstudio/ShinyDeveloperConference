library(httr)

# Please don't copy my API key. Get your own here, it's fast and free:
# https://www.flickr.com/services/api/keys/apply/
api_key <- "4f9974ed9c4ba04650ae725d743c9986"

# Get a data frame for the search term; one photo will be selected at random
# from the top 10 most relevant
flickr_photos_search_one <- function(api_key, query) {
  resp <- GET(
    sprintf(
      "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&api_key=%s&text=%s&safe_search=1&content_type=1&per_page=10&sort=relevance",
      api_key,
      utils::URLencode(query)
    ),
    accept_json()
  )
  resp <- jsonlite::fromJSON(sub("^jsonFlickrApi\\((.*)\\)$", "\\1", rawToChar(resp$content)))
  if (length(resp$photos$photo) == 0 || nrow(resp$photos$photo) == 0)
    return(NULL)
  resp$photos$photo[sample.int(nrow(resp$photos$photo), 1),]
}

# Form image URLs from flickr photos data frame
flickr_photo_url <- function(photo) {
  if (is.null(photo) || nrow(photo) == 0)
    return(character(0))
  
  sprintf(
    "https://farm%s.staticflickr.com/%s/%s_%s.jpg",
    photo$farm,
    photo$server,
    photo$id,
    photo$secret
  )
}
