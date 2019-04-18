library(purrr)
library(tidyverse)
library(ggplot2)
library(GGally)
library(gganimate)
library(naniar)
library(visdat)

# read data
load("data/nauru_a.rda")
load("data/nauru_b.rda")
load("data/McKell.rda")
load("data/OKS.rda")
load("data/Parkes.rda")
load("data/Rinehart_a.rda")
load("data/Rinehart_b.rda")

court <- rbind(nauru_a, nauru_b, McKell, OKS, Parkes, Rinehart_a, Rinehart_b)
save(court, file = "data/court.rda")  

# missing evaluation
court_miss <- court_0 %>% 
  select(judge_id, frame_id, video_id, x_1) %>% 
  mutate(judge_id = as.factor(judge_id))

missing <- court_miss %>% 
  group_by(video_id, judge_id) %>% 
  summarise(na_count = sum(is.na(x_1)), 
            count = n(),
            na_prop = na_count/count, 
            data_prop = 1-na_prop)

#kiefel: key-fall
judge_name <- c("Nettle", "Gageler", "Edelman", 
                "Nettle", "Gageler", "Edelman", 
                "left-1", "Gageler", "Bell", "Keane", "Edelman",
                "left-1", "Keane", "Bell", "Gageler", "Edelman",
                "left-1", "Bell", "Kiefel", "Keane", "Edelman",
                "left-1", "Gageler", "Kiefel", "Nettle", "Edelman",
                "left-1", "Gageler", "Kiefel", "Nettle", "Edelman")

missing <- data.frame(missing) %>% mutate(name = judge_name)


# maybe just want to include some judges 
McKell2 <- McKell %>% filter(judge_id != "Bell")
OKS2 <- OKS %>% filter(judge_id %in% c("Keane","Edelman"))
Parkes2 <- Parkes %>% filter(judge_id =="Keane")
Rinehart_a2 <- Rinehart_a %>% filter(judge_id %in% c("Gageler","Edelman"))
Rinehart_b2 <- Rinehart_b %>% filter(judge_id %in% c("Gageler","Edelman"))

court <- rbind(nauru_a, nauru_b, McKell2, OKS2, Parkes2, Rinehart_a2, Rinehart_b2)  

save(court, file = "data/court.rda")  


McKell %>% vis_dat()


# vis_dat: x: t y: judge, 7 plots for 7 videos 
predict based on the nubmer of interupt

label with outcome: hold/ not hold