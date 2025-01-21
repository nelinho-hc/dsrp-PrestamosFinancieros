USE dsrp_prestamos_financieros_6;
GO

/* Ejercicios Propuestos:
Inserci�n de Datos Iniciales:

Inserta al menos 3 registros en cada una de las tablas personas_naturales y personas_juridicas.
Registra 5 sucursales con c�digos �nicos y direcciones ficticias.
Crea 3 tipos de pr�stamo con descripciones.
*/

/*Consulta B�sica:
Obt�n una lista de todos los clientes (personas naturales y jur�dicas) con su tipo de persona (tipo_persona).
*/

SELECT
	c.tipo_persona AS 'Tipo Cliente',
	nt.numero_documento,
	ISNULL(nt.nombres, '') + ' ' + ISNULL(nt.apellido_paterno, '') + ' ' + ISNULL(nt.apellido_materno, '') AS 'Cliente',
	nt.email,
	nt.celular AS 'Celular/Tel�fono',
	nt.direccion
FROM clientes c
INNER JOIN personas_naturales nt ON nt.id = c.persona_id
AND c.tipo_persona = 'Persona Natural'

UNION

SELECT
	c.tipo_persona AS 'Tipo Cliente',
	pj.numero_documento,
	pj.razon_social AS 'Cliente',
	pj.email,
	pj.telefono AS 'Celular/Tel�fono',
	pj.direccion
FROM clientes c
INNER JOIN personas_juridicas pj ON pj.id = c.persona_id
AND c.tipo_persona = 'Persona Jur�dica';

/*Relaci�n Cliente-Pr�stamo:
Inserta al menos 5 registros en la tabla clientes, vinculando algunos con personas_naturales y otros con personas_juridicas.
Registra 3 pr�stamos asignados a diferentes sucursales y empleados, especificando los tipos de pr�stamo.
Pagos y Cuotas:

Para cada pr�stamo registrado, crea 3 cuotas con fechas de vencimiento consecutivas y estados alternados entre "Pendiente" y "Pagado".
Registra pagos realizados para cubrir una o m�s cuotas y genera los correspondientes registros en detalle_pagos.
*/

SELECT * FROM clientes;
SELECT * FROM prestamos WHERE plazo = 12;
SELECT * FROM cuotas;

-- Inserci�n Cuotas

INSERT INTO cuotas(prestamo_id, numero_cuota, monto, fecha_vencimiento, estado, monto_pendiente) VALUES 
(68, 1, '6846.70', '2023-08-30', 'Pagado', 0),
(68, 2, '6846.70', '2023-09-30', 'Pagado', 0),
(68, 3, '6846.70', '2023-10-30', 'Pagado', 0),
(68, 4, '6846.70', '2023-11-30', 'Pagado', 0),
(68, 5, '6846.70', '2023-12-30', 'Pagado', 0),
(68, 6, '6846.70', '2024-01-30', 'Pagado', 0),
(68, 7, '6846.70', '2024-02-29', 'Pagado', 0),
(68, 8, '6846.70', '2024-03-30', 'Pagado', 0),
(68, 9, '6846.70', '2024-04-30', 'Pagado', 0),
(68, 10, '6846.70', '2024-05-30', 'Pagado', 0),
(68, 11, '6846.70', '2024-06-30', 'Pagado', 0),
(68, 12, '6846.70', '2024-07-30', 'Pagado', 0);

-- Inserci�n Pagos
SELECT * FROM cuotas;
SELECT * FROM pagos;
SELECT * FROM detalle_pagos;

INSERT INTO pagos(codigo_operacion, fecha_pago, monto_abonado) VALUES
('000000001', '2023-08-30', 13693.40),
('000000002', '2023-09-22', 6846.70),
('000000003', '2023-10-30', 6846.70),
('000000004', '2023-11-30', 6846.70),
('000000005', '2023-12-25', 6846.70),
('000000006', '2024-01-30', 6846.70),
('000000007', '2024-02-29', 6846.70),
('000000008', '2024-03-14', 6846.70),
('000000009', '2024-04-30', 6846.70),
('000000010', '2024-05-29', 6846.70),
('000000011', '2024-06-15', 3846.70),
('000000012', '2024-07-30', 3000.00);

INSERT INTO detalle_pagos(cuota_id, pago_id, monto_afectado) VALUES
(1, 1, 6846.70), -- Se hizo el pago 1 de dos cuotas
(2, 1, 6846.70), -- Se hizo el pago 1 de dos cuotas
(3, 2, 6846.70),
(4, 3, 6846.70),
(5, 4, 6846.70),
(6, 5, 6846.70),
(7, 6, 6846.70),
(8, 7, 6846.70),
(9, 8, 6846.70),
(10, 9, 6846.70),
(11, 10, 6846.70),
(12, 11, 3846.70), -- Se hicieron dos pagos de la cuota 12
(12, 12, 3000.00); -- Se hicieron dos pagos de la cuota 12

-- C�lculo del valor de la cuota

SELECT ROUND((monto_otorgado + monto_otorgado*tasa_interes)/plazo, 2) AS 'monto_cuota'
FROM prestamos
WHERE plazo = 12;

-- Actualizar la fecha de vencimiento (Est�n en NULL)
SELECT
	fecha_inicio,
	plazo,
	fecha_vencimiento,
	DATEADD(MONTH, plazo, fecha_inicio) AS 'fecha_vencimiento_calculado'
FROM prestamos;

UPDATE prestamos
SET fecha_vencimiento = DATEADD(MONTH, plazo, fecha_inicio),
	updated_at = GETDATE(),
	updated_by = '1';

-- CONSULTAS INTERMEDIAS

-- 1. Lista los pr�stamos activos, mostrando el cliente, el tipo de pr�stamo, y el monto otorgado.

SELECT * FROM prestamos;

SELECT
	CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno) AS 'Clientes',
	tp.nombre AS 'Tipo Pr�stamo',
	p.monto_otorgado AS 'Monto Otorgado'
FROM prestamos p
	INNER JOIN tipos_prestamos tp ON tp.id = p.tipo_prestamo_id
	INNER JOIN clientes c ON c.id = p.cliente_id
	INNER JOIN personas_naturales pt ON pt.id = c.persona_id AND c.tipo_persona = 'Persona Natural'
WHERE p.fecha_vencimiento > GETDATE();

-- 2.Encuentra todas las cuotas pendientes, incluyendo el nombre del cliente y el c�digo del pr�stamo.

SELECT * FROM cuotas;

SELECT
	CASE
		WHEN c.tipo_persona = 'Persona Natural' THEN CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno)
		WHEN c.tipo_persona = 'Persona Jur�dica' THEN pj.razon_social
		ELSE 'Desconocido'
	END AS 'Clientes',
	p.id AS 'ID Pr�stamo',
	p.monto_otorgado AS 'Monto Otorgado',
	ct.numero_cuota AS 'N�mero de cuota',
	ct.monto_pendiente AS 'Monto Pendiente',
	ct.fecha_vencimiento AS 'Fecha de Vencimiento'
FROM prestamos p
	INNER JOIN tipos_prestamos tp ON tp.id = p.tipo_prestamo_id
	INNER JOIN clientes c ON c.id = p.cliente_id
	INNER JOIN personas_naturales pt ON pt.id = c.persona_id AND c.tipo_persona = 'Persona Natural'
	INNER JOIN personas_juridicas pj ON pj.id = c.persona_id AND c.tipo_persona = 'Persona Jur�dica'
	INNER JOIN cuotas ct ON ct.prestamo_id = p.id
WHERE ct.estado = 'Pendiente';

-- 3. Obt�n el total abonado por cada cliente en sus pagos.

SELECT
	CASE
		WHEN c.tipo_persona = 'Persona Natural' THEN CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno)
		WHEN c.tipo_persona = 'Persona Jur�dica' THEN pj.razon_social
		ELSE 'Desconocido'
	END AS 'Clientes',
	SUM(p.monto_otorgado) AS 'Total Abonado'
FROM prestamos p
	INNER JOIN clientes c ON c.id = p.cliente_id
	INNER JOIN personas_naturales pt ON pt.id = c.persona_id AND c.tipo_persona = 'Persona Natural'
	INNER JOIN personas_juridicas pj ON pj.id = c.persona_id AND c.tipo_persona = 'Persona Jur�dica'
	INNER JOIN cuotas ct ON ct.prestamo_id = p.id
	INNER JOIN detalle_pagos dp ON dp.cuota_id = ct.id
	INNER JOIN pagos pg ON pg.id = dp.pago_id
GROUP BY c.tipo_persona, pt.nombres, pt.apellido_paterno, pt.apellido_materno, pj.razon_social;

-- Solo con el c�digo(id) del cliente
SELECT * FROM clientes;

SELECT c.id AS 'cliente_id'
FROM prestamos p
	INNER JOIN clientes c ON c.id = p.cliente_id
	INNER JOIN cuotas ct ON ct.prestamo_id = p.id
	INNER JOIN detalle_pagos dp ON dp.cuota_id = ct.id
	INNER JOIN pagos pg ON pg.id = dp.pago_id
GROUP BY c.id;

-- ACTUALIZACIONES Y ELIMINACIONES

-- Actualiza la direcci�n de una sucursal
SELECT * FROM sucursales;

UPDATE sucursales
SET direccion = 'Av. Alfonso Ugarte N� 205'
WHERE id = 2;

-- Marca como eliminados (llenando deleted_at y deleted_by) todos los pr�stamos cuyo plazo ya haya vencido

UPDATE prestamos
SET
	deleted_at = GETDATE(),
	deleted_by = 1
WHERE fecha_vencimiento < GETDATE() AND deleted_at IS NULL;

-- Elimina un cliente y todos los registros asociados (pr�stamos, cuotas, etc.)
-- Como tiene un FK, se tienen que eliminar de tabla en tabla

SELECT * FROM prestamos;

-- Eliminando detalles_pagos

DELETE dp
FROM detalle_pagos dp
INNER JOIN cuotas ct ON ct.id = dp.cuota_id
INNER JOIN prestamos p ON p.id = ct.prestamo_id
WHERE p.cliente_id = 6;

-- Eliminando pagos

DELETE FROM pagos
WHERE id NOT IN (SELECT pago_id FROM detalle_pagos);

-- Eliminando cuotas

DELETE ct
FROM cuotas ct
INNER JOIN prestamos p ON p.id = ct.prestamo_id
WHERE p.cliente_id = 6;

-- Eliminando pr�stamos del cliente_id = 6

DELETE FROM prestamos WHERE cliente_id = 6;

-- Eliminar el cliente 6

DELETE FROM clientes WHERE id = 6;

-- ESTAD�STICAS Y AGREGACIONES

-- Calcula el promedio de los montos otorgados en los pr�stamos

SELECT AVG(monto_otorgado) AS 'monto_otorgado_promedio'
FROM prestamos;

-- Determina cu�l sucursal ha otorgado el mayor n�mero de pr�stamos

SELECT sc.nombres, COUNT(p.sucursal_id) AS 'Cantidad_pr�stamos'
INTO #t01	-- Tabla temporal
FROM prestamos p
INNER JOIN sucursales sc ON sc.id = p.sucursal_id
GROUP BY sc.nombres
ORDER BY COUNT(p.sucursal_id) DESC;

SELECT nombres, Cantidad_pr�stamos FROM #t01
WHERE Cantidad_pr�stamos IN (SELECT MAX(Cantidad_pr�stamos) FROM #t01);

-- Genera un reporte con el total de intereses generados por los pr�stamos

SELECT * FROM prestamos;

SELECT
	id AS 'prestamo_id',
	monto_otorgado,
	tasa_interes*monto_otorgado AS 'interes_a_generar',
	CASE
		WHEN deleted_at IS NOT NULL THEN 'prestamo_vencido'
		ELSE 'prestamo_activo'
	END AS 'Estado'
FROM prestamos;

SELECT SUM(tasa_interes*monto_otorgado) FROM prestamos WHERE deleted_at IS NOT NULL;

-- FUNCIONES

-- Funci�n para Obtener Nombre Completo
-- Crea una funci�n que reciba los nombres, apellido paterno y materno de una persona y devuelva su nombre completo en el formato
-- Apellido Paterno Apellido Materno, Nombres.

CREATE FUNCTION FN_NH_RETORNA_NOMBRE_COMPLETO(@nombres VARCHAR(255), @app VARCHAR(255), @apm VARCHAR(255))
RETURNS VARCHAR(1000) -- Si busco modificar una funci�n ya creada, debo reeemplazar 'CREATE' por 'ALTER'
AS
BEGIN
	DECLARE @nombre_completo VARCHAR(1000);
	SELECT @nombre_completo = CONCAT(@app, ' ', @apm, ' ', @nombres);
RETURN @nombre_completo;
END

-- Invocar la funci�n

SELECT dbo.FN_NH_RETORNA_NOMBRE_COMPLETO('Nelinho', 'Hurtado', 'Calder�n')

SELECT
	CASE
		WHEN c.tipo_persona = 'Persona Natural' THEN dbo.FN_NH_RETORNA_NOMBRE_COMPLETO(pn.nombres, pn.apellido_paterno, pn.apellido_materno)
		WHEN c.tipo_persona = 'Persona Jur�dica' THEN pj.razon_social
		ELSE 'desconocido'
	END AS 'nombre_cliente',
	tp.nombre AS 'tipo_prestamo',
	p.monto_otorgado
FROM prestamos p
INNER JOIN tipos_prestamos tp ON tp.id = p.tipo_prestamo_id
INNER JOIN clientes c ON c.id = p.cliente_id
LEFT JOIN personas_naturales pn ON pn.id = c.persona_id AND c.tipo_persona = 'Persona Natural'
LEFT JOIN personas_juridicas pj ON pj.id = c.persona_id AND c.tipo_persona = 'Persona Jur�dica'
WHERE p.fecha_vencimiento > GETDATE();

-- PROCEDIMIENTOS ALMACENADOS

-- Crea un procedimiento almacenado que registre autom�ticamente un pago y actualice las cuotas afectadas
--Dise�a un procedimiento para generar un reporte con los pr�stamos activos de una sucursal espec�fica

CREATE PROCEDURE SP_NH_PRESTAMOS_ACTIVOS_SUCURSAL
	@id_sucursal INT	-- Si busco modificar un procedimiento ya creado, debo reeemplazar 'CREATE' por 'ALTER'
AS
	SET NOCOUNT ON; -- Evita el desbordamiento de pila
	SELECT
		id AS 'prestamo_id',
		monto_otorgado,
		plazo,
		tasa_interes,
		fecha_inicio,
		fecha_vencimiento
	FROM prestamos
	WHERE sucursal_id = @id_sucursal AND deleted_at IS NULL;
GO

EXEC SP_NH_PRESTAMOS_ACTIVOS_SUCURSAL 1