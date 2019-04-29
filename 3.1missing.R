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
court_miss <- court %>% 
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

# missing plot 
load("data/court.rda")

videos <- list("Nauru_a", "Nauru_b", "McKell", "OKS", "Parkes","Rinehart_a", "Rinehart_b")
names <- map(videos, ~court %>% filter(video_id == .x) %>% select(judge_id) %>% unique())

missingplot <- map2(videos,names, function(videos,names){
  court_video <- court %>% filter(video_id == videos)
  map(names, function(names){
    map(names, ~ court_video %>% 
          filter(judge_id == .x) %>% select(x_1))})
})

names(missingplot) <- videos

vis <- function(x,name){
  x <- x[[1]]
  df <- as.data.frame(x)
  names(df) <- name[[1]]
  df %>% vis_miss + 
    coord_flip()
}

vis(missingplot[[3]], names[[3]])

temp<- map2(missingplot,names,vis)
names(temp) <- videos

gridExtra::grid.arrange(grobs = temp, nrow = 4)

  
gridExtra::grid.arrange(arrangeGrob(temp[[1]], top = video[1]),
                        arrangeGrob(temp[[2]], top = video[2]))


gridExtra::grid.arrange(arrangeGrob(temp[[3]], top = video[3]),
                        arrangeGrob(temp[[4]], top = video[4]),
                        arrangeGrob(temp[[5]], top = video[5]))

gridExtra::grid.arrange(arrangeGrob(temp[[6]], top = video[6]),
                        arrangeGrob(temp[[7]], top = video[7]))

save("missing.png", path = "images/")


# vis_dat: x: t y: judge, 7 plots for 7 videos 
predict based on the nubmer of interupt

label with outcome: hold/ not hold