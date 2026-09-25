-- =====================================================
-- | Objeto  | 15_chat_conversaciones.sql
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Ciclo de vida del chat (PB-31): solicitudes, aceptacion,
-- |         | rechazo y bloqueo en SQL. Los mensajes en vivo van por
-- |         | Firebase RTDB; el back escribe el meta via Admin SDK
-- | Afecta  | DDL: dbo.conversaciones (+ indice unico filtrado)
-- =====================================================
-- USE Mindzyxs;
-- GO

-- Requerido por el índice único filtrado:
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.conversaciones'))
BEGIN
    CREATE TABLE dbo.conversaciones (
        id_conversacion INT IDENTITY(1,1) PRIMARY KEY,
        id_paciente INT NOT NULL REFERENCES dbo.usuarios(id_usuario),
        id_psicologo INT NOT NULL REFERENCES dbo.usuarios(id_usuario),
        estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
            CHECK (estado IN ('Pendiente','Aceptada','Rechazada','Bloqueada','Cerrada')),
        id_bloqueador INT NULL REFERENCES dbo.usuarios(id_usuario),
        fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        fecha_respuesta DATETIME2 NULL,
        -- Una conversacion por pareja: si fue Rechazada/Cerrada se REACTIVA
        -- (UPDATE a Pendiente) en vez de insertar duplicado. UNIQUE simple a
        -- proposito: los indices computados/filtrados exigen QUOTED_IDENTIFIER
        -- ON y fallan en SSMS/sqlcmd con defaults (error 1934).
        CONSTRAINT UQ_conv_pareja UNIQUE (id_paciente, id_psicologo)
    );
    PRINT 'Tabla dbo.conversaciones creada.';
END
ELSE
BEGIN
    PRINT 'dbo.conversaciones ya existe.';
END
GO

-- VERIFICACION
SELECT c.name AS columna, t.name AS tipo
FROM sys.columns c JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.conversaciones') ORDER BY c.column_id;
