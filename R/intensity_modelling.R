au_intensity_all %>%
  ggplot(aes(x = judge, y = intensity, color = judge)) +
  geom_boxplot(coef = 100) +
  facet_wrap(vars(video), scales = "free_x") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1),
        legend.position = "none")

au_tidy_intensity <- au_tidy %>% filter(!is.na(intensity))

# au_tidy_intensity%>%
#   mutate(ind = row_number(),
#          zero = as.factor(ifelse(intensity <1, TRUE, FALSE)))  %>%
#   ggplot(aes(x = ind, y = intensity, col = zero)) +
#   geom_point()

model_dt <- au_tidy %>%
  ungroup(judge) %>%
  filter(AU %in% au_intensity) %>%
  mutate(judge = fct_relevel(judge, c("Edelman", "Keane", "Kiefel",
                                      "Nettle", "Gageler", "Bell")),
         video = fct_relevel(video, c("Nauru-a", "Nauru-b", "Rinehart-a",
                                      "Rinehart-b", "McKell", "OKS", "Parkes")),
         AU = fct_relevel(AU, "AU01"),
         non_zero = as.factor(ifelse(intensity ==0, 0, 1)))

model_dt %>% group_by(non_zero) %>%
  summarize(count = n(), prop = count/nrow(model_dt))

m1 <- glm(non_zero ~ judge*video + judge*AU + video*AU,
          data = model_dt, family = binomial(link = "logit"))
m2 <- glm(intensity ~ judge*video + judge*AU + video*AU,
          data = subset(model_dt, non_zero == 1),
          family = Gamma(link = "log"))

emmean_m2 <-  emmeans(m2, c("judge", "video", "AU"),
                      type = "response")
int_2 <- confint(emmean_m2, by = c("judge", "AU"), adjust = "bonferroni") # the by argument prescribe

int_2 %>%
  left_join(au_meaning, by = c("AU" = "AU_number")) %>%
  dplyr::select(-Muscle) %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x= video,
             y = response,  group = judge)) +
  geom_point(aes(col= video)) +
  geom_line(alpha = 0.5, lty = "dashed") +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL, col= video),
                width = 0.2) +
  facet_grid(AU_meaning ~ judge, scales = "free",
             labeller = label_wrap_gen(width = 5)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        strip.text.y = element_text(angle = 0),
        legend.position = "none") +
  xlab("video")

m1 <- glm(non_zero ~ judge*speaker + video*judge +
            AU*judge + video*AU, data = model_dt, family = binomial(link = logit))
m2 <- glm(intensity ~ judge*speaker + video*judge +
            AU*judge + video*AU,
          data = subset(model_dt, non_zero == 1), family = Gamma(link = log))

emmean_m3 <-  emmeans(m2, c("judge", "video", "AU", "speaker"),
                      type = "response")
int_3 <- confint(emmean_m3, by = c("judge", "AU"), adjust = "bonferroni") # the by argument prescribe

int_3 %>%
  left_join(au_meaning, by = c("AU" = "AU_number")) %>%
  dplyr::select(-Muscle) %>%
  filter(!is.na(df)) %>%
  ggplot(aes(x= video,y = response,group= judge)) +
  geom_point(aes(col = speaker),position = position_dodge(width = 0.3)) +
  geom_line(alpha = 0.5, lty = "dashed") +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL, col = speaker),
                width = 0.2,position = position_dodge(width = 0.3)) +
  facet_grid(AU_meaning ~ judge, scales = "free",
             labeller = label_wrap_gen(width = 5)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        strip.text.y = element_text(angle = 0),) +
  xlab("video")

# https://seananderson.ca/2014/05/18/gamma-hurdle/
# histo
au_tidy %>%
  filter(intensity > 1) %>%
  ggplot(aes(x =  log(intensity))) +
  geom_histogram()
  #facet_grid(judge ~ video, scales = "free")

# dist
au_tidy %>%
  filter(intensity > 1) %>%
  ggplot(aes(x =  log(intensity))) +
  geom_density()
  #facet_grid(judge ~ video, scales = "free")
  # all the distribution looks pretty same so no need to separate

#
au_tidy %>%
  filter(intensity > 1) %>%
  ggplot(aes(x =  log(intensity))) +
  stat_ecdf()

# fit distribution
library(fitdistrplus)
library(actuar)

intensity <- au_tidy %>% filter(!is.na(intensity)) %>%
  filter(intensity > 1) %>% pull(intensity) %>% log()

plotdist(intensity, histo = TRUE, demp = TRUE)

paretofit <- fitdist(intensity,"pareto", start = list(shape= 1e8, scale = 1.5e8))
weibullfit <- fitdist(intensity,"weibull", start = list(shape= 1.2, scale = 0.3))
gammafit <- fitdist(intensity,"gamma", start = list(shape= 1.2, scale = 0.3))
burrfit <- fitdist(intensity,"burr", start = list(shape1= 0.3, shape2=1))
lnormfit <- fitdist(intensity, "lnorm")
cdfcomp(list(paretofit, weibullfit, burrfit, lnormfit, gammafit))
gofstat(list(paretofit, weibullfit, burrfit, lnormfit, gammafit),
        fitnames = c("pareto", "weibull", "burr", "lnorm", "gamma"))

summary(bootdist(weibullfit, niter = 1001))
# say take 1.2?

model_dt <- au_tidy %>%
  ungroup(judge) %>%
  mutate(judge = fct_relevel(judge, "Bell"),
         AU = fct_relevel(AU, "AU01"))

model_i_1 <- glm(log(intensity) ~ judge*AU,
                        family = Gamma(link = "inverse"),
                        data = model_dt)

emmean_i_1 <-  emmeans(model_i_1, ~judge*AU)
int_i_1 <- confint(emmean_i_1, by = "judge",adjust = "bonferroni") %>% as.data.frame() %>% dplyr::select(-df)

int_i_1 %>%
  left_join(au_meaning, by = c("AU" = "AU_number")) %>%
  as_tibble()%>%
  filter(!is.na(df)) %>%
  ggplot(aes(x= AU,y = emmean, fill = AU)) +
  geom_point() +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL), width = 0.2) +
  facet_wrap(vars(judge))  +
  coord_flip() +
  xlab("AU") +
  theme(legend.position = "none") +
  ylim(c(1,5))

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


model_i_2 <- glm(sqrt(intensity) ~ judge*video + judge*AU + video*AU,
                        family = Gamma(link = "inverse"),
                        data = model_dt)

emmean_i_2 <- emmeans(model_i_2, c("judge", "video", "AU"), type = "response")

int_i_2 <- confint(emmean_i_2, by = c("judge", "AU"), adjust = "bonferroni") # the by argument prescribe

int_i_2 %>%
  left_join(au_meaning, by = c("AU" = "AU_number")) %>%
  dplyr::select(-Muscle) %>%
  filter(!is.na(df)) %>%
  mutate(judge = fct_relevel(judge, c("Edelman", "Keane", "Kiefel",
                                      "Nettle", "Gageler", "Bell"))) %>%
  ggplot(aes(x= fct_relevel(video, c("Nauru_a", "Nauru_b", "Rinehart_a",
                                     "Rinehart_b", "McKell", "OKS", "Parkes")),
             y = response,  group = judge)) +
  geom_point(aes(col= video)) +
  geom_line(alpha = 0.5, lty = "dashed") +
  geom_errorbar(aes(ymin = asymp.LCL, ymax = asymp.UCL, col= video),
                width = 0.2) +
  facet_grid(AU_meaning ~ judge, scales = "free",
             labeller = label_wrap_gen(width = 5)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        strip.text.y = element_text(angle = 0),
        legend.position = "none") +
  xlab("video")



binomial_model_3 <- glm(presence ~ judge*speaker + video*judge +
                          AU*judge + video*AU, family = "binomial",
                        data = model_dt)

emmean_obj_3 <-  emmeans(binomial_model_3,
                         c("judge", "AU", "speaker", "video") ,
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




