# to record results from https://egov.uscis.gov/processing-times/
library(tidyverse)
library(jsonlite)
library(lubridate)
# find the API URL via Chrome Dev tools Network module
# NSC = Nebraska Service Center
url_i140 <- "https://egov.uscis.gov/processing-times/api/processingtime/I-140/NSC"
url_i485 <- "https://egov.uscis.gov/processing-times/api/processingtime/I-485/NSC"
url_i765 <- "https://egov.uscis.gov/processing-times/api/processingtime/I-765/NSC"

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

df1 <- get_estimate(url_i140) %>% add_column(form = "I-140")
df2 <- get_estimate(url_i485) %>% add_column(form = "I-485")
df3 <- get_estimate(url_i765) %>% add_column(form = "I-765")

df_new <- bind_rows(df1, df2, df3) %>%
  mutate(Date_check = Sys.Date()) %>%
  as_tibble()

df_curr <- df_new %>%
  filter(id %in% c("136A-E13", "I-485 Employment", "147-OTH")) %>%
  select(form, form_type, date_pub, date_receipt, month_max, month_min)

# write entire data to database
file_db <- "~/data/uscis_proc_time.csv"
# append if existing data found
if (file.exists(file_db)) {
  df_old <- suppressMessages(read_csv(file_db))
  print(paste("Nb. records in DB Before update:", nrow(df_old)))
  df_new <- bind_rows(df_new, df_old) %>%
    distinct()
}
print(paste("Nb. records in DB After update:", nrow(df_new)))
write_csv(df_new, file_db)

# write latest data to current file
file_current <- "~/data/uscis_current.csv"
if (file.exists(file_current)) {
  message("----Last results----")
  df_curr_old <- suppressMessages(read_csv(file_current))
  print(df_curr_old)
}

# if a data udpate is detected, save as a separate copy
if (!setequal(df_curr_old, df_curr)) {
  message("#### Update found !! ####")
  date_pub_old <- df_curr_old$date_pub[1] %>% as.character()
  file.rename(file_current, paste0("~/data/uscis", date_pub_old, ".csv"))
}

message("----Current results----")
print(df_curr)
write_csv(df_curr, file_current)

