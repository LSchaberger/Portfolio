/*
==========================================================
Proyecto: Análisis del Desempeño de Ventas de Supermercados Argentinos
Autor: Leandro Daniel Schaberger

Archivo: 01_database_setup.sql

Objetivo:
Preparar el entorno de trabajo para el análisis de datos,
incluyendo la creación de la base de datos, la selección
del esquema y la verificación de la correcta importación
del conjunto de datos.

==========================================================
*/

/*
==========================================================

Índice de Consultas

1. Creación de la base de datos.

2. Selección de la base de datos.

3. Verificación de la tabla importada.

4. Verificación de la estructura de la tabla.

5. Verificación de la cantidad de registros.

6. Verificación del formato de la fecha.

7. Desactivación del modo seguro.

8. Conversión del tipo de dato de la fecha.

9. Activación del modo seguro.

10. Verificación final de la estructura.

11. Verificación final de la tabla.

==========================================================
*/


/*
----------------------------------------------------------
Consulta 1

Objetivo:
Crear la base de datos que almacenará toda la información
utilizada durante el proyecto.

Justificación:
Permite centralizar el almacenamiento y análisis de los
datos dentro de un único esquema.

Interpretación:
Al finalizar la consulta deberá existir la base de datos
supermercados_db.
----------------------------------------------------------
*/

CREATE DATABASE supermercados_db;


/*
----------------------------------------------------------
Consulta 2

Objetivo:
Seleccionar la base de datos sobre la cual se ejecutarán
las consultas del proyecto.

Justificación:
Permite establecer supermercados_db como esquema activo.

Interpretación:
Todas las operaciones posteriores se ejecutarán sobre la
base de datos seleccionada.
----------------------------------------------------------
*/

-- Compatible con MySQL 8.x
USE supermercados_db;


/*
----------------------------------------------------------
Consulta 3

Objetivo:
Visualizar la tabla importada desde el archivo CSV.

Justificación:
Permite comprobar que la importación se realizó
correctamente antes de iniciar el proceso de preparación
de los datos.

Interpretación:
La consulta mostrará todos los registros contenidos en la
tabla ventas_supermercados.
----------------------------------------------------------
*/

SELECT *
FROM ventas_supermercados;


/*
----------------------------------------------------------
Consulta 4

Objetivo:
Verificar la estructura de la tabla importada.

Justificación:
Permite comprobar que cada columna posee el tipo de dato
esperado.

Nota:
Durante la importación del archivo CSV mediante MySQL
Workbench 8.0.47, la columna indice_tiempo fue importada
como tipo TEXT en lugar de DATE.

Interpretación:
La estructura mostrará los nombres de las columnas y sus
respectivos tipos de datos.
----------------------------------------------------------
*/

DESCRIBE ventas_supermercados;


/*
----------------------------------------------------------
Consulta 5

Objetivo:
Verificar que la cantidad de registros importados sea la
esperada.

Justificación:
Permite confirmar que el proceso de importación no omitió
ni duplicó registros.

Interpretación:
La consulta deberá devolver un total de 112 registros.
----------------------------------------------------------
*/

SELECT COUNT(*)
FROM ventas_supermercados;


/*
----------------------------------------------------------
Consulta 6

Objetivo:
Verificar el formato de la columna indice_tiempo antes de
realizar la conversión del tipo de dato.

Justificación:
Permite comprobar que las fechas respetan el formato
AAAA-MM-DD requerido por MySQL.

Interpretación:
La consulta mostrará los primeros cinco registros de la
columna indice_tiempo.
----------------------------------------------------------
*/

SELECT indice_tiempo
FROM ventas_supermercados
LIMIT 5;


/*
----------------------------------------------------------
Consulta 7

Objetivo:
Desactivar temporalmente el modo seguro de MySQL.

Justificación:
Permite ejecutar modificaciones sobre la estructura de la
tabla sin restricciones del modo seguro.

Interpretación:
A partir de este momento será posible modificar la
estructura de la tabla.
----------------------------------------------------------
*/

SET SQL_SAFE_UPDATES = 0;


/*
----------------------------------------------------------
Consulta 8

Objetivo:
Modificar el tipo de dato de la columna indice_tiempo.

Justificación:
Permite almacenar las fechas utilizando el tipo DATE y
habilitar el uso de funciones temporales de MySQL.

Interpretación:
La columna indice_tiempo quedará definida con el tipo de
dato DATE.

Importante:
Esta conversión fue posible debido a que los valores
de la columna indice_tiempo ya se encontraban almacenados
con el formato AAAA-MM-DD, compatible con el tipo de dato DATE de MySQL.
----------------------------------------------------------
*/

ALTER TABLE ventas_supermercados
MODIFY COLUMN indice_tiempo DATE;


/*
----------------------------------------------------------
Consulta 9

Objetivo:
Reactivar el modo seguro de MySQL.

Justificación:
Permite restaurar la configuración de seguridad una vez
finalizada la modificación de la estructura.

Interpretación:
Las restricciones del modo seguro volverán a estar
habilitadas.
----------------------------------------------------------
*/

SET SQL_SAFE_UPDATES = 1;


/*
----------------------------------------------------------
Consulta 10

Objetivo:
Verificar que la modificación del tipo de dato se haya
realizado correctamente.

Justificación:
Permite confirmar que la columna indice_tiempo fue
convertida exitosamente al tipo DATE.

Interpretación:
La estructura deberá mostrar la columna indice_tiempo con
el tipo de dato DATE.
----------------------------------------------------------
*/

DESCRIBE ventas_supermercados;


/*
----------------------------------------------------------
Consulta 11

Objetivo:
Realizar una verificación final de la tabla.

Justificación:
Permite comprobar visualmente que los datos continúan
siendo consistentes luego de la modificación realizada.

Interpretación:
La consulta mostrará todos los registros almacenados en
la tabla ventas_supermercados.
----------------------------------------------------------
*/

SELECT *
FROM ventas_supermercados;