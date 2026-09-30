-- ============================================================
-- Mindzyxs-BD · Script 20 — PB-20: riesgo configurable por cuestionario
-- El psicólogo define intervalos Alto/Medio/Bajo sobre la SUMA de valores.
-- NULL en las 3 columnas = regla actual (promedio 1-2 Bajo, 3 Medio, 4-5 Alto).
-- Todo NULL-able: no rompe cuestionarios existentes ni seeds.
-- ============================================================

IF COL_LENGTH('dbo.cuestionarios', 'modo_calculo') IS NULL
BEGIN
    ALTER TABLE dbo.cuestionarios
        ADD modo_calculo VARCHAR(20) NULL; -- 'suma' = rangos propios; otro/NULL = promedio actual
END
GO

IF COL_LENGTH('dbo.cuestionarios', 'umbral_bajo_max') IS NULL
BEGIN
    ALTER TABLE dbo.cuestionarios
        ADD umbral_bajo_max INT NULL; -- puntaje máximo considerado Bajo
END
GO

IF COL_LENGTH('dbo.cuestionarios', 'umbral_medio_max') IS NULL
BEGIN
    ALTER TABLE dbo.cuestionarios
        ADD umbral_medio_max INT NULL; -- puntaje máximo considerado Medio (más = Alto)
END
GO
