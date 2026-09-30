-- =====================================================
-- | Objeto  | 19_chat_doblevia_bloqueo.sql
-- | Fecha   | 2026-09-30
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Solicitud doble vía + bloqueo pendiente en chats:
-- |         | - id_solicitante (quién pidió el chat; legacy = psicólogo)
-- |         | - motivo_bloqueo (motivo del paciente al solicitar bloqueo)
-- |         | - estado BloqueoPendiente en el CHECK
-- | Afecta  | DDL: dbo.conversaciones
-- =====================================================
-- USE Mindzyxs;
-- GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.conversaciones') AND name = 'id_solicitante')
    ALTER TABLE dbo.conversaciones ADD id_solicitante INT NULL REFERENCES dbo.usuarios(id_usuario);
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.conversaciones') AND name = 'motivo_bloqueo')
    ALTER TABLE dbo.conversaciones ADD motivo_bloqueo VARCHAR(500) NULL;
GO

-- Legacy: las solicitudes existentes las hizo el psicólogo.
UPDATE dbo.conversaciones SET id_solicitante = id_psicologo WHERE id_solicitante IS NULL;
GO

-- Ampliar el CHECK de estado (nombre autogenerado: se resuelve dinámico).
DECLARE @ck SYSNAME = (
    SELECT TOP 1 cc.name
    FROM sys.check_constraints cc
    JOIN sys.tables t ON t.object_id = cc.parent_object_id
    WHERE t.name = 'conversaciones' AND cc.definition LIKE '%Pendiente%'
);
IF @ck IS NOT NULL
    EXEC('ALTER TABLE dbo.conversaciones DROP CONSTRAINT [' + @ck + ']');
GO

ALTER TABLE dbo.conversaciones
    ADD CONSTRAINT CK_conversaciones_estado
    CHECK (estado IN ('Pendiente','Aceptada','Rechazada','Bloqueada','Cerrada','BloqueoPendiente'));
GO

-- VERIFICACION
SELECT c.name AS columna, t.name AS tipo
FROM sys.columns c JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.conversaciones') AND c.name IN ('id_solicitante','motivo_bloqueo');
SELECT name, definition FROM sys.check_constraints WHERE parent_object_id = OBJECT_ID('dbo.conversaciones');
