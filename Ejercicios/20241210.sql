USE dsrp_prestamos_financieros_6;
GO
/* 
Ejercicios Propuestos de Nivel Intermedio y Avanzado
Intermedio
Consulta con JOINs múltiples:

Obtén una lista de todos los préstamos, mostrando:
El cliente (nombre o razón social según corresponda).
La sucursal.
El empleado que gestionó el préstamo.
El tipo de préstamo.
El monto total otorgado y la tasa de interés.*/

SELECT
	p.id AS 'ID Préstamo',
	c.tipo_persona AS 'Tipo Cliente',
	CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno) AS 'Cliente',
	s.nombres AS 'Sucursal',
	CONCAT(pe.nombres, ' ', pe.apellido_paterno, ' ', pe.apellido_materno) AS 'Empleado',
	tp.nombre AS 'Tipo Préstamo',
	p.monto_otorgado,
	p.tasa_interes,
	p.plazo
FROM prestamos p
	INNER JOIN clientes c ON c.id = p.cliente_id
	INNER JOIN personas_naturales pt ON pt.id = c.persona_id AND c.tipo_persona = 'Persona Natural'
	INNER JOIN sucursales s ON p.sucursal_id = s.id
	INNER JOIN empleados e ON e.id = p.empleado_id
	INNER JOIN personas_naturales pe ON pe.id = e.persona_id
	INNER JOIN tipos_prestamos tp ON tp.id = p.tipo_prestamo_id

UNION

SELECT
	p.id AS 'ID Préstamo',
	c.tipo_persona AS 'Tipo Cliente',
	pj.razon_social AS 'Cliente',
	s.nombres AS 'Sucursal',
	CONCAT(pe.nombres, ' ', pe.apellido_paterno, ' ', pe.apellido_materno) AS 'Empleado',
	tp.nombre AS 'Tipo Préstamo',
	p.monto_otorgado,
	p.tasa_interes,
	p.plazo
FROM prestamos p
	INNER JOIN clientes c ON c.id = p.cliente_id
	INNER JOIN personas_juridicas pj ON pj.id = c.persona_id AND c.tipo_persona = 'Persona Jurídica'
	INNER JOIN sucursales s ON p.sucursal_id = s.id
	INNER JOIN empleados e ON e.id = p.empleado_id
	INNER JOIN personas_naturales pe ON pe.id = e.persona_id
	INNER JOIN tipos_prestamos tp ON tp.id = p.tipo_prestamo_id
ORDER BY 3;

/*
Cuotas Pendientes:

Crea una consulta para listar las cuotas vencidas que no han sido completamente abonadas, mostrando:
El cliente.
El préstamo relacionado.
El número de cuota y el monto pendiente.
*/

SELECT
	p.id AS 'ID Préstamo',
	c.tipo_persona AS 'Tipo Cliente',
	CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno) AS 'Cliente',
	ct.numero_cuota,
	ct.monto_pendiente,
	ct.fecha_vencimiento
FROM prestamos p
	INNER JOIN clientes c ON c.id = p.cliente_id
	INNER JOIN personas_naturales pt ON pt.id = c.persona_id AND c.tipo_persona = 'Persona Natural'
	INNER JOIN cuotas ct ON ct.prestamo_id = p.id
WHERE estado = 'Vencido'

UNION

SELECT
	p.id AS 'ID Préstamo',
	c.tipo_persona AS 'Tipo Cliente',
	pj.razon_social AS 'Cliente',
	ct.numero_cuota,
	ct.monto_pendiente,
	ct.fecha_vencimiento
FROM prestamos p
	INNER JOIN clientes c ON c.id = p.cliente_id
	INNER JOIN personas_juridicas pj ON pj.id = c.persona_id AND c.tipo_persona = 'Persona Jurídica'
	INNER JOIN cuotas ct ON ct.prestamo_id = p.id
WHERE estado = 'Vencido'
ORDER BY 3;

/*
Reporte de Saldos por Préstamo:

Calcula el monto pendiente total de cada préstamo (suma de monto_pendiente de las cuotas relacionadas) y clasifícalos como:
"Al día" si no tienen cuotas vencidas.
"En mora" si tienen al menos una cuota vencida.*/

SELECT
	p.id,
	SUM(c.monto_pendiente) AS 'Monto Pendiente Total',
	CASE
		WHEN c.estado != 'Vencido' THEN 'Al día'
		ELSE 'En mora'
	END AS 'Estado_Préstamo'
FROM prestamos p
	INNER JOIN cuotas c ON c.prestamo_id = p.id
GROUP BY p.id, c.estado
ORDER BY 2 DESC;

/*
Pagos por Cliente:

Diseña una consulta que liste los clientes y el total de dinero que han abonado hasta
la fecha, incluyendo aquellos que no han realizado ningún pago.
*/

SELECT
	CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno) AS 'Cliente',
	CASE
		WHEN dp.id IS NULL THEN 0
		ELSE SUM(dp.monto_afectado)
	END AS 'Total Abonado'
FROM clientes cl
INNER JOIN personas_naturales pt ON pt.id = cl.persona_id AND cl.tipo_persona = 'Persona Natural'
INNER JOIN prestamos p ON p.cliente_id = cl.id
INNER JOIN cuotas ct ON ct.prestamo_id = p.id
LEFT JOIN detalle_pagos dp ON dp.cuota_id = ct.id
GROUP BY pt.nombres, pt.apellido_paterno, pt.apellido_materno, dp.id;

/*
Subconsultas Correlacionadas:

Encuentra los empleados que han gestionado al menos un préstamo en cada sucursal.
*/

SELECT
	e.codigo_empleado,
	COUNT(DISTINCT s.id) AS 'num_sucursales'
FROM prestamos p
INNER JOIN sucursales s ON s.id = p.sucursal_id
INNER JOIN empleados e ON e.id = p.empleado_id
GROUP BY s.nombres, e.codigo_empleado
HAVING COUNT(DISTINCT s.id) = (SELECT COUNT(*) FROM sucursales) 
ORDER BY 1,2;

-- Otra versión

SELECT
	t2.persona_id,
	CONCAT(pn.nombres, ' ', pn.apellido_paterno, ' ', pn.apellido_materno) AS 'nombre_empleados'
	FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY t1.persona_id ORDER BY t1.persona_id) AS fila
	FROM (SELECT DISTINCT e.persona_id, p.sucursal_id FROM empleados e INNER JOIN prestamos p ON p.empleado_id = e.id) AS t1) AS t2 
	INNER JOIN personas_naturales pn ON pn.id = t2.persona_id
	WHERE t2.fila = 16;

SELECT * FROM sucursales;

/*
Pagos Detallados por Cuotas:

Lista todas las cuotas pagadas parcialmente, mostrando:
El cliente.
El préstamo relacionado.
El número de cuota.
El monto pendiente inicial, el monto abonado, y el saldo restante.
Cuotas Vencidas en un Rango de Fechas:

Crea una consulta parametrizada que permita listar las cuotas vencidas en un rango de fechas especificado por el usuario.
Procedimiento Almacenado - Registro de Préstamos:

Diseña un procedimiento almacenado que registre un nuevo préstamo, asignando automáticamente las cuotas relacionadas (según el plazo) con:
Montos iguales distribuidos en todas las cuotas.
Fechas de vencimiento calculadas según el plazo y la fecha de inicio.
Disparador para Pagos:

Crea un disparador (TRIGGER) que:
Se active al insertar un nuevo pago en la tabla pagos.
Actualice automáticamente el monto_pendiente en la tabla cuotas.
Cambie el estado de la cuota a "Pagado" si su saldo pendiente llega a cero.*/

SELECT * FROM cuotas;
SELECT * FROM detalle_pagos;
SELECT * FROM pagos;

-- DROP TRIGGER trg_nh_actualizar_cuotas;

ALTER TRIGGER trg_nh_actualizar_cuotas
ON detalle_pagos
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE c
	SET c.monto_pendiente = c.monto_pendiente - dp.monto_afectado,
		c.estado = CASE
			WHEN c.monto_pendiente - dp.monto_afectado <= 0 THEN 'Pagado'
			ELSE c.estado
		END
	FROM cuotas c
	INNER JOIN detalle_pagos dp ON dp.cuota_id = c.id
	INNER JOIN inserted i ON i.id = dp.id;
	PRINT 'Se insertó correctamente el pago.'
END;
GO

INSERT INTO pagos VALUES('123456', GETDATE(), '4694.5709');
INSERT INTO detalle_pagos VALUES(17, SCOPE_IDENTITY(), '4694.5709');

EXEC dbo.sp_nh_registra_pagos_cuota_v3 '49', '1468.4167'; -- Del archivo 20241212.sql

/*
Reporte de Eficiencia de Sucursales:

Genera un reporte que muestre:
El nombre de cada sucursal.
El número total de préstamos gestionados.
El porcentaje de estos préstamos que están al día.
El monto total otorgado.
Optimización de Cuotas con Pagos Parciales:

Diseña un procedimiento almacenado que redistribuya automáticamente pagos parciales de una cuota en cuotas futuras cuando el monto abonado supera el saldo pendiente de la cuota actual.

Consulta Jerárquica de Empleados: Resolver con un cursor

Lista los empleados junto con sus supervisores directos y, si aplica, el supervisor del supervisor, mostrando:
Nombre del empleado.
Nombre del supervisor directo.*/

DECLARE @cod_empleado AS VARCHAR(255)
DECLARE @empleado AS VARCHAR(255)
DECLARE cr_nh_imprime_cod_empleado CURSOR FOR
	SELECT
		CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno) AS 'Empleado',
		e.codigo_empleado AS 'cod_empleado'
	FROM empleados e
	INNER JOIN personas_naturales pt ON pt.id = e.persona_id
OPEN cr_nh_imprime_cod_empleado
FETCH NEXT FROM cr_nh_imprime_cod_empleado INTO @empleado, @cod_empleado
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'El(La) empleado(a) ' + @cod_empleado + ' tiene el código: '+ @cod_empleado
	FETCH NEXT FROM cr_nh_imprime_cod_empleado INTO @empleado, @cod_empleado
END
CLOSE cr_nh_imprime_cod_empleado
DEALLOCATE cr_nh_imprime_cod_empleado

-- Cursor para listar a los supervisores con sus respectivos empleados a cargo

DECLARE @cod_supervisor AS VARCHAR(255), @supervisor AS VARCHAR(255), @id_supervisor AS INT
DECLARE @message AS VARCHAR(255)
DECLARE @cod_empleado AS VARCHAR(255)
DECLARE @empleado AS VARCHAR(255)

PRINT '--------------------Reporte de supervisores con sus empleados a cargo--------------------'
-- Cursor principal para listar los supervisores

DECLARE cr_nh_imprime_supervisores CURSOR FOR
	SELECT
		CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno) AS 'Supervisor',
		e.codigo_empleado AS 'cod_supervisor',
		e.id AS 'id_supervisor'
	FROM empleados e
	INNER JOIN personas_naturales pt ON pt.id = e.persona_id
	WHERE e.supervisor_id IS NULL
OPEN cr_nh_imprime_supervisores
FETCH NEXT FROM cr_nh_imprime_supervisores INTO @supervisor, @cod_supervisor, @id_supervisor
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT ' '
	SELECT @message = '-----Empleados del supervisor: ' + @supervisor + ' (' + @cod_supervisor + ')'
	PRINT @message

	-- Cursor para listar empleados a cargo de cada supervisor

	DECLARE cr_nh_imprime_empleados CURSOR FOR
	SELECT
		CONCAT(pt.nombres, ' ', pt.apellido_paterno, ' ', pt.apellido_materno) AS 'Empleado',
		e.codigo_empleado AS 'cod_empleado'
	FROM empleados e
	INNER JOIN personas_naturales pt ON pt.id = e.persona_id
	WHERE e.supervisor_id = @id_supervisor
	OPEN cr_nh_imprime_empleados
	FETCH NEXT FROM cr_nh_imprime_empleados INTO @empleado, @cod_empleado
		IF @@FETCH_STATUS <> 0
		PRINT 'Por el momento con cuenta con empleados a cargo'

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @message = '' + @empleado + ' (' + @cod_empleado + ')'
		PRINT @message
		FETCH NEXT FROM cr_nh_imprime_empleados INTO @empleado, @cod_empleado
	END
	
	CLOSE cr_nh_imprime_empleados
	DEALLOCATE cr_nh_imprime_empleados
	--
	FETCH NEXT FROM cr_nh_imprime_supervisores
	INTO @supervisor, @cod_supervisor, @id_supervisor
END
CLOSE cr_nh_imprime_supervisores
DEALLOCATE cr_nh_imprime_supervisores

/*

Auditoría de Cambios:

Crea una tabla de auditoría para registrar cualquier cambio en la tabla prestamos
(incluyendo actualizaciones y eliminaciones), con:
El ID del préstamo afectado.
El tipo de cambio (INSERT, UPDATE, DELETE).
La fecha y el usuario que realizó el cambio.*/

-- Creamos la tabla auditoria_prestamos

CREATE TABLE audit_prestamos(
	id INT PRIMARY KEY IDENTITY(1,1),
	prestamo_id INT NOT NULL,
	tipo_cambio VARCHAR(50) NOT NULL,
	fecha_cambio DATETIME DEFAULT GETDATE(),
	usuario VARCHAR(100) NOT NULL
);

GO

SELECT SYSTEM_USER;

CREATE TRIGGER trg_nh_auditoria_prestamos
ON prestamos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @user_change VARCHAR(100);
	SET @user_change = SYSTEM_USER;
	
	-- INSERT

	IF EXISTS(SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
	BEGIN
		INSERT INTO audit_prestamos(prestamo_id, tipo_cambio, usuario)
		SELECT id, 'INSERT', @user_change
		FROM inserted;
	END;

	-- DELETE

	IF NOT EXISTS(SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
	BEGIN
		INSERT INTO audit_prestamos(prestamo_id, tipo_cambio, usuario)
		SELECT id, 'DELETE', @user_change
		FROM deleted;
	END;

	-- UPDATE

	IF EXISTS(SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
	BEGIN
		INSERT INTO audit_prestamos(prestamo_id, tipo_cambio, usuario)
		SELECT id, 'UPDATE', @user_change
		FROM inserted;
	END;
END;

GO

DROP TRIGGER trg_nh_auditoria_prestamos

-- Insertar préstamos aleatorios

DECLARE @Counter_pa INT
SET @Counter_pa = 0

WHILE @Counter_pa < 5
BEGIN
INSERT INTO prestamos (cliente_id,sucursal_id,empleado_id,tipo_prestamo_id,monto_otorgado,tasa_interes,plazo,fecha_inicio,created_at, created_by)
SELECT 
  c.id AS 'cliente_id',
  s.id AS 'sucursal_id',
  ROUND(RAND()*39,0) AS 'empleado_id',
  tp.id AS 'tipo_prestamo_id',
  ROUND(RAND() * 100000, 2) AS 'monto otorgado', -- Monto aleatorio
  ROUND(RAND(),2) AS tasa_interes,-- Tasa de interes en decimales ,
  ROUND(RAND()*24,0)+12 AS 'plazo_meses', -- Plazo meses,
  DATEADD(DAY, -ROUND(RAND() * 780,0), GETDATE()) AS 'fecha_inicio', -- Fecha de desembolso en los últimos 2 años
  DATEADD(DAY, -ROUND(RAND() * 780,0), GETDATE()) AS 'created_at', -- Fecha Creación en los ultimos 2 años
  ROUND(RAND()*39,0) AS 'created_by'
FROM clientes c
	CROSS JOIN sucursales s
	CROSS JOIN tipos_prestamos tp
ORDER BY NEWID()
OFFSET 0 ROWS
FETCH NEXT 1 ROWS ONLY;
    SET @Counter_pa = @Counter_pa + 1
END

SELECT * FROM prestamos;
SELECT * FROM audit_prestamos;

DELETE FROM prestamos WHERE id = 162;

UPDATE prestamos
SET monto_otorgado = 10000
WHERE id = 161;