-- Creamos la base de datos.
CREATE DATABASE supermercados_db;

-- La seleccionamos para ser usada.
USE supermercados_db;

-- Visualizamos como quedó.
SELECT * FROM ventas_supermercados;

-- Verificamos que la columna indice_tiempo se cargó como tipo de dato "text" y no como "DATE".
-- Esto se debe a un error de importación propio de MySQL Workbench 8.0.47
DESCRIBE ventas_supermercados;

-- Comprobamos que tenga las 112 filas correspondientes del .csv
SELECT COUNT(*) FROM ventas_supermercados;

-- Comprobamos formato de fecha adecuado YYYY/MM/DD
SELECT indice_tiempo FROM ventas_supermercados LIMIT 5;

-- Procedemos a modificar el tipo de dato de "indice_tiempo" a DATE.
-- Desactivamos el modo seguro para que nos deje modificar el tipo de dato.
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE ventas_supermercados MODIFY COLUMN indice_tiempo DATE;

-- Volvemos a activar el modo seguro.
SET SQL_SAFE_UPDATES = 1;

-- Comprobamos si la modificación de tipo de dato fue exitosa.
DESCRIBE ventas_supermercados;

-- Verificamos a simple vista que las fechas esten correctas.
SELECT * FROM ventas_supermercados;
