############################################################
# Proyecto: Análisis de Ventas de Supermercados Argentinos
# Archivo: 04_exploratory_analysis.R
#
# Objetivo:
# Explorar visualmente el comportamiento de las ventas
# mediante gráficos que permitan identificar tendencias,
# distribuciones, relaciones y posibles patrones.
############################################################

############################################################
# Índice
#
# 1. Carga de librerías.
# 2. Conexión a la base de datos.
# 3. Importación de los datos.
# 4. Evolución temporal de las ventas.
# 5. Evolución de las ventas a precios constantes.
# 6. Comparación entre ventas a precios corrientes y constantes.
# 7. Distribución de las ventas a precios corrientes.
# 8. Boxplot de las ventas a precios corrientes.
# 9. Evolución de las ventas por canal.
# 10. Evolución de las ventas por medio de pago.
# 11. Comparación de los medios de pago.
# 12. Comparación de los grupos de artículos.
# 13. Participación de las ventas por grupo de artículos.
# 14. Estacionalidad mensual.
# 15. Variación interanual de las ventas.
# 16. Mapa de calor de las ventas mensuales.
# 17. Relación entre las ventas online y los pagos con
#     tarjeta de crédito.
# 18. Media móvil de 12 meses.
# 19. Evolución de la participación de los canales de venta.
# 20. Detección de anomalías.
# 21. Estadísticas descriptivas.
############################################################

# Carga de librerías
library(DBI)
library(RMariaDB)
library(dplyr)
library(ggplot2)
library(scales)
library(corrplot)
library(tidyr)
library(grid)
library(zoo)
library(patchwork)
library(ggrepel)

# Conexión a la base de datos
con <- dbConnect(
  RMariaDB::MariaDB(),
  host = Sys.getenv("MYSQL_HOST"),
  port = as.integer(Sys.getenv("MYSQL_PORT")),
  dbname = Sys.getenv("MYSQL_DATABASE"),
  user = Sys.getenv("MYSQL_USER"),
  password = Sys.getenv("MYSQL_PASSWORD")
)

# Importación de los datos
ventas_supermercados <- dbReadTable(con, "ventas_supermercados")


# Variable de trabajo
# Excluir el año 2026 por tratarse de un período incompleto
ventas_supermercados <- ventas_supermercados |>
  filter(indice_tiempo < as.Date("2026-01-01"))


############################################################
# 4. Evolución temporal de las ventas
#
# Objetivo:
# Visualizar la evolución mensual de las ventas a precios
# corrientes durante el período analizado.
############################################################

ggplot(
  ventas_supermercados,
  aes(
    x = indice_tiempo,
    y = ventas_precios_corrientes
  )
) +
  geom_line(
    color = "steelblue",
    linewidth = 1.2
  ) +
  labs(
    title = "Monthly Sales at Current Prices",
    x = "Year",
    y = "Sales (Million ARS)"
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  theme_minimal()


############################################################
# 5. Evolución de las ventas a precios constantes
#
# Objetivo:
# Visualizar la evolución mensual de las ventas a precios
# constantes durante el período analizado.
############################################################

ggplot(
  ventas_supermercados,
  aes(
    x = indice_tiempo,
    y = ventas_precios_constantes
  )
) +
  geom_line(
    color = "darkgreen",
    linewidth = 1.2
  ) +
  labs(
    title = "Monthly Sales at Constant Prices",
    x = "Year",
    y = "Sales Index"
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  theme_minimal()



############################################################
# 6. Comparación entre ventas a precios corrientes y constantes
#
# Objetivo:
# Comparar ambas series utilizando paneles separados para
# facilitar la interpretación.
############################################################

ventas_long <- ventas_supermercados |>
  select(
    indice_tiempo,
    ventas_precios_corrientes,
    ventas_precios_constantes
  ) |>
  pivot_longer(
    cols = c(
      ventas_precios_corrientes,
      ventas_precios_constantes
    ),
    names_to = "Serie",
    values_to = "Valor"
  ) |>
  mutate(
    Serie = recode(
      Serie,
      ventas_precios_corrientes = "Current Prices",
      ventas_precios_constantes = "Constant Prices"
    )
  )


ggplot(
  ventas_long,
  aes(
    x = indice_tiempo,
    y = Valor,
    color = Serie
  )
) +
  geom_line(
    linewidth = 1.1
  ) +
  facet_wrap(
    ~ Serie,
    ncol = 1,
    scales = "free_y"
  ) +
  scale_color_manual(
    values = c(
      "Current Prices" = "steelblue",
      "Constant Prices" = "darkgreen"
    )
  ) +
  labs(
    title = "Comparison of Monthly Sales at Current and Constant Prices",
    x = "Year",
    y = NULL
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold"
    ),
    strip.text = element_text(
      size = 12,
      face = "bold"
    ),
    axis.title.x = element_text(
      size = 12
    ),
    axis.text = element_text(
      size = 10
    ),
    panel.spacing = unit(1.5, "lines")
  )


############################################################
# 7. Distribución de las ventas a precios corrientes
#
# Objetivo:
# Analizar la distribución de las ventas mensuales a
# precios corrientes.
############################################################

ggplot(
  ventas_supermercados,
  aes(x = ventas_precios_corrientes)
) +
  geom_histogram(
    bins = 30,
    fill = "steelblue",
    color = "white"
  ) +
  labs(
    title = "Distribution of Monthly Sales at Current Prices",
    x = "Sales (Million ARS)",
    y = "Frequency"
  ) +
  scale_x_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold"
    ),
    axis.title = element_text(
      size = 12
    ),
    axis.text = element_text(
      size = 10
    )
  )


############################################################
# 8. Boxplot de las ventas a precios corrientes
#
# Objetivo:
# Visualizar la dispersión de las ventas mensuales e
# identificar posibles valores atípicos.
############################################################

ggplot(
  ventas_supermercados,
  aes(
    y = ventas_precios_corrientes
  )
) +
  geom_boxplot(
    fill = "steelblue",
    color = "black",
    outlier.color = "red",
    outlier.size = 3
  ) +
  labs(
    title = "Boxplot of Monthly Sales at Current Prices",
    x = NULL,
    y = "Sales (Million ARS)"
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold"
    ),
    axis.title = element_text(
      size = 12
    ),
    axis.text = element_text(
      size = 10
    ),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )


############################################################
# 9. Evolución de las ventas por canal
#
# Objetivo:
# Comparar la evolución mensual de las ventas realizadas
# en el salón y a través de canales online.
############################################################

# Preparar los datos en formato largo
ventas_canales <- ventas_supermercados |>
  select(
    indice_tiempo,
    salon_ventas,
    canales_on_line
  ) |>
  pivot_longer(
    cols = c(
      salon_ventas,
      canales_on_line
    ),
    names_to = "Canal",
    values_to = "Ventas"
  ) |>
  mutate(
    Canal = recode(
      Canal,
      salon_ventas = "In-Store Sales",
      canales_on_line = "Online Sales"
    )
  )

# Gráfico
ggplot(
  ventas_canales,
  aes(
    x = indice_tiempo,
    y = Ventas,
    color = Canal
  )
) +
  geom_line(linewidth = 1) +
  facet_wrap(
    ~ Canal,
    ncol = 1,
    scales = "free_y"
  ) +
  labs(
    title = "Monthly Sales by Sales Channel",
    x = "Year",
    y = "Sales (Million ARS)"
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold"
    ),
    strip.text = element_text(
      size = 13,
      face = "bold"
    ),
    panel.spacing = unit(
      1.5,
      "lines"
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.position = "none"
  )


############################################################
# 10. Evolución de las ventas por medio de pago
#
# Objetivo:
# Comparar la evolución mensual de las ventas según
# el medio de pago utilizado por los consumidores.
############################################################

ventas_medios_pago <- ventas_supermercados |>
  select(
    indice_tiempo,
    efectivo,
    tarjetas_debito,
    tarjetas_credito,
    otros_medios
  ) |>
  pivot_longer(
    cols = c(
      efectivo,
      tarjetas_debito,
      tarjetas_credito,
      otros_medios
    ),
    names_to = "MedioPago",
    values_to = "Ventas"
  ) |>
  mutate(
    MedioPago = recode(
      MedioPago,
      efectivo = "Cash",
      tarjetas_debito = "Debit Card",
      tarjetas_credito = "Credit Card",
      otros_medios = "Other Payment Methods"
    )
  )


ggplot(
  ventas_medios_pago,
  aes(
    x = indice_tiempo,
    y = Ventas,
    color = MedioPago
  )
) +
  geom_line(linewidth = 1) +
  facet_wrap(
    ~ MedioPago,
    ncol = 2,
    scales = "free_y"
  ) +
  labs(
    title = "Monthly Sales by Payment Method",
    x = "Year",
    y = "Sales (Million ARS)"
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(
        b = 15
      )
    ),
    strip.text = element_text(
      hjust = 0.5,
      size = 13,
      face = "bold"
    ),
    panel.spacing = unit(
      2,
      "lines"
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.position = "none"
  )


############################################################
# 11. Comparación de los medios de pago
#
# Objetivo:
# Comparar la evolución mensual de las ventas de todos los
# medios de pago en un mismo gráfico.
############################################################

ggplot(
  ventas_medios_pago,
  aes(
    x = indice_tiempo,
    y = Ventas,
    color = MedioPago
  )
) +
  geom_line(linewidth = 1) +
  labs(
    title = "Comparison of Payment Methods",
    x = "Year",
    y = "Sales (Million ARS)",
    color = "Payment Method"
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(
        b = 15
      )
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10)
  )


############################################################
# 12. Comparación de los grupos de artículos
#
# Objetivo:
# Comparar la evolución mensual de las ventas de todos los
# grupos de artículos en un mismo gráfico.
############################################################

ventas_articulos <- ventas_supermercados |>
  select(
    indice_tiempo,
    bebidas,
    almacen,
    panaderia,
    lacteos,
    carnes,
    verduleria_fruteria,
    alimentos_preparados_rotiseria,
    articulos_limpieza_perfumeria,
    indumentaria_calzado_textiles_hogar,
    electronicos_articulos_hogar,
    otros
  ) |>
  pivot_longer(
    cols = -indice_tiempo,
    names_to = "Categoria",
    values_to = "Ventas"
  ) |>
  mutate(
    Categoria = recode(
      Categoria,
      bebidas = "Beverages",
      almacen = "Grocery",
      panaderia = "Bakery",
      lacteos = "Dairy",
      carnes = "Meat",
      verduleria_fruteria = "Fruit & Vegetables",
      alimentos_preparados_rotiseria = "Prepared Foods",
      articulos_limpieza_perfumeria = "Cleaning & Personal Care",
      indumentaria_calzado_textiles_hogar = "Clothing & Home Textiles",
      electronicos_articulos_hogar = "Electronics & Home Appliances",
      otros = "Other"
    )
  )

# Ordenar las categorías de mayor a menor según las ventas totales
orden_categorias <- ventas_articulos |>
  group_by(Categoria) |>
  summarise(
    Total = sum(Ventas),
    .groups = "drop"
  ) |>
  arrange(desc(Total)) |>
  pull(Categoria)

ventas_articulos <- ventas_articulos |>
  mutate(
    Categoria = factor(
      Categoria,
      levels = orden_categorias
    )
  )




ggplot(
    ventas_articulos,
    aes(
        x = indice_tiempo,
        y = Ventas,
        color = Categoria
    )
) +
    geom_line(linewidth = 1) +
    labs(
        title = "Comparison of Product Categories",
        x = "Year",
        y = "Sales (Million ARS)",
        color = "Product Category"
    ) +
    scale_x_date(
        date_breaks = "1 year",
        date_labels = "%Y"
    ) +
    scale_y_continuous(
        labels = label_number(
            scale = 1e-6,
            suffix = " M"
        )
    ) +
  scale_color_manual(
    values = c(
      "Beverages" = "#1f77b4",
      "Grocery" = "#ff7f0e",
      "Bakery" = "#2ca02c",
      "Dairy" = "#d62728",
      "Meat" = "#9467bd",
      "Fruit & Vegetables" = "#8c564b",
      "Prepared Foods" = "#e377c2",
      "Cleaning & Personal Care" = "#7f7f7f",
      "Clothing & Home Textiles" = "#bcbd22",
      "Electronics & Home Appliances" = "#17becf",
      "Other" = "#000000"
    )
  )+
    theme_minimal() +
      theme(
        plot.title = element_text(
          hjust = 0.5,
          size = 16,
          face = "bold",
          margin = margin(b = 15)
        ),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10),
        legend.title = element_text(size = 11),
        legend.text = element_text(size = 9),
        
        # Fondo del gráfico
        plot.background = element_rect(
          fill = "white",
          color = NA
        ),
        
        # Fondo del panel
        panel.background = element_rect(
          fill = "white",
          color = NA
        ),
        
        # Fondo de la leyenda
        legend.background = element_rect(
          fill = "white",
          color = NA
        ),
        
        # Fondo detrás de los elementos de la leyenda
        legend.key = element_rect(
          fill = "white",
          color = NA
        )
        )


############################################################
# 13. Participación de las ventas por grupo de artículos
#
# Objetivo:
# Analizar la participación de cada grupo de artículos
# sobre las ventas totales del período 2017–2025.
############################################################

participacion_articulos <- ventas_articulos |>
  group_by(Categoria) |>
  summarise(
    Ventas = sum(Ventas),
    .groups = "drop"
  ) |>
  mutate(
    Porcentaje = Ventas / sum(Ventas)
  ) |>
  arrange(desc(Ventas))


ggplot(
  participacion_articulos,
  aes(
    x = reorder(Categoria, Ventas),
    y = Ventas,
    fill = Categoria
  )
) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(
    title = "Total Sales by Product Category (2017–2025)",
    x = "Product Category",
    y = "Sales (Million ARS)"
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 15)
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )


############################################################
# 14. Estacionalidad mensual
#
# Objetivo:
# Analizar el comportamiento promedio de las ventas en cada
# mes del año para identificar patrones estacionales.
############################################################

ventas_estacionalidad <- ventas_supermercados |>
  mutate(
    Mes = factor(
      format(indice_tiempo, "%B"),
      levels = month.name
    )
  ) |>
  group_by(Mes) |>
  summarise(
    Ventas = median(ventas_precios_corrientes),
    .groups = "drop"
  )


ggplot(
  ventas_estacionalidad,
  aes(
    x = Mes,
    y = Ventas
  )
) +
  geom_col(
    fill = "#1f77b4"
  ) +
  labs(
    title = "Median Monthly Sales (2017–2025)",
    x = "Month",
    y = "Median Sales (Million ARS)"
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 15)
    ),
    axis.title = element_text(size = 12),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    ),
    axis.text = element_text(size = 10)
  )


############################################################
# 15. Variación interanual de las ventas
#
# Objetivo:
# Analizar el crecimiento o disminución porcentual de las
# ventas totales respecto al año anterior.
############################################################

ventas_interanual <- ventas_supermercados |>
  mutate(
    Anio = as.numeric(format(indice_tiempo, "%Y"))
  ) |>
  group_by(Anio) |>
  summarise(
    Ventas = sum(ventas_precios_corrientes),
    .groups = "drop"
  ) |>
  mutate(
    Variacion = (Ventas / lag(Ventas) - 1) * 100
  ) |>
  filter(!is.na(Variacion))


ggplot(
  ventas_interanual,
  aes(
    x = factor(Anio),
    y = Variacion
  )
) +
  geom_col(
    fill = "#1f77b4"
  ) +
  geom_text(
    aes(
      label = paste0(round(Variacion, 1), "%")
    ),
    vjust = -0.5,
    size = 4,
    fontface = "bold"
  ) +
  labs(
    title = "Year-over-Year Sales Growth",
    x = "Year",
    y = "Growth (%)"
  ) +
  scale_y_continuous(
    labels = label_number(
      suffix = "%"
    ),
    expand = expansion(
      mult = c(0, 0.08)
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 15)
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )


############################################################
# 16. Mapa de calor de las ventas mensuales
#
# Objetivo:
# Visualizar la evolución de las ventas por año y mes para
# identificar patrones estacionales y tendencias.
############################################################

ventas_heatmap <- ventas_supermercados |>
  mutate(
    Anio = factor(format(indice_tiempo, "%Y")),
    Mes = factor(
      format(indice_tiempo, "%B"),
      levels = month.name
    )
  ) |>
  group_by(Anio) |>
  mutate(
    Ventas_Normalizadas = (
      ventas_precios_corrientes - min(ventas_precios_corrientes)
    ) / (
      max(ventas_precios_corrientes) - min(ventas_precios_corrientes)
    )
  ) |>
  ungroup()


ggplot(
  ventas_heatmap,
  aes(
    x = Mes,
    y = Anio,
    fill = Ventas_Normalizadas
  )
) +
  geom_tile(
    color = "white",
    linewidth = 0.5
  ) +
  labs(
    title = "Monthly Sales Seasonality (2017–2025)",
    x = "Month",
    y = "Year",
    fill = "Normalized\nSales"
  ) +
  scale_fill_viridis_c(
    limits = c(0, 1)
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 15)
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    )
  )


############################################################
# 17. Relación entre las ventas online y los pagos con
# tarjeta de crédito
#
# Objetivo:
# Analizar la relación entre las ventas realizadas por
# canales online y los pagos efectuados con tarjetas de
# crédito.
############################################################

correlacion <- cor(
  ventas_supermercados$tarjetas_credito,
  ventas_supermercados$canales_on_line
)



ggplot(
  ventas_supermercados,
  aes(
    x = tarjetas_credito,
    y = canales_on_line
  )
) +
  geom_point(
    color = "#1f77b4",
    size = 2.5,
    alpha = 0.7
  ) +
  geom_smooth(
    method = "lm",
    se = TRUE,
    color = "#d62728",
    linewidth = 1
  ) +
  annotate(
    "text",
    x = 2.2e8,
    y = 8.7e7,
    label = paste0(
      "r = ",
      round(correlacion, 2)
    ),
    fontface = "bold",
    size = 5
  ) +
  labs(
    title = "Online Sales vs Credit Card Payments",
    x = "Credit Card Payments (Million ARS)",
    y = "Online Sales (Million ARS)"
  ) +
  scale_x_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    ),
    expand = expansion(
      mult = c(0.02, 0.05)
    )
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    ),
    expand = expansion(
      mult = c(0.02, 0.08)
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 15)
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )



############################################################
# 18. Media móvil de 12 meses
#
# Objetivo:
# Suavizar las fluctuaciones mensuales de las ventas para
# visualizar la tendencia de largo plazo.
############################################################

ventas_media_movil <- ventas_supermercados |>
  mutate(
    Media_Movil = rollmean(
      ventas_precios_constantes,
      k = 12,
      fill = NA,
      align = "right"
    )
  )

ggplot(
  ventas_media_movil,
  aes(x = indice_tiempo)
) +
  geom_line(
    aes(
      y = ventas_precios_constantes,
      color = "Monthly Sales"
    ),
    linewidth = 0.8
  ) +
  geom_line(
    aes(
      y = Media_Movil,
      color = "12-Month Moving Average"
    ),
    linewidth = 1.3
  ) +
  scale_color_manual(
    values = c(
      "Monthly Sales" = "gray70",
      "12-Month Moving Average" = "#1f77b4"
    ),
    name = ""
  ) +
  labs(
    title = "12-Month Moving Average of Constant Sales",
    x = "Year",
    y = "Sales (Million ARS)"
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 15)
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.position = "top",
    legend.text = element_text(size = 10)
  )



############################################################
# 19. Evolución de la participación de los canales de venta
#
# Objetivo:
# Analizar cómo evolucionó la participación relativa de las
# ventas en salón y de las ventas online a lo largo del
# tiempo.
############################################################

participacion_canales <- ventas_supermercados |>
  mutate(
    In_Store = salon_ventas / ventas_totales_canal_venta,
    Online = canales_on_line / ventas_totales_canal_venta
  )


grafico_instore <- ggplot(
  participacion_canales,
  aes(
    x = indice_tiempo,
    y = In_Store
  )
) +
  geom_line(
    color = "#1f77b4",
    linewidth = 1.2
  ) +
  labs(
    title = "In-store Sales Share",
    x = NULL,
    y = "Share"
  ) +
  scale_y_continuous(
    labels = label_percent(
      accuracy = 1
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 14
    ),
    axis.title = element_text(size = 11),
    axis.text = element_text(size = 10)
  )


grafico_online <- ggplot(
  participacion_canales,
  aes(
    x = indice_tiempo,
    y = Online
  )
) +
  geom_line(
    color = "#d62728",
    linewidth = 1.2
  ) +
  labs(
    title = "Online Sales Share",
    x = "Year",
    y = "Share"
  ) +
  scale_y_continuous(
    labels = label_percent(
      accuracy = 1
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      face = "bold",
      size = 14
    ),
    axis.title = element_text(size = 11),
    axis.text = element_text(size = 10)
  )


grafico_instore /
  grafico_online +
  plot_annotation(
    title = "Sales Channel Share Over Time",
    theme = theme(
      plot.title = element_text(
        hjust = 0.5,
        size = 16,
        face = "bold"
      )
    )
  )


############################################################
# 20. Detección de anomalías
#
# Objetivo:
# Identificar meses con ventas excepcionalmente altas o
# bajas respecto de la tendencia de largo plazo utilizando
# la serie desestacionalizada y una media móvil de 12 meses.
############################################################

ventas_anomalias <- ventas_supermercados |>
  mutate(
    Media_Movil = rollmean(
      ventas_precios_constantes_desestacionalizada,
      k = 12,
      fill = NA,
      align = "right"
    ),
    Residuo = ventas_precios_constantes_desestacionalizada - Media_Movil
  )

desvio <- sd(
  ventas_anomalias$Residuo,
  na.rm = TRUE
)

ventas_anomalias <- ventas_anomalias |>
  mutate(
    Anomalia = abs(Residuo) > 2 * desvio
  )

ggplot(
  ventas_anomalias,
  aes(
    x = indice_tiempo,
    y = ventas_precios_constantes_desestacionalizada
  )
) +
  geom_line(
    aes(
      color = "Monthly Sales"
    ),
    linewidth = 0.8,
    alpha = 0.6
  ) +
  geom_line(
    aes(
      y = Media_Movil,
      color = "12-Month Moving Average"
    ),
    linewidth = 1.3
  ) +
  geom_point(
    data = filter(
      ventas_anomalias,
      Anomalia
    ),
    aes(
      color = "Detected Anomaly"
    ),
    size = 3
  ) +
  geom_text_repel(
    data = filter(
      ventas_anomalias,
      Anomalia
    ),
    aes(
      label = format(
        indice_tiempo,
        "%Y-%m"
      )
    ),
    color = "#d62728",
    fontface = "bold",
    size = 3.5,
    box.padding = 0.4,
    point.padding = 0.3,
    segment.color = "gray50",
    max.overlaps = Inf
  ) +
  labs(
    title = "Deseasonalized Sales Anomaly Detection",
    x = "Year",
    y = "Sales (Million ARS)"
  ) +
  scale_color_manual(
    values = c(
      "Monthly Sales" = "gray70",
      "12-Month Moving Average" = "#1f77b4",
      "Detected Anomaly" = "#d62728"
    ),
    breaks = c(
      "Monthly Sales",
      "12-Month Moving Average",
      "Detected Anomaly"
    ),
    name = ""
  ) +
  scale_y_continuous(
    labels = label_number(
      scale = 1e-6,
      suffix = " M"
    ),
    expand = expansion(
      mult = c(0.02, 0.12)
    )
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(
      hjust = 0.5,
      size = 16,
      face = "bold",
      margin = margin(b = 15)
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.position = "top",
    legend.text = element_text(size = 10)
  )


############################################################
# 21. Descriptive Statistics
#
# Objetivo:
# Resumir las principales medidas descriptivas de las ventas
# a precios constantes para comprender su distribución y
# variabilidad.
############################################################

estadisticas <- tibble(
  Statistic = c(
    "Mean",
    "Median",
    "Standard Deviation",
    "Minimum",
    "1st Quartile (Q1)",
    "3rd Quartile (Q3)",
    "Maximum",
    "Interquartile Range (IQR)",
    "Coefficient of Variation"
  ),
  Value = c(
    mean(
      ventas_supermercados$ventas_precios_constantes
    ),
    median(
      ventas_supermercados$ventas_precios_constantes
    ),
    sd(
      ventas_supermercados$ventas_precios_constantes
    ),
    min(
      ventas_supermercados$ventas_precios_constantes
    ),
    quantile(
      ventas_supermercados$ventas_precios_constantes,
      probs = 0.25
    ),
    quantile(
      ventas_supermercados$ventas_precios_constantes,
      probs = 0.75
    ),
    max(
      ventas_supermercados$ventas_precios_constantes
    ),
    IQR(
      ventas_supermercados$ventas_precios_constantes
    ),
    sd(
      ventas_supermercados$ventas_precios_constantes
    ) /
      mean(
        ventas_supermercados$ventas_precios_constantes
      ) * 100
  ),
  Unit = c(
    "ARS",
    "ARS",
    "ARS",
    "ARS",
    "ARS",
    "ARS",
    "ARS",
    "ARS",
    "%"
  )
)

print(estadisticas)

