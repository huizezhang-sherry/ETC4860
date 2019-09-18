library(tidyverse)
library(magick)

# parameters to crop 
xy_cord <- read_csv("raw_data/taipan-export-2019-03-31.csv")

cord <- xy_cord %>% 
  mutate(geom = paste0((xmax - xmin), "x",(ymax- ymin) , "+", xmin, "+", ymin)) %>% 
  mutate(xrange = xmax-xmin) %>% 
  mutate(yrange = ymax - ymin) %>% 
  separate(image_name, into = c("video", "suffix"), sep = "_") %>% 
  select(-suffix)

crop_function <- function(video){
  
  start_position <- match(video, cord$video)-1
  cmd = numeric()
  
  if(video %in% c("nauru-a", "nauru-b")){
    for (j in seq(1,3,1)){
      cmd[j] = paste0("cd dt/", video,"; magick mogrify -crop ", cord$geom[j + start_position], " -path ../../cropped/", video, "/", j, " *.png")
    }
    
    for (i in 1:length(cmd)){
      system(cmd[i])
    }
  }else{
    for (j in seq(1,5,1)){
      cmd[j] = paste0("cd dt/", video,"; magick mogrify -crop ", cord$geom[j + start_position], " -path ../../cropped/", video, "/", j, " *.png")
    }
    
    for (i in 1:length(cmd)){
      system(cmd[i])
    }
  }
}

videos <- list("nauru-a", "nauru-b", "McKell", "OKS", "Parkes","Rinehart-a", "Rinehart-b")
map(videos,crop_function)
