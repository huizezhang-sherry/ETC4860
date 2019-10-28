library(datapasta)
library(tidyverse)
library(rvest)

load(here::here("raw_data", "au_imputed.rda"))
au_raw <- read_html("https://en.wikipedia.org/wiki/Facial_Action_Coding_System") %>% 
  html_nodes("table:nth-child(30)") %>% 
  html_table() 

names <-  c("AU", "Meaning")

au45 <- tibble(AU = 45, 
               Meaning = "Blink")

au_meaning <- au_raw[[1]] %>% 
  as_tibble() %>% 
  dplyr::select(-`Muscular basis`) %>% 
  rename_all(~names) %>% 
  bind_rows(au45) %>% 
  mutate(AU = as.factor(ifelse(AU < 10, 
                                      paste0("AU0", AU), 
                                      paste0("AU", AU)))) %>% 
  filter(AU %in% unique(au_imputed$AU)) %>% 
  mutate(Meaning = as.factor(paste0(AU, ": ", Meaning)))

related_emotion <- c("sadness, surprise and fear",
                     "surprise, fear and interested",
                     "sadness, fear, anger and confusion",
                     "surprise, fear, anger adn interested",
                     "happiness",
                     "fear, anger and confusion", 
                     "disgust",
                     "no specific related emotion", 
                     "happiness and possibly contempt if appears unilateraly", 
                     "contempt or boredom if appears unilateraly", 
                     "sadness, disgust and confusion", 
                     "interested and confusion", 
                     "fear", 
                     "anger, confusion or bordom", 
                     "no specific related emotion", 
                     "surprise and fear", 
                     "no specific related emotion", 
                     "no specific related emotion")

au_meaning <- au_meaning %>% mutate(Emotion = related_emotion)


save(au_meaning, file = here::here("raw_data", "au_meaning.rda"))
