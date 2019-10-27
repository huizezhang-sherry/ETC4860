library(forecast)
library(tidyverse)
library(tsibble)

load(here::here("raw_data", "full_data.rda"))

au <- organised %>% 
  select(AU01_r:speaker)%>% 
  # seems to have duplicates for Nettle in nauru-a frame 33
  mutate(ind = paste0(judge,video,frame)) %>% 
  filter(ind != "Nettlenauru-a33") %>% 
  filter(judge != "Gordon") %>% 
  mutate(video = fct_recode(video, `Nauru-a` = "nauru-a",
                            `Nauru-b` = "nauru-b"))
  
### imputation for intensity
au_intensity1 <- au %>% 
  # end with _r is intensity
  dplyr::select(frame, judge, video,AU01_r:AU45_r) %>% 
  filter(judge %in% c("Nettle", "Edelman", "Gageler", 
                      "Bell", "Keane")) %>% 
  gather(AU, value, -c(frame: video)) %>% 
  group_by(judge, video, AU) %>% 
  nest() %>% 
  mutate(interp = map(data, 
                      ~.x %>% pull(value) %>% na.interp() %>% as.numeric())) 

au_intensity2 <- au %>% 
  # end with _r is intensity
  dplyr::select(frame, judge, video,ends_with("_r")) %>% 
  # seems that no observation for Parkes for kiefel
  filter(judge == "Kiefel", video %in% c("Rinehart-a", "Parkes")) %>% 
  gather(AU, value, -c(frame: video)) %>% 
  group_by(judge, video, AU) %>% 
  nest() %>% 
  mutate(interp = map(data, 
                      ~.x %>% pull(value) %>% na.interp() %>% as.numeric()))

au_intensity <- bind_rows(au_intensity1, au_intensity2) %>% 
  dplyr::select(judge, video, AU, interp) %>% 
  unnest() %>% 
  group_by(judge, video, AU) %>%
  mutate(frame = row_number()) %>% # add back frame_id as index
  spread(AU, interp) %>% 
  left_join(au %>% dplyr::select(judge: speaker)) # add back speaker column

# imputation for presence based on intensity
au_imputed <- au %>% 
  dplyr::select(frame, judge, video, speaker, ends_with("_c")) %>% 
  left_join(au_intensity, by = c("frame", "judge", "video", "speaker")) %>% 
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
  filter(AU != "AU28")

save(au_imputed, file = "raw_data/au_imputed.rda") 
