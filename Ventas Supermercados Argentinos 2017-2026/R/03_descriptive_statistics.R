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

ventas_corrientes <- ventas_supermercados$ventas_precios_corrientes

############################################################
# 1. Medidas de tendencia central
############################################################

mean(ventas_corrientes)

median(ventas_corrientes)


############################################################
# 2. Medidas de dispersión
############################################################

#Desvío estándar
sd(ventas_corrientes)

#Varianza
var(ventas_corrientes)

#Rango
range(ventas_corrientes)

#Rango intercuartílico
IQR(ventas_corrientes)

#Coeficiente de variación
sd(ventas_corrientes) / mean(ventas_corrientes) * 100


############################################################
# 3. Medidas de posición.
############################################################

#Cuartiles
quantile(ventas_corrientes)

#Deciles
quantile(ventas_corrientes, probs = seq(0, 1, 0.1))

#Percentiles
quantile(ventas_corrientes, probs = c(.10,.25,.50,.75,.90,.95,.99))


############################################################
# 4. Medidas de forma.
############################################################

library(moments)

#Asimetría
skewness(ventas_corrientes)

#Curtosis
kurtosis(ventas_corrientes)


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
# Identificar posibles valores atípicos en la variable
# ventas_precios_corrientes mediante el criterio del rango
# intercuartílico (IQR).
############################################################

###################################################
#Podría haberlo hecho de forma rápida con boxplot:

#"boxplot.stats(ventas_corrientes)"

#pero preferí hacerlo manualmente para la ocasión.
###################################################


# Primer cuartil (Q1)
Q1 <- quantile(ventas_corrientes, 0.25)

# Tercer cuartil (Q3)
Q3 <- quantile(ventas_corrientes, 0.75)

# Rango intercuartílico (IQR)
IQR_ventas <- IQR(ventas_corrientes)

# Límite inferior
limite_inferior <- Q1 - (1.5 * IQR_ventas)

# Límite superior
limite_superior <- Q3 + (1.5 * IQR_ventas)

# Cantidad de valores atípicos detectados
cantidad_outliers <- sum(
  ventas_corrientes < limite_inferior |
    ventas_corrientes > limite_superior
)

# Porcentaje de valores atípicos
porcentaje_outliers <- round(
  (cantidad_outliers / length(ventas_corrientes)) * 100, 2)

# Registros considerados valores atípicos
outliers <- ventas_supermercados |>
  filter(ventas_precios_corrientes < limite_inferior |
      ventas_precios_corrientes > limite_superior)

############################################################
# Resultados
############################################################

cat("Cantidad de valores atípicos:", cantidad_outliers, "\n")
cat("Porcentaje de valores atípicos:", porcentaje_outliers, "%\n\n")

outliers
