library(tidyverse)
library(broom)
library(visreg)
load(here::here("raw_data", "model_dt.rda"))


int <- au_imputed %>% group_by(AU) %>% 
  summarise(int = mean(intensity, na.rm = TRUE)) %>% 
  arrange(-int) %>% 
  top_n(10)

AU_included <- au_imputed %>% group_by(AU) %>% 

binomial_model_1 <- glm(presence ~ judge*AU,
                        family = binomial(link = "logit"),
                        data = model_dt)

binomial_model_2 <- glm(presence ~ judge*video + judge*AU + video*AU,
                        family = binomial(link = "logit"),
                        data = model_dt)

binomial_model_3 <- glm(presence ~ judge*speaker + video*judge +
                          AU*judge + video*AU, family = "binomial",
                        data = model_dt)

# model 1& 2 or 1&3 are nested so can use anova chisq test to compare the model
# both suggest 1 is worse than 2 or 3
anova(binomial_model_1, binomial_model_2, test = "Chisq")
anova(binomial_model_1, binomial_model_3, test = "Chisq")

# AIC can be another way to compare models - it is an alternative if the model is not nested.
AIC(binomial_model_2)
AIC(binomial_model_3)
# this suggest 3 has slightly smaller aic but not really much


# residual fit

# the traditional residual fit against predicted value plot is wired
augment(binomial_model_1, type.predict = "response", type.resid = "response") %>%
  ggplot(aes(x = .fitted, y= .resid)) +
  geom_point()


# partial residual plots

# visreg is really the one to look at the effect/relationship between interactions
# thus more similar to my 95% CI plot


visreg(binomial_model_1, "AU", by = "judge")

visreg(binomial_model_2, "video",by = "judge")
visreg(binomial_model_2, "AU", by = "judge")

visreg(binomial_model_3, "AU", by = "judge")
visreg(binomial_model_3, "speaker",by = "judge")


# a better way to visualise these residuals are through the binned residual plot
# go through some of the technical nitty gitty about binned residual plot

# for model 1, it is wired that all the values are at the scale of 1e-14 or 1e-15
# dont know what does that mean
library(arm)
# http://www.stat.columbia.edu/~gelman/research/published/dogs.pdf
binnedplot(fitted(binomial_model_1),
           resid(binomial_model_1, type = "response"))
arm:::binned.resids(fitted(binomial_model_1),
                    resid(binomial_model_1, type = "response"),
                    floor(sqrt(length(fitted(binomial_model_1)))))[[1]]


binnedplot(fitted(binomial_model_2),
           resid(binomial_model_2, type = "response"))
binned.resids(fitted(binomial_model_2),
                    resid(binomial_model_2, type = "response"),
                    floor(sqrt(length(fitted(binomial_model_2)))))[[1]] %>%
  as_tibble() %>%
  mutate(abnormal = ifelse(abs(ybar)<`2se`, 0, 1)) %>%
  filter(`2se` != 0) %>% #filter(abnormal  ==1) %>% View()
  summarise(abnormal = sum(abnormal), all = n()) %>%
  mutate(prop = abnormal/all)

binned.resids(fitted(binomial_model_2),
                    resid(binomial_model_2, type = "response"),
                    floor(sqrt(length(fitted(binomial_model_2)))))[[1]] %>%
  as_tibble() %>%
  mutate(abnormal = as.factor(ifelse(abs(ybar)<`2se`, 0, 1))) %>%
  filter(`2se` != 0) %>%
  ggplot(aes(x = xbar)) +
  geom_line(aes(y = `2se`)) +
  geom_line(aes(y = -`2se`)) +
  geom_point(aes(y = ybar,col = abnormal))


binnedplot(fitted(binomial_model_3),
           resid(binomial_model_3, type = "response"))
binned.resids(fitted(binomial_model_3),
                    resid(binomial_model_3, type = "response"),
                    floor(sqrt(length(fitted(binomial_model_3)))))[[1]] %>%
  as_tibble() %>%
  mutate(abnormal = ifelse(abs(ybar)<`2se`, 0, 1)) %>%
  filter(`2se` != 0) %>% filter(abnormal  ==1) %>% 
  summarise(abnormal = sum(abnormal), all = n()) %>%
  mutate(prop = abnormal/all)

binned.resids(fitted(binomial_model_3),
              resid(binomial_model_3, type = "response"),
              floor(sqrt(length(fitted(binomial_model_3)))))[[1]] %>%
  as_tibble() %>%
  mutate(abnormal = as.factor(ifelse(abs(ybar)<`2se`, 0, 1))) %>%
  filter(`2se` != 0) %>%
  ggplot(aes(x = xbar)) +
  geom_line(aes(y = `2se`)) +
  geom_line(aes(y = -`2se`)) +
  geom_point(aes(y = ybar,col = abnormal))


