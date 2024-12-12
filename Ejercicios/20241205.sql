USE dsrp_prestamos_financieros_6;
GO

/* Ejercicios Propuestos:
Inserción de Datos Iniciales:

Inserta al menos 3 registros en cada una de las tablas personas_naturales y personas_juridicas.
Registra 5 sucursales con códigos únicos y direcciones ficticias.
Crea 3 tipos de préstamo con descripciones.
*/

/*Consulta Básica:
Obtén una lista de todos los clientes (personas naturales y jurídicas) con su tipo de persona (tipo_persona).
*/

SELECT
	c.tipo_persona AS 'Tipo Cliente',
	nt.numero_documento,
	ISNULL(nt.nombres, '') + ' ' + ISNULL(nt.apellido_paterno, '') + ' ' + ISNULL(nt.apellido_materno, '') AS 'Cliente',
	nt.email,
	nt.celular AS 'Celular/Teléfono',
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
	pj.telefono AS 'Celular/Teléfono',
	pj.direccion
FROM clientes c
INNER JOIN personas_juridicas pj ON pj.id = c.persona_id
AND c.tipo_persona = 'Persona Jurídica';

/*Relación Cliente-Préstamo:
Inserta al menos 5 registros en la tabla clientes, vinculando algunos con personas_naturales y otros con personas_juridicas.
Registra 3 préstamos asignados a diferentes sucursales y empleados, especificando los tipos de préstamo.
Pagos y Cuotas:

Para cada préstamo registrado, crea 3 cuotas con fechas de vencimiento consecutivas y estados alternados entre "Pendiente" y "Pagado".
Registra pagos realizados para cubrir una o más cuotas y genera los correspondientes registros en detalle_pagos.
*/

SELECT * FROM clientes;
SELECT * FROM prestamos WHERE plazo = 12;
SELECT * FROM cuotas;

-- Inserción Cuotas

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

-- Inserción Pagos
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

-- Cálculo del valor de la cuota

SELECT ROUND((monto_otorgado + monto_otorgado*tasa_interes)/plazo, 2) AS 'monto_cuota'
FROM prestamos
WHERE plazo = 12;

-- Actualizar la fecha de vencimiento (Están en NULL)
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

