-- =====================================================
-- Mindzyx - 06_seed_cuestionarios_invitado.sql
-- Cuestionarios Predeterminados/Publicados para invitados (PB-07)
-- y pacientes registrados (PB-11). Escala 1-4:
--   Nunca=1, A veces=2, A menudo=3, Casi siempre=4
-- Puntaje = promedio de respuestas tipo 'escala' (redondeado):
--   1-2 bajo, 3 medio, 4-5 alto. Preguntas tipo 'binaria'
--   (ej. q4 Si/No) son obligatorias pero NO entran al promedio.
-- Todas las preguntas son siempre obligatorias (HU1-PB7).
-- Re-ejecutable (guardas NOT EXISTS / rangos). Ejecutar despues de 01 y 02.
-- USE Mindzyxs;
-- =====================================================

DECLARE @admin INT = (SELECT id_usuario FROM dbo.usuarios WHERE correo='admin@test.com');

-- PASO 1: reescalar cuestionario 1 (prueba) de 0-3 a 1-4.
UPDATE dbo.opciones_pregunta SET valor = valor + 1
WHERE id_pregunta IN (SELECT id_pregunta FROM dbo.preguntas WHERE id_cuestionario = 1)
  AND valor BETWEEN 0 AND 3;

UPDATE dbo.preguntas SET puntaje_max = 4
WHERE id_cuestionario = 1 AND puntaje_max = 3;

-- PASO 2: cuestionario A - bienestar emocional (6 preguntas del mockup HU1-PB7).
DECLARE @cA INT;
IF NOT EXISTS (SELECT 1 FROM dbo.cuestionarios WHERE titulo = 'Cuestionario de bienestar emocional')
BEGIN
    INSERT INTO dbo.cuestionarios (titulo, descripcion, tipo, estado, id_creador, fecha_creacion)
    VALUES ('Cuestionario de bienestar emocional',
     'Cuestionario de invitados y pacientes para el monitoreo del bienestar emocional. No realiza diagnosticos clinicos.',
     'Predeterminado', 'Publicado', @admin, SYSDATETIME());
    SET @cA = SCOPE_IDENTITY();

    INSERT INTO dbo.preguntas (id_cuestionario, texto, orden, tipo, puntaje_max) VALUES
     (@cA, 'Con que frecuencia te has sentido triste o desanimado en las ultimas dos semanas?', 1, 'escala', 4),
     (@cA, 'Has tenido dificultades para dormir o te has sentido cansado(a)?', 2, 'escala', 4),
     (@cA, 'Te ha costado concentrarte o tomar decisiones?', 3, 'escala', 4),
     (@cA, 'Deseas recibir recomendaciones basicas al finalizar?', 4, 'binaria', NULL),
     (@cA, 'Has sentido ansiedad o nerviosismo sin razon aparente?', 5, 'escala', 4),
     (@cA, 'Has perdido interes o placer en actividades que antes disfrutabas?', 6, 'escala', 4);

    INSERT INTO dbo.opciones_pregunta (id_pregunta, texto, valor, orden)
    SELECT p.id_pregunta, o.t, o.v, o.v
    FROM dbo.preguntas p
    CROSS JOIN (VALUES ('Nunca',1),('A veces',2),('A menudo',3),('Casi siempre',4)) o(t,v)
    WHERE p.id_cuestionario = @cA AND p.tipo = 'escala';

    INSERT INTO dbo.opciones_pregunta (id_pregunta, texto, valor, orden)
    SELECT p.id_pregunta, o.t, o.v, o.v
    FROM dbo.preguntas p
    CROSS JOIN (VALUES ('Si',0),('No',0)) o(t,v)
    WHERE p.id_cuestionario = @cA AND p.tipo = 'binaria';
END

-- PASO 3: cuestionario B - chequeo breve de animo (4 preguntas escala).
DECLARE @cB INT;
IF NOT EXISTS (SELECT 1 FROM dbo.cuestionarios WHERE titulo = 'Chequeo breve de animo')
BEGIN
    INSERT INTO dbo.cuestionarios (titulo, descripcion, tipo, estado, id_creador, fecha_creacion)
    VALUES ('Chequeo breve de animo',
     'Cuestionario corto de invitados y pacientes para el monitoreo del animo diario. No realiza diagnosticos clinicos.',
     'Predeterminado', 'Publicado', @admin, SYSDATETIME());
    SET @cB = SCOPE_IDENTITY();

    INSERT INTO dbo.preguntas (id_cuestionario, texto, orden, tipo, puntaje_max) VALUES
     (@cB, 'Te has sentido irritable o de mal humor sin un motivo claro?', 1, 'escala', 4),
     (@cB, 'Has tenido preocupaciones o pensamientos repetitivos dificiles de controlar?', 2, 'escala', 4),
     (@cB, 'Te has sentido con poca energia para tus actividades diarias?', 3, 'escala', 4),
     (@cB, 'Has notado cambios en tu apetito (comer mucho mas o mucho menos)?', 4, 'escala', 4);

    INSERT INTO dbo.opciones_pregunta (id_pregunta, texto, valor, orden)
    SELECT p.id_pregunta, o.t, o.v, o.v
    FROM dbo.preguntas p
    CROSS JOIN (VALUES ('Nunca',1),('A veces',2),('A menudo',3),('Casi siempre',4)) o(t,v)
    WHERE p.id_cuestionario = @cB;
END

-- VERIFICACION
PRINT '--- CUESTIONARIOS ---';
SELECT c.id_cuestionario, c.titulo, c.tipo, c.estado,
 (SELECT COUNT(*) FROM dbo.preguntas p WHERE p.id_cuestionario = c.id_cuestionario) AS preguntas
FROM dbo.cuestionarios c ORDER BY c.id_cuestionario;

PRINT '--- PREGUNTAS + OPCIONES ---';
SELECT p.id_pregunta, p.id_cuestionario, p.orden, p.tipo,
 COUNT(o.id_opcion) AS opciones, MIN(o.valor) AS vmin, MAX(o.valor) AS vmax
FROM dbo.preguntas p JOIN dbo.opciones_pregunta o ON o.id_pregunta = p.id_pregunta
GROUP BY p.id_pregunta, p.id_cuestionario, p.orden, p.tipo
ORDER BY p.id_cuestionario, p.orden;
