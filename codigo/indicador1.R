source("R/functions.R")

indicador2_1_1 <- readxl::read_xlsx('dados/2.1.1-Tx-Cobertura-Prev-Ocupados.xlsx', sheet = "serie_2")

cria_indicador(2,1,1, 'tx_cobertura_prev_ocupados', "Taxa de cobertura previdenciária dos ocupados de 16 a 64 anos")
