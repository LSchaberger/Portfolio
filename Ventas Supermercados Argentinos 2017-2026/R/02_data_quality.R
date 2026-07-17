############################################################
# Proyecto: Análisis del Desempeño de Ventas de Supermercados Argentinos
# Autor: Leandro Daniel Schaberger
#
# Archivo: 02_data_quality.R
#
# Objetivo:
# Evaluar la calidad del conjunto de datos importado desde
# MySQL mediante verificaciones de estructura,
# consistencia y completitud antes de realizar el análisis
# estadístico.
############################################################


############################################################
# Índice
#
# 1. Dimensiones del conjunto de datos.
# 2. Tipos de datos.
# 3. Valores faltantes.
# 4. Registros duplicados.
# 5. Verificación de consistencia.
############################################################

############################################################
# 1. Dimensiones del conjunto de datos
#
# Objetivo:
# Verificar que el número de filas y columnas coincida con
# el conjunto de datos validado previamente en MySQL.
############################################################

dim(ventas_supermercados)


############################################################
# 2. Tipos de datos
#
# Objetivo:
# Comprobar que cada variable haya sido importada con el
# tipo de dato esperado.
############################################################

str(ventas_supermercados)


############################################################
# 3. Valores faltantes
#
# Objetivo:
# Identificar la cantidad de valores faltantes presentes
# en cada variable del conjunto de datos.
############################################################

colSums(is.na(ventas_supermercados))


############################################################
# 4. Registros duplicados
#
# Objetivo:
# Verificar si existen registros completamente
# duplicados.
############################################################

sum(duplicated(ventas_supermercados))


############################################################
# 5. Verificación de consistencia
#
# Objetivo:
# Obtener un resumen general del conjunto de datos para
# detectar posibles inconsistencias.
############################################################

skimr::skim(ventas_supermercados)
