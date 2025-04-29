# ============================================================== #
# ANÁLISE DE ANOMALIAS TÉRMICAS - CAMPOS DOS GOYTACAZES/RJ
# ============================================================== #
# Objetivo: Analisar e visualizar anomalias térmicas mensais comparando
#           dados observados com normais climatológicas (1991-2010)
# Projeto Colaborativo: Processamento e Análise de Dados Ambientais com R (@proamb.r)
# Repositório: https://github.com/PExCCA-UENF
# Etapas:
#   1. Configuração do ambiente e carregamento de pacotes
#   2. Importação e preparação dos dados brutos
#   3. Cálculo das anomalias térmicas
#   4. Visualização tabular com {gt}
#   5. Visualização gráfica com {ggplot2}
# Dados:
#   - INMET (BDMEP): dados observacionais e normais climatológicas
# Saídas:
#   - Tabela interativa em formato heatmap
#   - Gráfico combinado heatmap + série temporal
# Autor: Nícolas Chenquel Nogueira (@nchnogueira)
# Colaboração: Projeto @proamb.r
# Última atualização: 16/10/2023
# ============================================================== #

# Introdução -------------------------------------------------------------------

# A proposta do presente script é produzir uma visualização em formato de tebela,
# ou heatmap com os dados de anomalias de temperatura da cidade de Campos dos Goy-
# tacazes-RJ. Os dados para a visualização, bem como as normais climatológicas
# dos períodos de referência foram coletadas do Instituto Nacional de Meteorolo-
# gia(INMET), disponíveis em: https://bdmep.inmet.gov.br/ .

# O script segue uma estrutura simples, imporanto os dados e as normais, calculan-
# do as anomalias, e seguindo para a visualização e exportação do produto final.

# Para mais informações do projeto e acompanhar conteúdos relacionados a lingua-
# gem de programação R, siga nossas redes sociais. Sugestões, dúvidas, elogios
# ou críticas, envie e-mail para: pexcca.lamet@uenf.br .


# Bibliotecas e outras configurações--------------------------------------------

# Neste trecho do script, efetuamos a verificação e carregamento dos pacotes
# necessários para a análise e visualização de dados, além de configurar a
# gravação das figuras geradas e a customização de fontes para melhorar a
# estética das visualizações.

# Inicialmente, percorremos uma lista de pacotes requeridos (tidyverse,
# showtext, ggtext, patchwork, gt e gtExtras). Para cada um,
# verificamos se ele está instalado no sistema; caso contrário, o script
# realiza a instalação automaticamente. Em seguida, carregamos todos os pacotes,
# garantindo que suas funções estejam disponíveis para uso posterior no código.

# Posteriormente utilizamos a função font_add_google do pacote showtext para adicionar
# a fonte "Comfortaa" diretamente do Google Fonts, garantindo uma tipografia
# consistente e estilizada nas figuras. Finalmente, ativamos a renderização
# de fontes customizadas através de showtext_auto, o que assegura que a fonte
# escolhida seja aplicada corretamente em todas as visualizações gráficas.

# Função de cada pacote:
#   tidyverse: Coleta de pacotes para manipulação e análise de dados, incluindo dplyr, ggplot2, tibble e outros.
#   showtext: Facilita a utilização de fontes personalizadas em gráficos, especialmente fontes que não estão instaladas localmente, permitindo o uso direto de Google Fonts.
#   ggtext: Permite a adição de elementos textuais aprimorados e estilizados nos gráficos, oferecendo suporte a HTML e Markdown.
#   patchwork: Ferramenta para combinar múltiplos gráficos de forma eficiente e organizada em uma única visualização.
#   gt: Criação de tabelas estilizadas para visualização de dados tabulares de forma clara e esteticamente agradável.
#   gtExtras: Complementa as funcionalidades do gt, permitindo customizações adicionais nas tabelas.

for (p in c("tidyverse",
            "showtext",
            "ggtext",
            "patchwork",
            "gt",
            "gtExtras")) {
  if (!require(p, character.only = T)) {
    install.packages(p, character = T)
  }
  library(p, quietly = T, character.only = T)
}

font_add_google("Comfortaa", "Comfortaa")
showtext_auto()

# Importação e organização dos dados -------------------------------------------

# Neste trecho do script, realizamos a importação e preparação inicial dos dados
# que serão utilizados para análise das anomalias de temperatura em Campos dos
# Goytacazes - RJ. Os dados são provenientes de dois arquivos distintos: um arquivo
# CSV contendo as medições recentes de temperatura e um arquivo Excel que apresenta
# valores climatológicos de referência para o cálculo das anomalias, ambos fornecidos
# pelo INMET.

# Primeiramente, importamos o arquivo CSV dados_83698_M_2000-01-01_2024-09-30.csv
# usando a função read_delim. Essa função permite a leitura de arquivos delimitados
# por ponto e vírgula, tratando corretamente as colunas e valores ausentes (NA)
# designados como "null". Além disso, definimos a formatação adequada para a coluna
# de datas (Data Medicao) e removemos eventuais espaços em branco antes e depois dos
# valores, garantindo uma importação limpa e estruturada dos dados. O parâmetro
# skip = 10 ignora as primeiras 10 linhas do arquivo, que contêm informações de
# cabeçalho irrelevantes para a análise. Esse processo resulta em um dataframe
# denominado df_campos, que conterá as medições históricas de temperatura.

# Em seguida, importamos os dados de normal climatológica (referência histórica)
# a partir do arquivo Excel 01-Temperatura-Média-Compensada-Bulbo-Seco-NCB_1981-2010.xls.
# Para isso, utilizamos a função read_excel do pacote readxl. Especificamos o
# parâmetro skip = 3 para ignorar as três primeiras linhas do arquivo, que contêm
# informações de cabeçalho. Após a leitura, filtramos para incluir apenas as
# informações correspondentes ao código 83698, que é específico para a
# estação meteorológica de interesse. Selecionamos as colunas que representam
# os meses de Janeiro a Dezembro e, com o auxílio da função pivot_longer,
# transformamos os dados para um formato "longo", facilitando futuras operações
# de manipulação e análise.

df_campos <-
  read_delim(
    file = "Dados/dados_83698_M_2000-01-01_2024-12-31.csv",
    delim = ";",
    escape_double = FALSE,
    col_types =
      cols(`Data Medicao` = col_date(format = "%Y-%m-%d")),
    na = "null",
    trim_ws = TRUE,
    skip = 10
  )
df_campos

df_normais <-
  readxl::read_excel(path = "Dados/01-Temperatura-Média-Compensada-Bulbo-Seco-NCB_1981-2010.xls", skip = 3, na = "-") |>
  filter(Código == 83698) |>
  select(Janeiro:Dezembro) |>
  pivot_longer(cols = Janeiro:Dezembro)
df_normais

# Visualização com pacote {gt} -------------------------------------------------

# Neste bloco de código, realizamos a criação de uma visualização tabular das
# anomalias de temperatura média mensal para a cidade de Campos dos Goytacazes-RJ,
# utilizando o pacote {gt}. Inicialmente, preparamos a base de dados, calculando
# as anomalias a partir da diferença entre as temperaturas médias mensais observadas
# e as normais climatológicas previamente importadas. Para facilitar a leitura dos
# resultados, a base é reorganizada por meio de transformações, com as anomalias
# sendo agrupadas por mês e ano.

# Primeiramente, unimos as informações das normais climatológicas aos dados
# observados, organizando-as para que o cálculo das anomalias pudesse ser
# realizado diretamente. Em seguida, transformamos a tabela para um formato mais
# adequado, em que cada coluna representa um mês específico, facilitando a
# visualização anual das anomalias.

# Para a criação da tabela, empregamos o pacote {gt}, que nos permite gerar uma
# estrutura organizada e estilizada. Incluímos um cabeçalho com título e subtítulo
# descritivos, além de uma nota de fonte, para contextualizar os dados e atribuições.
# Adicionalmente, aplicamos uma paleta de cores que varia de azul a vermelho, para
# destacar as anomalias negativas e positivas, respectivamente. Isso possibilita
# uma leitura intuitiva, facilitando a identificação de tendências e padrões de
# anomalias ao longo dos anos.

# A seguir, ocultamos colunas que não são de interesse direto na visualização
# final, e centralizamos todos os elementos para manter a consistência estética.
# Por fim, salvamos a tabela gerada como uma imagem (Anomalias_CamposRJ_gt.png),
# garantindo que o produto final possa ser utilizado em apresentações e relatórios.

df_gt <-
  df_campos |>
  mutate(
    normais = rep(df_normais$value, length.out = n()),
    anomalias = `TEMPERATURA MEDIA COMPENSADA, MENSAL(°C)` - normais,
    ...3 = NULL,
    Ano = year(`Data Medicao`),
    Mês = month(`Data Medicao`)
  ) |>
  rename(Temp = `TEMPERATURA MEDIA COMPENSADA, MENSAL(°C)`) |>
  mutate(Temp = round(Temp, 2), anomalias = round(anomalias, 3)) |>
  select(Ano, Mês, Temp, anomalias) |>
  pivot_wider(names_from = Mês,
              values_from = c(Temp, anomalias)) |>
  rename(
    Jan = anomalias_1,
    Fev = anomalias_2,
    Mar = anomalias_3,
    Abr = anomalias_4,
    Mai = anomalias_5,
    Jun = anomalias_6,
    Jul = anomalias_7,
    Ago = anomalias_8,
    Set = anomalias_9,
    Out = anomalias_10,
    Nov = anomalias_11,
    Dez = anomalias_12
  )

tabela <-
  df_gt |>
  filter(Ano >= 2011) |>
  gt(rowname_col = "Ano") |>
  tab_header(
    title = md(
      "Anomalias de Temperaturas Médias Mensais (°C) de Campos dos Goytacazes - RJ"
    ),
    subtitle = html(
      "<div style='text-align: center;'>Climatologia de referência: 1991-2010</div>"
    )
  ) |>
  tab_source_note(
    source_note = html(
      "<div style='text-align: center;'>
  <div style='margin-bottom: 3px;'>Temperatura:</div>
    <div style='display: flex; align-items: center; justify-content: center;'>
      <span style='margin-right: 10px;'>-3°C</span>
        <div style='position: relative; width: 300px; height: 20px; background: linear-gradient(to right, #67001f, #d6604d, #f7f7f7, #4393c3, #053061); border: 1px solid #808080;'>
          <div style='position: absolute; left: 50%; top: 0; bottom: 0; width: 2px; background-color: #808080;'></div>
            </div>
            <span style='margin-left: 10px;'>3°C</span>
              </div>
              <div style='text-align: center; margin-top: 3px;'>0°C</div>
                </div>
    <div style='text-align: center;'>Fonte dos dados: INMET• Elaborado por Nícolas Chenquel Nogueira (Projeto: @Proamb.R)</div>"
    )
  ) |>
  tab_stubhead(label = md("Ano")) |>
  data_color(
    columns = c(Jan, Fev, Mar, Abr, Mai, Jun, Jul, Ago, Set, Out, Nov, Dez),
    direction = "column",
    target_columns =  c(Jan, Fev, Mar, Abr, Mai, Jun, Jul, Ago, Set, Out, Nov, Dez),
    method = "numeric",
    domain =  seq(from = -3, to = 3, by = 0.5),
    palette = "RdBu",
    reverse = T,
    na_color = "gray50"
  ) |>
  cols_hide(
    columns = c(
      Temp_1,
      Temp_2,
      Temp_3,
      Temp_4,
      Temp_5,
      Temp_6,
      Temp_7,
      Temp_8,
      Temp_9,
      Temp_10,
      Temp_11,
      Temp_12
    )
  ) |>
  cols_align(align = "center", columns = everything()) |>
  cols_nanoplot(
    columns = c(14:25),
    plot_type = "bar",
    autohide = F,
    new_col_label = md("Anomalias"),
    options = nanoplot_options(
      data_bar_fill_color = "#cd0000",
      data_bar_stroke_color = "#cd0000",
      data_bar_negative_fill_color = "#0000cd",
      data_bar_negative_stroke_color = "#0000cd",
      data_point_radius = 0
    )
  )

tabela

tabela |> gt_theme_nytimes() |> gtsave(filename = "Graficos/Anomalias_CamposRJ_gt.png")

## Analises
## Resultados foram utilizados no README do repositório

df_campos |>
  mutate(
    normais = rep(df_normais$value, length.out = n()),
    anomalias = `TEMPERATURA MEDIA COMPENSADA, MENSAL(°C)` - normais,
    ...3 = NULL,
    Ano = year(`Data Medicao`),
    Mês = month(`Data Medicao`)
  ) |>
  rename(Temp = `TEMPERATURA MEDIA COMPENSADA, MENSAL(°C)`) |>
  select(Ano, Mês, Temp, anomalias) |>
  filter(Ano >= 2011) |>
  mutate(
    Anomalias_ID =
      case_when(
        anomalias < 0 ~  "NEG",
        anomalias > 0 ~  "POS",
        anomalias == 0 ~ "-"
      )
  ) |>
  group_by(Anomalias_ID) |>
  summarise(
    n = n()
  )


# Visualização com pacote {ggplot2} --------------------------------------------


# Neste trecho do código, desenvolvemos uma análise visual das anomalias de
# temperatura em Campos dos Goytacazes - RJ, utilizando o ggplot2 para criar
# gráficos que sintetizam as variações mensais e anuais das temperaturas médias
# em comparação aos valores climatológicos de referência. O processo está dividido
# em duas etapas principais: a preparação e manipulação dos dados e a criação
# dos gráficos.

# Primeiramente, criamos o dataframe df_ggplot, derivado de df_campos, que contém
# as informações principais para a visualização. Utilizamos a função transmute para
# gerar uma nova estrutura de dados que simplifica e organiza as colunas necessárias,
# como a data (data), o mês (mes), o ano (ano), a temperatura média compensada (temp),
# e os valores climatológicos normais (normais). A coluna de anomalias (anomalias)
# é calculada como a diferença entre a temperatura média e os valores normais, sendo
# categorizada em valores positivos e negativos por meio da criação de uma variável
# auxiliar (anomalias_c). Além disso, empregamos funções como case_when e case_match
# para classificar as anomalias e converter os meses para abreviações padronizadas
# (por exemplo, "Jan", "Fev", etc.).

# A seguir, elaboramos dois gráficos principais. O primeiro é um heatmap que apresenta
# visualmente as anomalias mensais de temperatura ao longo dos anos. Utilizando o
# ggplot2, o gráfico é construído com a função geom_tile, onde as cores variam de azul
# (valores negativos) a vermelho (valores positivos), destacando as flutuações de
# temperatura em relação à climatologia de referência. Adicionalmente, são incluídos
# textos nos blocos do heatmap para indicar os valores numéricos arredondados das
# anomalias. A escala de cores (scale_fill_gradient2) é configurada para ter o branco
# como ponto médio (zero), azul para temperaturas abaixo da média e vermelho para
# valores acima. Os detalhes estéticos e de tema são ajustados para melhorar a clareza
# e a legibilidade do gráfico, como a configuração das fontes, títulos e legendas.

# O segundo gráfico (cols) é um gráfico de barras que representa as anomalias ao
# longo do tempo, com uma barra para cada mês desde 2008. As barras são coloridas de
# acordo com a natureza das anomalias: azul para valores negativos (abaixo da média)
# e vermelho para valores positivos (acima da média). Utilizamos funções como geom_col
# e scale_fill_manual para definir essas características e destacar as variações de
# maneira clara. Um título de legenda e rótulos adicionais são configurados para
# assegurar uma apresentação limpa e informativa.

# Por fim, os gráficos são combinados utilizando o pacote patchwork para que o heatmap
# e o gráfico de barras sejam apresentados em um único layout vertical. O resultado é
# salvo como uma imagem (Anomalias_CamposRJ_ggheatmap.png) com as especificações de
# tamanho e fundo definidas para assegurar uma visualização adequada e esteticamente
# agradável.

df_ggplot <-
  df_campos |>
  transmute(
    data = `Data Medicao`,
    mes = month(data),
    ano = year(data),
    temp = `TEMPERATURA MEDIA COMPENSADA, MENSAL(°C)`,
    normais = c(rep(df_normais$value, length.out = n())),
    anomalias = temp - normais,
    anomalias_c = case_when(anomalias <= 0 ~ "n", anomalias >= 0 ~ "p", .default = NA),
    mes_n = case_match(
      mes,
      1 ~ "Jan",
      2 ~ "Fev",
      3 ~ "Mar",
      4 ~ "Abr",
      5 ~ "Mai",
      6 ~ "Jun",
      7 ~ "Jul",
      8 ~ "Ago",
      9 ~ "Set",
      10 ~ "Out",
      11 ~ "Nov",
      12 ~ "Dez"
    ) |> factor(
      levels = c(
        "Jan",
        "Fev",
        "Mar",
        "Abr",
        "Mai",
        "Jun",
        "Jul",
        "Ago",
        "Set",
        "Out",
        "Nov",
        "Dez"
      )
    )
  )


heatmap <-
  ggplot(
    data = df_ggplot |> filter(ano >= 2011),
    mapping = aes(
      y = mes_n,
      x = ano,
      fill = anomalias,
      label = anomalias |> round(digits = 2) |> paste()
    )
  ) +
  geom_tile(color = rgb(0, 0, 0, 0.3),
            lwd = 0.5,
            show.legend = T) +
  geom_text(
    mapping = aes(family = "Comfortaa"),
    color = "black",
    size = 5
  ) +
  scale_x_continuous(breaks = 2011:2024) +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 0,
    na.value = "gray70",
    limits = c(-3, 3),
    label = ~paste0(.x,"°")
  ) +
  labs(
    x = "",
    y = "",
    fill = "Temperatura:",
    title = "Anomalias de Temperaturas Médias Mensais (°C) de Campos dos Goytacazes - RJ",
    subtitle = "Climatologia de referencia: 1991-2010",
  ) +
  theme_void() +
  theme(
    text = element_text(family = "Comfortaa", colour = "gray20"),
    plot.title = element_textbox_simple(
      halign = 0.5,
      size = 23,
      face = "bold",
      lineheight = 0.4,
      margin = margin(
        t = 3,
        r = 0,
        l = 0,
        unit = "mm"
      )
    ),
    plot.subtitle = element_text(
      hjust = 0.5,
      vjust = 4,
      size = 15
    ),
    plot.caption = element_text(
      hjust = 0.99,
      vjust = 10,
      size = 14,
      color = "#53738c",
      face = "italic"
    ),
    axis.text = element_text(size = 18),
    axis.text.x = element_text(face = "italic", size = 15, angle = 90),
    legend.position = "bottom",
    legend.key.height = unit(5,units = "pt"),
    legend.title.position = "top"
  ) +
  coord_fixed()
heatmap

cols <-
  ggplot(data = df_ggplot |> filter(ano >= 2011)) +
  aes(x = data, y = anomalias, fill = anomalias_c) +
  geom_col(show.legend = F) +
  scale_fill_manual(values = c("blue3", "red3")) +
  scale_x_date(
    breaks = "6 months",
    date_labels = "%Y",
    limits = c(ymd("2011-01-01"), ymd("2024-12-31"))
  ) +
  labs(caption = "Fonte dos dados: INMET • Elaborado por Nícolas Chenquel Nogueira (Projeto: @Proamb.R)") +
  theme_void() +
  theme(
    text = element_text(family = "Comfortaa", colour = "gray20"),
    plot.caption = element_textbox_simple(
      halign = 0.5,
      size = 12,
      color = "#53738c",
      margin = margin(t = 2, b = 2)
    ),
    axis.text.x = element_text(
      angle = 270,
      size = 0,
      color = "gray50",
      margin = margin(b = 3, unit = "mm")
    )
  )
cols

heatmap + cols +
  plot_layout(ncol = 1, heights = c(6, 1))

ggsave(
  filename = "Graficos/Anomalias_CamposRJ_ggheatmap.png",
  width = 1080,
  height = 1080,
  units = "px",
  bg = "#faf7f2"
)

