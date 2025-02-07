indicador_mun <- data.frame(id_municipio = "122411", ano = "2010", ind1 = "48.7")

data <- indicador_mun

cria_indicador <- function(id_indicador, abbrev_indicador, nome_indicador){

  nome_indicador <- janitor::make_clean_names(abbrev_indicador)
  id_indicador <- paste0(numero_indicador, "_", abbrev_indicador)
  
  file_metadata <- glue::glue("metadados/{id_indicador}.yaml")
  
  metadata <- list(
  author_name = whoami::fullname(),
  author_email = whoami::email_address(),
  id_indicador = numero_indicador,
  indicador = nome_indicador, 
  abbrev_indicador = abbrev_indicador, 
  nome_indicador = nome_indicador,
  last_update = as.character(Sys.time())
  ) 

  body <- readLines("_template/docs_indicador.txt") |> paste(collapse = "\n")
  header <- glue::glue("---
    title: {nome_indicador}
  ---")
  
  docs <- glue::glue("{header}
  
  {body}")
 
  writeLines(docs, "docs/docs.qmd")
}


cria_indicador("2.1.1", "tx_cobertura_prev_ocupados", "Taxa de cobertura de ...")


yaml::read_yaml('metadados/ind.yaml')
