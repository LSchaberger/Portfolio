/*
==========================================================
Proyecto: Análisis del Desempeño de Ventas de Supermercados Argentinos
Autor: Leandro Daniel Schaberger

Archivo: 06_product_analysis.sql

Objetivo:
Analizar el comportamiento de los distintos grupos de
artículos comercializados por los supermercados
argentinos, identificando su participación, evolución y
contribución al volumen total de ventas.

==========================================================
*/

/*
==========================================================

Índice de Consultas

1. Participación acumulada de los grupos de artículos.

2. Evolución anual de la participación de los grupos de artículos.

3. Ranking de categorías según su participación acumulada.

==========================================================
*/

-- Compatible con MySQL 8.x
USE supermercados_db;


/*
----------------------------------------------------------
Pregunta de Negocio 1

¿Qué participación porcentual tiene cada grupo de
artículos sobre el total de ventas del período analizado?

Objetivo:
Calcular la participación acumulada de cada grupo de
artículos dentro del volumen total de ventas.

Justificación:
Permite identificar cuáles son las categorías con mayor
peso en las ventas del sector supermercadista.

Interpretación:
Los porcentajes representan la participación acumulada de
cada grupo de artículos entre 2017 y 2025.
----------------------------------------------------------
*/

SELECT

ROUND(SUM(bebidas) / SUM(ventas_totales_grupo_articulos) *100,2) AS bebidas,

ROUND(SUM(almacen) / SUM(ventas_totales_grupo_articulos) *100,2) AS almacen,

ROUND(SUM(panaderia) / SUM(ventas_totales_grupo_articulos) *100,2) AS panaderia,

ROUND(SUM(lacteos) / SUM(ventas_totales_grupo_articulos) *100,2) AS lacteos,

ROUND(SUM(carnes) / SUM(ventas_totales_grupo_articulos) *100,2) AS carnes,

ROUND(SUM(verduleria_fruteria) / SUM(ventas_totales_grupo_articulos) *100,2) AS verduleria,

ROUND(SUM(alimentos_preparados_rotiseria) / SUM(ventas_totales_grupo_articulos) *100,2) AS rotiseria,

ROUND(SUM(articulos_limpieza_perfumeria) / SUM(ventas_totales_grupo_articulos) *100,2) AS limpieza,

ROUND(SUM(indumentaria_calzado_textiles_hogar) / SUM(ventas_totales_grupo_articulos) *100,2) AS indumentaria,

ROUND(SUM(electronicos_articulos_hogar) / SUM(ventas_totales_grupo_articulos) *100,2) AS electronicos,

ROUND(SUM(otros) / SUM(ventas_totales_grupo_articulos) *100,2) AS otros

FROM ventas_supermercados

WHERE YEAR(indice_tiempo) < 2026;



/*
----------------------------------------------------------
Pregunta de Negocio 2

¿Cómo evolucionó la participación porcentual de cada
grupo de artículos durante el período analizado?

Objetivo:
Calcular la participación anual de cada grupo de
artículos sobre el total de ventas.

Justificación:
Permite analizar cómo fue cambiando la importancia
relativa de cada categoría a lo largo del tiempo.

Interpretación:
Cada registro representa la participación porcentual
anual de cada grupo de artículos.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio,

    ROUND(SUM(bebidas) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS bebidas,
    ROUND(SUM(almacen) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS almacen,
    ROUND(SUM(panaderia) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS panaderia,
    ROUND(SUM(lacteos) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS lacteos,
    ROUND(SUM(carnes) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS carnes,
    ROUND(SUM(verduleria_fruteria) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS verduleria,
    ROUND(SUM(alimentos_preparados_rotiseria) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS rotiseria,
    ROUND(SUM(articulos_limpieza_perfumeria) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS limpieza,
    ROUND(SUM(indumentaria_calzado_textiles_hogar) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS indumentaria,
    ROUND(SUM(electronicos_articulos_hogar) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS electronicos,
    ROUND(SUM(otros) / SUM(ventas_totales_grupo_articulos) * 100, 2) AS otros

FROM ventas_supermercados

WHERE YEAR(indice_tiempo) < 2026

GROUP BY YEAR(indice_tiempo)

ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 3

¿Cuál fue el ranking de categorías según su participación
acumulada durante el período analizado?

Objetivo:
Ordenar los grupos de artículos según su participación
porcentual sobre el total de ventas.

Justificación:
Permite identificar las categorías con mayor y menor
contribución al volumen total de ventas del sector
supermercadista.

Interpretación:
Cada registro representa el porcentaje acumulado de
participación de un grupo de artículos entre 2017 y 2025,
ordenado de mayor a menor.
----------------------------------------------------------
*/

WITH datos AS
(
    SELECT *
    FROM ventas_supermercados
    WHERE YEAR(indice_tiempo) < 2026
),

total_ventas AS
(
    SELECT
        SUM(ventas_totales_grupo_articulos) AS total
    FROM datos
)

SELECT *
FROM
(
    SELECT
        'Bebidas' AS categoria,
        ROUND(SUM(bebidas) / (SELECT total FROM total_ventas) * 100, 2) AS participacion
    FROM datos

    UNION ALL

    SELECT
        'Almacén',
        ROUND(SUM(almacen) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Panadería',
        ROUND(SUM(panaderia) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Lácteos',
        ROUND(SUM(lacteos) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Carnes',
        ROUND(SUM(carnes) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Verdulería y Frutería',
        ROUND(SUM(verduleria_fruteria) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Alimentos Preparados y Rotisería',
        ROUND(SUM(alimentos_preparados_rotiseria) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Artículos de Limpieza y Perfumería',
        ROUND(SUM(articulos_limpieza_perfumeria) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Indumentaria, Calzado y Textiles para el Hogar',
        ROUND(SUM(indumentaria_calzado_textiles_hogar) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Electrónicos y Artículos para el Hogar',
        ROUND(SUM(electronicos_articulos_hogar) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

    UNION ALL

    SELECT
        'Otros',
        ROUND(SUM(otros) / (SELECT total FROM total_ventas) * 100, 2)
    FROM datos

) AS ranking

ORDER BY participacion DESC;
