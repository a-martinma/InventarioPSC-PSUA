# Este script forman parte del Trabajo de Fin de Grado de Álvaro Martín Martín
# (©2023). Distribuido bajo la licencia CC BY-SA 4.0.

##################### MODIFICAR RUTA #####################
ruta <- "/Ruta/a/la/carpeta/donde/se/alojan/los/datasets/"
##################### MODIFICAR RUTA #####################

dfTaxon <- readRDS(paste0(ruta, "20231220_PSC_taxon.r"))
dfRegistro <- readRDS(paste0(ruta, "20231220_PSC_registro.r"))
dfPoblacion <- readRDS(paste0(ruta, "20231220_PSC_poblacion.r"))

rm(ruta)

if (!requireNamespace("httr", quietly = TRUE)) install.packages("httr", depfinencies = TRUE)
library(httr)

if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr", depfinencies = TRUE)
library(dplyr)

if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite", depfinencies = TRUE)
library(jsonlite)

if (!requireNamespace("furrr", quietly = TRUE)) install.packages("furrr")
library(furrr)

convertirEnLista <- function(string) {
  string <- gsub("\"", "", string)
  elementos <- strsplit(string, split = ";")[[1]]
  return(elementos)
}

calcularpesosJSON <- function(parte) {
  sapply(1:nrow(parte), function(i) {
    nchar(toJSON(parte[i, ], auto_unbox = TRUE))
  })
}

transformarEnJSON <- function(parte) {
  toJSON(parte, auto_unbox = TRUE)
}

transformarYYYYMMDD <- function(string) {
  if (string == "YYYYMMDD") {
    return("")
  } else {
    return(string)
  }
}

numCores <- availableCores() / 2
numPartes <- numCores


####################################################
##################CONFIGURACIONES ##################
####################################################

#############
### TAXÓN ###
#############

# Información taxonómica
InformacionTaxonomica <- data.frame(
  species_LP = dfTaxon$species_LP, 
  TAXONID_LP = dfTaxon$TAXONID_LP,
  FAMILY = dfTaxon$FAMILY,
  GENUS = dfTaxon$GENUS,
  SPECIES = dfTaxon$SPECIES,
  SPAUTHOR = dfTaxon$SPAUTHOR,
  scientificName_LP  = dfTaxon$scientificName_LP,
  NATIONAL_CAT = dfTaxon$NATIONAL_CAT,
  LEGSTATUS = dfTaxon$LEGSTATUS,
  DIST_STATUS = dfTaxon$DIST_STATUS,
  acceptedTaxonKey_GBIF = dfTaxon$acceptedTaxonKey_GBIF,
  acceptedScientificName_GBIF = dfTaxon$acceptedScientificName_GBIF,
  ERGF = dfTaxon$ERGF,
  CP_National_Lev = dfTaxon$CP_National_Lev,
  CP_Regional_Lev = dfTaxon$CP_Regional_Lev
)

# Rasgos ecológicos
RasgosEcologicos <- data.frame(TAXONID_LP = dfTaxon$TAXONID_LP)

# RasgosBiologicos
RasgosBiologicos <- data.frame(TAXONID_LP = dfTaxon$TAXONID_LP)

# MejoraGenética
MejoraGenetica <- data.frame(TAXONID_LP = dfTaxon$TAXONID_LP)

# DetalleMejoraGenetica
DetalleMejoraGenetica <- data.frame(
  TAXONID_LP = dfTaxon$TAXONID_LP,
  RELATEDCROP = dfTaxon$RELATEDCROP,
  GENEPOOL = dfTaxon$GENEPOOL
)

# Usos
Usos <- data.frame(USE_VALUE = dfTaxon$USE_VALUE)

###################
### AJUSTES (;) ### 
###################

# Usos$USE_VALUE
indices <- which(!is.na(Usos$USE_VALUE) & Usos$USE_VALUE != "")
Usos$USE_VALUE[indices] <- lapply(Usos$USE_VALUE[indices], convertirEnLista)

# InformacionTaxonomica$LEGSTATUS
indices <- which(!is.na(InformacionTaxonomica$LEGSTATUS) & InformacionTaxonomica$LEGSTATUS != "")
InformacionTaxonomica$LEGSTATUS[indices] <- lapply(InformacionTaxonomica$LEGSTATUS[indices], convertirEnLista)

# DetalleMejoraGenetica$GENEPOOL
indices <- which(!is.na(DetalleMejoraGenetica$GENEPOOL) & DetalleMejoraGenetica$GENEPOOL != "")
DetalleMejoraGenetica$GENEPOOL[indices] <- lapply(DetalleMejoraGenetica$GENEPOOL[indices], convertirEnLista)

# DetalleMejoraGenetica$RELATEDCROP
indices <- which(!is.na(DetalleMejoraGenetica$RELATEDCROP) & DetalleMejoraGenetica$RELATEDCROP != "")
DetalleMejoraGenetica$RELATEDCROP[indices] <- lapply(DetalleMejoraGenetica$RELATEDCROP[indices], convertirEnLista)

### ### ### ### ### ### ### ### ### ###
#### Embeber InformacionTaxonomica #### 
### ### ### ### ### ### ### ### ### ###

InformacionTaxonomica$Usos <- Usos

InformacionTaxonomica$RasgosEcologicos <- RasgosEcologicos
InformacionTaxonomica$RasgosBiologicos <- RasgosBiologicos

MejoraGenetica$DetalleMejoraGenetica <- DetalleMejoraGenetica
InformacionTaxonomica$MejoraGenetica <- MejoraGenetica

rm(dfTaxon, RasgosEcologicos, RasgosBiologicos, Usos, DetalleMejoraGenetica, MejoraGenetica)


##############################
### REGISTRO DE OCURRENCIA ###
##############################

# RegistroDeOcurrencia
RegistroDeOcurrencia <- data.frame(
  TAXONID_LP = dfRegistro$TAXONID_LP,
  species_LP = dfRegistro$species_LP,
  POPID = dfRegistro$POPID,
  uniqueID = dfRegistro$uniqueID,
  gbifID = dfRegistro$gbifID,
  basisOfRecord = dfRegistro$basisOfRecord,
  bibliographicCitation = dfRegistro$bibliographicCitation,
  recordedBy = dfRegistro$recordedBy,  
  scientificName_GBIF = dfRegistro$scientificName_GBIF,
  FILTERPOPID = dfRegistro$FILTERPOPID,
  Yearmonthday = dfRegistro$Yearmonthday
)

# DescripciónDelLugar
DescripciónDelLugar <- data.frame(
  uniqueID = dfRegistro$uniqueID,
  stateProvince = dfRegistro$stateProvince,
  county = dfRegistro$county,
  municipality = dfRegistro$municipality,
  locality = dfRegistro$locality,
  island = dfRegistro$island,
  decimalLatitude = dfRegistro$decimalLatitude,
  decimalLongitude = dfRegistro$decimalLongitude,
  coordinateUncertaintyInMeters = dfRegistro$coordinateUncertaintyInMeters,
  verbatimElevation = dfRegistro$verbatimElevation,
  issue = dfRegistro$issue, 
  habitat = dfRegistro$habitat
)

# Herbario
Herbario <- data.frame(
  uniqueID = dfRegistro$uniqueID,
  SPECNUMB = dfRegistro$SPECNUMB,
  HERBCODE = dfRegistro$HERBCODE,
  HERBNAME = dfRegistro$HERBNAME
)

###################
### AJUSTES (;) ###
###################

# RegistroDeOcurrencia$recordedBy
indices <- which(!is.na(RegistroDeOcurrencia$recordedBy) & RegistroDeOcurrencia$recordedBy != "")
RegistroDeOcurrencia$recordedBy[indices] <- lapply(RegistroDeOcurrencia$recordedBy[indices], convertirEnLista)

# DescripciónDelLugar$issue
indices <- which(!is.na(DescripciónDelLugar$issue) & DescripciónDelLugar$issue != "")
DescripciónDelLugar$issue[indices] <- lapply(DescripciónDelLugar$issue[indices], convertirEnLista)

# RegistroDeOcurrencia$Yearmonthday
indices <- which(RegistroDeOcurrencia$Yearmonthday == "YYYYMMDD")
RegistroDeOcurrencia$Yearmonthday[indices] <- lapply(RegistroDeOcurrencia$Yearmonthday[indices], transformarYYYYMMDD)

### ### ### ### ### ### ### ### ### ###
#### Embeber RegistroDeOcurrencia #### 
### ### ### ### ### ### ### ### ### ###

RegistroDeOcurrencia$Herbario <- Herbario
RegistroDeOcurrencia$DescripciónDelLugar <- DescripciónDelLugar

rm(dfRegistro, Herbario, DescripciónDelLugar, transformarYYYYMMDD)

##############################
########## POBLACIÓN##########
##############################

# Población
Poblacion <- data.frame(
  species_LP = dfPoblacion$species_LP,
  POPID = dfPoblacion$POPID,
  OBSDATE = dfPoblacion$OBSDATE,
  ORIGCTY = dfPoblacion$ORIGCTY,
  ADM1 = dfPoblacion$ADM1,
  ADM2 = dfPoblacion$ADM2,
  OCCURSITE = dfPoblacion$OCCURSITE,
  DECLATITUDE = dfPoblacion$DECLATITUDE,
  DECLONGITUDE = dfPoblacion$DECLONGITUDE,
  COORDUNCERT = dfPoblacion$COORDUNCERT,
  BIOGEOGRAPHIC = dfPoblacion$Biogeographic,
  ECOGEOGRAPHIC = dfPoblacion$Ecogeographic,
  SPECIES_LP_ECO = dfPoblacion$species_LP_ECO,
  REMARKS = dfPoblacion$REMARKS,
  ELEVATION = dfPoblacion$ELEVATION,
  DHprot = dfPoblacion$DHprot
)

# InventarioNacional
InventarioNacional <- data.frame(
  POPID = dfPoblacion$POPID,
  PUID = dfPoblacion$PUID,
  NICODE = dfPoblacion$NICODE,
  MLSSTAT = dfPoblacion$MLSSTAT,
  POPSCR = dfPoblacion$POPSRC,
  SAMPSTAT = dfPoblacion$SAMPSTAT,
  SITEPROT = dfPoblacion$SITEPROT,
  STORAGE = dfPoblacion$STORAGE
)

# ConservacionExSitu
ConservacionExSitu <- data.frame(
  OTHERNUMB = dfPoblacion$OTHERNUMB
)

# Gestion
Gestion <- data.frame(
  MNGINSTCODE = dfPoblacion$MNGINSTCODE,
  MNGINSTNAME = dfPoblacion$MNGINSTNAME,
  LIAISONCODE = dfPoblacion$LIAISONCODE,
  LIAISONNAME = dfPoblacion$LIAISONNAME
)	

# MedidasDeConservación
MedidasDeConservación <- data.frame(
  CONSACTION = dfPoblacion$CONSACTION
)

# Links
Links <- data.frame(URL = dfPoblacion$LINKS
)

###################
### AJUSTES (;) ### 
###################

indices <- which(!is.na(Links$URL) & Links$URL != "")
Links$URL[indices] <- lapply(Links$URL[indices], convertirEnLista)

### ### ### ### ### ### ### ### ### ###
######### Embeber Poblaciones ######### 
### ### ### ### ### ### ### ### ### ###

InventarioNacional$Gestion <- Gestion
InventarioNacional$MedidasDeConservación <- MedidasDeConservación

Poblacion$InventarioNacional <- InventarioNacional
Poblacion$ConservacionExSitu <- ConservacionExSitu
Poblacion$Links <- Links

rm(dfPoblacion, InventarioNacional, Gestion, MedidasDeConservación, ConservacionExSitu, Links, convertirEnLista)

###############################
### DISEÑO DE LA ESTRUCTURA ###
###############################

###
### Meter array de RegistrosdeOcurrencia en Poblacion
###
listaRegistrosPoblaciones <- split(RegistroDeOcurrencia, RegistroDeOcurrencia$POPID) 
indices <- match(Poblacion$POPID, names(listaRegistrosPoblaciones))
Poblacion$RegistroDeOcurrencia <- listaRegistrosPoblaciones[indices]


###
### Meter array de Poblaciones en InformacionTaxonomica
###
listaPoblacionesTaxones <- split(Poblacion, Poblacion$species_LP) 
indices <- match(InformacionTaxonomica$species_LP, names(listaPoblacionesTaxones))
InformacionTaxonomica$Poblacion <- listaPoblacionesTaxones[indices]


rm(listaRegistrosPoblaciones, listaPoblacionesTaxones, indices, Poblacion, RegistroDeOcurrencia)


##################################
# Separar los 2 dataframes NUEVO #
##################################

##################
# Calcular pesos #
##################

rowsPerPart <- ceiling(nrow(InformacionTaxonomica) / numPartes)
splitData <- split(InformacionTaxonomica, rep(1:numPartes, each = rowsPerPart, length.out = nrow(InformacionTaxonomica)))

plan(multisession, workers = numCores)
resultados <- future_map(splitData, calcularpesosJSON)
pesosJSON <- unname(unlist(resultados)) 

rm(calcularpesosJSON, resultados, splitData, rowsPerPart)

############################
# Separar los 2 dataframes #
############################

limite <- 10

pesosMayoresQueLimite <- pesosJSON[pesosJSON >= 10]

indicesMenoresQueLimite <- which(pesosJSON < 10)
indicesMayoresQueLimite <- which(pesosJSON >= 10)

InformacionTaxonomicaMenorQueLimite <- InformacionTaxonomica[indicesMenoresQueLimite, ]
InformacionTaxonomicaMayorQueLimite <- InformacionTaxonomica[indicesMayoresQueLimite, ]

rm(indicesMenoresQueLimite, indicesMayoresQueLimite, InformacionTaxonomica, pesosJSON)

##########################################################
# Ajustar el dataframe "InformacionTaxonomicaMayorQueLimite" #
##########################################################


InformacionTaxonomicaMayorQueLimiteAjustado <- data.frame()

for (i in 1:nrow(InformacionTaxonomicaMayorQueLimite)) {
  pesoFila <- pesosMayoresQueLimite[i]
  
  numDivisiones <- ceiling(pesoFila / limite)
  numFilasPoblacion <- nrow(InformacionTaxonomicaMayorQueLimite$Poblacion[[i]])
  numTamañoDivisiones <- ceiling(numFilasPoblacion / numDivisiones)
  
  for (j in 1:numDivisiones) {
    inicio <- (j - 1) * numTamañoDivisiones + 1
    fin <- min(j * numTamañoDivisiones, numFilasPoblacion)
    
    nuevaFila <- InformacionTaxonomicaMayorQueLimite[i, ]
    nuevaFila$Poblacion <- list(InformacionTaxonomicaMayorQueLimite$Poblacion[[i]][inicio:fin, ])
    
    InformacionTaxonomicaMayorQueLimiteAjustado <- bind_rows(InformacionTaxonomicaMayorQueLimiteAjustado, nuevaFila)
  }
}

rm(pesosMayoresQueLimite, numTamañoDivisiones, fin, i, indiceMenosOchenta, j, limite, numDivisiones, numFilasPoblacion, inicio, pesoFila, nuevaFila, InformacionTaxonomicaMayorQueLimite)

############################
### INSERCIÓN EN MONGODB ###
############################

 ##############
# INSERCIÓN DE: InformacionTaxonomicaMayorQueLimiteAjustado
 ##############

rowsPerPart <- ceiling(nrow(InformacionTaxonomicaMayorQueLimiteAjustado) / numPartes)
splitData <- split(InformacionTaxonomicaMayorQueLimiteAjustado, rep(1:numPartes, each = rowsPerPart, length.out = nrow(InformacionTaxonomicaMayorQueLimiteAjustado)))

plan(multisession, workers = numCores)
resultados <- future_map(splitData, transformarEnJSON)

for (json in resultados) {
  POST("http://localhost:5000/insert", body = json, encode = "json")
}

 ##############
# INSERCIÓN DE: InformacionTaxonomicaMenorQueLimite
 ##############

rowsPerPart <- ceiling(nrow(InformacionTaxonomicaMenorQueLimite) / numPartes)
splitData <- split(InformacionTaxonomicaMenorQueLimite, rep(1:numPartes, each = rowsPerPart, length.out = nrow(InformacionTaxonomicaMenorQueLimite)))

plan(multisession, workers = numCores)
resultados <- future_map(splitData, transformarEnJSON)

for (json in resultados) {
  POST("http://localhost:5000/insert", body = json, encode = "json") 
}


rm(InformacionTaxonomicaMayorQueLimiteAjustado, InformacionTaxonomicaMenorQueLimite, resultados, rowsPerPart, splitData, numCores, numPartes)