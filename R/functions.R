proj_destroy <- function(){

  fs::dir_ls("indicadores/") |> lapply(fs::file_delete)
  fs::dir_ls("metadados/") |> lapply(fs::file_delete)
  fs::dir_ls("docs/") |> lapply(fs::file_delete)
  fs::dir_ls("_site/inds/") |> lapply(fs::file_delete)
  quarto::quarto_render("_site/index.qmd")
}

cria_indicador <- function(co_area, co_tema, co_subtema, co_indicador, abbrev_indicador, nome_indicador, fontes, coordenacao){

  pk_value <- paste0(co_area, "_", co_tema, "_", co_subtema)
  td_tema <- data.table::fread("_aux/td_tema.csv")
  categ <- collapse::fsubset(td_tema, pk == pk_value)

  co_area <- as.integer(co_area)
  co_tema <- as.integer(co_tema)
  co_subtema <- as.integer(co_subtema)
  co_indicador <- as.integer(co_indicador)
  
  # mise en place
  num_indicador <- glue::glue("{co_area}_{co_tema}_{co_subtema}_{co_indicador}")
  abbrev_indicador <- janitor::make_clean_names(abbrev_indicador)
  label_indicador <- paste0(num_indicador, "_ind_", abbrev_indicador)
  
  file_docs <- glue::glue("docs/{label_indicador}.qmd")
  file_metadata <- glue::glue("metadados/{label_indicador}.yaml")
    
  # metadados
  if(!fs::file_exists(file_metadata)){
  metadata <- list(
    id_indicador = num_indicador,
    co_area = co_area,
    no_area = categ$no_area, 
    co_tema = co_tema, 
    no_tema = categ$no_tema,
    co_subtema = co_subtema,
    no_subtema = categ$no_subtema, 
    abbrev_indicador = abbrev_indicador, 
    no_indicador = nome_indicador, 
    fontes = fontes, 
    diretoria_responsavel = 'disoc',
    coordenacao_responsavel = coordenacao, 
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

cria_serie <- function(dados, co_area, co_tema, co_subtema, co_indicador, serie){

  # update metadados indicador
  num_indicador <- glue::glue("{co_area}_{co_tema}_{co_subtema}_{co_indicador}")
  file_metadados <- fs::dir_ls(path = "metadados", regexp = paste0(num_indicador, "_ind_.*"))
  
  metadados <- yaml::read_yaml(file_metadados)
  if(!serie %in% metadados$series) metadados$series <- append(metadados$serie, serie)
  no_indicador <- metadados$no_indicador
  abbrev_indicador <- metadados$abbrev_indicador
  

  # calcula períodos
  cob_temp <- sort(unique(as.integer(dados$ano)))

  # cria metadados series
  file_metadados_serie <- glue::glue("metadados/{num_indicador}_serie_{serie}_{abbrev_indicador}.yaml")

  metadados_serie <- list(
    num_indicador = num_indicador, 
    no_indicador = no_indicador,
    serie = serie,
    criado_por = list(nome = whoami::fullname(), email = whoami::email_address()), 
    criado_em = as.character(format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    cobertura_temporal = cob_temp, 
    colunas = names(dados),
    atualizado_por = list(nome = whoami::fullname(), email = whoami::email_address()),
    atualizado_em = as.character(format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
  )

  yaml::write_yaml(metadados_serie, file_metadados_serie)

  # cria_indicador 

  file_csv <- glue::glue("indicadores/{num_indicador}_{serie}_{abbrev_indicador}.csv")
  data.table::fwrite(dados, file_csv)

  if(!file_csv %in% metadados$arquivos) metadados$arquivos <- append(metadados$arquivos, file_csv)
  metadados$atualizado_em <- as.character(format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
  yaml::write_yaml(metadados, file_metadados)
}

publish <- function(num_indicador){


  file_metadados <- fs::dir_ls(path = "metadados", regexp = paste0(num_indicador, "_ind_.*"))
  metadados <- yaml::read_yaml(file_metadados)
  criado_por <- metadados$criado_por$nome
  criado_em <- metadados$criado_em
  series_disponiveis <- paste(metadados$series, collapse = ", ")
  atualizado_por <- metadados$atualizado_por$nome
  atualizado_em <- metadados$atualizado_em

  docs <-  readChar(metadados$documentacao, file.info(metadados$documentacao)$size)[1] 
  foot <- glue::glue("### Metadados
  **Publicado por**: {criado_por}\n
  **Criado em:** {criado_em}\n

  **Atualizado por**: {atualizado_por}\n
  **Atualizado em**: {atualizado_em}

  **Séries disponíveis**: {series_disponiveis}
  ")
  
  page <- paste0(docs, "\n", foot)

  page_path <- paste0("_site/inds/", fs::path_file(metadados$documentacao))

  writeLines(page, page_path)

  quarto::quarto_render(page_path)
  quarto::quarto_render("_site/index.qmd")
}

