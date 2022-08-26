pacman::p_load(datasets, tidyverse, ggpubr, ggpval, extrafont, ggtext, ggplotgui)
data(CO2)

CO2 %>% group_by(Treatment, Type) %>%
describe()

#####

CO2 %>%
  ggplot(aes(x = Treatment, y = uptake)) +
    geom_boxplot() +
    geom_point(alpha = 0.3,
               aes(size = conc,
                   colour = Plant)) +
  facet_wrap(~Type) +
  theme_void()+
  labs(title = "Fotossintese <i>Echinochloa crus-galli</i>",
       x = "",
       y = "Ganho liquido de CO2 (umol/m^2)",
       name = c("a","B")) +
  theme(legend.position="none")+
  scale_x_discrete(labels = c("Controle", "Resfriado")) +
  theme(
    plot.title = element_textbox_simple(size = 17),
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
    axis.text.y = element_text(margin = margin(r = 1, unit = 'mm'))) -> plot
  add_pval(ggplot_obj = plot, pairs = list(c(1, 2)), test = "var.test")

#####

CO2 %>% group_by(Type, Treatment) %>%
  mutate(Med = mean(uptake),
         Sd = sd(uptake)) %>% View()
  ggplot(aes(x = Treatment, y = Med, fill = Type)) +
    geom_bar(stat = 'identity', position = "dodge") +
    geom_errorbar(aes(ymin = Med-Sd, ymax = Med+Sd), width = 0.3) +
    facet_wrap(~Type) +
    theme_void()+
  labs(title = "Fotossintese em <i>Echinochloa crus-galli</i>",
       x = "",
       y = "Ganho liquido de CO2 (umol/m^2)"#,
       # name = c("A","B")
       ) +
  theme(legend.position="none")+
  scale_x_discrete(labels = c("Controle", "Resfriado")) +
  scale_fill_brewer(palette = 'Paired') +
  theme(
    plot.title = element_textbox_simple(size = 17),
    plot.background = element_rect(fill = "white"),
    plot.margin = margin(1,1,1,1, 'cm'),
    panel.grid.major = element_line(colour = 'grey70', linetype = 'dotted'),
    panel.grid.minor = element_line(colour = 'grey90', linetype = 'dotted'),
    axis.line = element_line(colour = 'grey50'),
    axis.title = element_text(colour = '#082234'),
    axis.title.y = element_text(angle = 90, margin = margin(r = 2, unit = 'mm')),
    axis.text = element_text()) -> plot2
  add_pval(ggplot_obj = plot2, pairs = list(c(1, 2)),
           test = "t.test", response = 'uptake', pval_star = T)

#####
a
