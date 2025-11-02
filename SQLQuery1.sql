CREATE DATABASE ConsoricioAiresDeSaintJust
go

use ConsoricioAiresDeSaintJust
go

create schema cons
go

CREATE TABLE cons.Personas_Inquilinos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    DNI BIGINT,
    EmailPersonal NVARCHAR(150),
    TelefonoContacto NVARCHAR(50),
    CVU_CBU NVARCHAR(30),
    EsInquilino BIT
);
go

BULK INSERT cons.Personas_Inquilinos
FROM 'C:\Users\admin\OneDrive\Desktop\consorcios\Inquilino-propietarios-datos.csv'
WITH (
    FIELDTERMINATOR = ',',     -- separador
    ROWTERMINATOR = '\n',      -- fin de línea
    FIRSTROW = 2,              -- salta encabezado
    CODEPAGE = 'ACP'          -- compatible con español Windows
);
go

select * from cons.Personas_Inquilinos
go