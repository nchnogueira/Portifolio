library(tidyverse)

iris %>%
  group_by(Species) %>%
  summarise("Média" = mean(Petal.Length),
            "Desvio Padrão" = sd(Petal.Length)) %>%
    ggplot(aes(x = Species, y = Média)) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_errorbar(aes(x = Species,
                        ymin = Média-`Desvio Padrão`,
                        ymax = Média+`Desvio Padrão`),
                    width = 0.3)

