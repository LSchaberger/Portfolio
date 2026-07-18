############################################################
# Proyecto:
# Análisis de Ventas de Supermercados en Argentina (INDEC)
#
# Script:
# 07_power_bi_integration.R
#
# Objetivo:
# Verificar que los archivos generados por los scripts de
# análisis estén disponibles para su utilización en Power BI.
############################################################

############################################################
# Índice
#
# 1. Definición de archivos requeridos.
# 2. Verificación de la carpeta de resultados.
# 3. Verificación de los archivos exportados.
# 4. Mensaje final.
############################################################

# Definición de los archivos requeridos
archivos_requeridos <- c(
  "results/descriptive_statistics.csv",
  "results/confidence_interval.csv",
  "results/normality_test.csv",
  "results/correlation_results.csv",
  "results/regression_coefficients.csv",
  "results/regression_summary.csv",
  "results/forecast_2026.csv"
)

# Verificación de la carpeta de resultados
if (!dir.exists("results")) {
  stop(
    "The 'results' folder was not found. Run the analysis scripts before integrating with Power BI."
  )
}

# Verificación de los archivos exportados
archivos_faltantes <- archivos_requeridos[
  !file.exists(archivos_requeridos)
]

# Mensaje final
if (length(archivos_faltantes) == 0) {
  
  cat("Power BI integration is ready.\n")
  
} else {
  
  cat("Missing files:\n")
  cat(paste("-", archivos_faltantes), sep = "\n")
  
}