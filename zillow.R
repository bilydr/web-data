library(tidyverse)
library(rvest)

# URL for Wayzata townhomes for sales
url_zillow <- "https://www.zillow.com/homes/for_sale/Wayzata-MN/townhouse_type/"
page <- read_html(url_zillow)

houses <- page %>%
  html_nodes(".photo-cards li article")

z_id <- houses %>%
  html_attr("id")

address <- houses %>%
  html_nodes(".zsg-photo-card-address") %>%
  html_text()

price <- houses %>%
  html_nodes(".zsg-photo-card-price") %>%
  html_text() %>%
  parse_number()

params <- houses %>%
  html_nodes(".zsg-photo-card-info") %>%
  html_text() %>%
  # split by middle dot - http://www.fileformat.info/info/unicode/char/b7/index.htm
  strsplit("\u00b7")

beds <- params %>%
  map_chr(1) %>%
  parse_number()

baths <- params %>%
  map_chr(2) %>%
  parse_number()

area_sqft <- params %>%
  map_chr(3) %>%
  parse_number()

url_details <- houses %>%
  html_nodes(".zsg-photo-card-overlay-link") %>%
  html_attr("href") %>%
  paste0("https://www.zillow.com", .)
  
dom <- houses %>%
  html_nodes(".zsg-list_inline") %>%
  html_text() %>%
  gsub("&nbsp", " ", .) %>%
  gsub(" on Zillow", "", .)

df <- tibble(
  z_id,
  address,
  beds,
  baths,
  area_sqft,
  price,
  dom,
  url_details
)

print(df)
write_excel_csv(df, paste0("zillow", Sys.Date(), ".csv"))
