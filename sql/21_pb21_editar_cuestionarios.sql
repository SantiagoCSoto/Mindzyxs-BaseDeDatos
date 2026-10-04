-- =====================================================
-- | Objeto  | 21_pb21_editar_cuestionarios.sql
-- | Fecha   | 2026-10-03
-- | Autor   | kscastrillon
-- | Cambio  | PB-21 HU1-PB21: editar/eliminar cuestionarios del
-- |         | psicologo (baja logica de preguntas y cuestionarios)
-- | Hace    | 1) Marca suave `eliminada` en dbo.preguntas: las respuestas
-- |         |    guardan el id de la pregunta por FK, asi que una pregunta
-- |         |    en uso nunca se borra fisicamente; al editar, las que ya no
-- |         |    vienen (o las de un cuestionario eliminado) quedan eliminadas.
-- |         | 2) Recrea sp_cuestionario_completo para NO devolver preguntas
-- |         |    eliminadas. Mantiene el MISMO orden de columnas que consume
-- |         |    el back: la columna `eliminada` va AL FINAL (no afecta los
-- |         |    indices del reader). Ejecutar despues del 11 (lo reemplaza).
-- | Afecta  | DDL + SP: dbo.preguntas, dbo.sp_cuestionario_completo
-- =====================================================

IF COL_LENGTH('dbo.preguntas', 'eliminada') IS NULL
  ALTER TABLE dbo.preguntas ADD eliminada BIT NOT NULL
    CONSTRAINT DF_preguntas_eliminada DEFAULT(0);
GO

CREATE OR ALTER PROCEDURE dbo.sp_cuestionario_completo @id INT
AS
BEGIN
  SET NOCOUNT ON;

  -- set 1: cuestionario (el back ya lo validó con Find; se omite).
  SELECT * FROM dbo.cuestionarios WHERE id_cuestionario = @id;

  -- set 2: preguntas activas (eliminada = 0).
  SELECT p.id_pregunta, p.id_cuestionario, p.texto, p.orden, p.tipo, p.puntaje_max, p.eliminada
  FROM dbo.preguntas p
  WHERE p.id_cuestionario = @id AND p.eliminada = 0
  ORDER BY p.orden;

  -- set 3: opciones de las preguntas activas (las opciones se reconstruyen al editar).
  SELECT o.id_opcion, o.id_pregunta, o.texto, o.valor, o.orden
  FROM dbo.opciones_pregunta o
  JOIN dbo.preguntas p ON p.id_pregunta = o.id_pregunta AND p.eliminada = 0
  WHERE p.id_cuestionario = @id
  ORDER BY o.orden;
END
GO