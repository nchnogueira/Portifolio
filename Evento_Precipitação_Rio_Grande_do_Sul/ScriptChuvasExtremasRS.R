# ============================================================== #
# ANÁLISE DE PRECIPITAÇÃO EXTREMA NO RIO GRANDE DO SUL (ABR/MAI 2024)
# ============================================================== #
# Autoria: Nícolas Chenquel Nogueira
# Orientação: Dra. Eliane Barbosa Santos
# Fomento: ProEx UENF
# Dados:
#   - INMET/BDMEP: Séries horárias de estações automáticas
#   - GeoBR: Shapefiles de unidades territoriais
# Contexto Histórico: Maior evento pluviométrico já registrado no estado
#                     com >2 milhões de afetados e perdas de R$ 10 bi+
# ============================================================== #

# ------ CONFIGURAÇÃO DO AMBIENTE ------
# Pacotes

packages <- c("tidyverse", "camcorder", "ggtext", "showtext",
              "ggrepel", "magick", "sf", "geobr", "patchwork",
              "ggspatial")

for (p in packages) {
  if (!require(p, character.only = T)) install.packages(p, character = T)
  library(p, quietly = T, character.only = T)
}

# Demais configurações
if(!dir.exists("camcorder")) dir.create("camcorder/")
gg_record(dir = "camcorder/", device = "png", width = 2000, height = 2000, units = "px", bg = "white")

font_add_google("Outfit", "Outfit")
showtext_auto()

# ------ IMPORTAÇÃO DE DADOS METEOROLÓGICOS ------
# Importando dados 
# Os dados utilizados para este script foram fornecidos gentilmente pelo Instituto Nacional
# de Meteorologia (INMET), através do Banco de Dados Meteorológicos para Ensino e Pesquisa 
# (BDMEP).

# Função para lidar com a importação
import_from_INMET_BDMEP <-
  function(file){
    require(tidyverse)
    df_id <-
      read_csv2(
        file = file,
        col_names = F,
        n_max = 9
      ) |> 
      separate(
        col = X1, 
        into = c("info", "value"), 
        sep = ": "
      ) |> 
      pivot_wider(
        names_from = info, 
        values_from = value
      )
    
    df_data <-
      read_csv2(
        file = file,
        na = "null",
        skip = 10,
        col_types = cols(`Hora Medicao` = col_time(format = "%H%M"))
      ) |> 
      select(!starts_with("...")) 
    
    df_final <-
      bind_cols(df_id, df_data)
    
    return(df_final)
  }

# Listando arquivos para importação

files <- list.files(path = "dados/", full.names = T)

# Importando dados

dados <-
  map_df(
    .x = files,
    .f = ~ import_from_INMET_BDMEP(file = .x)
  )

# ------ IMPORTAÇÃO GEOESPACIAL ------
# Integração com bases do IBGE via pacote geobr:
# - América do Sul (escala 1:250k)
# - Mesorregiões do RS (divisão 2022)
# - Georreferenciamento de estações

LatAme <- read_sf("a__031_001_americaDoSul/a__031_001_americaDoSul.shp")
BR_states <- read_state()
RS_meso <- read_meso_region(code_meso = "RS")

# ------ ENGENHARIA DE DADOS ------
# Transformações aplicadas:
# 1. Cálculo de precipitação acumulada por estação
# 2. Classificação mesorregional das estações
# 3. Padronização de coordenadas geográficas
# 4. Preparação de rótulos dinâmicos

dados_f <-
  dados |>
  mutate(
    DataHora = paste(`Data Medicao`, `Hora Medicao`) |> ymd_hms(),
  ) |> 
  drop_na() |> 
  group_by(`Codigo Estacao`) |> 
  mutate(
    Prec_acc = cumsum(`PRECIPITACAO TOTAL, HORARIO(mm)`)
  ) |> 
  ungroup() |> 
  mutate(
    name_meso = 
      case_match(
        Nome,
        "PORTO ALEGRE - JARDIM BOTANICO"  ~ "Metropolitana De Porto Alegre",
        "RIO GRANDE" ~ "Sudeste Rio-Grandense",
        "SANTA MARIA" ~ "Centro Ocidental Rio-Grandense",
        "SANTANA DO LIVRAMENTO" ~ "Sudoeste Rio-Grandense",
        "SANTO AUGUSTO" ~ "Noroeste Rio-Grandense",
        "TORRES" ~ "Metropolitana De Porto Alegre",
        "URUGUAIANA" ~ "Sudoeste Rio-Grandense",
        "SANTA ROSA" ~ "Noroeste Rio-Grandense",
        "CANGUCU" ~ "Sudeste Rio-Grandense",
        "CACAPAVA DO SUL" ~ "Sudeste Rio-Grandense",
        "RIO PARDO" ~ "Centro Oriental Rio-Grandense",
        "ALEGRETE" ~ "Sudoeste Rio-Grandense",
        "BAGE" ~ "Sudoeste Rio-Grandense",
        "ERECHIM" ~ "Noroeste Rio-Grandense",
        "SAO JOSE DOS AUSENTES" ~ "Nordeste Rio-Grandense",
        "SAO BORJA" ~ "Sudoeste Rio-Grandense",
        "QUARAI" ~ "Sudoeste Rio-Grandense",
        "SAO GABRIEL" ~ "Sudoeste Rio-Grandense",
        "SANTIAGO" ~ "Centro Ocidental Rio-Grandense",
        "TRAMANDAI" ~ "Metropolitana De Porto Alegre",
        "JAGUARAO" ~ "Sudeste Rio-Grandense",
        "SOLEDADE" ~ "Noroeste Rio-Grandense",
        "CAMAQUA" ~ "Metropolitana De Porto Alegre",
        "PASSO FUNDO" ~ "Noroeste Rio-Grandense",
        "BENTO GONCALVES" ~ "Nordeste Rio-Grandense",
        "LAGOA VERMELHA" ~ "Nordeste Rio-Grandense",
        "SAO LUIZ GONZAGA" ~ "Noroeste Rio-Grandense",
        "CRUZ ALTA" ~ "Noroeste Rio-Grandense",
        "FREDERICO WESTPHALEN" ~ "Noroeste Rio-Grandense",
        "PALMEIRA DAS MISSOES" ~ "Noroeste Rio-Grandense",
        "MOSTARDAS" ~ "Metropolitana De Porto Alegre",
        "CANELA" ~ "Metropolitana De Porto Alegre",
        "VACARIA" ~ "Nordeste Rio-Grandense",
        "DOM PEDRITO" ~ "Sudoeste Rio-Grandense",
        "TEUTONIA" ~ "Centro Oriental Rio-Grandense",
        "IBIRUBA" ~ "Noroeste Rio-Grandense",
        "CAMPO BOM" ~ "Metropolitana De Porto Alegre",
        "TUPANCIRETA" ~ "Centro Ocidental Rio-Grandense",
        "CAPAO DO LEAO (PELOTAS)" ~ "Sudeste Rio-Grandense",
        "SAO VICENTE DO SUL" ~ "Centro Ocidental Rio-Grandense",
        "ENCRUZILHADA DO SUL"  ~ "Sudeste Rio-Grandense",
        "SERAFINA CORREA" ~ "Nordeste Rio-Grandense",
        "CAMBARA DO SUL" ~ "Nordeste Rio-Grandense",
        "SANTA VITORIA DO PALMAR" ~ "Sudeste Rio-Grandense",
        "PORTO ALEGRE- BELEM NOVO"  ~ "Metropolitana De Porto Alegre"
      ) |> as.factor(),
    across(Latitude:Longitude, parse_number)
  )

# ------ MODELAGEM DE VISUALIZAÇÃO ------
# Sistema híbrido de plots contendo:
# - Mapa de contexto regional (ggspatial)
# - Série temporal acumulada (ggplot2)
# - Anotações dinâmicas (ggrepel)
# - Elementos cartográficos profissionais

# Geração automatizada para 7 mesorregiões:
# 1. Metropolitana de Porto Alegre
# 2. Nordeste Rio-Grandense
# 3. Noroeste Rio-Grandense
# 4. Sudoeste Rio-Grandense
# 5. Sudeste Rio-Grandense
# 6. Centro Ocidental Rio-Grandense
# 7. Centro Oriental Rio-Grandense

# Adição de elementos institucionais:
# - Logotipos do projeto
# - QR Code para repositório
# - Metadados de autoria

dados_label <-
  dados_f |> 
  group_by(Nome) |> 
  summarise(
    lab_x = max(DataHora),
    lab_y = max(Prec_acc),
    lab_l = paste(lab_y, "mm"),
    name_meso = unique(name_meso)
  ) |> 
  arrange(desc(lab_y))

plots <-
  function(data, region){
    
    ggmap_plot <-
      ggplot(
        data = {{data}} |> filter(name_meso == region),
      ) +
      geom_sf(data = LatAme, fill = "gray90", color = "gray70") +
      geom_sf(data = BR_states, fill = "gray80", color = "gray50", lwd = 1.1) +
      geom_sf(data = RS_meso, fill = "gray70") +
      geom_sf(data = RS_meso |> filter(name_meso == region),
              fill = "#8dd3c7") +
      geom_point(
        aes(x = Longitude, y = Latitude, color = fct_relevel(Nome, dados_label$Nome)), 
        size = 2, show.legend = F) +
      scale_color_viridis_d(begin = 0.1, end = 0.9) +
      scale_x_continuous(
        limits = c(-58, -49.3)
      )  +
      scale_y_continuous(
        limits = c(-34, -27)
      ) +
      ggspatial::annotation_north_arrow(height = unit(0.5, "cm"), width = unit(0.5, "cm")) +
      theme_minimal() +
      theme(
        panel.background = element_rect(fill = "lightskyblue"),
        axis.text = element_text(size = 20),
        axis.title = element_blank(),
        panel.grid = element_blank()
      )
    
    gr <-
      ggplot(
        data = {{data}} |> filter(name_meso == region),
        mapping = aes(x = DataHora, y = Prec_acc, color = fct_relevel(Nome, dados_label$Nome))
      ) +
      geom_path() +
      geom_line(lwd = 1.3, alpha = 0.7) +
      geom_label_repel(
        data = dados_label |> filter(name_meso == region),
        mapping = aes(
          label = lab_l, 
          y = lab_y, 
          x = lab_x, 
          family = "Outfit", 
          fontface = "bold"),
        size = 10,
        force = 1,
        fill = "gray98",
        alpha = 0.9,
        show.legend = F,
        inherit.aes = T
      ) +
      scale_x_datetime( 
        date_labels = "%b %d", breaks = "5 days",
        expand = expansion(mult = c(0, 0.2))
      ) +
      scale_y_continuous(
        limits = c(0, 1200)
      ) +
      scale_color_viridis_d(begin = 0.1, end = 0.9) +
      annotation_custom(
        grob = ggplotGrob(ggmap_plot),
        xmin = ymd_hms("2024-03-09 00:00:00"),
        xmax = ymd_hms("2024-05-15 00:00:00"),
        ymin = 750,
        ymax = 1250
      ) +
      labs(
        title = "Precipitação Acumulada no Rio Grande do Sul em Abril e Maio de 2024",
        subtitle = paste0("Estações automáticas do ", region),
        caption = "Elaborado por: Nícolas Chenquel Nogueira • Fonte dos dados: INMET",
        color = "Estação",
        x = "Dia",
        y = "Precipitação Acumulada (mm)"
      ) +
      theme(
        text = element_text(family = "Outfit", size = 32),
        axis.title = element_text(color = "#8b9099"),
        axis.text = element_text(color = "#8b9099"),
        axis.text.x = element_text(angle = 15, vjust = 0.4, margin = margin(0.5, 0.5, 0.5, 0.5, "mm")),
        axis.ticks = element_line(color = "white"),
        axis.line = element_line(color = "white"),
        plot.title = element_textbox_simple(face = "bold", margin = unit(c(1, 0, 1, 0), "mm")),
        plot.subtitle = element_textbox(margin = unit(c(1, 0, 1, 0), "mm"), size = 30),
        plot.caption = element_text(color = "#8b9099", vjust = 0),
        plot.background = element_rect(fill = "#e9f1ff"),
        plot.margin = margin(t = 3, r = 6, b = 10, l = 3, unit = "mm"),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        legend.title = element_text(face = "bold", size = 38),
        legend.text = element_text(size = 26),
        legend.background = element_blank(),
        legend.position = "inside",
        legend.justification = c(0, 0.45),
        legend.margin = margin(3,3,3,3, "mm"),
        legend.key.spacing.y = unit(0.03, "mm"),
        legend.key.size = unit(4, "mm")
      )
    
    ggsave(filename = paste0("plots/", region, ".png"), plot = gr,
           device = "png", width = 2000, height = 2000,
           unit = "px")
    
    gr      <- image_read(paste0("plots/", region, ".png"))
    qrcode  <- image_read('images/qrcode.png')  |> image_scale("190")
    pexcca  <- image_read('images/pexcca.png')  |> image_scale("190")
    proambr <- image_read('images/proambr.png') |> image_scale("190")
    
    logos <- image_append(image = c(qrcode, pexcca, proambr), stack = F)
    
    image_composite(gr, logos, gravity = "SouthWest") |> 
      image_write(
        path = paste0("plots/", region, ".png"),
        format = "png",
      )
  }

for(i in unique(dados_f$name_meso)) {
  plots(data = dados_f, region = i)
}

