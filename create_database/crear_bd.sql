CREATE DATABASE dsrp_prestamos_financieros_6;
GO

USE dsrp_prestamos_financieros_6;
GO
-- Personas Naturales
CREATE TABLE personas_naturales(
	id INT PRIMARY KEY IDENTITY(1,1),
	numero_documento VARCHAR(20) UNIQUE NOT NULL,
	nombres VARCHAR(255) NOT NULL,
	apellido_paterno VARCHAR(255) NOT NULL,
	apellido_materno VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL,
	celular VARCHAR(20) NOT NULL,
	direccion VARCHAR(255) NOT NULL
);
GO

SELECT * FROM personas_naturales;

EXEC SP_HELP personas_naturales;

-- Personas Jur�dicas
CREATE TABLE personas_juridicas(
	id INT PRIMARY KEY IDENTITY(1,1),
	numero_documento VARCHAR(20) UNIQUE NOT NULL,
	razon_social VARCHAR(255) NOT NULL,
	email VARCHAR(100) NOT NULL,
	telefono VARCHAR(20) NOT NULL,
	direccion VARCHAR(255) NOT NULL
);
GO

-- Clientes
CREATE TABLE clientes(
	id INT PRIMARY KEY IDENTITY(1,1),
	tipo_persona VARCHAR(55) NOT NULL,
	persona_id INT NOT NULL
);