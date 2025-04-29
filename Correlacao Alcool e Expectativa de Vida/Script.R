# ==============================================================
# ANÁLISE: RELAÇÃO ENTRE CONSUMO DE ÁLCOOL, IDH E EXPECTATIVA DE VIDA
# ==============================================================
# Objetivo: Investigar a relação entre consumo de álcool, desenvolvimento humano
#           e expectativa de vida em diferentes países (2020)
# Etapas:
#   1. Carregamento de pacotes e configuração do ambiente
#   2. Importação e preparação dos dados
#   3. Processamento e integração dos datasets
#   4. Criação de visualização
#   5. Análise estatística de correlação
# Pacotes principais:
#   - tidyverse: Manipulação de dados e visualização
#   - countrycode: Padronização de códigos de países
#   - ggflags: Visualização de bandeiras em gráficos
# Fontes de dados:
#   - Our World in Data (dados e metadados)
# Saídas:
#   - Gráfico com bandeiras e estatísticas
#   - Análise de correlação entre as variáveis
# Notas:
#   - Dados referentes ao ano de 2020
#   - Correlação não implica causalidade
#   - Código reproduzível com fontes públicas
# Autor: Nícolas Nogueira @nchnogueira
# Última atualização: 29/04/2025
# ==============================================================

# ------ CONFIGURAÇÃO DO AMBIENTE ------
# Instalação e carregamento de pacotes CRAN
# (Garante a reprodutibilidade do ambiente)
packages <- c(
  "tidyverse", "jsonlite",
  "countrycode",
  "ggtext", "showtext",
  "camcorder", "plotly")

for (p in packages) {
  if (!require(p, character.only = TRUE)) {
    install.packages(p, character.only = TRUE, dependencies = TRUE)
  }
  library(p, quietly = TRUE, character.only = TRUE)
}

# Instalação e carregamento de pacotes externos
# (ggflags não disponível no CRAN oficial)
if(!require("ggflags")) {
  install.packages("ggflags", repos = c(
    "https://jimjam-slam.r-universe.dev",
    "https://cloud.r-project.org"))
}
library(ggflags)

# ------ PREPARAÇÃO GRÁFICA ------
# Configuração de fontes e sistema de gravação de plots
font_add_google("Outfit")  # Fonte moderna e legível
showtext_auto()            # Renderização otimizada para textos

# Configuração do sistema de gravação de imagens
gg_record(
  dir = "Plots",          # Diretório de saída
  units = "px",           # Unidades absolutas para precisão
  height = 1100*1.5,      # Resolução alta para diferentes formatos
  width = 1600*1.5,
  bg = "gray95"           # Fundo padrão para consistência visual
)

# ------ IMPORTAÇÃO DE DADOS ------
# Fontes primárias dos dados (atualizadas em tempo real)
alcool <- read.csv("https://ourworldindata.org/grapher/total-alcohol-consumption-per-capita-litres-of-pure-alcohol.csv")
idh <- read.csv("https://ourworldindata.org/grapher/human-development-index-groups.csv")
expect <- read.csv("https://ourworldindata.org/grapher/life-expectancy.csv")

# Metadados para contextualização
alcool_metadata <- fromJSON("https://ourworldindata.org/grapher/total-alcohol-consumption-per-capita-litres-of-pure-alcohol.metadata.json")
idh_metadata <- fromJSON("https://ourworldindata.org/grapher/human-development-index-groups.metadata.json")
expect_metadata <- fromJSON("https://ourworldindata.org/grapher/life-expectancy.metadata.json")

# Backup dos dados (Abr-2025)
# dir.create("BackupDados/")
# map(
#   .x = c("alcool", "alcool_metadata", "expect", "expect_metadata", "idh", "idh_metadata"),
#   .f = ~ write_rds(.x, file = paste0("BackupDados/", .x, ".rds"))
# )

# ------ PROCESSAMENTO DOS DADOS ------
# Integração dos datasets com tratamento consistente
df <-
  left_join(
    x = alcool,
    y = idh,
    by = c("Code", "Entity", "Year")
  ) |>
  left_join(
    y = expect,
    by = c("Code", "Entity", "Year")
  ) |>
  rename(
    alc = sh_alc_pcap_li,
    exp = life_expectancy_0__sex_total__age_0
  ) |>
  mutate(
    # Conversão para códigos de 2 letras (requerido pelo ggflags)
    Code = countrycode(Code, "iso3c", "iso2c")
  ) |>
  filter(
    Year == 2020, # Foco na análise mais recente
    # Seleção estratégica de países para variedade geográfica e de desenvolvimento
    Code %in% c(
      "CA", "CN", "TD", "SO", "CI", "ML", "ZW", "ZA", "GA", "EJ", "PK",
      "RW", "IN", "UA", "SR", "BO", "IQ", "BD", "VE", "AZ", "BY", "PY",
      "MX", "HN", "SA", "BR", "LT", "AR", "TR", "CO", "PL", "CZ", "UZ",
      "CU", "CR", "DE", "PT", "GB", "NL", "SE", "NO", "FR", "ES", "IT", "JP"
    )
  ) |>
  mutate(Code = tolower(Code)) |> # Padronização para ggflags
  drop_na() # Remoção de dados incompletos

# ------ VISUALIZAÇÃO DOS DADOS ------
# Criação do gráfico principal
plot_final <- df |>
  ggplot(aes(x = alc, y = exp)) +
  # Linha de tendência com intervalo de confiança
  geom_smooth(
    method = "lm",
    linetype = 2,        # Linha tracejada para diferenciar da tendência real
    linewidth = 1.1,
    color = "gray40",    # Cor neutra para elemento secundário
    fill = "gray85"      # Área de confiança sutil
  ) +
  # Marcadores com bandeiras nacionais
  geom_flag(aes(country = Code), size = 7) +
  # Anotações textuais dinâmicas
  geom_text(
    aes(label = toupper(Code)),
    family = "Outfit",    # Consistência tipográfica
    size = 12,
    nudge_y = 1.8,       # Posicionamento estratégico
    color = "gray40"
  ) +
  geom_text(
    aes(label = signif(hdi, 2)),  # IDH com 2 dígitos significativos
    family = "Outfit",
    size = 10,
    nudge_y = -1.8,
    color = "#bb6f16"     # Cor destacada para o IDH
  ) +
  # Elemento de anotação estatística
  geom_curve(
    aes(x = 10, y = 76, xend = 11.25, yend = 54),
    curvature = -0.4,     # Curvatura estética
    color = "gray80",
    linetype = 2
  ) +
  ggtext::geom_richtext(
    aes(x = 10, y = 54, label = "y = 0.9 * x + 67.6 • R² = 0.24 • p-valor < 0.01<br>ρ de Pearson = 0.49 • p-valor < 0.01"),
    color = "gray60",
    size = 10,
    lineheight = 0.2      # Compactação controlada
  ) +
  # Elementos de titulação e documentação
  labs(
    x = "Consumo de Álcool per Capta",
    y = "Expectativa de Vida Populacional",
    title = "Um brinde à longevidade: **<span style='color: #83293d;'>mais taças</span>**, **<span style='color: #1873cc; '>mais tempo</span>**!",
    subtitle = "O <span style='color: #83293d;'>Consumo de Àlcool per Capta</span> apresenta uma correlação **sem causalidade** com a <span style='color: #1873cc; '>Expectativa de Vida Populacional</span>. A explicação para o fenômeno pode ser atribuída<br>a outras variáveis, por exemplo, o <span style='color: #bb6f16; '>IDH</span> ou aspectos culturais.",
    caption = "Estimativa de consumo de álcool medida em litros de álcool puro por pessoa com 15 anos ou mais, por ano.<br>Expectativa de vida ao nascer, em um determinado ano.<br>Dados referentes ao ano de 2020. Fonte: ourworldindata.org • **Elaborado por Nícolas Nogueira @nchnogueira**"
  ) +
  # Tematização profissional
  theme_minimal(base_family = "Outfit") +
  theme(
    text = element_text(size = 40),
    plot.title = element_textbox_simple(
      size = 68,          # Hierarquia visual clara
      margin = margin(b = 10)),
    plot.subtitle = element_textbox_simple(
      lineheight = 0.2,   # Compactação controlada
      margin = margin(b = 20)),
    plot.caption = element_textbox_simple(
      lineheight = 0.1,
      size = 30,
      color = "gray70",
      margin = margin(t = 15)),
    axis.title.x = element_text(color = "#83293d"),
    axis.title.y = element_text(
      color = "#1873cc",
      angle = 90,         # Alinhamento vertical padrão
      margin = margin(r = 10)),
    panel.grid.major = element_line(
      color = "gray70",
      linetype = 3,       # Linhas pontilhadas sutis
      linewidth = 0.35)
  )

plot_final

ggsave(
  filename = 'Plot_Correlacao_Causalidade.png',
  plot = plot_final,
  units = "px",           # Unidades absolutas para precisão
  height = 1100*1.5,      # Resolução alta para diferentes formatos
  width = 1600*1.5,
  bg = "gray95"
)

# ------ ANÁLISE ESTATÍSTICA ------
# Modelo linear para relação alcool-expectativa de vida
mod <- lm(exp ~ alc, data = df)
summary(mod)  # Extração de R² e coeficientes

# Teste de correlação para validação
cor_test <- cor.test(df$exp, df$alc)
cor_test  # Coeficiente e significância

# Nota: Os resultados destas análises são utilizados diretamente
#       nas anotações do gráfico principal
