USE dsrp_prestamos_financieros_6;
GO

-- Crear un procedimiento almacenado que al momento de insertar un préstamo le genere automáticamente
-- su calendario de cuotas

SELECT * FROM prestamos WHERE id = 51;
SELECT * FROM cuotas;

CREATE PROCEDURE sp_nh_insertar_cuotas_prestamo
	@id_prestamo INT
AS
	SET NOCOUNT ON;
	DECLARE @plazo INT;

	SELECT @plazo = plazo FROM prestamos WHERE id = @id_prestamo;

	-- Insertar cuotas
	DECLARE @Counter INT;
	SET @Counter = 0

	WHILE @Counter < @plazo
	BEGIN
		INSERT INTO cuotas(prestamo_id, numero_cuota, monto, fecha_vencimiento, estado, monto_pendiente)
		SELECT
			@id_prestamo,
			@Counter + 1,
			(monto_otorgado + monto_otorgado * tasa_interes)/plazo AS 'Monto',
			CAST(DATEADD(MONTH, @Counter + 1, fecha_inicio) AS DATE) AS 'Fecha_Vencimiento',
			'Pendiente' AS 'estado',
			(monto_otorgado + monto_otorgado * tasa_interes)/plazo AS 'Monto_Pendiente'
		FROM prestamos
		WHERE id = @id_prestamo
		-- Estructura propia de WHILE
		ORDER BY NEWID()	-- Cada vez que se hace una nueva inserción, se va a ir actualizando
		OFFSET 0 ROWS		-- Pasa 1 a 1 la siguiente fila
		FETCH NEXT 1 ROWS ONLY;
			SET @Counter = @Counter + 1		-- Actualizar el contador
	END
GO

EXEC sp_nh_insertar_cuotas_prestamo 51;

-- Eliminar procedimientos almacenados
DROP PROCEDURE sp_nh_insertar_cuotas_prestamo;

-- Actualizar las cuotas de los préstamos

DECLARE @num_prestamos INT
SELECT @num_prestamos = COUNT(*) FROM prestamos;

DECLARE @Counter1 INT
	SET @Counter1 = 2
DECLARE @CounterTemp INT

	WHILE @Counter1 <= @num_prestamos
	BEGIN
		SET @CounterTemp = @Counter1 + 50
		EXEC dbo.sp_nh_insertar_cuotas_prestamo @CounterTemp
			SET @Counter1 = @Counter1 + 1
	END

-- Actualizar cuotas: Todas las cuotas con fecha anterior a la actual, se coloca como estado 'Vencido'

UPDATE cuotas
SET estado = 'Vencido'
WHERE fecha_vencimiento < GETDATE();

SELECT * FROM cuotas
WHERE estado = 'Vencido';

-- Analizando los pagos

SELECT * FROM detalle_pagos;
SELECT * FROM pagos;
SELECT * FROM cuotas WHERE id = 13;

-- Insertar el pago de la cuota de id = 13

DECLARE @cuota_id INT
SET @cuota_id = 13
DECLARE @monto_pagar MONEY
DECLARE	@fecha_pago DATETIME

SELECT @monto_pagar = monto_pendiente, @fecha_pago = fecha_vencimiento FROM cuotas
WHERE id = @cuota_id;

-- Insertando pago

INSERT INTO pagos (codigo_operacion, fecha_pago, monto_abonado)
VALUES (ROUND(RAND()*100000, 0), @fecha_pago, @monto_pagar);

INSERT INTO detalle_pagos (cuota_id, pago_id, monto_afectado)
VALUES (@cuota_id, SCOPE_IDENTITY(), @monto_pagar)		-- SCOPE_IDENTITY() captura el último ID generado

-- Actualizar cuotas

UPDATE cuotas
SET estado = 'Pagado',
	monto_pendiente = monto_pendiente - @monto_pagar
WHERE id = @cuota_id;

-- Procedimiento almacenado para registrar pagos v1

CREATE PROCEDURE sp_nh_registra_pagos_cuota
	@cuota_id INT
AS
	SET NOCOUNT ON;
	DECLARE @monto_pagar MONEY
	DECLARE	@fecha_pago DATETIME

	SELECT @monto_pagar = monto_pendiente, @fecha_pago = fecha_vencimiento FROM cuotas
	WHERE id = @cuota_id;

	-- Insertando pago

	INSERT INTO pagos (codigo_operacion, fecha_pago, monto_abonado)
	VALUES (ROUND(RAND()*100000, 0), @fecha_pago, @monto_pagar);

	INSERT INTO detalle_pagos (cuota_id, pago_id, monto_afectado)
	VALUES (@cuota_id, SCOPE_IDENTITY(), @monto_pagar)		-- SCOPE_IDENTITY() captura el último ID generado

	-- Actualizar cuotas

	UPDATE cuotas
	SET estado = 'Pagado',
		monto_pendiente = monto_pendiente - @monto_pagar
	WHERE id = @cuota_id;
GO

-- Procedimiento almacenado para registrar pagos v2

CREATE PROCEDURE sp_nh_registra_pagos_cuota_v2
	@cuota_id INT,
	@monto_ingresado MONEY
AS
	SET NOCOUNT ON;
	DECLARE @monto_pagar MONEY
	DECLARE	@fecha_pago DATETIME

	SELECT @monto_pagar = monto_pendiente, @fecha_pago = fecha_vencimiento FROM cuotas
	WHERE id = @cuota_id;

	-- Insertando pago

	INSERT INTO pagos (codigo_operacion, fecha_pago, monto_abonado)
	VALUES (ROUND(RAND()*100000, 0), @fecha_pago, @monto_ingresado);

	INSERT INTO detalle_pagos (cuota_id, pago_id, monto_afectado)
	VALUES (@cuota_id, SCOPE_IDENTITY(), @monto_ingresado)		-- SCOPE_IDENTITY() captura el último ID generado

	-- Actualizar cuotas
	IF @monto_pagar = @monto_ingresado
	BEGIN
		UPDATE cuotas
		SET estado = 'Pagado',
			monto_pendiente = monto_pendiente - @monto_ingresado
		WHERE id = @cuota_id;
	END
	ELSE BEGIN
		UPDATE cuotas
		SET estado = 'Pendiente',
			monto_pendiente = monto_pendiente - @monto_ingresado
		WHERE id = @cuota_id;
	END
GO

EXEC dbo.sp_nh_registra_pagos_cuota_v2 '16', '500.00';
SELECT * FROM cuotas;

-- Procedimiento almacenado para registrar pagos v2

CREATE PROCEDURE sp_nh_registra_pagos_cuota_v3
	@cuota_id INT,
	@monto_ingresado MONEY
AS
	SET NOCOUNT ON;
	DECLARE @monto_pagar MONEY
	DECLARE	@fecha_pago DATETIME

	SELECT @monto_pagar = monto_pendiente, @fecha_pago = fecha_vencimiento FROM cuotas
	WHERE id = @cuota_id;

	-- Insertando pago

	INSERT INTO pagos (codigo_operacion, fecha_pago, monto_abonado)
	VALUES (ROUND(RAND()*100000, 0), @fecha_pago, @monto_ingresado);

	INSERT INTO detalle_pagos (cuota_id, pago_id, monto_afectado)
	VALUES (@cuota_id, SCOPE_IDENTITY(), @monto_ingresado)		-- SCOPE_IDENTITY() captura el último ID generado
GO