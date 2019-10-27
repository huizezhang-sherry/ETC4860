library(forecast)
library(tidyverse)

load("../raw_data/full_data.rda")

au_intensity <- organised %>% 
  filter(judge %in% c("Keane", "Nettle", "Edelman", "Gageler", "Bell")|
           (judge == "Kiefel" & video != "Rinehart_b")) %>% 
  dplyr::select(frame, judge, video, ends_with("_r")) %>% 
  gather(AU, value, -c(frame: video)) %>% 
  group_by(judge, video, AU) %>% 
  nest() %>% 
  mutate(interp = map(data, 
                      ~.x %>% pull(value) %>% na.interp %>% as.numeric)) %>% 
  dplyr::select(judge, video, AU, interp) %>% 
  unnest() %>% 
  group_by(judge, video, AU) %>%
  mutate(frame = row_number()) %>% # add back frame_id as index
  spread(AU, interp) %>% 
  left_join(au %>% dplyr::select(judge: speaker)) # add back speaker column


au_imputed <- organised %>% 
  dplyr::select(frame, judge, video, ends_with("_c")) %>% 
  left_join(au_intensity, by = c("frame", "judge", "video")) %>% 
  gather(AU_label, value, -c(judge, video, frame, speaker)) %>% 
  separate(AU_label, c("AU", "suffix")) %>% 
  spread(suffix, value) %>% 
  rename(presence = c, intensity = r) %>% 
  mutate(presence = case_when(
    !is.na(presence) ~ presence, 
    is.na(presence) & intensity > 1 ~ 1, 
    is.na(presence) & intensity < 1 ~ 0),
  ) %>% 
  ungroup(judge) %>% 
  mutate(judge = as.factor(judge), 
         speaker = as.factor(speaker), 
         AU = as.factor(AU)) %>% 
  mutate(video = as.factor(case_when(
    video == "Nauru_a" ~ "Nauru-a",
    video == "Nauru_b" ~ "Nauru-b",
    video == "Rinehart_a" ~ "Rinehart-a",
    video == "Rinehart_b" ~ "Rinehart-b",
    TRUE ~ as.character(video)
  )))

save(au_imputed, file = "../raw_data/au_imputed.rda") 
