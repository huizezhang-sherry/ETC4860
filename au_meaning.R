library(datapasta)

library(rvest)

au_raw <- read_html("https://en.wikipedia.org/wiki/Facial_Action_Coding_System") %>% 
  html_nodes("table:nth-child(30)") %>% 
  html_table()

names <-  c("AU_number", "AU_meaning", "Muscle")

au45 <- tibble(AU_number = 45, 
               AU_meaning = "Blink", 
               Muscle ="...")

au_meaning <- au_raw[[1]] %>% 
  as_tibble() %>% 
  rename_all(~names) %>% 
  bind_rows(au45) %>% 
  mutate(AU_number = as.factor(ifelse(AU_number < 10, 
                                      paste0("AU0", AU_number), 
                                      paste0("AU", AU_number)))) %>% 
  mutate(AU_meaning = as.factor(paste0(AU_number, ": ", AU_meaning)))

save(au_meaning, file = "raw_data/au_meaning.rda")
