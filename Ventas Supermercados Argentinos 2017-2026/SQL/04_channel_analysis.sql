/*
==========================================================
Proyecto: Análisis del Desempeño de Ventas de Supermercados Argentinos
Autor: Leandro Daniel Schaberger

Archivo: 04_channel_analysis.sql

Objetivo:
Analizar la evolución de las ventas según el canal de
comercialización, comparando las ventas realizadas en el
salón de ventas con las efectuadas mediante canales
online.

==========================================================
*/

/*
==========================================================

Índice de Consultas

1. Evolución de las ventas realizadas en el salón de ventas.

2. Evolución de las ventas realizadas mediante canales online.

3. Participación acumulada del salón de ventas y los canales online.

4. Evolución anual de la participación del canal online.

5. Evolución anual de la participación del salón de ventas.

6. Variación interanual de la participación del canal online.

==========================================================
*/

-- Compatible con MySQL 8.x
USE supermercados_db;


/*
----------------------------------------------------------
Pregunta de Negocio 1

¿Cómo evolucionaron las ventas realizadas en el salón de
ventas durante el período analizado?

Objetivo:
Analizar la evolución anual de las ventas efectuadas en
el canal tradicional.

Justificación:
Permite conocer el comportamiento del principal canal de
comercialización de los supermercados argentinos.

Interpretación:
Cada registro representa el total anual de ventas
realizadas en el salón de ventas.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(salon_ventas) AS ventas_salon FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 2

¿Cómo evolucionaron las ventas realizadas mediante
canales online durante el período analizado?

Objetivo:
Analizar la evolución anual de las ventas efectuadas por
comercio electrónico.

Justificación:
Permite evaluar el crecimiento del canal online dentro
del sector supermercadista.

Interpretación:
Cada registro representa el total anual de ventas
realizadas mediante canales online.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(canales_on_line) AS ventas_online FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 3

¿Qué participación tienen el salón de ventas y los
canales online sobre el total de ventas?

Objetivo:
Calcular la participación porcentual de cada canal de
venta durante el período analizado.

Justificación:
Permite conocer la importancia relativa de cada canal
dentro del volumen total de ventas.

Interpretación:
Los porcentajes indican la contribución de cada canal al
total de ventas registradas entre 2017 y 2025.
----------------------------------------------------------
*/

SELECT ROUND(SUM(salon_ventas) / SUM(ventas_totales_canal_venta) * 100, 2) AS porcentaje_salon,
		ROUND(SUM(canales_on_line) / SUM(ventas_totales_canal_venta) * 100, 2) AS porcentaje_online
FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026;



/*
----------------------------------------------------------
Pregunta de Negocio 4

¿Cómo evolucionó la participación del canal online a lo
largo del período analizado?

Objetivo:
Calcular la participación porcentual anual del canal
online sobre el total de ventas.

Justificación:
Permite analizar si el comercio electrónico fue ganando
relevancia dentro del sector supermercadista.

Interpretación:
Cada registro representa el porcentaje de participación
del canal online sobre el total anual de ventas.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, ROUND(SUM(canales_on_line) /
			SUM(ventas_totales_canal_venta) * 100, 2) AS participacion_online FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 5

¿Cómo evolucionó la participación del salón de ventas a
lo largo del período analizado?

Objetivo:
Calcular la participación porcentual anual del salón de
ventas sobre el total de ventas.

Justificación:
Permite evaluar la importancia del canal tradicional a lo
largo del tiempo.

Interpretación:
Cada registro representa el porcentaje de participación
del salón de ventas sobre el total anual de ventas.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, ROUND(SUM(salon_ventas) /
        SUM(ventas_totales_canal_venta) * 100, 2) AS participacion_salon FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 6

¿Cómo evolucionó la participación del canal online
respecto al año anterior?

Objetivo:
Calcular la variación anual de la participación del canal
online sobre el total de ventas.

Justificación:
Permite evaluar si el comercio electrónico fue ganando o
perdiendo relevancia dentro del sector supermercadista a
lo largo del período analizado.

Interpretación:
Un porcentaje positivo indica que la participación del
canal online aumentó respecto al año anterior, mientras
que un porcentaje negativo representa una disminución de
su participación.
----------------------------------------------------------
*/

WITH participacion_online AS
(
    SELECT
        YEAR(indice_tiempo) AS anio,
        ROUND(
            SUM(canales_on_line) /
            SUM(ventas_totales_canal_venta) * 100,
            2
        ) AS porcentaje_online
    FROM ventas_supermercados
    WHERE YEAR(indice_tiempo) < 2026
    GROUP BY YEAR(indice_tiempo)
)

SELECT
    anio,
    porcentaje_online,

    ROUND(
        porcentaje_online
        - LAG(porcentaje_online)
            OVER(ORDER BY anio),
        2
    ) AS variacion_puntos_porcentuales

FROM participacion_online

ORDER BY anio;
