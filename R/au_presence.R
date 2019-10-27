library(tidyverse)
library(emmeans)

load(here::here("raw_data", "au_tidy.rda"))
load(here::here("raw_data", "au_imputed.rda"))
load(here::here("raw_data", "au_meaning.rda"))


#---------------------------------------
# EDA
most_common <- au_tidy %>% 
  group_by(judge,AU) %>% 
  summarise(avg_presence = mean(presence)) %>% 
  filter(avg_presence != "NaN") %>% 
  group_by(judge) %>% 
  arrange(-avg_presence) %>% 
  mutate(common = row_number()) %>% 
  mutate(most_common = as_factor(ifelse(common <=5, 1, 0))) %>% 
  left_join(au_meaning, by = c("AU" = "AU")) %>% 
  mutate(AU = as.factor(AU))

most_common %>%
  ggplot(aes(x =  fct_reorder(AU, avg_presence), y = avg_presence,
             fill = most_common, col = most_common)) +
  geom_col() +
  xlab("AU") +
  ylab("Average Presence") +
  facet_wrap(vars(judge)) +
  coord_flip() +
  theme(legend.position = "none")

# by videos 
# plot int_1
more_presence <- au_tidy %>%
  group_by(judge,AU, video) %>%
  summarise(avg_presence = mean(presence)) %>%
  filter(avg_presence != "NaN") %>%
  arrange(-avg_presence) %>%
  ungroup(judge) %>%
  left_join(au_meaning, by = "AU") %>%
  mutate(AU = as.factor(AU))

# need more work on this plot
more_presence %>%
  filter(AU %in% AU_included) %>%
  ggplot(aes(x = video, y = avg_presence,
             group = judge, col = judge)) +
  geom_line() +
  geom_point() +
  facet_wrap(vars(Meaning),scales = "free_x") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

#---------------------------------------
# Modelling
int <- au_imputed %>% group_by(AU) %>% 
  summarise(int = mean(intensity, na.rm = TRUE)) %>% 
  arrange(-int) %>% 
  top_n(10)

AU_included <- au_imputed %>% group_by(AU) %>% 
  summarise(pres = mean(presence, na.rm = TRUE)) %>% 
  arrange(-pres) %>% 
  top_n(10) %>% 
  inner_join(int) %>% 
  pull(AU)

model_dt <- au_imputed %>%
  ungroup(judge) %>%
  filter(AU %in% AU_included) %>%
  mutate(judge = fct_relevel(judge, c("Edelman", "Keane", "Kiefel",
                                      "Nettle", "Gageler", "Bell")),
         video = fct_relevel(video, c("Nauru-a", "Nauru-b", "Rinehart-a",
                                      "Rinehart-b", "McKell", "OKS", "Parkes")),
         AU = fct_relevel(AU, "AU01"))
save(model_dt, file = "raw_data/model_dt.rda")


binomial_model_1 <- glm(presence ~ judge*AU,
                        family = binomial(link = "logit"),
                        data = model_dt)

emmean_obj_1 <-  emmeans(binomial_model_1, ~judge*AU, type = "response")
int_1 <- confint(emmean_obj_1, by = "judge",adjust = "bonferroni") %>% as.data.frame() %>% dplyr::select(-df)



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
                         c("judge", "AU", "speaker", "video") ,
                         type = "response",weights = "cell")

int_3 <- confint(emmean_obj_3, by = c("judge", "AU"),adjust = "bonferroni")


anova(binomial_model_1, binomial_model_2, test= "Chisq")
anova(binomial_model_2, binomial_model_3, test= "Chisq")


int_2 %>% 
  left_join(au_meaning, by = "AU") %>% 
  filter(!is.na(df)) %>% 
  ggplot(aes(x= video, y = prob,  group = judge)) + 
  geom_point(aes(col= video)) + 
  geom_line(alpha = 0.5, lty = "dashed") + 
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL, col= video), 
                width = 0.2) + 
  facet_grid(Meaning ~ judge, scales = "free",
             labeller = label_wrap_gen(width = 5)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1), 
        strip.text.y = element_text(angle = 0),
        legend.position = "none") + 
  xlab("video")

int_3 %>%
  left_join(au_meaning, by = "AU") %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x= video,y = prob,group= judge)) +
  geom_point(aes(col = speaker)) +
  geom_line(alpha = 0.5, lty = "dashed") +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL, col = speaker),
                width = 0.2,position = position_dodge(width = 0.3)) +
  facet_grid(Meaning ~ judge, scales = "free",
             labeller = label_wrap_gen(width = 5)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        strip.text.y = element_text(angle = 0),) +
  xlab("video")

int_3 %>%
  left_join(au_meaning, by = "AU") %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x = speaker, y = prob), position = position_dodge(width = 0.5)) +
  geom_point(alpha = 0.5) +
  geom_line(aes(group = judge, col = judge)) +
  # geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL),
  #               width = 0.2, alpha = 0.5) +
  facet_grid(Meaning ~video, scales = "free")

int_3 %>%
  left_join(au_meaning, by = "AU") %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x = speaker, y = prob, col = judge)) +
  geom_point(position = position_dodge(width = 0.3)) +
  geom_line(aes(group = judge),
            position = position_dodge(width = 0.3)) +
  facet_grid(Meaning ~video, scales = "free")


