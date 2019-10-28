anomaly_detection <- function(data,index){
  val <-  data$value[index]
  t = mean(val)
  val_sub <- val[-which.max(val)]
  tm = mean(val_sub)
  return(t-tm)
}

by_index <- au %>%
  filter(AU01_c != "NA") %>%
  select(AU01_r: AU45_r, judge_id: video_id) %>%
  gather(AU, value, -judge_id, -video_id) %>%
  group_by(judge_id, AU) %>% 
  nest()

model <- by_index %>% 
  mutate(bootstrap = map(data, ~boot(.x, anomaly_detection, R= 100))) %>% 
  mutate(t = map(bootstrap, ~.x$t))

anomaly_result <- data.frame(matrix(unlist(model$t), nrow=length(model$t), byrow=T)) %>% 
  mutate(AU = by_index$AU, judge_id = by_index$judge_id) %>% 
  gather(t_n, value, -c(AU, judge_id))

judge_id %in% c("Keane","Gageler","Nettle","Edelman")

anomaly_result %>% 
  filter(judge_id %in% c("Keane","Gageler","Nettle","Edelman"),
         AU %in% c("AU45_r", "AU09_r", "AU06_r", "AU17_r", "AU04_r")) %>% 
  ggplot(aes(x = value)) +
  geom_density() + 
  facet_grid(AU~judge_id, scales = "free")

anomaly_result %>% 
  filter(judge_id %in% c("Bell","Kiefel", "Gordon"), 
         AU %in% c("AU45_r", "AU09_r", "AU06_r", "AU17_r", "AU04_r")) %>% 
  ggplot(aes(x = value)) +
  geom_density() + # bins = 3 works
  facet_grid(AU~judge_id, scales = "free")


anomaly_result %>% 
  filter(judge_id == "Kiefel", 
         AU %in% c("AU45_r", "AU09_r", "AU06_r", "AU17_r", "AU04_r")) %>% 
  ggplot(aes(x = value)) +
  geom_density() + # bins = 3 works
  facet_wrap(vars(AU), scales = "free")


area.com <- function(x, y, n) {
  browser()
  
  x1 <- x[-1]
  y1 <- y[-1]
  indx.local <- (y[-c(1,n)] >= y[1:(n-2)]) & (y[-c(1,n)] >= c(y[3:n]))
  y1.max <- max(y1[indx.local])
  x1.max <- x1[y1 == y1.max] 
  x1.max  <- x1.max[length(x1.max)]
  ##     
  indx <- (x <= x1.max) & (y <= y1.max)
  n0 <- sum(indx)
  x0 <- x[indx]
  y0 <- y[indx] 
  delta.x <- x[3] - x[2]       
  
  area <- (max(x0) - min(x0) + delta.x) * y1.max -  delta.x * sum(y0)  
  #      area <- (max(x0) - min(x0)) * y1.max -  delta.x * sum(y0)   
  
  return(list(area=area, x=x[x >= x1.max] - x1.max, y=y[x >= x1.max]))
} 


area.com(x = seq(1:10), y = seq(1:20), n = 100)
