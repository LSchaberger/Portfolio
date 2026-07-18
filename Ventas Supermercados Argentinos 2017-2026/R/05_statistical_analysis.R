############################################################
# Proyecto:
# Análisis de Ventas de Supermercados en Argentina (INDEC)
#
# Script:
# 05_statistical_analysis.R
#
# Objetivo:
# Aplicar técnicas de estadística inferencial para analizar
# las ventas, evaluar relaciones entre variables y validar
# resultados mediante modelos estadísticos.
############################################################

############################################################
# Índice
#
# 1. Carga de librerías.
# 2. Conexión a la base de datos.
# 3. Importación de los datos.
# 4. Intervalo de confianza de la media.
# 5. Evaluación de normalidad.
# 6. Análisis de correlación.
# 7. Regresión lineal simple.
# 8. Diagnóstico del modelo.
############################################################

# Creación de la carpeta de resultados
if (!dir.exists("results")) {
  dir.create("results")
}

############################################################
# 1. Carga de librerías
############################################################

library(DBI)
library(RMariaDB)
library(dplyr)
library(ggplot2)
library(broom)


############################################################
# 2. Conexión a la base de datos
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
# 3. Importación de los datos
############################################################

ventas_supermercados <- dbGetQuery(
  con,
  "
  SELECT *
  FROM ventas_supermercados;
  "
)


############################################################
# Preparación de los datos
############################################################

ventas_supermercados <- ventas_supermercados |>
  filter(indice_tiempo < "2026-01-01")


############################################################
# 4. Intervalo de confianza de la media
#
# Objetivo:
# Estimar el intervalo de confianza del 95% para la media de
# las ventas mensuales a precios constantes.
############################################################

ventas <- ventas_supermercados$ventas_precios_constantes

ic_media <- t.test(
  ventas,
  conf.level = 0.95
)

intervalo_confianza_media <- tibble(
  Statistic = c(
    "Sample Mean",
    "Lower 95% Confidence Limit",
    "Upper 95% Confidence Limit"
  ),
  Value = c(
    ic_media$estimate,
    ic_media$conf.int[1],
    ic_media$conf.int[2]
  ),
  Unit = "ARS"
)

print(intervalo_confianza_media)



############################################################
# 5. Evaluación de la normalidad
#
# Objetivo:
# Evaluar si las ventas mensuales a precios constantes siguen
# una distribución aproximadamente normal.
############################################################


#Histograma
ggplot(
  ventas_supermercados,
  aes(x = ventas_precios_constantes)
) +
  geom_histogram(
    bins = 12,
    fill = "#4C72B0",
    color = "white"
  ) +
  labs(
    title = "Distribution of Monthly Sales at Constant Prices 2017-2025",
    x = "Monthly Sales (ARS)",
    y = "Frequency"
  ) +
  theme_minimal()


#Prueba de Shapiro-Wilk
shapiro_resultado <- shapiro.test(ventas)

print(shapiro_resultado)


#Gráfico Q-Q
ggplot(
  ventas_supermercados,
  aes(sample = ventas_precios_constantes)
) +
  stat_qq() +
  stat_qq_line(
    color = "red",
    linewidth = 1
  ) +
  labs(
    title = "Normal Q-Q Plot of Monthly Sales at Constant Prices 2017-2025",
    x = "Theoretical Quantiles",
    y = "Sample Quantiles"
  ) +
  theme_minimal()



#Tabla resumen
normalidad <- tibble(
  Statistic = "Shapiro-Wilk W",
  Value = shapiro_resultado$statistic,
  P_Value = shapiro_resultado$p.value
)

print(normalidad)



############################################################
# 6. Análisis de correlación
#
# Objetivo:
# Evaluar la relación lineal entre las ventas realizadas por
# canales online y las ventas realizadas mediante tarjeta de
# de crédito utilizando el coeficiente de correlación de
# Pearson.
############################################################

#Prueba de correlación
correlacion <- cor.test(
  ventas_supermercados$canales_on_line,
  ventas_supermercados$tarjetas_credito,
  method = "pearson"
)

print(correlacion)


#Tabla resumen
correlacion_resumen <- tibble(
  Statistic = c(
    "Pearson Correlation",
    "Lower 95% Confidence Limit",
    "Upper 95% Confidence Limit",
    "P-Value"
  ),
  Value = c(
    round(correlacion$estimate, 4),
    round(correlacion$conf.int[1], 4),
    round(correlacion$conf.int[2], 4),
    signif(correlacion$p.value, 3)
  )
)

print(correlacion_resumen)



############################################################
# 7. Regresión lineal simple
#
# Objetivo:
# Modelar la relación entre las ventas realizadas por canales
# online y las ventas realizadas mediante tarjeta de crédito.
############################################################

# Ajuste del modelo
modelo <- lm(
  tarjetas_credito ~ canales_on_line,
  data = ventas_supermercados
)



# Coeficientes del modelo
coeficientes_modelo <- tidy(modelo) |>
  transmute(
    Term = term,
    Estimate = round(estimate, 2),
    `Standard Error` = round(std.error, 2),
    `P-Value` = signif(p.value, 3)
  )

print(coeficientes_modelo)


# Métricas del modelo
metricas_modelo <- glance(modelo)


# Tabla resumen
resumen_modelo <- tibble(
  Metric = c(
    "R-Squared",
    "Adjusted R-Squared",
    "Residual Standard Error",
    "P-Value"
  ),
  Value = c(
    round(metricas_modelo$r.squared, 4),
    round(metricas_modelo$adj.r.squared, 4),
    round(metricas_modelo$sigma, 0),
    signif(metricas_modelo$p.value, 3)
  )
)

print(resumen_modelo)



############################################################
# 8. Diagnóstico del modelo
#
# Objetivo:
# Evaluar los supuestos del modelo de regresión lineal mediante
# el análisis gráfico de los residuos.
############################################################


# Residuals vs Fitted
# File name: residuals_vs_fitted.png
plot(
  modelo,
  which = 1
)


# Normal Q-Q Plot of Residuals
# File name: normal_qq_plot_residuals.png
plot(
  modelo,
  which = 2
)


# Scale-Location
# File name: scale_location.png
plot(
  modelo,
  which = 3
)


# Residuals vs Leverage
# File name: residuals_vs_leverage.png
plot(
  modelo,
  which = 5
)


# Exportación del intervalo de confianza
write_csv(
  intervalo_confianza_media,
  "results/confidence_interval.csv"
)

# Exportación del test de normalidad
write_csv(
  normalidad,
  "results/normality_test.csv"
)

# Exportación de los resultados de correlación
write_csv(
  correlacion_resumen,
  "results/correlation_results.csv"
)

# Exportación de los coeficientes de la regresión
write_csv(
  coeficientes_modelo,
  "results/regression_coefficients.csv"
)

# Exportación del resumen del modelo de regresión
write_csv(
  resumen_modelo,
  "results/regression_summary.csv"
)

