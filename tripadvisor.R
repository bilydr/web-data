 # --- TripAdvisor----
library(tidyverse)
library(rvest)

url_ta <- "https://www.tripadvisor.com/Attractions-g60878-Activities-Seattle_Washington.html"
page <- read_html(url_ta)

attractions <- page %>%
  html_nodes("#FILTERED_LIST .attraction_element")

id <- attractions %>%
  html_attr("id")

title <- attractions %>%
  html_nodes(".listing_title ") %>%
  html_text() %>%
  gsub("\n", "", .)


rating <- attractions %>%
  html_nodes(".listing_rating")

score <- rating %>%
  html_nodes(".wrap .ui_bubble_rating") %>%
  html_attr("alt") %>%
  parse_number()

n_review <- rating %>%
  html_nodes(".wrap .more") %>%
  html_text() %>%
  parse_number()

tags <- attractions %>%
  html_nodes(".tag_line") %>%
  html_text() %>%
  gsub("\n", "", .) %>%
  # split multiple tags into list of char vector
  str_split(", ")
  

df <- tibble(id, title, score, n_review, tags)
glimpse(df)
View(df)
