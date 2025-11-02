USE Consorcio_AiresDeSaintJust
GO

CREATE TABLE cons.tmp_Personas (
    Nombre NVARCHAR(200),
    apellido NVARCHAR(200),
    DNI NVARCHAR(50),
    [email personal] NVARCHAR(255),
    [teléfono de contacto] NVARCHAR(100),
    [CVU/CBU] NVARCHAR(100),
    Inquilino NVARCHAR(20)
);
GO

CREATE TABLE cons.tmp_Unidades (
    raw_line NVARCHAR(MAX)
    -- para archivos con formato no estándar, cargamos línea y luego parseamos
);
GO

CREATE TABLE cons.tmp_Pagos (
    IdPago NVARCHAR(50),
    FechaPago NVARCHAR(50),
    CVU_CBU NVARCHAR(100),
    Valor NVARCHAR(100)
);
GO

CREATE TABLE cons.tmp_Consorcios (
    IdConsorcio NVARCHAR(100),
    NombreConsorcio NVARCHAR(200),
    Domicilio NVARCHAR(200),
    CantUF NVARCHAR(50),
    M2Totales NVARCHAR(50)
);
GO

CREATE TABLE cons.tmp_Proveedores (
    NombreProveedor NVARCHAR(255),
    CUIT NVARCHAR(100),
    Domicilio NVARCHAR(255),
    Telefono NVARCHAR(100),
    Email NVARCHAR(255)
);
GO

CREATE TABLE cons.ArchivosImportados (
    ImportId INT IDENTITY(1,1) PRIMARY KEY,
    RutaArchivo NVARCHAR(4000),
    HashArchivo VARBINARY(8000) NULL,
    NombreArchivo NVARCHAR(500),
    FechaImportacion DATETIME2 DEFAULT SYSUTCDATETIME(),
    TablaDestino NVARCHAR(200),
    FilasInsertadas INT DEFAULT 0,
    FilasActualizadas INT DEFAULT 0,
    FilasRechazadas INT DEFAULT 0,
    Comentarios NVARCHAR(2000) NULL
);
go

CREATE TABLE cons.ErroresImportacion (
    ErrorId INT IDENTITY(1,1) PRIMARY KEY,
    ImportId INT NULL,                 -- referencia a ArchivosImportados.ImportId
    FechaError DATETIME2 DEFAULT SYSUTCDATETIME(),
    MensajeError NVARCHAR(MAX),
    DatosCrudos NVARCHAR(MAX)
);
go