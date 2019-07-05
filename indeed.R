# example script to get data from Indeed
library(dplyr)
library(stringr)
library(readr)
library(rvest)

# URL for job search
url_jobs <- "https://www.indeed.com/q-Javascript-l-Minneapolis,-MN-jobs.html"
page <- read_html(url_jobs)

tbl_results <- page %>%
  html_nodes("#resultsBody")

job_links <- tbl_results %>%
  html_nodes(".title a")

titles <- job_links %>% 
  html_text(trim = TRUE)

detail_urls <- job_links %>% 
  html_attr("href") %>%
  str_extract("jk=[a-z0-9]+") %>%
  paste0("https://www.indeed.com/viewjob?", .)

companies <- tbl_results %>%
  html_nodes(".sjcl .company") %>% 
  html_text(trim = TRUE)

df <- tibble(
  title = titles,
  company = companies,
  detail = detail_urls
)

print(df)
write_excel_csv(df, paste0("job_", Sys.Date(), ".csv"))
