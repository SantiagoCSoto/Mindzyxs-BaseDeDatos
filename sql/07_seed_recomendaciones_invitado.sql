-- =====================================================
-- Mindzyx - 07_seed_recomendaciones_invitado.sql
-- Recomendaciones basicas por nivel de riesgo (PB-08 / PB-09).
-- Las lineas de ayuda reales las administra el admin (PB-29).
-- Re-ejecutable (guardas NOT EXISTS). Ejecutar despues de 01 y 02.
-- USE Mindzyxs;
-- =====================================================

IF NOT EXISTS (SELECT 1 FROM dbo.recomendaciones WHERE titulo = 'Puedes mejorar paso a paso')
INSERT INTO dbo.recomendaciones (titulo, contenido, nivel_riesgo)
VALUES ('Puedes mejorar paso a paso',
 'Esta bien no sentirse bien siempre: puedes mejorar paso a paso. Prueba una pausa consciente de 5 minutos, respira profundo y registra como te sientes manana. Si lo necesitas, revisa las demas recomendaciones basicas.',
 'Medio');

IF NOT EXISTS (SELECT 1 FROM dbo.recomendaciones WHERE titulo = 'Alerta: busca apoyo ahora')
INSERT INTO dbo.recomendaciones (titulo, contenido, nivel_riesgo)
VALUES ('Alerta: busca apoyo ahora',
 'En riesgo: consulta a las lineas de ayuda o a un profesional de la salud mental. No te quedes solo con esto: busca ayuda profesional o comunicate con una linea de ayuda de tu pais.',
 'Alto');

-- VERIFICACION
SELECT id_recomendacion, titulo, nivel_riesgo FROM dbo.recomendaciones ORDER BY id_recomendacion;
