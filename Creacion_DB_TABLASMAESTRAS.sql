
IF DB_ID('Consorcio_AiresDeSaintJust') IS NULL
BEGIN
    CREATE DATABASE Consorcio_AiresDeSaintJust;
END
go

USE Consorcio_AiresDeSaintJust
go

IF SCHEMA_ID('cons') IS NULL
    EXEC('CREATE SCHEMA cons');
GO

CREATE TABLE cons.Personas_Inquilinos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    DNI BIGINT NULL,
    EmailPersonal NVARCHAR(150) NULL,
    TelefonoContacto NVARCHAR(50) NULL,
    CVU_CBU NVARCHAR(50) NULL,
    EsInquilino BIT NULL,
    FechaAlta DATETIME2 DEFAULT SYSUTCDATETIME()
);
go

CREATE TABLE cons.Unidades_Funcionales (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CVU_CBU NVARCHAR(50) NOT NULL,
    Consorcio NVARCHAR(100),
    NroUF INT NULL,
    Piso NVARCHAR(10),
    Departamento NVARCHAR(10),
    FechaAlta DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE cons.Pagos_Consorcios (
    IdPago INT PRIMARY KEY,
    FechaPago DATE NULL,
    CVU_CBU NVARCHAR(50) NULL,
    Valor DECIMAL(18,2) NULL,
    FechaCarga DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE cons.Consorcios (
    IdConsorcio NVARCHAR(50) PRIMARY KEY,
    NombreConsorcio NVARCHAR(150),
    Domicilio NVARCHAR(200),
    CantUF INT NULL,
    M2Totales DECIMAL(12,2) NULL,
    FechaAlta DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE cons.Proveedores (
    IdProveedor INT IDENTITY(1,1) PRIMARY KEY,
    NombreProveedor NVARCHAR(200),
    CUIT NVARCHAR(25) NULL,
    Domicilio NVARCHAR(200) NULL,
    Telefono NVARCHAR(50) NULL,
    Email NVARCHAR(150) NULL,
    FechaAlta DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

