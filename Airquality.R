# Bibliotecas

library(tidyverse)
library(lubridate)
library(ggtext)
library(extrafont)

loadfonts(device = "win")

# Carregando e arrumando os dados

df <- tibble(airquality)

# Calculando médias e desvios semanais

df_su <-
  df %>%
  mutate(Year = 1973, .before = Month) %>%
  unite(Date, Year:Day, sep = "-") %>%
  mutate(Date = as.Date(Date),
         Week = week(Date)) %>%
  group_by(Week) %>%
  drop_na() %>%
  mutate(mu = mean(Temp),
         sd = sd(Temp))

# Plotando gráfico

df_su %>%
  ggplot(aes(x = Week, y = mu)) +
  geom_line(color = "#145baf", size = 2) +
  geom_errorbar(aes(ymin = mu - sd, ymax = mu + sd, x = Week),
                width = 0.1, color = "#145baf") +
  geom_point(color = "#145baf", size = 3, shape = 16) +
  geom_hline(yintercept = 77.88235, color = "red", linetype = "twodash") +
  labs(title = "Evolução da Temperatura em Nova York, 1973",
       x = "Semana",
       y = "Médias Semanais de Temperatura (°F)") +
  theme(
    text = element_text(size = 12, family = "mono"),
    plot.title = element_textbox_simple(size = 14),
    plot.background = element_rect(fill = "#fefef4"),
    plot.margin = margin(1,1,1,1, 'cm'),
    panel.grid.major = element_line(colour = 'grey70', linetype = 'dotted'),
    panel.grid.minor = element_line(colour = 'grey90', linetype = 'dotted'),
    panel.background = element_rect(fill = "#fefef4"),
    axis.line = element_line(colour = 'grey50'),
    axis.title = element_text(colour = '#082234'),
    axis.title.y = element_text(angle = 90, margin = margin(r = 2, unit = 'mm')),
    axis.text = element_text())

ggsave("Airquality.png")
