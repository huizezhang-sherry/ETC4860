library(tidyverse)
library(emmeans)

load(here::here("raw_data", "au_tidy.rda"))
load(here::here("raw_data", "au_imputed.rda"))
load(here::here("raw_data", "au_meaning.rda"))

au_intensity_all <- au_tidy %>% 
  mutate(is_intense = ifelse(intensity >= 2, 1, 0)) 

most_intense <- au_intensity_all %>%
  filter(!AU == "AU28") %>%  # AU28 doesnt have intensity score
  group_by(judge, AU) %>%
  summarise(mean_intensity = mean(intensity, na.rm = TRUE)) %>%
  arrange(-mean_intensity) %>%
  mutate(index = row_number(),
         most_intense = as.factor(ifelse(index <= 5, 1,0)))

# intensity boxplot
au_intensity_all %>% 
  ggplot(aes(x = judge, y = intensity, color = judge)) + 
  geom_boxplot(coef= 100) + 
  facet_wrap(vars(video), scales = "free_x") + 
  theme(axis.text.x = element_text(angle = 30, hjust = 1), 
        legend.position = "none") + 
  coord_trans(y = "sqrt")

# mean intensity plot
most_intense %>%
  ggplot(aes(x = fct_reorder(AU, mean_intensity),
             y = mean_intensity,
             fill = most_intense)) +
  geom_col() +
  facet_wrap(vars(judge)) +
  coord_flip() + 
  ylab("AU")

# High intensity points
au_intensity_all %>% filter(is_intense ==1) %>% 
  ggplot(aes(x = frame, y = intensity, col = speaker)) + 
  geom_point() +
  facet_wrap(vars(judge),ncol = 1) + 
  scale_color_brewer(palette = "Dark2")

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
         AU = fct_relevel(AU, "AU01"),
         non_zero = as.factor(ifelse(intensity ==0, 0, 1)))


m1 <- glm(non_zero ~ judge*video + judge*AU + video*AU,
          data = model_dt, family = binomial(link = "logit"))
m2 <- glm(intensity ~ judge*video + judge*AU + video*AU,
          data = subset(model_dt, non_zero == 1),
          family = Gamma(link = "log"))

m1_2 <- glm(non_zero ~ judge*speaker + judge*video + judge*AU + video*AU,
          data = model_dt, family = binomial(link = "logit"))
m2_2 <- glm(intensity ~ judge*speaker + judge*video + judge*AU + video*AU,
          data = subset(model_dt, non_zero == 1),
          family = Gamma(link = "log"))

anova(m2, m2_2, test = "Chisq")

# Model 2
emmean_m2 <-  emmeans(m2, c("judge", "video", "AU"), type = "response")
int_2i <- confint(emmean_m2, by = c("judge", "AU"), adjust = "bonferroni") # the by argument prescribe

int_2i %>%
  left_join(au_meaning, by = "AU") %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x= video,
             y = response,  group = judge)) +
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


# Model 3
emmean_m3 <-  emmeans(m2_2, c("judge", "video", "AU", "speaker"), type = "response")
int_3i <- confint(emmean_m3, by = c("judge", "AU"), adjust = "bonferroni") # the by argument prescribe

# For Bell and Kiefel there are some obvious discrepency: they tend to react more to the appellent. 
# however this effect is not significant
int_3i %>%
  left_join(au_meaning, by = "AU") %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x= video,y = response,group= judge)) +
  geom_point(aes(col = speaker)) +
  geom_line(alpha = 0.5, lty = "dashed") +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL, col = speaker),
                width = 0.2,position = position_dodge(width = 0.3)) +
  facet_grid(Meaning ~ judge, scales = "free",
             labeller = label_wrap_gen(width = 5)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        strip.text.y = element_text(angle = 0),) +
  xlab("video")
