# Bibliotecas

library(tidyverse)
library(ggpubr)
library(ggpval)
library(ggtext)
library(extrafont)

# Carregando e arrumando os dados

df <- tibble(CO2)

# Calculando sumário com média e desvio por grupos

df_su <-
  df %>%
  group_by(Type, Treatment) %>%
  summarise(mu = mean(uptake),
            sd = sd(uptake))

# Plotando gráficos

df %>%
  ggplot(aes(x = Treatment, y = uptake)) +
    geom_boxplot() +
    geom_point(aes(size = conc, colour = Plant),
               alpha = 0.3) +
    facet_wrap(~ Type) +
    labs(title = "Fotossintese <i>Echinochloa crus-galli</i>",
         x = "",
         y = "Ganho liquido de CO2 (umol/m^2)",
         name = c("a","B")) +
    scale_x_discrete(labels = c("Controle", "Resfriado")) +
    theme_void() +
    theme(plot.title = element_textbox_simple(size = 17),
          plot.background = element_rect(fill = "White"),
          plot.margin = margin(1,1,1,1, 'cm'),
          panel.grid.major = element_line(colour = 'grey70', linetype = 'dotted'),
          panel.grid.minor = element_line(colour = 'grey90', linetype = 'dotted'),
          axis.line = element_line(colour = 'grey50'),
          axis.title = element_text(colour = 'grey40'),
          axis.title.x = element_text(margin = margin(t = 2, unit = 'mm')),
          axis.title.y = element_text(angle = 90, margin = margin(r = 2, unit = 'mm')),
          axis.text = element_text(colour = 'grey70'),
          axis.text.x = element_text(margin = margin(t = 1, unit = 'mm')),
          axis.text.y = element_text(margin = margin(r = 1, unit = 'mm')),
          legend.position = "none")
ggsave("PlantCO2_Fotossintese_Boxplot.png")


df_su %>%
  ggplot(aes(x = Treatment, y = mu, fill = Type)) +
    geom_bar(stat = 'identity', position = "dodge") +
    geom_errorbar(aes(ymin = mu-sd, ymax = mu+sd), width = 0.3) +
    facet_wrap(~ Type) +
    labs(title = "Fotossintese em <i>Echinochloa crus-galli</i>",
         x = "",
         y = "Ganho liquido de CO2 (umol/m^2)") +
    scale_x_discrete(labels = c("Controle", "Resfriado")) +
    scale_fill_brewer(palette = 'Paired') +
    theme_void() +
    theme(
      plot.title = element_text(size = 17),
      plot.background = element_rect(fill = "white"),
      plot.margin = margin(1,1,1,1, 'cm'),
      panel.grid.major = element_line(colour = 'grey70', linetype = 'dotted'),
      panel.grid.minor = element_line(colour = 'grey90', linetype = 'dotted'),
      axis.line = element_line(colour = 'grey50'),
      axis.title = element_text(colour = '#082234'),
      axis.title.y = element_text(angle = 90, margin = margin(r = 2, unit = 'mm')),
      axis.text = element_text(),
      legend.position = "none")
ggsave("PlantCO2_Fotossintese_Barplot.png")


