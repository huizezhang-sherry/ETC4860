# model 1& 2 or 1&3 are nested so can use anova chisq test to compare the model
# both suggest 1 is worse than 2 or 3
anova(binomial_model_1, binomial_model_2, test = "Chisq")
anova(binomial_model_1, binomial_model_3, test = "Chisq")


# since 2 and 3 are not nested, cant use anova to compare - use AIC instead
# see more technical thing from here: https://stats.stackexchange.com/questions/20441/non-nested-model-selection
AIC(binomial_model_2)
AIC(binomial_model_3)
# this suggest 3 has slightly smaller aic but not really much


# residual fit

# the traditional residual fit against predicted value plot is wired
augment(binomial_model_1, type.predict = "response", type.resid = "response") %>%
  ggplot(aes(x = .fitted, y= .resid)) +
  geom_point()

# a better way to visualise these residuals are through the binned residual plot
# go through some of the technical nitty gitty about binned residual plot

# for model 1, it is wired that all the values are at the scale of 1e-14 or 1e-15
# dont know what does that mean
binnedplot(fitted(binomial_model_1),
           resid(binomial_model_1, type = "response"))
arm:::binned.resids(fitted(binomial_model_1),
                    resid(binomial_model_1, type = "response"),
                    floor(sqrt(length(fitted(binomial_model_1)))))[[1]]


binnedplot(fitted(binomial_model_2),
           resid(binomial_model_2, type = "response"))
arm:::binned.resids(fitted(binomial_model_2),
                    resid(binomial_model_2, type = "response"),
                    floor(sqrt(length(fitted(binomial_model_2)))))[[1]] %>%
  as_tibble() %>%
  mutate(abnormal = ifelse(abs(ybar)<`2se`, 0, 1)) %>%
  summarise(abnormal = sum(abnormal), all = n()) %>%
  mutate(prop = abnormal/all)


binnedplot(fitted(binomial_model_3),
           resid(binomial_model_3, type = "response"))
arm:::binned.resids(fitted(binomial_model_3),
                    resid(binomial_model_3, type = "response"),
                    floor(sqrt(length(fitted(binomial_model_3)))))[[1]] %>%
  as_tibble() %>%
  mutate(abnormal = ifelse(abs(ybar)<`2se`, 0, 1)) %>%
  summarise(abnormal = sum(abnormal), all = n()) %>%
  mutate(prop = abnormal/all)

dt <- model_dt %>% mutate(ind = row_number()) %>% filter(!ind %in% c(17442, 17450, 25482, 25850))
influencePlot(binomial_model_1)
influencePlot(binomial_model_2)
influencePlot(binomial_model_3)
