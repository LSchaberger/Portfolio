############################################################
# Proyecto: Análisis del Desempeño de Ventas de Supermercados Argentinos
# Autor: Leandro Daniel Schaberger
#
# Archivo: 01_import_and_preparation.R
#
# Objetivo:
# Conectarse a la base de datos MySQL, importar el conjunto
# de datos y realizar una exploración inicial para
# verificar que la información se encuentre lista para los
# análisis posteriores.
############################################################

############################################################

# Índice

# 1. Carga de librerías.

# 2. Conexión a MySQL.

# 3. Importación de la tabla.

# 4. Exploración inicial.

# 5. Conversión de tipos de datos.

# 6. Verificación de valores faltantes.

############################################################

############################################################
# 1. Carga de librerías
############################################################

library(DBI)
library(RMariaDB)
library(dplyr)
library(lubridate)

############################################################
# 2. Conexión a MySQL
############################################################

con <- dbConnect(
  drv = RMariaDB::MariaDB(),
  host = Sys.getenv("MYSQL_HOST"),
  port = as.integer(Sys.getenv("MYSQL_PORT")),
  dbname = Sys.getenv("MYSQL_DATABASE"),
  user = Sys.getenv("MYSQL_USER"),
  password = Sys.getenv("MYSQL_PASSWORD")
)


############################################################
# 3. Verificación de la conexión
############################################################

dbListTables(con)


############################################################
# 4. Importación de la tabla
############################################################

ventas_supermercados <- dbReadTable(
  con,
  "ventas_supermercados"
)


############################################################
# 5. Exploración inicial
#
# Objetivo:
# Verificar que la tabla fue importada correctamente y
# conocer su estructura antes de comenzar el análisis.
############################################################

dim(ventas_supermercados)


names(ventas_supermercados)


str(ventas_supermercados)


glimpse(ventas_supermercados)


head(ventas_supermercados)


tail(ventas_supermercados)


############################################################
# 6. Resumen descriptivo
#
# Objetivo:
# Obtener una visión general del comportamiento de las
# variables antes de iniciar el análisis estadístico.
############################################################

summary(ventas_supermercados)


skimr::skim(ventas_supermercados)


############################################################
# 7. Desconexión de la base de datos
#
# Objetivo:
# Finalizar la conexión con MySQL una vez completada la
# importación y exploración inicial de los datos.
############################################################

dbDisconnect(con)