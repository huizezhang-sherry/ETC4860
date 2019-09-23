# combine and read in all the csv
#filenames <- list.files("csv/processed", pattern = "*.csv", full.names = TRUE)
#
# temp <- map_df(filenames, function(x){
#   map_df(x, function(x){
#     read_csv(x) %>%
#       mutate(info = x)
#   })
# })
#
#save(temp, file = "raw_data/csv_aug.rda")
load("raw_data/csv_aug.rda")

# init different metadata vectors 
video <- c("nauru-a", "nauru-b", "McKell", "OKS", "Parkes", "Rinehart-a", "Rinehart-b")
number_of_frame <-  c(151, 101, 158, 42, 227, 332,36)
appellent_respondent_change <- c(90, 90,90, 23, 82, 120, 25)
judge <- c(rep(1:3,2), rep(1:5, 5))
meta_2 <- expand.grid(judge = 1:3, video = c("nauru-a", "nauru-b"))
meta_3 <- expand.grid(judge = 1:5, video = c("McKell", "OKS", "Parkes", "Rinehart-a", "Rinehart-b"))
meta_judge <- bind_rows(meta_2, meta_3) %>% 
  mutate(judge_name = c("Nettle","Gageler", "Edelman", 
                        "Nettle","Gageler", "Edelman", 
                        "Gordon","Gageler", "Bell","Keane", "Edelman", 
                        "Gordon","Keane",  "Bell","Gageler", "Edelman", 
                        "Gordon", "Bell", "Kiefel","Keane", "Edelman", 
                        "Gordon","Gageler",  "Kiefel", "Nettle", "Edelman", 
                        "Gordon","Gageler",  "Kiefel", "Nettle", "Edelman"), 
         judge = as.factor(judge), 
         video = as.factor(video))

meta_speaker <- tibble(video = as.factor(video), appellent_respondent_change)

# dealing with the missings
paste_fullname <- function(video, number_of_frame){
  a <- paste0(video,"_" ,
         formatC(seq(1, number_of_frame, 1), width=3, flag="0"),
         ".csv")
  return(a)
}

full_filename <- map2(video,number_of_frame, paste_fullname) %>% 
  unlist() %>% 
  as_tibble() %>%
  mutate(info = value) %>% 
  tidyr::separate(info, into = c("video", "misc"), sep = "_") %>% 
  left_join(meta_judge) %>% 
  mutate(info = paste0("csv/processed/",judge, "-",value))

missing_files <- setdiff(unlist(full_filename$info),unlist(temp$info))
dt <- temp %>% add_row(info = missing_files)

# add all the metadata
organised <- dt %>% 
  separate(info, into = c("csv", "processed", "info_2"), sep = "/") %>% 
  select(-csv, -processed) %>% 
  separate(info_2, into = c("info_3", "info_4"), sep = "_") %>% 
  mutate(judge = as.factor(str_sub(info_3, 1, 1))) %>% 
  mutate(video = as.factor(str_sub(info_3, 3, nchar(info_3)))) %>% 
  mutate(frame = as.numeric(str_sub(info_4, 1,3))) %>% 
  select(-info_3, -info_4) %>% 
  left_join(meta_judge, by = c("judge", "video")) %>% 
  mutate(judge = as.factor(judge_name)) %>% 
  select(-judge_name) %>% 
  left_join(meta_speaker, by = "video") %>% 
  mutate(speaker = as.factor(ifelse(frame < appellent_respondent_change, 
                                    "Appellent", "Respondent"))) %>% 
  select(-appellent_respondent_change) %>% 
  arrange(judge,video, frame)
  

save(organised,file = "raw_data/new_dt.rda")
