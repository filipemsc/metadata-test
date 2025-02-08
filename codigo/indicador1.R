source("R/functions.R")

indicador2_1_1_cat  <- readxl::read_xlsx('dados/2.1.1-Tx-Cobertura-Prev-Ocupados.xlsx', sheet = "serie_1") |>
  dplyr::rename(ano = vl_periodo)

indicador2_1_1_uf <- readxl::read_xlsx('dados/2.1.1-Tx-Cobertura-Prev-Ocupados.xlsx', sheet = "serie_2") |>
  dplyr::rename(ano = vl_periodo)

dados <- indicador2_1_1_uf 

cria_indicador( 
  2,2,1,2, 
  abbrev_indicador = 'tx_cobertura_prev_ocupados', 
  nome_indicador = "Taxa de cobertura previdenciária dos ocupados de 16 a 64 anos",
  fontes = c("pnadc"),
  coordenacao = "copre"
)

cria_serie(
  dados = indicador2_1_1_uf,
  2,2,1,2,
  serie = "uf"
)

cria_serie(
  dados = indicador2_1_1_cat,
  2,2,1,1,
  "categoria"
)

publish(num_ind = "2_2_1_2")
