library(tidyverse)

iris %>%
  group_by(Species) %>%
  mutate(mu = mean(Petal.Length),
         sd = sd(Petal.Length)) %>%
  ggplot(aes(x = Species, y = mu)) +
    geom_bar(stat = "identity", position = "dodge") +
    geom_errorbar(aes(ymin = mu - sd, ymax = mu + sd, x = Species),
                  width = 0.2)

data("Nile")
Nile
data.frame("Flow" = Nile,
           "Year" = 1871:1970) -> df

ggplot(df, aes(x = Year, y = Flow)) +
  geom_line() +
  geom_point() +
  geom_smooth()

plot(Nile)
