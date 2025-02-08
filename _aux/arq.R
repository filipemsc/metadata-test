readxl::read_xlsx("dados/2.1.1-Tx-Cobertura-Prev-Ocupados.xlsx",sheet= "td_tema2") |>
  dplyr::filter(!is.na(co_tema)) |>
  dplyr::mutate(pk = paste0(co_area, "_", co_tema, "_", co_subtema)) |>
  data.table::fwrite("_aux/td_tema.csv")
