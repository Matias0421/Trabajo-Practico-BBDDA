CREATE DATABASE PRUEBA_TP
go

create schema dba
go

CREATE TABLE dba.Personas_Inquilinos (
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

CREATE TABLE dba.Unidades_Funcionales (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CVU_CBU NVARCHAR(50) NOT NULL,
    Consorcio NVARCHAR(100),
    NroUF INT NULL,
    Piso NVARCHAR(10),
    Departamento NVARCHAR(10),
    FechaAlta DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dba.Pagos_Consorcios (
    IdPago INT PRIMARY KEY,
    FechaPago DATE NULL,
    CVU_CBU NVARCHAR(50) NULL,
    Valor DECIMAL(18,2) NULL,
    FechaCarga DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dba.Consorcios (
    IdConsorcio NVARCHAR(50) PRIMARY KEY,
    NombreConsorcio NVARCHAR(150),
    Domicilio NVARCHAR(200),
    CantUF INT NULL,
    M2Totales DECIMAL(12,2) NULL,
    FechaAlta DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dba.Proveedores (
    IdProveedor INT IDENTITY(1,1) PRIMARY KEY,
    NombreProveedor NVARCHAR(200),
    CUIT NVARCHAR(25) NULL,
    Domicilio NVARCHAR(200) NULL,
    Telefono NVARCHAR(50) NULL,
    Email NVARCHAR(150) NULL,
    FechaAlta DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE dba.tmp_Personas (
    Nombre NVARCHAR(200),
    apellido NVARCHAR(200),
    DNI NVARCHAR(50),
    [email personal] NVARCHAR(255),
    [teléfono de contacto] NVARCHAR(100),
    [CVU/CBU] NVARCHAR(100),
    Inquilino NVARCHAR(20)
);
GO

CREATE TABLE dba.tmp_Unidades (
    raw_line NVARCHAR(MAX)
    -- para archivos con formato no estándar, cargamos línea y luego parseamos
);
GO

CREATE TABLE dba.tmp_Pagos (
    IdPago NVARCHAR(50),
    FechaPago NVARCHAR(50),
    CVU_CBU NVARCHAR(100),
    Valor NVARCHAR(100)
);
GO

CREATE TABLE dba.tmp_Consorcios (
    IdConsorcio NVARCHAR(100),
    NombreConsorcio NVARCHAR(200),
    Domicilio NVARCHAR(200),
    CantUF NVARCHAR(50),
    M2Totales NVARCHAR(50)
);
GO

CREATE TABLE dba.tmp_Proveedores (
    NombreProveedor NVARCHAR(255),
    CUIT NVARCHAR(100),
    Domicilio NVARCHAR(255),
    Telefono NVARCHAR(100),
    Email NVARCHAR(255)
);
GO

CREATE TABLE dba.ArchivosImportados (
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

CREATE TABLE dba.ErroresImportacion (
    ErrorId INT IDENTITY(1,1) PRIMARY KEY,
    ImportId INT NULL,                 -- referencia a ArchivosImportados.ImportId
    FechaError DATETIME2 DEFAULT SYSUTCDATETIME(),
    MensajeError NVARCHAR(MAX),
    DatosCrudos NVARCHAR(MAX)
);
go

/*SELECT TOP 5 BulkColumn 
FROM OPENROWSET(BULK 'C:\Users\admin\OneDrive\Documentos\consorcios\Inquilino-propietarios-datos.csv', SINGLE_CLOB) AS x;
*/

CREATE OR ALTER FUNCTION dba.NormalizarNombre (@Texto NVARCHAR(200))
RETURNS NVARCHAR(200)
AS
BEGIN
    IF @Texto IS NULL RETURN NULL;
    
    DECLARE @Resultado NVARCHAR(200);
    
    -- Eliminar espacios múltiples y normalizar a minúsculas primero
    SET @Texto = LOWER(LTRIM(RTRIM(@Texto)));
    
    -- Eliminar espacios múltiples
    WHILE CHARINDEX('  ', @Texto) > 0
        SET @Texto = REPLACE(@Texto, '  ', ' ');
    
    -- Convertir a Title Case (primera letra de cada palabra en mayúscula)
    SET @Resultado = (
        SELECT STRING_AGG(
            UPPER(LEFT(value, 1)) + SUBSTRING(value, 2, LEN(value)),
            ' '
        ) 
        FROM STRING_SPLIT(@Texto, ' ')
        WHERE value <> ''
    );
    
    -- Casos especiales y preposiciones (mantener en minúscula)
    SET @Resultado = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        ISNULL(@Resultado, ''),
        ' De ', ' de '),
        ' Del ', ' del '),
        ' La ', ' la '),
        ' Las ', ' las '),
        ' Y ', ' y ');
    
    RETURN @Resultado;
END
GO

CREATE OR ALTER PROCEDURE dba.TestArchivo
    @RutaArchivo NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Probando acceso al archivo: ' + @RutaArchivo;
        
        -- Limpiar tabla temporal
        TRUNCATE TABLE dba.tmp_Personas;
        
        -- Intentar cargar el archivo
        DECLARE @SQL NVARCHAR(MAX) = N'
            BULK INSERT dba.tmp_Personas
            FROM ''' + @RutaArchivo + '''
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = '';'',
                ROWTERMINATOR = ''\n'',
                CODEPAGE = ''ACP'',
                TABLOCK
            );';
        
        PRINT 'Ejecutando: ' + @SQL;
        EXEC sp_executesql @SQL;
        
        -- Mostrar resultados normalizados
        DECLARE @Filas INT = (SELECT COUNT(*) FROM dba.tmp_Personas);
        PRINT 'Filas cargadas: ' + CAST(@Filas AS NVARCHAR);
        
        -- Mostrar datos normalizados
        WITH DatosNormalizados AS (
            SELECT 
                -- Normalizar nombre (cada palabra con primera letra mayúscula)
                (
                    SELECT STRING_AGG(
                        UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))),
                        ' '
                    )
                    FROM STRING_SPLIT(LTRIM(RTRIM(Nombre)), ' ')
                ) AS Nombre_Normalizado,
                -- Normalizar apellido (cada palabra con primera letra mayúscula)
                (
                    SELECT STRING_AGG(
                        UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))),
                        ' '
                    )
                    FROM STRING_SPLIT(LTRIM(RTRIM(apellido)), ' ')
                ) AS Apellido_Normalizado,
                -- DNI solo números
                REPLACE(REPLACE(LTRIM(RTRIM(DNI)), '.', ''), ' ', '') AS DNI_Normalizado,
                -- Email original para referencia
                LTRIM(RTRIM([email personal])) AS Email_Original,
                -- Teléfono solo números
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM([teléfono de contacto])), 
                    '+', ''), '-', ''), '(', ''), ')', ''), ' ', '') AS Telefono_Normalizado,
                -- CVU/CBU sin espacios
                REPLACE(LTRIM(RTRIM([CVU/CBU])), ' ', '') AS CVU_CBU_Normalizado,
                -- Inquilino normalizado a 1/0
                CASE 
                    WHEN LTRIM(RTRIM(Inquilino)) IN ('1','TRUE','SI','S','Yes') THEN '1'
                    ELSE '0'
                END AS Inquilino_Normalizado
            FROM dba.tmp_Personas
        )
        SELECT 
            Nombre_Normalizado AS Nombre,
            Apellido_Normalizado AS Apellido,
            DNI_Normalizado AS DNI,
            -- Email: eliminar TODOS los espacios
            LOWER(REPLACE(REPLACE(Email_Original, ' ', ''), '__', '_')) AS [email personal],
            Telefono_Normalizado AS [teléfono de contacto],
            CVU_CBU_Normalizado AS [CVU/CBU],
            Inquilino_Normalizado AS Inquilino
        FROM DatosNormalizados;
        
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: ' + ERROR_MESSAGE();
    END CATCH;
END
GO
EXEC dba.TestArchivo 'C:\Users\admin\OneDrive\Documentos\consorcios\Inquilino-propietarios-datos.csv';