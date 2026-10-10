-- ============================================================
-- Mindzyxs-BD · Script 25 — verificación de especialidades
-- El psicólogo cambia/agrega especialidades: las nuevas quedan ocultas
-- (verificada = 0) hasta que el admin verifique la nueva tarjeta.
-- El psicólogo NO pierde acceso: solo se restringe la visibilidad.
-- Existentes = verificadas (1). Idempotente.
-- ============================================================

IF COL_LENGTH('dbo.psicologo_especialidades', 'verificada') IS NULL
BEGIN
    ALTER TABLE dbo.psicologo_especialidades
        ADD verificada BIT NOT NULL DEFAULT 1;
END
GO
