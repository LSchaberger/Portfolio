/*
==========================================================
Proyecto: Análisis del Desempeño de Ventas de Supermercados Argentinos
Autor: Leandro Daniel Schaberger

Archivo: 02_data_validation.sql

Objetivo:
Validar la calidad, integridad y consistencia del conjunto
de datos antes de comenzar el análisis exploratorio.

==========================================================
*/

/*
==========================================================

Índice de Consultas

1. Verificación de la cantidad de registros.

2. Verificación de la estructura de la tabla.

3. Verificación de valores nulos.

4. Verificación de registros duplicados.

5. Verificación del rango temporal.

6. Verificación de valores negativos.

7. Verificación de valores iguales a cero.

8. Verificación de consistencia entre ventas por canal.

9. Verificación de consistencia entre medios de pago.

10. Verificación de consistencia entre grupos de artículos.

11. Verificación de estadísticas descriptivas.

12. Verificación de registros fuera del período esperado.

==========================================================
*/

-- Compatible con MySQL 8.x
USE supermercados_db;


/*
----------------------------------------------------------
Consulta 1

Objetivo:
Verificar la cantidad total de registros importados en la
tabla ventas_supermercados.

Justificación:
Confirmar que la totalidad de los registros del archivo
CSV fueron importados correctamente.

Criterio de Validación:
La consulta debe devolver exactamente 112 registros.
----------------------------------------------------------
*/

SELECT COUNT(*) FROM ventas_supermercados;


/*
----------------------------------------------------------
Consulta 2

Objetivo:
Verificar la cantidad de columnas existentes en la tabla.

Justificación:
Confirmar que todas las variables del conjunto de datos
fueron importadas correctamente.

Criterio de Validación:
La tabla debe contener exactamente 27 columnas.
----------------------------------------------------------
*/

SELECT COUNT(*) FROM information_schema.columns
WHERE table_schema = 'supermercados_db' AND table_name = 'ventas_supermercados';


/*
----------------------------------------------------------
Consulta 3

Objetivo:
Verificar el rango temporal cubierto por el conjunto de
datos.

Justificación:
Comprobar que el período de estudio se encuentra completo
y no existen registros faltantes al inicio o al final de
la serie temporal.

Criterio de Validación:
La primera fecha debe corresponder a enero de 2017 y la
última a abril de 2026.
----------------------------------------------------------
*/

SELECT MIN(indice_tiempo) AS primera_fecha, MAX(indice_tiempo) AS ultima_fecha 
FROM ventas_supermercados;


/*
----------------------------------------------------------
Consulta 4

Objetivo:
Verificar la existencia de registros duplicados.

Justificación:
Cada registro representa un único mes, por lo que no
deben existir fechas repetidas.

Criterio de Validación:
La consulta no debe devolver registros.
----------------------------------------------------------
*/

SELECT indice_tiempo, COUNT(*) FROM ventas_supermercados
GROUP BY indice_tiempo
HAVING COUNT(*) > 1;


/*
----------------------------------------------------------
Consulta 5

Objetivo:
Verificar la existencia de valores nulos en todas las
variables del conjunto de datos.

Justificación:
Los valores nulos pueden afectar los análisis
estadísticos, las visualizaciones y el cálculo de los
indicadores del proyecto.

Criterio de Validación:
Todas las columnas deben devolver 112 registros.
----------------------------------------------------------
*/

SELECT
    COUNT(indice_tiempo),
    COUNT(ventas_precios_corrientes),
    COUNT(ventas_precios_constantes),
    COUNT(ventas_precios_constantes_original),
    COUNT(ventas_precios_constantes_desestacionalizada),
    COUNT(ventas_precios_constantes_tendencia_ciclo),
    COUNT(ventas_totales_canal_venta),
    COUNT(salon_ventas),
    COUNT(canales_on_line),
    COUNT(ventas_totales_medio_pago),
    COUNT(efectivo),
    COUNT(tarjetas_debito),
    COUNT(tarjetas_credito),
    COUNT(otros_medios),
    COUNT(ventas_totales_grupo_articulos),
    COUNT(subtotal_ventas_alimentos_bebidas),
    COUNT(bebidas),
    COUNT(almacen),
    COUNT(panaderia),
    COUNT(lacteos),
    COUNT(carnes),
    COUNT(verduleria_fruteria),
    COUNT(alimentos_preparados_rotiseria),
    COUNT(articulos_limpieza_perfumeria),
    COUNT(indumentaria_calzado_textiles_hogar),
    COUNT(electronicos_articulos_hogar),
    COUNT(otros)
FROM ventas_supermercados;


/*
----------------------------------------------------------
Consulta 6

Objetivo:
Verificar los tipos de datos asignados a cada columna de
la tabla.

Justificación:
Utilizar tipos de datos adecuados mejora el rendimiento
de las consultas y evita errores durante el análisis.

Criterio de Validación:
Cada columna debe poseer un tipo de dato acorde a la
información que almacena.
----------------------------------------------------------
*/

DESCRIBE ventas_supermercados;


/*
----------------------------------------------------------
Consulta 7

Objetivo:
Visualizar una muestra representativa del conjunto de
datos.

Justificación:
Realizar una inspección manual para comprobar que la
información fue importada correctamente y detectar
posibles inconsistencias que no puedan identificarse
mediante validaciones automáticas.

Criterio de Validación:
Los registros deben visualizarse correctamente, sin
valores inesperados ni inconsistencias aparentes.
----------------------------------------------------------
*/

SELECT * FROM ventas_supermercados LIMIT 10;

/*
----------------------------------------------------------
Consulta 8

Objetivo:
Verificar la existencia de valores negativos en las
variables numéricas del conjunto de datos.

Justificación:
Las variables representan montos de ventas, por lo que
no deberían existir valores negativos.

Criterio de Validación:
La consulta no debe devolver registros.
----------------------------------------------------------
*/

SELECT * FROM ventas_supermercados
WHERE
    ventas_precios_corrientes < 0
    OR ventas_precios_constantes < 0
    OR ventas_precios_constantes_original < 0
    OR ventas_precios_constantes_desestacionalizada < 0
    OR ventas_precios_constantes_tendencia_ciclo < 0
    OR ventas_totales_canal_venta < 0
    OR salon_ventas < 0
    OR canales_on_line < 0
    OR ventas_totales_medio_pago < 0
    OR efectivo < 0
    OR tarjetas_debito < 0
    OR tarjetas_credito < 0
    OR otros_medios < 0
    OR ventas_totales_grupo_articulos < 0
    OR subtotal_ventas_alimentos_bebidas < 0
    OR bebidas < 0
    OR almacen < 0
    OR panaderia < 0
    OR lacteos < 0
    OR carnes < 0
    OR verduleria_fruteria < 0
    OR alimentos_preparados_rotiseria < 0
    OR articulos_limpieza_perfumeria < 0
    OR indumentaria_calzado_textiles_hogar < 0
    OR electronicos_articulos_hogar < 0
    OR otros < 0;
    
    
    /*
----------------------------------------------------------
Consulta 9

Objetivo:
Verificar la consistencia de las ventas por canal.

Justificación:
Las ventas totales por canal deben ser iguales a la suma
de las ventas realizadas en salón y por canales online.

Criterio de Validación:
La consulta no debe devolver registros.
----------------------------------------------------------
*/

SELECT * FROM ventas_supermercados
WHERE ABS(ventas_totales_canal_venta - (salon_ventas + canales_on_line)) > 0.01;


/*
----------------------------------------------------------
Consulta 10

Objetivo:
Verificar la consistencia de las ventas según el medio de
pago.

Justificación:
Las ventas totales por medio de pago deben coincidir con
la suma de las ventas realizadas mediante efectivo,
tarjetas de débito, tarjetas de crédito y otros medios.

Criterio de Validación:
La consulta no debe devolver registros.
----------------------------------------------------------
*/

SELECT * FROM ventas_supermercados
WHERE ABS(ventas_totales_medio_pago - (efectivo + tarjetas_debito + tarjetas_credito + otros_medios)) > 0.01;


/*
----------------------------------------------------------
Consulta 11

Objetivo:
Verificar la consistencia de las ventas por grupo de
artículos.

Justificación:
Las ventas totales por grupo de artículos deben coincidir
con la suma del subtotal de alimentos y bebidas, artículos
de limpieza y perfumería, indumentaria, electrónicos y la
categoría "otros".

Criterio de Validación:
La consulta no debe devolver registros.
----------------------------------------------------------
*/

SELECT * FROM ventas_supermercados
WHERE ABS(ventas_totales_grupo_articulos -
    (subtotal_ventas_alimentos_bebidas +
	articulos_limpieza_perfumeria +
	indumentaria_calzado_textiles_hogar +
	electronicos_articulos_hogar +
	otros)) > 0.01;
    
    
/*
----------------------------------------------------------
Consulta 12

Objetivo:
Obtener un resumen estadístico básico de las principales
variables de ventas.

Justificación:
Conocer el comportamiento general de las principales
variables numéricas antes de iniciar el análisis
exploratorio de datos e identificar posibles valores
atípicos o inconsistencias.

Criterio de Validación:
Los valores mínimo, máximo y promedio deben ser
coherentes con el contexto del negocio y el período
analizado.
----------------------------------------------------------
*/

SELECT
    MIN(ventas_precios_corrientes),
    MAX(ventas_precios_corrientes),
    AVG(ventas_precios_corrientes),
    MIN(ventas_precios_constantes),
    MAX(ventas_precios_constantes),
    AVG(ventas_precios_constantes)
FROM ventas_supermercados;


/*
----------------------------------------------------------
Consulta 13

Objetivo:
Verificar la continuidad temporal del conjunto de datos,
comprobando que no existan meses faltantes entre el primer
y el último registro.

Justificación:
La ausencia de uno o más períodos puede afectar el
análisis de tendencias, estacionalidad y la comparación
entre distintos intervalos de tiempo.

Criterio de Validación:
La consulta no debe devolver registros.
----------------------------------------------------------
*/

WITH RECURSIVE calendario AS (
    SELECT MIN(indice_tiempo) AS fecha
    FROM ventas_supermercados

    UNION ALL

    SELECT DATE_ADD(fecha, INTERVAL 1 MONTH)
    FROM calendario
    WHERE fecha < (SELECT MAX(indice_tiempo) FROM ventas_supermercados)
    )

SELECT fecha
FROM calendario
WHERE fecha NOT IN (SELECT indice_tiempo FROM ventas_supermercados);
