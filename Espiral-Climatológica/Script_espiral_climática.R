#---------------------------------- ESPIRAL CLIMÁTICA ---------------------------------
# Elaboração: Nícolas C. Nogueira
# Revisão: Profa. Eliane B. Santos
# Atualização: 10/12/2022
#--------------------------------------------------------------------------------------

### Para instalar as bibliotecas necessárias, use os comandos abaixo:
for (p in c("magrittr", "tidyverse", "lubridate", "RColorBrewer"
            "readxl", "ggthemes", "av",
            "showtext", "ggtext")) {
  if (!require(p, character.only = T)) {
    install.packages(p, character = T)
  }
  library(p, quietly = T, character.only = T)
}

font_add_google("Lexend", "Lexend")
showtext_auto()

### Importação e organização dos dados.

# Vamos utilizar os dados mensais de Campos-RJ (Código 83698) obtidos no
# Banco de Dados Meteorológicos para Ensino e Pesquisa (BDMEP) do INMET.
# O BDMEP/INMET disponibiliza os dados no link: https://bdmep.inmet.gov.br/

file1 = "data/dados_83698_M_1961-01-01_2021-12-31.csv" # Arquivo que será importado.

dados <-
  # Importando dados
  read_csv2(
    file = file1,
    skip = 10,
    na = "null"
  ) |> 
  # Selecionando e renomeando as colunas com as datas e a temperatura média compensada (Tmc).
  select(Data = "Data Medicao",
         Tmc = "TEMPERATURA MEDIA COMPENSADA, MENSAL(°C)")  |>
  # Dividindo a coluna Data em 3: Ano, Mes e Dia.
  separate(col = Data, into = c("Ano", "Mes", "Dia"), sep = "-", remove = F) |>
  mutate(Ano = as.numeric(Ano),
         Mes = as.numeric(Mes),
         Dia = as.numeric(Dia)) |>
  # Selecionando os dados a partir de 1991.
  filter(Ano >= 1991)

## Importação e organização das normais climatológicas (1961-1990) da temperatura média compensada (Tmc).
# Link para baixar os dados: https://portal.inmet.gov.br/uploads/normais/Temperatura-Media-Compensada_NCB_1961-1990.xls

file2 = "data/Temperatura-Media-Compensada_NCB_1961-1990.xls" # Arquivo que será importado.

normais <- 
  read_excel(path = file2, sheet = 1, skip = 3, na = "-") |>
  filter(Código == 83698) |>    # Selecionando os dados de Campos-RJ (Código 83698).
  select(Janeiro:Dezembro) |>   # Selecionando as colunas de janeiro a dezembro.
  # Pivotando os dados para obter duas colunas: Mês e Temperatura.
  pivot_longer(cols = everything()) |>
  mutate("Mes" = 1:12)   # Adicionando uma coluna extra com o número dos meses, 1 a 12.

### Criando um data frame com as anomalias de temperatura.
dados.anomalias <- 
  data.frame(
    Ano = as.numeric(dados$Ano),
    Mes = as.numeric(dados$Mes),
    Tmc.mensal = dados$Tmc,
    Tmc.normal = normais$value) |> 
  mutate(
    Tmc.anomalias = Tmc.mensal - Tmc.normal
  )

### Visualização - Espiral climática ###

# Primeiro vamos criar uma conexão dezembro-janeiro.
# Para isso, vamos criar um mês "zero" em cada ano, que representa o mês de dezembro do ano anterior.

Tmc.mes0 <- dados.anomalias |>
  filter(Mes == 12) |>
  mutate(Ano = Ano + 1, Mes = 0)

# Em seguida, crie um vetor com uma sequência de números para funcionar como contagem de frames.
v.seq <- 1:sum(c(nrow(dados.anomalias), nrow(Tmc.mes0)))

# Agora vamos Unir os dados.
dados.plot <-
  dados.anomalias |>
  rbind(Tmc.mes0) |>
  arrange(Ano, Mes) |>
  cbind(v.seq)

# Crie um data frame com os valores (-2 a +2) para legenda.
Legenda <- data.frame(
  x = 1,
  y = seq(from = -2, to = 2, by = 1),
  labels = c("-2\u00B0C", "-1\u00B0C", "0\u00B0C", "+1\u00B0C", "+2\u00B0C"))

# Crie um vetor com os meses para legenda.
Meses <- month(1:12,
               label = TRUE)

# Crie uma pasta no seu computador e a defina como diretório de trabalho para salvar os frames, vamos denominar a pasta de "Anim".
setwd("./img/") # Definindo a pasta "img" como diretório de trabalho.

# Crie um vetor para filtrar o "Mes 0" do gráfico para não ter duplicações.
frames <- data.frame(v.seq,
                     multiplo13 = if_else(v.seq %% 13 == 0,
                                          print("True"),
                                          print("False")))
frames |>
  filter(multiplo13 != "True") |>
  filter(v.seq >= 13) %$%
  as.vector(v.seq) -> frames.f

## Plotando e salvando os frames ##
# ATENÇÃO! Esta etapa demanda tempo.

# Definir intervalos e cores
intervalos <- seq(-3, 3, by = 0.5)
cores <- colorRampPalette(rev(brewer.pal(11, "RdBu")))(length(intervalos) - 1)

for(i in frames.f[1]){
  alpha = c(rep(0.15, times = i - 11), seq(0.15, 1, by = 1/12))
  
  dados.plot |> 
    filter(v.seq <= i) |>
    mutate(Intervalo = cut(Tmc.anomalias, breaks = intervalos, include.lowest = TRUE)) |>
  
    ggplot(aes(x = Mes, y = Tmc.anomalias, group = Ano, color = Intervalo)) +
    geom_hline(yintercept = intervalos, color = "gray30", size = 0.5, alpha = 0.3) +
    geom_hline(yintercept = -2, color = "DarkBlue", size = 1.3, alpha = 0.5) +
    geom_hline(yintercept = -1, color = "#ad84ff", size = 1.3, alpha = 0.5) +
    geom_hline(yintercept = 0, color = "White", size = 1.3, alpha = 0.5) +
    geom_hline(yintercept = 1, color = "#ffa286", size = 1.3, alpha = 0.5) +
    geom_hline(yintercept = +2, color = "DarkRed", size = 1.3, alpha = 0.5) +
    geom_label(data = Legenda, aes(x = x, y = y, label = labels, family = "Lexend"), inherit.aes = F, color = c("DarkBlue", "#ad84ff", "White", "#ffa286", "DarkRed"), fill = "Black", label.size = 0, size = 10, alpha = 0.5) +
    geom_label(aes(x = 0, y = -10, label = Ano, family = "Lexend"), size = 20, fill = "black", label.size = 0) +
    geom_line(size = 1.2, alpha = alpha) +
    geom_point(alpha = alpha) +
    scale_color_manual(
      name = "Anomalia (°C)",
      values = cores,
      labels = levels(cut(dados.plot$Tmc.anomalias, intervalos)),
      drop = FALSE
    ) +
    scale_x_continuous(breaks = 1:12,
                       labels = toupper(Meses)) +
    scale_y_continuous(limits = c(-10, 4)) +
    coord_polar(start = -2*pi/12) +
    labs(title = "test title", caption = "Elaborado por Nícolas Nogueira") +
    theme(
      text = element_text(family = "Lexend", size = 40, color = "white"),
      plot.caption = element_text(size = 20),
      panel.background = element_rect(fill = "Gray10"),
      plot.background = element_rect(fill = "Gray10"),
      panel.grid = element_line(color = "#002240"),
      axis.text.x = element_text(color = "yellow", size = 30),
      axis.text.y = element_blank(),
      axis.title.y = element_blank(),
      axis.title.x = element_blank(),
      axis.ticks = element_blank()
    )
  ggsave(filename = paste("Spiral_Frame_", i+100, # Acrescentamos 100 ao i para evitar problemas no ordenamento de strings com os nomes dos frames.
                          ".png", sep = ""),
         width = 1600, height = 1600,
         units = "px", bg = "Gray10")
}

### Criando um vídeo a partir das imagens ###
images <- list.files(pattern = "Spiral_Frame_",
                     all.files = TRUE, recursive = FALSE)

av::av_encode_video(input = images, output = "Spiral.mp4")

### Para mais informações, dúvidas e/ou sugestões, e-mail para contato: pexcca.lamet@uenf.br