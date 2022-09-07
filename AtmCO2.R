# Bibliotecas


library(tidyverse)
library(plotly)
library(timetk)
library(gganimate)
library(hrbrthemes)

loadfonts(device = "win")
# Carregando e arrumando os dados

df <- co2
df <- tk_tbl(df)
df <- transform(df, Data = zoo::as.Date(index, frac = 0))
df <- tibble(df)
df

# Plotando a série temporal
p <-
df %>%
  ggplot(aes(x = Data, y = value, color = value)) +
    geom_line(size = 1.2, alpha = 0.3) +
    geom_point(size = 2.5) +
    scale_color_gradient(low = "green", high = "red") +
    labs(title = "Observatório Mauna Loa, Havaii\nConcentração de CO2 Atmosférico",
         caption = "As concentrações de CO2 atmosférico vêm aumentando com o passar dos anos de forma significativa\nBase de dados fornecida por Scripps CO2 Program",
         x = "Ano",
         y = "CO2 (ppm)",
         color = "CO2 (ppm)") +
    theme_ipsum()


# Plot simples
p
ggsave("AtmCO2.png")
# Plot interativo
ggplotly(p)

# Plot animado
p2 <-
  df %>%
  ggplot(aes(x = Data, y = value, color = value)) +
  geom_line(size = 1.2, alpha = 0.3) +
  geom_point(size = 2.5) +
  scale_color_gradient(low = "green", high = "red") +
  labs(title = "Observatório Mauna Loa, Havaii\nConcentração de CO2 Atmosférico",
       x = "Ano",
       y = "CO2 (ppm)",
       caption = "As concentrações de CO2 atmosférico vêm aumentando com o passar dos anos de forma significativa\nBase de dados fornecida por Scripps CO2 Program",
       color = "CO2 (ppm)") +
  theme_ipsum_pub() +
  transition_reveal(Data)

anim <-
animate(p2, nframes = 468, fps = 30) # ATENÇÃO RENDERIZAÇÃO LONGA
save_animation(animation = anim, file = "AtmCO2.gif")
