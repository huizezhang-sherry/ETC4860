# old method of choosing AUs
## Presence

compute_au_number <- function(cutpoint, num_judge){
  count <- most_common %>% ungroup() %>%
    filter(avg_presence > cutpoint) %>% group_by(AU) %>%
    summarise(count = n()) %>% filter(count >=num_judge) %>% ungroup() %>%
    pull(AU) %>% length()
  return(count)
}

x <- seq(0.05, 0.5, 0.05)
y <- 1:6
heatmap_dt <- expand.grid(x, y) %>%
  as_tibble() %>%
  mutate(number = map2(Var1, Var2, compute_au_number)) %>%
  unnest(number)

heatmap_dt %>%
  ggplot(aes(x = Var1, y = Var2, fill = number, col = number)) +
  geom_tile() +
  geom_text(aes(label = number), col = "red") +
  scale_x_continuous(breaks = seq(0.05, 0.5, 0.05)) +
  scale_y_continuous(breaks = 1:6)


# number of action unit to include against
# number of judges that has the action unit average intensity to be greater than 0.25
# tibble(cutpoint = 1:6,
#        count = map_dbl(cutpoint, compute_au_number)) %>%
#   ggplot(aes(x = cutpoint, y = count, fill = count)) +
#   geom_col() +
#   geom_text(aes(label = count),nudge_y = 0.5, col = "red") +
#   scale_x_continuous(breaks = seq(1,6,1))

# count>= 3 - 13 AUs
# count>= 4 - 10 AUs
# count>= 5 - 8 AUs
# count>= 6 - 3 AUs
# we want to choose a parsimonious model,
# that is, explain more about the data but as precise and concise as possible

common_au <- most_common %>% ungroup() %>%
  filter(avg_presence > 0.3) %>% group_by(AU) %>%
  summarise(count = n()) %>% filter(count >=5) %>% pull(AU)

# average presence score for the action unit where at least 5 judges has average presence score greater than 0.25
most_common %>%
  filter(AU %in% common_au) %>%
  mutate(less = as.factor(ifelse(avg_presence > 0.25, 0, 1))) %>%
  ggplot(aes(x = AU, y = avg_presence,
             col = less, fill = less)) +
  geom_col() +
  xlab("AU") +
  ylab("Average Presence") +
  facet_wrap(vars(judge)) +
  coord_flip() +
  theme(legend.position = "none")



## Intensity 
compute_au_number <- function(cutoff,num_judge){
  count <- most_intense %>% ungroup() %>%
    filter(mean_intensity > cutoff) %>% group_by(AU) %>%
    summarise(count = n()) %>% filter(count >=num_judge) %>% ungroup() %>%
    pull(AU) %>% length()
  return(count)
}

x <- seq(0.05, 0.5, 0.05)
y <- 1:6
heatmap_dt <- expand.grid(x, y) %>%
  as_tibble() %>%
  mutate(number = map2(Var1, Var2, compute_au_number)) %>%
  unnest(number)

heatmap_dt %>%
  ggplot(aes(x = Var1, y = Var2, fill = number, col = number)) +
  geom_tile() +
  geom_text(aes(label = number), col = "red") +
  scale_x_continuous(breaks = seq(0.05, 0.5, 0.05)) +
  scale_y_continuous(breaks = 1:6)


# number of action unit to include against
# number of judges that has the action unit average intensity to be greater than 0.25
tibble(cutpoint = 1:6,
       count = map_dbl(cutpoint, compute_au_number)) %>%
  ggplot(aes(x = cutpoint, y = count, fill = count)) +
  geom_col() +
  geom_text(aes(label = count),nudge_y = 0.5, col = "red") +
  scale_x_continuous(breaks = seq(1,6,1))

# most jduge : 5 or 6,
# also need a certain amount of au -> choose 0.2 as cut off
# (0.2, 5), (0.2, 4), (0.25,4), (0.25,5) also valid candidate
# but want to overlap with the action unit choosen for presence for compare (they only overlap by two AUs)

au_intensity <- most_intense %>% ungroup() %>%
  filter(mean_intensity > 0.15) %>% group_by(AU) %>%
  summarise(count = n()) %>% filter(count >=5) %>% pull(AU)
