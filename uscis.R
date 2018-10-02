# to record results from https://egov.uscis.gov/processing-times/
library(tidyverse)
library(jsonlite)
library(lubridate)
# find the API URL via Chrome Dev tools Network module
# NSC = Nebraska Service Center
url_i140 <- "https://egov.uscis.gov/processing-times/api/processingtime/I-140/NSC"
url_i485 <- "https://egov.uscis.gov/processing-times/api/processingtime/I-485/NSC"

get_estimate <- function(url_api) {
  res <- fromJSON(url_api)
  
  df <- res$data$processing_time$subtypes %>%
    mutate(date_pub = mdy(publication_date),
           date_receipt = mdy(service_request_date)) %>%
    select(id = form_type, date_pub, date_receipt, range, 	
           form_type = subtype_info_en)
  
  df$month_max <- df$range %>%
    map("value") %>%
    map_dbl(1)
  
  df$month_min <- df$range %>%
    map("value") %>%
    map_dbl(2)
  
  df %>%
    select(-range)
}

df1 <- get_estimate(url_i140)
df2 <- get_estimate(url_i485)

df <- bind_rows(df1, df2) %>%
  mutate(Date_check = Sys.Date())


print(df[,1:3])

file_db <- "uscis_proc_time.csv"

if (file.exists(file_db)) {
  df0 <- read_csv(file_db)
  df <- bind_rows(df, df0) %>%
    distinct()
}

write_csv(df, file_db)