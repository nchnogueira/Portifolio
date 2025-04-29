# ============================================================== #
# ANÁLISE DE TENDÊNCIAS EM EXTREMOS CLIMÁTICOS - CAMPOS DOS GOYTACAZES/RJ
# ============================================================== #
# Projeto: Análise de Tendências de Temperaturas Extremas
# Autoria: Nícolas Chenquel Nogueira¹ ²
# Orientação: Dra. Eliane Barbosa Santos³
# Instituições:
#   1 - Instituto de Biodiversidade e Sustentabilidade (NUPEM/UFRJ)
#   2 - Laboratório de Meteorologia (LAMET/UENF)
#   3 - Universidade Estadual do Norte Fluminense Darcy Ribeiro (UENF)
# Fomento: Bolsa de Extensão - ProEx/UENF
# Evento: Conferência Pan-Americana de Meteorologia 2024
# Dados: INMET (Estação 83698 | 1961-2023)
# Metodologia:
#   - Índices ETCCDI para extremos climáticos
#   - Teste de Mann-Kendall (α=0.05)
#   - Estimador de Sen para magnitude de tendências
# Referências-chave:
#   - IPCC AR6 (2022)
#   - ETCCDI (2009)
#   - Natividade et al. (2017)
#   - Santos & Oliveira (2017)
# Repositório: https://github.com/PExCCA-UENF
# ============================================================== #

# ------ CONFIGURAÇÃO DO AMBIENTE ------
# Instalação e carregamento de pacotes essenciais

required_packages <- c(
  "tidyverse",   # Manipulação de dados e visualização
  "trend",       # Testes não paramétricos para análise de tendências
  "ggtext",      # Elementos textuais estilizados em gráficos
  "camcorder",    # Gravação reprodutível de visualizações
  "showtext"
)

for (p in required_packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p, dependencies = TRUE)
  }
  library(p, character.only = TRUE)
}

# Importando Fonte
font_add_google("Montserrat")
showtext_auto()

# Configurações gráficas
gg_record(
  dir = "plots/",
  device = "png",
  width = 5669,
  height = 1771,
  units = "px",
)

# ------ CARREGAMENTO DE DADOS ------
# Séries históricas diárias do INMET (BDMEP)

df <-
  read_csv2(
    file = "dados/dados_83698_D_1911-06-16_2023-12-31.csv",
    na = "null", skip = 10
  ) |>
  select(!starts_with("...")) |>
  rename_with(~c("Data", "Tmax", "Tmin"))

# ------ CONTROLE DE QUALIDADE ------
# Avaliação de dados faltantes por ano-mês

df |>
  pivot_longer(
    cols = Tmax:Tmin
  ) |>
  group_by(Ano = year(Data), Mes = month(Data), Var = name) |>
  summarise(
    pna = sum(is.na(value)) / n() * 100
  ) |> View()

# Períodos com menos de 15% de dados faltantes: 1960-1985 e 2000-2016

# ------ CÁLCULO DE ÍNDICES ETCCDI ------
# Calcula 8 índices de extremos climáticos anuais

df_a <-
  df |>
  pivot_longer(
    cols = Tmax:Tmin
  ) |>
  group_by(ano = year(Data),
           var = name) |>
  drop_na(value) |>
  summarise(
    # TXn/TNn: Mínimo anual
    stat_min = min(value),
    # TXx/TNx: Máximo anual
    stat_max = max(value),
    # TX10p/TN10p: Dias abaixo do percentil 10
    stat_p10 = sum(value <= quantile(value, probs = 0.10)) / n() * 100,
    # TX90p/TN90p: Dias acima do percentil 90
    stat_p90 = sum(value >= quantile(value, probs = 0.90)) / n() * 100,
  ) |>
  ungroup() |>
  pivot_longer(cols = starts_with('stat_'), names_to = "stat")

df_a

# ------ ANÁLISE ESTATÍSTICA ------
# Testes de Tendência

# Função para codificar significancia dos valores
parse_significance_code <- function(p_values) {
  significance_codes <- character(length(p_values))

  for (i in seq_along(p_values)) {
    if (p_values[i] <= 0.001) {
      significance_codes[i] <- "***"
    } else if (p_values[i] <= 0.01) {
      significance_codes[i] <- "**"
    } else if (p_values[i] <= 0.05) {
      significance_codes[i] <- "*"
    } else if (p_values[i] <= 0.1) {
      significance_codes[i] <- "."
    } else {
      significance_codes[i] <- " "
    }
  }

  return(significance_codes)
}

# Função para aplicar os testes
aplicar_testes <- function(data, var_g, stat_g) {

  # Formatação dos dados
  x <-
    data %>%
    filter(var == var_g, stat == stat_g) %>%
    pull(value) %>%
    ts(start = 1961, end = 2023)

  # Teste de Mann-Kendall (não paramétrico)
  teste_mann.kendal <-
    trend::mk.test(x = x)

  # Estimativa de Sen (magnitude da tendência)
  teste_sens.slope <-
    trend::sens.slope(x = x, conf.level = 0.95)


  df_test <-
    tibble(
      var = var_g,
      stat = stat_g,
      sens_estimates = teste_sens.slope$estimates,
      sens_pval = teste_sens.slope$p.value,
      sens_pval_code = parse_significance_code(p_values = teste_sens.slope$p.value),
      `mk_estimates(S; varS; tau)` = paste(teste_mann.kendal$estimates, collapse = "; "),
      mk_pval = teste_mann.kendal$p.value
    )

  return(df_test)
}

# ------ APLICAÇÃO DOS TESTES ------
# Gera combinações de variáveis e índices para análise

combinacoes_analise <- expand_grid(
  variavel = unique(df_a$var),
  indice = unique(df_a$stat)
)

# Executa análise para todas as combinações
resultados_tendencia <- map2_dfr(
  .x = combinacoes_analise$variavel,
  .y = combinacoes_analise$indice,
  .f = ~ aplicar_testes(data = df_a, var_g = .x, stat_g = .y)
)

# ------ VISUALIZAÇÃO DOS RESULTADOS ------
# Configurações gráficas unificadas

tema <- function(){
  theme_void() +
    theme(
      text = element_text(family = "Montserrat", size = 50, margin = margin(3,3,3,3, "mm")),

      plot.margin = margin(3,3,3,3, "mm"),
      plot.title = element_text(size = 85, face = "bold", margin = margin(b = 3, t = 3, unit = "mm")),

      panel.grid.major = element_line(color = "gray80"),
      panel.grid.minor = element_line(color = "gray93"),

      legend.text = element_textbox_simple(size = 85, padding = unit(c(2,2,2,2), units = "mm")),
      legend.position = "top",
      legend.direction = "vertical",
      legend.justification.top = "left",
      legend.title = element_blank(),
      legend.key.size = unit(15 , "mm"),
      legend.key.spacing.y = unit(2, "mm"),
      legend.key.spacing.x = unit(2, "mm"),

      axis.title = element_text(),
      axis.title.y = element_text(angle = 90),
      axis.text = element_text(),
      axis.line = element_line(),
    )
}

###  Gr1 ----
df_a |>
  filter(stat == "stat_min") |>
  ggplot(
    aes(x = ano,
        y = value,
        color = var)
  ) +
  geom_line() +
  geom_point() +
  geom_smooth(method = "loess") +
  scale_x_continuous(
    breaks = seq(1960, 2020, 10),
    minor_breaks = seq(1965, 2025, 10)) +
  scale_color_manual(
    values = c("#307abd", "#6c3d94"),
    label = c("<b><span style=color:#307abd>[TXn] Mann-Kendall: tau = 0.2968, p < 0.001; Inclinação de Sen: +0.0278 °C/Ano.</span></b>",
              "<b><span style=color:#6c3d94>[TNn] Mann-Kendall: tau = 0.1995, p = 0.022; Inclinação de Sen: +0.0186 °C/Ano.</span></b>")
  ) +
  labs(x = "Ano", y = "Temperatura (°C)", color = "Variável",
       title = "Mínimas Anuais") +
  tema() +
  guides(
    color = guide_legend(override.aes = list(size = 4, linewidth = 2))
  )

### Gr2 ----
df_a |>
  filter(stat == "stat_max") |>
  ggplot(
    aes(x = ano,
        y = value,
        color = var)
  ) +
  geom_line() +
  geom_point() +
  geom_smooth(method = "loess") +
  scale_x_continuous(
    breaks = seq(1960, 2020, 10),
    minor_breaks = seq(1965, 2025, 10)) +
  scale_color_manual(
    values = c("#307abd", "#6c3d94"),
    label = c("[TXx] Mann-Kendall: tau = 0.1359, p = 0.121; Inclinação de Sen: +0.0143 °C/Ano.",
              "<b><span style=color:#6c3d94;font-weight: bold>[TNx] Mann-Kendall: tau = 0.4060, p < 0.001; Inclinação de Sen: +0.0250 °C/Ano.</span></b>")
  ) +
  labs(x = "Ano", y = "Temperatura (°C)", color = "Variável",
       title = "Máximas Anuais") +
  tema() +
  guides(
    color = guide_legend(override.aes = list(size = 4, linewidth = 2))
  )

### Gr3 ----

df_a |>
  filter(stat == "stat_p90") |>
  ggplot(
    aes(x = ano,
        y = value,
        color = var)
  ) +
  geom_line() +
  geom_point() +
  geom_smooth(method = "loess") +
  scale_x_continuous(
    breaks = seq(1960, 2020, 10),
    minor_breaks = seq(1965, 2025, 10)) +
  scale_color_manual(
    values = c("#307abd", "#6c3d94"),
    label = c("[TX90p] Mann-Kendall: tau = 0.1199, p = 0.175; Inclinação de Sen: +0.0010% Dias/Ano.",
              "<b><span style=color:#6c3d94;font-weight: bold>[TN90p] Mann-Kendall: tau = 0.2087, p = 0.017; Inclinação de Sen: +0.0162% Dias/Ano.</span></b>")
  ) +
  labs(x = "Ano", y = "Numero de Dias", color = "Variável",
       title = "Dias Anuais Acima do Percentil 90") +
  tema() +
  guides(
    color = guide_legend(override.aes = list(size = 4, linewidth = 2))
  )

### Gr4 ----

df_a |>
  filter(stat == "stat_p10") |>
  ggplot(
    aes(x = ano,
        y = value,
        color = var)
  ) +
  geom_line() +
  geom_point() +
  geom_smooth(method = "loess") +
  scale_x_continuous(
    breaks = seq(1960, 2020, 10),
    minor_breaks = seq(1965, 2025, 10)) +
  scale_color_manual(
    values = c("#307abd", "#6c3d94"),
    label = c("[TX10p] Mann-Kendall: tau = 0.1123, p = 0.205; Inclinação de Sen: +0.0007% Dias/Ano.",
              "[TN10p] Mann-Kendall: tau = 0.1481, p = 0.094; Inclinação de Sen: +0.0030% Dias/Ano.")
  ) +
  labs(x = "Ano", y = "Numero de Dias", color = "Variável",
       title = "Dias Anuais Abaixo do Percentil 10") +
  tema() +
  guides(
    color = guide_legend(override.aes = list(size = 4, linewidth = 2))
  )

# ------ PRINCIPAIS CONCLUSÕES ------
# Tendências Significativas (α=0.05)

#  1. **Temperatura Mínima (TN):**
#   - **TNn (Mínima Anual):** +0.0186°C/ano (τ=0.1995, p=0.022)*
#   - **TNx (Máxima Anual):** +0.0250°C/ano (τ=0.4060, p<0.001)***
#   - **TN90p (Dias Quentes):** +0.0162% dias/ano (τ=0.2087, p=0.017)*
#
#   2. **Temperatura Máxima (TX):**
#   - **TXn (Mínima Anual):** +0.0278°C/ano (τ=0.2968, p<0.001)***

#   # Tendências Não-Significativas
#   - TXx (Máxima Anual): +0.0143°C/ano (p=0.121)
# - TX90p (Dias Quentes): +0.0010% dias/ano (p=0.175)
# - TX10p (Dias Frios): +0.0007% dias/ano (p=0.205)
# - TN10p (Dias Frios): +0.0030% dias/ano (p=0.094)

# Padrões identificados alinhados com:
# - Natividade et al. (2017) para TN90p em MG
# - Santos & Oliveira (2017) para TNn no PA
# - Dantas et al. (2015) para TNx em PE
# - Silva et al. (2015) para TN90p no PR

# ------ REFERÊNCIAS BIBLIOGRÁFICAS ------

# DANTAS, Leydson Galvíncio; SANTOS, Carlos Antonio Costa dos; OLINDA, Ricardo Alves de. Tendências anuais e sazonais nos extremos de temperatura do ar e precipitação em Campina Grande-PB.

# Revista Brasileira de Meteorologia, v. 30, n. 4, p. 423-434, 2015.

# ETCCDI. Climate Change Indices: Definitions of the 27 core indices. 2009. Disponível em: https://etccdi.pacificclimate.org/list_27_indices.shtml. Acesso em: 08 ago. 2024.

# IPCC. Climate Change 2022: Impacts, Adaptation, and Vulnerability. Contribution of Working Group II to the Sixth Assessment Report of the Intergovernmental Panel on Climate Change [H.-O.
# Pörtner, D.C. Roberts, M. Tignor, E.S. Poloczanska, K. Mintenbeck, A. Alegría, M. Craig, S. Langsdorf, S. Löschke, V. Möller, A. Okem, B. Rama (eds.)]. Cambridge: Cambridge University Press, 2022. 3056
# p. doi:10.1017/9781009325844.

# NATIVIDADE, Ulisses Antônio; GARCIA, Sâmia Regina; TORRES, Roger Rodrigues. Tendência dos índices de extremos climáticos observados e projetados no estado de Minas Gerais. Revista Brasileira
# de Meteorologia, v. 32, p. 600-614, 2017.

# POHLERT, T. trend: Non-Parametric Trend Tests and Change-Point Detection. R package version 1.1.6. 2023. Disponível em: https://CRAN.R-project.org/package=trend.

# R CORE TEAM. R: A Language and Environment for Statistical Computing. Vienna: R Foundation for Statistical Computing, 2024. Disponível em: https://www.R-project.org/.

# SANTOS, Carlos Antonio Costa dos; OLIVEIRA, Verônica Gabriella de. Trends in extreme climate indices for Pará State, Brazil. Revista Brasileira de Meteorologia, v. 32, p. 13-24, 2017.

# SILVA, Wanderson Luiz et al. Tendências observadas em indicadores de extremos climáticos de temperatura e precipitação no estado do Paraná. Revista Brasileira de Meteorologia, v. 30, n. 2, p. 181
# 194, 2015.

# WICKHAM, H. et al. Welcome to the tidyverse. Journal of Open Source Software, v. 4, n. 43, p. 1686, 2019. doi:10.21105/joss.01686. Disponível em: https://doi.org/10.21105/joss.01686
