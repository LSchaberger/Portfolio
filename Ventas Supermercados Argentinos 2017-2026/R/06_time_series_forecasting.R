############################################################
# Proyecto:
# Análisis de Ventas de Supermercados en Argentina (INDEC)
#
# Script:
# 06_forecasting.R
#
# Objetivo:
# Construir un modelo de series temporales para pronosticar
# las ventas mensuales a precios constantes.
############################################################

############################################################
# Índice
#
# 1. Carga de librerías.
# 2. Conexión a la base de datos.
# 3. Importación de los datos.
# 4. Preparación de los datos.
# 5. Creación de la serie temporal.
# 6. Exploración de la serie temporal.
# 7. Ajuste del modelo.
# 8. Pronóstico.
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
library(forecast)


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
# 4. Preparación de los datos
############################################################

ventas_supermercados <- ventas_supermercados |>
  filter(indice_tiempo < "2026-01-01")


############################################################
# 5. Creación de la serie temporal
#
# Objetivo:
# Crear una serie temporal mensual con las ventas a precios
# constantes para el período 2017-2025.
############################################################

serie_ventas <- ts(
  ventas_supermercados$ventas_precios_constantes,
  start = c(2017, 1),
  frequency = 12
)


############################################################
# 6. Exploración de la serie temporal
#
# Objetivo:
# Visualizar la evolución temporal de las ventas mensuales y
# analizar sus componentes.
############################################################

# Monthly Sales Time Series
# File name: monthly_sales_time_series.png

autoplot(serie_ventas) +
  labs(
    title = "Monthly Sales at Constant Prices (2017-2025)",
    x = "Year",
    y = "Monthly Sales (ARS)"
  ) +
  theme_minimal()


# Time Series Decomposition
# File name: time_series_decomposition.png

descomposicion <- stl(
  serie_ventas,
  s.window = "periodic"
)

autoplot(descomposicion) +
  labs(
    title = "Time Series Decomposition"
  ) +
  theme_minimal()


############################################################
# 7. Ajuste del modelo
#
# Objetivo:
# Ajustar un modelo ETS para representar la tendencia y la
# estacionalidad de las ventas mensuales.
############################################################

# Ajuste del modelo ETS

modelo_ets <- ets(serie_ventas)

print(summary(modelo_ets))


modelo_resumen <- tibble(
  Metric = c(
    "Model",
    "AIC",
    "BIC",
    "AICc"
  ),
  Value = c(
    modelo_ets$method,
    round(modelo_ets$aic, 2),
    round(modelo_ets$bic, 2),
    round(modelo_ets$aicc, 2)
  )
)

print(modelo_resumen)


############################################################
# 8. Pronóstico
#
# Objetivo:
# Generar un pronóstico de las ventas mensuales para los
# próximos 12 meses utilizando el modelo ETS.
############################################################

# Pronóstico para los próximos 12 meses

pronostico <- forecast(
  modelo_ets,
  h = 12
)

# Monthly Sales Forecast
# File name: monthly_sales_forecast_2026.png

autoplot(pronostico) +
  labs(
    title = "Monthly Sales Forecast for 2026",
    x = "Year",
    y = "Monthly Sales (ARS)"
  ) +
  scale_x_continuous(
    breaks = 2017:2027
  ) +
  theme_minimal()

# Tabla resumen del pronóstico

pronostico_resumen <- tibble(
  Month = seq(
    as.Date("2026-01-01"),
    by = "month",
    length.out = 12
  ),
  Forecast = round(as.numeric(pronostico$mean), 2),
  Lower_95 = round(pronostico$lower[, 2], 2),
  Upper_95 = round(pronostico$upper[, 2], 2)
)

print(pronostico_resumen)


# Exportación del pronóstico para 2026
write_csv(
  pronostico_resumen,
  "results/forecast_2026.csv"
)


############################################################
# Cierre de la conexión
############################################################

dbDisconnect(con)

