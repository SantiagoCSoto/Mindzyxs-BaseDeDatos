-- =====================================================
-- | Objeto  | 16_historial_nota.sql
-- | Fecha   | 2026-09-26
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Agrega nota (descripcion propia de como se sintio) a
-- |         | eventos_bienestar (igual que el proyecto original, maximo
-- |         | 200 palabras validado en back) + seed demo para PB-13/14
-- | Afecta  | DDL + seed: dbo.eventos_bienestar, dbo.respuestas,
-- |         | dbo.observaciones
-- =====================================================
-- USE Mindzyxs;
-- GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.eventos_bienestar') AND name = 'nota')
    ALTER TABLE dbo.eventos_bienestar ADD nota VARCHAR(MAX) NULL;
GO

-- Seed demo: cuestionario finalizado de paciente 6 (id_usuario=6 debe existir)
DECLARE @ev1 INT;
IF NOT EXISTS (SELECT 1 FROM dbo.eventos_bienestar WHERE id_paciente = 6 AND id_tipo_evento = 2)
BEGIN
    INSERT INTO dbo.eventos_bienestar (id_paciente, id_tipo_evento, id_cuestionario, id_nivel_riesgo, fecha_evento, puntaje_total, nota)
    VALUES (6, 2, 2, 2, DATEADD(DAY, -2, SYSDATETIME()), 3, 'Me he sentido con poca energia estos dias, pero dormir mejor me ayudaria.');
    SET @ev1 = SCOPE_IDENTITY();
    INSERT INTO dbo.respuestas (id_evento, id_pregunta, valor, fecha_respuesta)
    VALUES (@ev1, 4, 3, SYSDATETIME()), (@ev1, 5, 3, SYSDATETIME()), (@ev1, 6, 2, SYSDATETIME()),
           (@ev1, 8, 4, SYSDATETIME()), (@ev1, 9, 2, SYSDATETIME());
    -- Apoyo del psicologo 9 sobre ese evento
    IF NOT EXISTS (SELECT 1 FROM dbo.observaciones WHERE id_evento = @ev1)
    INSERT INTO dbo.observaciones (id_psicologo, id_paciente, id_evento, contenido, firma, fecha_observacion)
    VALUES (9, 6, @ev1, 'Que bonito ver que identificas lo que sientes. Sigue registrando tu animo cada dia.', 'Psic. Prueba', SYSDATETIME());
END

-- Seed demo: registro emocional escala (tipo 1) de paciente 6
IF NOT EXISTS (SELECT 1 FROM dbo.eventos_bienestar WHERE id_paciente = 6 AND id_tipo_evento = 1)
BEGIN
    INSERT INTO dbo.eventos_bienestar (id_paciente, id_tipo_evento, fecha_evento, puntaje_total, nota)
    VALUES (6, 1, DATEADD(DAY, -1, SYSDATETIME()), 2, 'Dia tranquilo en general.');
END
GO

-- VERIFICACION
SELECT e.id_evento, e.id_tipo_evento, e.puntaje_total, e.nota,
 (SELECT COUNT(*) FROM dbo.respuestas r WHERE r.id_evento = e.id_evento) AS respuestas,
 (SELECT COUNT(*) FROM dbo.observaciones o WHERE o.id_evento = e.id_evento) AS observaciones
FROM dbo.eventos_bienestar e WHERE e.id_paciente = 6 ORDER BY e.fecha_evento DESC;
