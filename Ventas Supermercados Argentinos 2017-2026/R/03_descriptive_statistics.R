############################################################
# Proyecto: Análisis del Desempeño de ventas_corrientes de Supermercados Argentinos
# Autor: Leandro Daniel Schaberger
#
# Archivo: 03_descriptive_statistics.R
#
# Objetivo:
# Calcular estadísticas descriptivas de las principales
# variables del conjunto de datos para comprender su
# comportamiento antes del análisis exploratorio.
############################################################


############################################################
# Índice
#
# 1. Medidas de tendencia central.
# 2. Medidas de dispersión.
# 3. Medidas de posición.
#    3.1 Cuartiles.
#    3.2 Deciles.
#    3.3 Percentiles.
# 4. Medidas de forma.
# 5. Análisis de correlación.
# 6. Detección de valores atípicos.
############################################################


library(dplyr)
library(readr)
library(moments)


# Creación de la carpeta de resultados
if (!dir.exists("results")) {
  dir.create("results")
}


ventas_corrientes <- ventas_supermercados$ventas_precios_corrientes

############################################################
# Estadísticas descriptivas
############################################################

# Medidas de tendencia central
media <- mean(ventas_corrientes)
mediana <- median(ventas_corrientes)

# Medidas de dispersión
desvio_estandar <- sd(ventas_corrientes)
varianza <- var(ventas_corrientes)
minimo <- min(ventas_corrientes)
maximo <- max(ventas_corrientes)
rango <- maximo - minimo
rango_intercuartilico <- IQR(ventas_corrientes)
coeficiente_variacion <- desvio_estandar / media * 100

# Medidas de forma
asimetria <- skewness(ventas_corrientes)
curtosis <- kurtosis(ventas_corrientes)


############################################################
# 5. Análisis de correlación
#
# Objetivo:
# Analizar el grado de asociación lineal entre las
# principales variables del conjunto de datos.
############################################################

correlacion <- ventas_supermercados |>
  select(
    ventas_precios_corrientes,
    ventas_precios_constantes,
    salon_ventas,
    canales_on_line
  )


# Matriz de correlación
matriz_correlacion <- cor(correlacion)

# Matriz de correlación redondeada
matriz_correlacion_redondeada <- round(matriz_correlacion, 2)

# Mostrar resultados
matriz_correlacion

matriz_correlacion_redondeada



############################################################
# 6. Detección de valores atípicos
#
# Objetivo:
# Identificar los valores atípicos de la variable
# ventas_precios_corrientes mediante la regla de Tukey.
############################################################

# Valores atípicos según la regla de Tukey (1.5 × IQR)
outliers <- boxplot.stats(ventas_corrientes)$out

# Cantidad de valores atípicos
cantidad_outliers <- length(outliers)

# Porcentaje de valores atípicos
porcentaje_outliers <- round(
  cantidad_outliers / length(ventas_corrientes) * 100,
  2
)

# Registros correspondientes a los valores atípicos
outliers_registros <- ventas_supermercados |>
  filter(
    ventas_precios_corrientes %in% outliers
  )



############################################################
# Tabla de estadísticas descriptivas
############################################################

descriptive_statistics <- tibble(
  Statistic = c(
    "Mean",
    "Median",
    "Standard Deviation",
    "Variance",
    "Minimum",
    "Maximum",
    "Range",
    "Interquartile Range",
    "Coefficient of Variation (%)",
    "Skewness",
    "Kurtosis"
  ),
  Value = c(
    media,
    mediana,
    desvio_estandar,
    varianza,
    minimo,
    maximo,
    rango,
    rango_intercuartilico,
    coeficiente_variacion,
    asimetria,
    curtosis
  )
)



############################################################
# Resultados
############################################################

descriptive_statistics

cat("Cantidad de valores atípicos:", cantidad_outliers, "\n")
cat("Porcentaje de valores atípicos:", porcentaje_outliers, "%\n\n")

outliers_registros



# Exportación de las estadísticas descriptivas
write_csv(
  descriptive_statistics,
  "results/descriptive_statistics.csv"
)

