# Portfólio de Análise de Dados - Nícolas Chenquel Nogueira

[![Licença: MIT](https://img.shields.io/badge/Licença-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Linguagem R](https://img.shields.io/badge/Powered_by-R-276DC3?logo=R)](https://www.r-project.org)

🌍 **Bem-vindo ao meu repositório de projetos em Ciência de Dados!**  
Um espaço dedicado à análise exploratória, visualização criativa e storytelling com dados.

---

## 📌 Sobre Mim

**Nícolas Chenquel Nogueira**  
🎓 Licenciado em Ciências Biológicas pela *Universidade Federal do Rio de Janeiro*  
💻 Programador em Linguagem R | 📊 Analista de Dados | 📈 Especialista em Visualização Científica

Combinando formação em ciências naturais com expertise técnica, desenvolvo análises que traduzem dados complexos em insights acionáveis. Minha abordagem enfatiza:
- Rigor estatístico com clareza narrativa
- Visualizações autoexplicativas
- Reproducibilidade científica
- Integração interdisciplinar

**Habilidades Técnicas:**  
`R` `tidyverse` `ggplot2` `shiny` `markdown` `Git` `Estatística Descritiva` `Análise Espacial`

---

## 📂 Visão Geral do Repositório

### 📊 **Análise Socioepidemiológica - Consumo de Álcool vs Indicadores Globais**

![Gráfico de Correlação](Correlacao_Alcool_e_Expectativa_de_Vida/Plot_Correlacao_Causalidade.png)  
*Visualização interativa produzida com ggplot2 e ggflags*

#### 🔍 **Contexto Analítico:**  
Investigação da relação entre consumo de álcool per capita, IDH e expectativa de vida em 45 países (2020). Detalhes técnicos:
- Fontes: Our World in Data
- Técnicas: Modelagem linear, análise de correlação
- Ferramentas: `tidyverse`, `countrycode`, `ggtext`

#### 💡 **Principais Insights:**  
- Correlação significativa positiva moderada (ρ = 0.49; p < 0.01) entre variáveis  
- Padrões geoeconômicos identificados  
- IDH como fator mediador relevante  
*(Nota: Correlação ≠ Causalidade)*

### 🌡️ **Análise de Anomalias Térmicas em Campos dos Goytacazes-RJ**

![Heatmap de Anomalias](Anomalias_Temperatura_Campos/Graficos/Anomalias_CamposRJ_gt.png)  
*Tabela interativa produzida com {gt} - Dados: INMET (2024)*

#### 🔍 **Contexto Analítico:**

**Objetivo:**  
Identificar padrões temporais nas variações térmicas mensais comparadas à climatologia histórica (1991-2010) para avaliar tendências locais.

**Metodologia:**  
- Dados observacionais: Série histórica 2011-2024 (INMET/BDMEP)  
- Métrica: `Anomalia = Temperatura Observada - Normal Climatológica`  
- Técnicas:  
  - Visualização matricial com codificação cromática  
  - Análise descritiva longitudinal  

**Escala de Interpretação:**  
- 🔵 **Azul**: Temperaturas abaixo da média histórica (até -3°C)  
- 🔴 **Vermelho**: Temperaturas acima da média histórica (até +3°C)  

#### 💡 **Principais Insights:**

1. **Padrão Emergente (2024)**  
   - Primeiro ano com anomalias **positivas em todos os meses**  
   - Abril/2024 apresenta `NA` por inconsistência nos dados brutos  
   - Sinaliza possível aceleração local das mudanças climáticas  

2. **Extremos Verificados**  
   - Período 2011-2023: ~51% dos meses com anomalias positivas  
   - Maior anomalia positiva: **+2.9°C** (Mai/2024)  
   - Maior anomalia negativa: **-1.5°C** (Nov/2011)   

#### ⚠️ **Considerações Metodológicas:**

- **Especificidade Geográfica:**  
  Análise restrita à estação INMET 83698 - Resultados não são generalizáveis  

- **Fatores Não Considerados:**  
  - Urbanização acelerada  
  - Mudanças de uso do solo  
  - Oscilações oceânicas (ex: ENSO)  

- **Recomendações:**  
  - "Apesar do padrão emergente, correlações com mudanças climáticas globais requerem modelagem multivariada e análises em escalas temporais mais extensas."

---
