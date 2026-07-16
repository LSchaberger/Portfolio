/*
==========================================================
Proyecto: Análisis del Desempeño de Ventas de Supermercados Argentinos
Autor: Leandro Daniel Schaberger

Archivo: 03_sales_analysis.sql

Objetivo:
Analizar la evolución de las ventas del sector
supermercadista argentino durante el período comprendido
entre enero de 2017 y abril de 2026.

==========================================================
*/

USE supermercados_db;


/*
----------------------------------------------------------
Pregunta de Negocio 1

¿Cómo evolucionaron las ventas de supermercados
argentinos durante el período analizado?

Objetivo:
Observar la evolución mensual de las ventas medidas a
precios corrientes.

Justificación:
Permite identificar la tendencia general de las ventas y
servirá como punto de partida para el análisis
exploratorio.

Interpretación:
La consulta mostrará la evolución cronológica de las
ventas a precios corrientes.
----------------------------------------------------------
*/

SELECT indice_tiempo, ventas_precios_corrientes FROM ventas_supermercados ORDER BY indice_tiempo;

/*
----------------------------------------------------------
Pregunta de Negocio 1.1

¿Cómo evolucionaron las ventas a precios corrientes
agrupadas por año?

Objetivo:
Obtener el total anual de ventas para facilitar la
comparación entre distintos años.

Justificación:
El análisis anual permite identificar tendencias de
crecimiento y cambios en el desempeño del sector.

Interpretación:
Cada registro representa el total de ventas acumuladas
durante un año calendario.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(ventas_precios_corrientes) AS ventas_totales
FROM ventas_supermercados
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);


/*
----------------------------------------------------------
Pregunta de Negocio 1.2

¿Cuál fue el crecimiento anual de las ventas a precios
corrientes?

Objetivo:
Calcular la variación porcentual de las ventas respecto
al año anterior.

Justificación:
Permite identificar los años con mayor crecimiento,
estancamiento o disminución de las ventas.

Interpretación:
Un porcentaje positivo indica crecimiento respecto al año
anterior, mientras que un porcentaje negativo representa
una disminución de las ventas.

ADVERTENCIA:
**** El año 2026 no fue considerado para la comparación
anual completa debido a que el conjunto de datos contiene
información únicamente hasta el mes de abril, lo que podría
generar interpretaciones incorrectas sobre la evolución
de las ventas.****
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(ventas_precios_corrientes) AS ventas_totales,
    ROUND(((SUM(ventas_precios_corrientes) - LAG(SUM(ventas_precios_corrientes))
			OVER(ORDER BY YEAR(indice_tiempo))) / LAG(SUM(ventas_precios_corrientes))
			OVER(ORDER BY YEAR(indice_tiempo))) * 100, 2) AS crecimiento_porcentual
            FROM ventas_supermercados WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);


/*
----------------------------------------------------------
Pregunta de Negocio 1.3

¿Cuál fue el crecimiento acumulado de las ventas a
precios corrientes entre 2017 y 2025?

Objetivo:
Calcular el crecimiento porcentual acumulado de las
ventas entre el primer y el último año completo del
período analizado.

Justificación:
Comparar años completos permite evaluar la evolución
global de las ventas evitando sesgos provocados por años
con información parcial.

Interpretación:
Un porcentaje positivo indica que las ventas nominales
del año 2025 fueron superiores a las registradas en 2017.
----------------------------------------------------------
*/

SELECT
    ROUND(
        (
            (
                (
                    SELECT SUM(ventas_precios_corrientes)
                    FROM ventas_supermercados
                    WHERE YEAR(indice_tiempo) = 2025
                )
                -
                (
                    SELECT SUM(ventas_precios_corrientes)
                    FROM ventas_supermercados
                    WHERE YEAR(indice_tiempo) = 2017
                )
            )
            /
            (
                SELECT SUM(ventas_precios_corrientes)
                FROM ventas_supermercados
                WHERE YEAR(indice_tiempo) = 2017
            )
        ) * 100,
        2
    ) AS crecimiento_acumulado;



/*
----------------------------------------------------------
Pregunta de Negocio 2

¿Cómo evolucionaron las ventas a precios constantes
durante el período analizado?

Objetivo:
Analizar la evolución de las ventas ajustadas por
inflación para evaluar el crecimiento real del sector.

Justificación:
Las ventas a precios constantes permiten eliminar el
efecto de la inflación y conocer la verdadera evolución
del consumo.

Interpretación:
Cada registro representa el total de ventas reales
correspondiente a un año calendario.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(ventas_precios_constantes) AS ventas_totales
FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);


/*
----------------------------------------------------------
Pregunta de Negocio 2.1

¿Cómo se comparan las ventas a precios corrientes y las
ventas a precios constantes?

Objetivo:
Comparar ambas métricas para identificar el impacto de la
inflación sobre la evolución de las ventas.

Justificación:
La diferencia entre ambas medidas permite distinguir el
crecimiento nominal del crecimiento real.

Interpretación:
Cuanto mayor sea la diferencia entre ambas series, mayor
será el efecto de la inflación sobre las ventas.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio,
    SUM(ventas_precios_corrientes) AS ventas_corrientes,
    SUM(ventas_precios_constantes) AS ventas_constantes
FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);


/*
----------------------------------------------------------
Pregunta de Negocio 2.2

¿Cuál fue el crecimiento anual de las ventas a precios
constantes?

Objetivo:
Calcular la variación porcentual anual de las ventas
ajustadas por inflación.

Justificación:
Permite evaluar si el consumo creció, se mantuvo estable
o disminuyó una vez eliminado el efecto de la inflación.

Interpretación:
Un porcentaje positivo indica un crecimiento real de las
ventas respecto al año anterior, mientras que un
porcentaje negativo representa una disminución del
consumo.
----------------------------------------------------------
*/

SELECT
    YEAR(indice_tiempo) AS anio, SUM(ventas_precios_constantes) AS ventas_constantes,
    ROUND(((SUM(ventas_precios_constantes) - LAG(SUM(ventas_precios_constantes))
			OVER(ORDER BY YEAR(indice_tiempo))) / LAG(SUM(ventas_precios_constantes))
			OVER(ORDER BY YEAR(indice_tiempo))) * 100, 2) AS crecimiento_real
FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);


/*
----------------------------------------------------------
Pregunta de Negocio 3

¿Cuáles fueron los meses con mayor y menor volumen de
ventas a precios corrientes?

Objetivo:
Identificar los períodos de mayor y menor desempeño
comercial durante el período analizado.

Justificación:
Permite detectar extremos en la serie temporal y conocer
los momentos de mayor y menor actividad del sector.

Interpretación:
La consulta devuelve el mes con mayor volumen de ventas y
el mes con menor volumen de ventas.
----------------------------------------------------------
*/

(SELECT indice_tiempo, ventas_precios_corrientes FROM ventas_supermercados
ORDER BY ventas_precios_corrientes DESC
LIMIT 1)

UNION ALL

(SELECT indice_tiempo, ventas_precios_corrientes
FROM ventas_supermercados
ORDER BY ventas_precios_corrientes
LIMIT 1);



/*
----------------------------------------------------------
Pregunta de Negocio 3.1

¿En qué año se registró el mayor y el menor volumen de
ventas a precios corrientes?

Objetivo:
Identificar los años con mayor y menor volumen de ventas
durante el período analizado.

Justificación:
Permite reconocer los extremos del desempeño anual del
sector supermercadista.

Interpretación:
La consulta devuelve el año con mayor volumen de ventas y
el año con menor volumen de ventas.
----------------------------------------------------------
*/

(SELECT YEAR(indice_tiempo) AS anio, SUM(ventas_precios_corrientes) AS ventas_totales
FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY ventas_totales DESC
LIMIT 1)

UNION ALL

(SELECT YEAR(indice_tiempo) AS anio, SUM(ventas_precios_corrientes) AS ventas_totales
FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY ventas_totales
LIMIT 1);



/*
----------------------------------------------------------
Pregunta de Negocio 3.2

¿Qué porcentaje del total de ventas representa cada año?

Objetivo:
Calcular la participación porcentual de cada año sobre
el total de ventas del período analizado.

Justificación:
Permite evaluar el peso relativo de cada año dentro del
volumen total de ventas.

Interpretación:
El porcentaje indica la contribución de cada año al total
de ventas acumuladas entre 2017 y 2025.
----------------------------------------------------------
*/

SELECT YEAR(indice_tiempo) AS anio, SUM(ventas_precios_corrientes) AS ventas_totales,
    ROUND(SUM(ventas_precios_corrientes) /
        (SELECT SUM(ventas_precios_corrientes) FROM ventas_supermercados
		WHERE YEAR(indice_tiempo) < 2026) * 100, 2) AS participacion_porcentual
FROM ventas_supermercados
WHERE YEAR(indice_tiempo) < 2026
GROUP BY YEAR(indice_tiempo)
ORDER BY YEAR(indice_tiempo);
