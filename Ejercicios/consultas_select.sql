USE dsrp_prestamos_financieros_6;
GO

-- A. Igualdad simple (=)

-- Seleccionar el DNI, nombre completo y DNI de todas las personas naturales que se llaman David

SELECT * FROM personas_naturales;

SELECT
	numero_documento AS 'DNI',
	CONCAT(nombres, ' ', apellido_paterno, ' ', apellido_materno) AS 'Nombre_Completo',
	email
FROM personas_naturales
WHERE nombres = 'David';

-- B. Encontrar filas que contienen un valor como parte de una cadena (LIKE)

-- Seleccionar todas las personas naturales cuyo apellido paterno
-- contenga la cadena "ez"

SELECT
	numero_documento AS 'DNI',
	CONCAT(nombres, ' ', apellido_paterno, ' ', apellido_materno) AS 'Nombre_Completo',
	email
FROM personas_naturales
WHERE apellido_paterno LIKE ('%ez%');

-- Los apellidos paternos que empiecen con "R"

SELECT
	numero_documento AS 'DNI',
	CONCAT(nombres, ' ', apellido_paterno, ' ', apellido_materno) AS 'Nombre_Completo',
	email
FROM personas_naturales
WHERE apellido_paterno LIKE ('R%');

-- Los apellidos paternos que terminen con "S"

SELECT
	numero_documento AS 'DNI',
	CONCAT(nombres, ' ', apellido_paterno, ' ', apellido_materno) AS 'Nombre_Completo',
	email
FROM personas_naturales
WHERE apellido_paterno LIKE ('%S');

-- C.Encontrar filas mediante un operador de comparación (>, <, >=, <=, !=)

-- Listar los clientes cuyo id sea mayor a 50
SELECT * FROM clientes
WHERE id > 50;

-- Listar los clientes cuyo id sea mayor o igual a 50
SELECT * FROM clientes
WHERE id >= 50;

-- Listar los clientes cuyo id sea menor a 50
SELECT * FROM clientes
WHERE id < 50;

-- Listar los clientes cuyo id sea mnenor o igual a 50
SELECT * FROM clientes
WHERE id <= 50;

-- Listar los clientes cuyo id esté entre 90 y 100
SELECT * FROM clientes
WHERE id > 40 AND id < 50;

SELECT * FROM clientes
WHERE id >= 40 AND id <= 50;

SELECT * FROM clientes
WHERE id BETWEEN 40 AND 50;

-- Seleccionar todos los id diferentes de 50
SELECT * FROM clientes
WHERE id != 50;

SELECT * FROM clientes
WHERE tipo_persona != 'Persona Natural';

-- D. Encontrar filas que cumplan cualquiera de las 3 condiciones (OR)

-- Condición 1: El id es 1
-- Condición 2: El teléfono sea 32165894
-- Condición 3: La dirección es una avenida

SELECT * FROM personas_juridicas
WHERE
	id = 1 OR
	telefono = '32165894' OR
	direccion LIKE ('AV.%') OR
	direccion LIKE ('Avenida%');

-- E. Encontrar filas que cumplan varias condiciones (AND)

-- Condición 1: El código es mayor a 654789130
-- Condición 2: El nombre contenga la palabra 'sucursal'
-- Condición 3: La dirección no es una avenida

SELECT * FROM sucursales
WHERE
	codigo > '654789130' AND
	nombres LIKE ('%Sucursal%') AND
	direccion NOT LIKE ('%Av.%');

-- F. Encontrar filas que estén en una lista de valores

SELECT * FROM personas_naturales
WHERE numero_documento IN ('67890123', '78901234', '89012345', '90123456', '12323456');

-- Encontrar filas que no estén en una lista de valores

SELECT * FROM personas_naturales
WHERE numero_documento NOT IN ('67890123', '78901234', '89012345', '90123456', '12323456');

-- Funciones matemáticas

SELECT * FROM prestamos;
-- Sum
-- Monto total otorgado en préstamos de la sucursal de id 1 y 10

SELECT
	sucursal_id,
	SUM(monto_otorgado) AS 'Monto_total_otorgado'
FROM prestamos
WHERE sucursal_id IN (1,10)
GROUP BY sucursal_id
ORDER BY 2 ASC;

-- Max, min

SELECT
	sucursal_id,
	MAX(monto_otorgado) AS 'Monto_total_otorgado'
FROM prestamos
WHERE sucursal_id IN (1, 5, 10, 11, 15)
GROUP BY sucursal_id
ORDER BY 2 ASC;


SELECT
	sucursal_id,
	MIN(monto_otorgado) AS 'Monto_total_otorgado'
FROM prestamos
WHERE sucursal_id IN (1, 5, 10, 11, 15)
GROUP BY sucursal_id
ORDER BY 2 ASC;

-- Contar

SELECT
	sucursal_id,
	COUNT(sucursal_id) AS 'Num_préstamos'
FROM prestamos
WHERE sucursal_id IN (1, 5, 10, 11, 15)
GROUP BY sucursal_id
ORDER BY 2 ASC;

-- Contar

SELECT
	sucursal_id,
	COUNT(sucursal_id) AS 'Num_préstamos'
FROM prestamos
WHERE sucursal_id IN (1, 5, 10, 11, 15)
GROUP BY sucursal_id
ORDER BY 2 ASC;

-- Having
-- Solo se utiliza 'HAVING' cuando se emplea 'GROUP BY'
-- Reemplaza a 'WHERE' cuando se emplean subqueries ('COUNT')

SELECT
	sucursal_id,
	COUNT(id) AS 'Num_préstamos'
FROM prestamos
GROUP BY sucursal_id
HAVING COUNT(id) > 5
ORDER BY 2 ASC;

-- Creación de una vista
-- Encapsular tablas en una vista

CREATE VIEW vw_nh_lista_personas_naturales AS
SELECT
	numero_documento AS 'DNI',
	CONCAT(nombres, ' ', apellido_paterno, ' ', apellido_materno) AS 'Nombre_Completo',
	email
FROM personas_naturales;

-- Solo se invoca a la vista
SELECT * FROM vw_nh_lista_personas_naturales;

-- Combinación de tablas

SELECT
	p.sucursal_id,
	s.nombres AS 'Sucursal',
	COUNT(p.id) AS 'Num_préstamos'
FROM prestamos p, sucursales s
WHERE p.sucursal_id = s.id
GROUP BY p.sucursal_id, s.nombres
HAVING COUNT(p.id) > 5
ORDER BY 2 ASC;

-- Similiar con JOIN

SELECT
	p.sucursal_id,
	s.nombres AS 'Sucursal',
	COUNT(p.id) AS 'Num_préstamos'
FROM prestamos p
INNER JOIN sucursales s
ON p.sucursal_id = s.id
GROUP BY p.sucursal_id, s.nombres
HAVING COUNT(p.id) > 5
ORDER BY 2 ASC;

-- JOINS

-- INNER JOIN

SELECT
	c.persona_id,
	c.tipo_persona AS 'tipo_cliente',
	p.monto_otorgado,
	p.fecha_inicio
FROM clientes c
INNER JOIN prestamos p
ON p.cliente_id = c.id;

-- LEFT JOIN

SELECT
	c.persona_id,
	c.tipo_persona AS 'tipo_cliente',
	p.monto_otorgado,
	p.fecha_inicio
FROM clientes c
LEFT JOIN prestamos p
ON p.cliente_id = c.id;

-- RIGHT JOIN

SELECT
	c.persona_id,
	c.tipo_persona AS 'tipo_cliente',
	p.monto_otorgado,
	p.fecha_inicio
FROM prestamos p
RIGHT JOIN clientes c
ON p.cliente_id = c.id;

-- FULL JOIN

SELECT
	c.persona_id,
	c.tipo_persona AS 'tipo_cliente',
	p.monto_otorgado,
	p.fecha_inicio
FROM prestamos p
FULL OUTER JOIN clientes c
ON p.cliente_id = c.id;

-- CROSS JOIN
-- Producto cartesiano
-- Préstamos: 95 filas
-- Clientes: 79 filas
-- Cross Join: 95*79 = 7505

SELECT
	c.persona_id,
	c.tipo_persona AS 'tipo_cliente',
	p.monto_otorgado,
	p.fecha_inicio
FROM prestamos p
CROSS JOIN clientes c;

-- Seleccionar la lista de empleados (nombre completo, dni, dirección, cod_empleado, cargo,
-- nombre completo del supervisor y sucursal al que pertenece) con sus supervisores

SELECT * FROM clientes;
SELECT * FROM prestamos;
SELECT * FROM empleados;

SELECT
	e.id AS 'empleado_id',
	CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS 'Nombre_Completo',
	p.numero_documento AS 'DNI',
	p.direccion,
	e.codigo_empleado,
	e.cargo,
	s.id AS 'supervisor_id',
	CONCAT(p2.nombres, ' ', p2.apellido_paterno, ' ', p2.apellido_materno) AS 'Supervisor',
	sc.nombres AS 'Sucursal'
FROM empleados e
INNER JOIN personas_naturales p ON e.persona_id = p.id
INNER JOIN empleados s ON s.id = e.supervisor_id
INNER JOIN personas_naturales p2 ON p2.id = s.persona_id
INNER JOIN sucursales sc ON sc.id = e.sucursal_id;
