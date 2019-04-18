library(rvest)
library(tidyverse)
library(purrr)
library(tidytext)

# Scraping all the transcript
url_list = list(
  nauru_a = "http://www.austlii.edu.au/au/other/HCATrans/2018/230.html",
  nauru_b = "http://www.austlii.edu.au/au/other/HCATrans/2018/231.html",
  rinehart_a = "http://www.austlii.edu.au/au/other/HCATrans/2018/234.html",
  rinehart_b = "http://www.austlii.edu.au/au/other/HCATrans/2018/236.html",
  parkes = "http://www.austlii.edu.au/au/other/HCATrans/2018/237.html", 
  mckell = "http://www.austlii.edu.au/au/other/HCATrans/2018/257.html",
  oks= "http://www.austlii.edu.au/au/other/HCATrans/2019/11.html"
)
last_para = list(363, 241, 1168, 292, 615, 418, 142)

html_list <- map(url_list, read_html)
xpath <- map(last_para, ~paste0("/html/body/p[", seq(7, .x, 1), "]"))
text <- map2(html_list, xpath, function(html, xpath){
  map(xpath, ~html %>% html_nodes(xpath = .x) %>% html_text)
})

# Text Analysis dt[1]
dt <- map(text, unlist)
temp <- unlist(dt[1])
tdata <- tibble(text = temp) %>% 
  mutate(line = row_number()) %>% 
  filter(line > 32) %>% 
  unnest_tokens(word, text, to_lower = FALSE)

# three judges, Merkel is the appellent and Kennett is the respondent
people <- c("GAGELER", "NETTLE","EDELMAN", "KENNETT", "MERKEL")
role <- c("judge","judge","judge", "respondent","appellant")
portfolio <- tibble(people, role)

token %>% 
  anti_join(stop_words) %>% 
  count(word, sort = TRUE) %>% 
  filter(word %in% portfolio$people) %>% 
  mutate(role = portfolio$role[match(word, portfolio$people)])

tdata %>% filter(word == "KENNETT")

# another try on dt[2]
naurub <- unlist(dt[2])
n_t <- tibble(text = temp) %>% mutate(line = row_number())

n_t


token <- tdata %>% unnest_tokens(word, text, to_lower = FALSE)

people <- list("GAGELER", "NETTLE","EDELMAN", "KENNETT", "MERKEL")
token %>% anti_join(stop_words) %>% count(word, sort = TRUE) %>% filter(word %in% people)
