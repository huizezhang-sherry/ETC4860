most_common %>%
  ggplot(aes(x =  fct_reorder(AU, avg_presence), y = avg_presence,
             fill = most_common, col = most_common)) +
  geom_col() +
  xlab("AU") +
  ylab("Average Presence") +
  facet_wrap(vars(judge)) +
  coord_flip() +
  theme(legend.position = "none")

compute_au_number <- function(cutpoint){
  count <- most_common %>% ungroup() %>%
  filter(avg_presence > 0.25) %>% group_by(AU) %>%
  summarise(count = n()) %>% filter(count >=cutpoint) %>% ungroup() %>%
    pull(AU) %>% length()
  return(count)
}

# number of action unit to include against
# number of judges that has the action unit average intensity to be greater than 0.25
tibble(cutpoint = 1:6,
       count = map_dbl(cutpoint, compute_au_number)) %>%
  ggplot(aes(x = cutpoint, y = count, fill = count)) +
  geom_col() +
  geom_text(aes(label = count),nudge_y = 0.5, col = "red") +
  scale_x_continuous(breaks = seq(1,6,1))

# count>= 3 - 13 AUs
# count>= 4 - 10 AUs
# count>= 5 - 8 AUs
# count>= 6 - 3 AUs
# we want to choose a parsimonious model,
# that is, explain more about the data but as precise and concise as possible


common_au <- most_common %>% ungroup() %>%
  filter(avg_presence > 0.25) %>% group_by(AU) %>%
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

model_dt <- au_tidy %>%
  ungroup(judge) %>%
  filter(AU %in% common_au) %>%
  mutate(judge = fct_relevel(judge, "Bell"),
         AU = fct_relevel(AU, "AU01"))

binomial_model_1 <- glm(presence ~ judge*AU,
                        family = binomial(link = "logit"),
                        data = model_dt)

emmean_obj_1 <-  emmeans(binomial_model_1, ~judge*AU, type = "response")
int_1 <- confint(emmean_obj_1, by = "judge",adjust = "bonferroni") %>% as.data.frame() %>% dplyr::select(-df)

# plot int_1

more_presence <- au_tidy %>%
  group_by(judge,AU, video) %>%
  summarise(avg_presence = mean(presence)) %>%
  filter(avg_presence != "NaN") %>%
  arrange(-avg_presence) %>%
  ungroup(judge) %>%
  left_join(au_meaning, by = c("AU" = "AU_number")) %>%
  mutate(AU = as.factor(AU))

# need more work on this plot
more_presence %>%
  filter(AU %in% common_au) %>%
  ggplot(aes(x = video, y = avg_presence,
             group = judge, col = judge)) +
  geom_line() +
  geom_point() +
  facet_wrap(vars(AU_meaning),scales = "free_x") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))


binomial_model_2 <- glm(presence ~ judge*video + judge*AU + video*AU,
                        family = binomial(link = "logit"),
                        data = model_dt)

emmean_obj_2 <- emmeans(binomial_model_2, c("judge", "video", "AU"),
                        type = "response")

int_2 <- confint(emmean_obj_2, by = c("judge", "AU"), adjust = "bonferroni") # the by argument prescribe



binomial_model_3 <- glm(presence ~ judge*speaker + video*judge +
                          AU*judge + video*AU, family = "binomial",
                        data = model_dt)

emmean_obj_3 <-  emmeans(binomial_model_3,
                         c("judge", "AU", "speaker") ,
                         type = "response",weights = "cell")

Anova(binomial_model_3, type = "III", singular.ok = TRUE) %>%
  kable(digits = 5)
# interesting that speaker is not significant, but speaker*judge is
# given the interactions, speaker is not significant but it still useful because
# the interactions are significant
int_3 <- confint(emmean_obj_3, by = c("judge", "AU"),adjust = "bonferroni")



int_3 %>%
  left_join(au_meaning, by = c("AU" = "AU_number")) %>%
  select(-Muscle) %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x = speaker, y = prob), position = position_dodge(width = 0.5)) +
  geom_point(alpha = 0.5) +
  geom_line(aes(group = judge, col = judge)) +
  # geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL),
  #               width = 0.2, alpha = 0.5) +
  facet_grid(AU_meaning ~video, scales = "free")

int_3 %>%
  left_join(au_meaning, by = c("AU" = "AU_number")) %>%
  select(-Muscle) %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x = speaker, y = prob, col = judge)) +
  geom_point(position = position_dodge(width = 0.3)) +
  geom_line(aes(group = judge),
            position = position_dodge(width = 0.3)) +
  facet_grid(AU_meaning ~video, scales = "free")


