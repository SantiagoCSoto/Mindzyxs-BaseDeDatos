-- =====================================================
-- | Objeto  | 17_recordatorios_frecuencia.sql
-- | Fecha   | 2026-09-26
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Agrega frecuencia (Diaria/Semanal) a recordatorios.
-- |         | Diaria = implicita todos los dias (sin filas en
-- |         | recordatorio_dias); Semanal usa los dias elegidos
-- | Afecta  | DDL: dbo.recordatorios
-- =====================================================
-- USE Mindzyxs;
-- GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.recordatorios') AND name = 'frecuencia')
    ALTER TABLE dbo.recordatorios ADD frecuencia VARCHAR(20) NOT NULL DEFAULT 'Diaria';
GO

-- VERIFICACION
SELECT c.name AS columna, t.name AS tipo
FROM sys.columns c JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.recordatorios') ORDER BY c.column_id;
