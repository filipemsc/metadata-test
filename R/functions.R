cria_indicador <- function(co_tema, co_subtema, co_indicador, abbrev_indicador, nome_indicador, fontes, coordenacao){

  co_tema <- as.integer(co_tema)
  co_subtema <- as.integer(co_subtema)
  co_indicador <- as.integer(co_indicador)
  
  # mise en place
  num_indicador <- glue::glue("{co_tema}_{co_subtema}_{co_indicador}")
  nome_indicador <- janitor::make_clean_names(abbrev_indicador)
  label_indicador <- paste0(num_indicador, "_", abbrev_indicador)
  
  file_docs <- glue::glue("docs/{label_indicador}.qmd")
  file_metadata <- glue::glue("metadados/{label_indicador}.yaml")
    
  # metadados

  if(!fs::file_exists(file_metadata)){

  metadata <- list(
    id_indicador = num_indicador,
    co_tema = co_tema, 
    no_tema = co_tema,
    co_subtema = co_subtema,
    no_subtema = co_subtema, 
    abbrev_indicador = abbrev_indicador, 
    no_indicador = nome_indicador, 
    fontes = fontes, 
    coordenacao = coordenacao, 
    criado_por = list(nome = whoami::fullname(), email = whoami::email_address()), 
    criado_em = as.character(format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    series = NULL, 
    documentacao = file_docs, 
    arquivos = NULL,
    atualizado_por = list(nome = whoami::fullname(), email = whoami::email_address()),
    atualizado_em = as.character(format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
    )
  
  yaml::write_yaml(metadata, file_metadata)
  }

  # docs

  body <- readLines("_template/docs_indicador.txt") |> paste(collapse = "\n")
  header <- glue::glue("---
    title: {nome_indicador}
  ---")
  
  docs <- glue::glue("{header}
  
  {body}")

  writeLines(docs, file_docs)
  
}

cria_serie <- function(dados, co_tema, co_subtema, co_indicador, serie){

  # update metadados indicador
  num_indicador <- glue::glue("{co_tema}_{co_subtema}_{co_indicador}")
  file_metadados <- fs::dir_ls(path = "metadados", regexp = paste0(num_indicador, ".*"))
  
  metadados <- yaml::read_yaml(file_metadados)
  if(!serie %in% metadados$serie) metadados$serie <- append(metadados$serie, serie)
  no_indicador <- metadados$no_indicador
  abbrev_indicador <- metadados$abbrev_indicador
  yaml::write_yaml(metadados, file_metadados)

  # calcula período min
  periodo_min <- min(dados$ano)
  periodo_max <- min(dados$ano)

  # create_metadados_serie
  file_metadados_serie <- glue::glue("metadados/{num_indicador}_{abbrev_indicador}_{serie}.yaml")

  metadados_serie <- list(
    num_indicador = num_indicador, 
    no_indicador = no_indicador,
    serie = serie,
    criado_por = list(nome = whoami::fullname(), email = whoami::email_address()), 
    criado_em = as.character(format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    periodo_min = periodo_min,
    periodo_max = periodo_max,
    colunas = names(dados),
    atualizado_por = list(nome = whoami::fullname(), email = whoami::email_address()),
    atualizado_em = as.character(format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
  )

  yaml::write_yaml(metadados_serie, file_metadados_serie)

}