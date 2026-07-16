/*
==========================================================
Proyecto: Análisis del Desempeño de Ventas de Supermercados Argentinos
Autor: Leandro Daniel Schaberger

Archivo: 05_payment_analysis.sql

Objetivo:
Analizar la evolución de las ventas según los distintos
medios de pago utilizados por los consumidores,
identificando su participación y comportamiento durante
el período analizado.

==========================================================
*/

/*
==========================================================

Índice de Consultas

1. Evolución de las ventas en efectivo.

2. Evolución de las ventas con tarjeta de débito.

3. Evolución de las ventas con tarjeta de crédito.

4. Evolución de las ventas mediante otros medios de pago.

5. Participación acumulada de los medios de pago.

6. Evolución anual de la participación de los medios de pago.

==========================================================
*/

-- Compatible con MySQL 8.x
USE supermercados_db;


/*
----------------------------------------------------------
Pregunta de Negocio 1

¿Cómo evolucionaron las ventas realizadas en efectivo
durante el período analizado?

Objetivo:
Analizar la evolución anual de las ventas abonadas en
efectivo.

Justificación:
Permite conocer el comportamiento de uno de los medios
de pago más utilizados por los consumidores.

Interpretación:
Cada registro representa el total anual de ventas
realizadas en efectivo.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(efectivo) AS ventas_efectivo FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 2

¿Cómo evolucionaron las ventas realizadas mediante
tarjeta de débito durante el período analizado?

Objetivo:
Analizar la evolución anual de las ventas abonadas con
tarjeta de débito.

Justificación:
Permite evaluar la utilización de este medio de pago a
lo largo del tiempo.

Interpretación:
Cada registro representa el total anual de ventas
realizadas con tarjeta de débito.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(tarjetas_debito) AS ventas_debito FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 3

¿Cómo evolucionaron las ventas realizadas mediante
tarjeta de crédito durante el período analizado?

Objetivo:
Analizar la evolución anual de las ventas abonadas con
tarjeta de crédito.

Justificación:
Permite evaluar el comportamiento del crédito como medio
de pago en el sector supermercadista.

Interpretación:
Cada registro representa el total anual de ventas
realizadas con tarjeta de crédito.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(tarjetas_credito) AS ventas_credito FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 4

¿Cómo evolucionaron las ventas realizadas mediante otros
medios de pago durante el período analizado?

Objetivo:
Analizar la evolución anual de las ventas registradas en
otros medios de pago.

Justificación:
Permite conocer la participación de medios alternativos
dentro del total de ventas.

Interpretación:
Cada registro representa el total anual de ventas
realizadas mediante otros medios de pago.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(otros_medios) AS ventas_otros FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 5

¿Cómo evolucionó la participación porcentual de cada
medio de pago durante el período analizado?

Objetivo:
Calcular la participación anual de cada medio de pago
sobre el total de ventas registradas.

Justificación:
Permite identificar cambios en las preferencias de pago
de los consumidores y analizar la evolución relativa de
cada medio de pago a lo largo del tiempo.

Interpretación:
Cada registro representa el porcentaje anual de
participación de cada medio de pago sobre el total de
ventas del correspondiente año.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio,

    ROUND(
        SUM(efectivo) /
        SUM(ventas_totales_medio_pago) * 100,
        2
    ) AS porcentaje_efectivo,

    ROUND(
        SUM(tarjetas_debito) /
        SUM(ventas_totales_medio_pago) * 100,
        2
    ) AS porcentaje_debito,

    ROUND(
        SUM(tarjetas_credito) /
        SUM(ventas_totales_medio_pago) * 100,
        2
    ) AS porcentaje_credito,

    ROUND(
        SUM(otros_medios) /
        SUM(ventas_totales_medio_pago) * 100,
        2
    ) AS porcentaje_otros

FROM ventas_supermercados

WHERE YEAR(indice_tiempo) < 2026

GROUP BY YEAR(indice_tiempo)

ORDER BY YEAR(indice_tiempo);



/*
----------------------------------------------------------
Pregunta de Negocio 6

¿Qué participación porcentual tiene cada medio de pago
sobre el total de ventas del período analizado?

Objetivo:
Calcular la participación de cada medio de pago dentro
del volumen total de ventas.

Justificación:
Permite identificar cuáles son los medios de pago más
utilizados por los consumidores.

Interpretación:
Los porcentajes representan la participación acumulada de
cada medio de pago entre 2017 y 2025.
----------------------------------------------------------
*/

SELECT
    ROUND(SUM(efectivo) / SUM(ventas_totales_medio_pago) * 100, 2) AS porcentaje_efectivo,
    ROUND(SUM(tarjetas_debito) / SUM(ventas_totales_medio_pago) * 100, 2) AS porcentaje_debito,
    ROUND(SUM(tarjetas_credito) / SUM(ventas_totales_medio_pago) * 100, 2) AS porcentaje_credito,
    ROUND(SUM(otros_medios) / SUM(ventas_totales_medio_pago) * 100, 2) AS porcentaje_otros
FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026;
