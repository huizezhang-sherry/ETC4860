library(rvest)
library(tidyverse)
library(purrr)
library(tidytext)

# Scraping all the transcript
url_list = list(
  Nauru_a = "http://www.austlii.edu.au/au/other/HCATrans/2018/230.html",
  Nauru_b = "http://www.austlii.edu.au/au/other/HCATrans/2018/231.html",
  Rinehart_a = "http://www.austlii.edu.au/au/other/HCATrans/2018/234.html",
  Rinehart_b = "http://www.austlii.edu.au/au/other/HCATrans/2018/236.html",
  Parkes = "http://www.austlii.edu.au/au/other/HCATrans/2018/237.html", 
  McKell = "http://www.austlii.edu.au/au/other/HCATrans/2018/257.html",
  OKS= "http://www.austlii.edu.au/au/other/HCATrans/2019/11.html"
)
last_para = list(363, 241, 1168, 292, 615, 418, 142)

html_list <- map(url_list, read_html)
xpath <- map(last_para, ~paste0("/html/body/p[", seq(7, .x, 1), "]"))
text <- map2(html_list, xpath, function(html, xpath){
  map(xpath, ~html %>% html_nodes(xpath = .x) %>% html_text)
})

# Create a tibble for judge, appellent and respondent for all the cases
people = vector(length = 45)
role = vector(length = 45)
case = vector(length = 45)

people[1:5] <- c("GAGELER", "NETTLE","EDELMAN", "KENNETT", "MERKEL")
role[1:5] <- c("Chief Judge","Judge","Judge", "Respondent","Appellant")
case[1:5] <- "Nauru_a"

people[6:10] <- list("GAGELER", "NETTLE","EDELMAN", "KENNETT", "GILBERT")
role[6:10] <- c("Chief Judge","Judge","Judge", "Respondent","Appellant")
case[6:10] <- "Nauru_b"

people[11:17] <-c("BELL", "GAGELER", "KEANE", "GORDON", "EDELMAN", "JORDAN","ABRAHAM") 
role[11:17] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[11:17] <- "McKell"


people[18:24] <-c("BELL", "KEANE", "NETTLE", "GORDON", "EDELMAN", "VANDONGEN","FORRESTER") 
role[18:24] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[18:24] <- "OKS"

people[25:31] <-c("KIEFEL", "BELL","KEANE", "GORDON", "EDELMAN", "WILLIAMS","GLEESON") 
role[25:31] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[25:31] <- "Parkes"


people[32:38] <-c("KIEFEL", "GAGELER","NETTLE", "GORDON", "EDELMAN", "WALKER","HUTLEY") 
role[32:38] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[32:38] <- "Rinehart_a"

people[39:45] <-c("KIEFEL", "GAGELER","NETTLE", "GORDON", "EDELMAN", "NG","HUTLEY") 
role[39:45] <- c("Chief Judge","Judge","Judge", "Judge","Judge", "Respondent","Appellant")
case[39:45] <- "Rinehart_b"

people <- unlist(people)
portfolio <- tibble(people, role, case)

# compute people's freqency for all the cases
compute_frequency <- function(x){
  temp <- unlist(x)
  
  tibble(text = temp) %>% 
    mutate(line = row_number()) %>% 
    filter(line >= 32) %>% 
    unnest_tokens(word, text, to_lower = FALSE)%>% 
    count(word) %>% 
    filter(word %in% portfolio$people) 
}


dt <- map(text, unlist)
list<- map(dt, compute_frequency)
repitition <- map(list, ~nrow(.x))
case = unlist(map2(names(list), repitition, ~rep(.x, .y)))


freq <- map_df(dt, compute_frequency) %>% 
  add_column(case) 
names(freq)[1] = "people"
names(freq)[2] = "count"


people_freq <- freq %>% 
  left_join(portfolio, by = c("people", "case")) %>% 
  mutate(people = as.factor(people)) %>% 
  mutate(case = as.factor(case)) %>% 
  mutate(role = as.factor(role))

# Combine case in two sessions into one 
Rinehart_a <- people_freq %>% filter(case == "Rinehart_a")
Rinehart_b <- people_freq %>% filter(case == "Rinehart_b")

Rinehart <- full_join(Rinehart_a, Rinehart_b, by = c("people","role")) %>% 
  mutate(count.x = ifelse(is.na(count.x), 0, count.x)) %>% 
  mutate(count.y = ifelse(is.na(count.y), 0, count.y)) %>% 
  filter(role != "NA") %>% 
  mutate(count = count.x + count.y) %>% 
  select(-c(count.x, count.y, case.x, case.y))

Rinehart <- Rinehart %>% 
  mutate(case = rep("Rinehart", nrow(Rinehart))) 


Rinehart <- Rinehart[,c(1, 3, 4, 2)]

people_frequency <- people_freq %>% 
  filter(case != "Rinehart_a" & case != "Rinehart_b") %>% 
  bind_rows(Rinehart) %>% 
  mutate(people = as.factor(people)) %>% 
  mutate(role = as.factor(role)) %>% 
  mutate(case = as.factor(case)) %>% 
  as.data.frame() %>% 
  group_by(case) %>% 
  add_tally(count) %>% 
  mutate(percent = count/n)

# get insights from people's frequency
ggplot(subset(people_frequency, role %in% c("Chief Judge","Judge")), 
       aes(x = people, y = percent, col = role, fill = role)) +
  geom_bar(stat = "identity") + 
  facet_wrap(~case, nrow = 1) + 
  coord_flip()

# From the text analysis we can see that chief judge has a high liklihood to have ask more questions than other judges 

ggplot(subset(people_frequency, role %in% c("Respondent", "Appellant")), 
       aes(x = people, y = count, col = role, fill = role)) +
  geom_bar(stat = "identity") + 
  facet_wrap(~case, nrow = 1, scales = "free_x") + 
  coord_flip()



