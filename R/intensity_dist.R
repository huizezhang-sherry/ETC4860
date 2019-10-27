library(tidyverse)
library(emmeans)
load(here::here("raw_data", "au_tidy.rda"))
load(here::here("raw_data", "au_imputed.rda"))

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

# cdf
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

# try different distributional fit on the data to see which model should be chosen - gamma looks alright
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

