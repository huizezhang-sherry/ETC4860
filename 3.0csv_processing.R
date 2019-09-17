processing <- function(video_name, judge_name, number_of_frame, appellent_respondent_change){
  
  num_of_judge <- length(judge_name)
  names <- map(judges, ~paste0("data/csv/", video_name, "/face",.x, "/processed"))
  names <- map(judges, ~paste0("data/csv/", video_name,"/face",.x, "/processed"))
  filenames <- map(names, list.files, pattern = "*.csv", full.names = TRUE)
  temp <- map_df(filenames, function(x){
        map_df(x, function(x){
          read_csv(x) %>%
            mutate(info = x)
        })
      })

  save(temp,file = past0e("data/temp_", video_name, ".rda"))
  
  # load("data/temp_nauru_a.rda")
  
  if(num_of_judge ==3){
    judges <- c("1","2","3")
  }else{
    judges <- c("1","2","3", "4", "5")
  }
  
  judge_profile <- tibble(judge, judge_name)
  
  
  names <- map(judges, ~paste0("data/csv/",video_name ,"/face",.x, "/processed"))
  filenames <- map(names, list.files, pattern = "*.csv", full.names = TRUE)
  
  filenames_n <- map(names,
                     ~paste0(.x,"/", video_name,"_" ,
                             formatC(seq(1, number_of_frame, 1), width=3, flag="0"),
                             ".csv"))
  
  names(filenames) <- judges
  
  missing_files <- setdiff(unlist(filenames_n),  unlist(filenames))
  
  dt <- temp %>% add_row(info = missing_files)
  
  organised <- dt %>%
    separate(info,
             into = c("dt", "csv", video_name, "judge_id", "processed", paste0(video_name, "_id")),
             sep = "/") %>%
    separate(nauru_a_id, into= c(video_name, "frame_no"), sep = "_") %>%
    separate(frame_no, into = c("frame_id", "csv"), sep = "\\.") %>%
    arrange(judge_id, frame_id) %>%
    mutate(judge_id = sub("face","", judge_id)) %>%
    left_join(judge_profile, by = c("judge_id" = "judge"))
    mutate(frame_id = as.numeric(frame_id),
           video_id = as.factor(video_name),
           speaker = ifelse(frame_id < appellent_respondent_change, "Appellent", "Respondent")) %>%
    select(-c("dt", "csv", video_name, "processed", "csv"))
  
  save(organised,file = paste0("data/",video_name ,".rda"))
}

processing(video_name = "nauru-a", 
           judge_name = c("Nettle","Gageler", "Edelman"),
           number_of_frame = 151, 
           appellent_respondent_change = 90)


processing(video_name = "nauru-b", 
           judge_name = c("Nettle","Gageler", "Edelman"),
           number_of_frame = 101, 
           appellent_respondent_change = 90)


processing(video_name = "McKell", 
           judge_name = c("Gordon","Gageler", "Bell","Keane", "Edelman"),
           number_of_frame = 132, 
           appellent_respondent_change = 90)


processing(video_name = "OKS", 
           judge_name = c("Gordon","Keane",  "Bell","Gageler", "Edelman"),
           number_of_frame = 42, 
           appellent_respondent_change = 23)


processing(video_name = "Parkes", 
           judge_name = c("Gordon", "Bell", "Kiefel","Keane", "Edelman"),
           number_of_frame = 227, 
           appellent_respondent_change = 82)

processing(video_name = "Rinehart-a", 
           judge_name = c("Gordon","Gageler",  "Kiefel", "Nettle", "Edelman"),
           number_of_frame = 332, 
           appellent_respondent_change = 120)

processing(video_name = "Rinehart-b", 
           judge_name = c("Gordon","Gageler",  "Kiefel", "Nettle", "Edelman"),
           number_of_frame = 336, 
           appellent_respondent_change = 25)