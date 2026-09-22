-- =====================================================
-- | Objeto  | 13_lineas_ayuda_reales.sql
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Siembra lineas de ayuda reales de Colombia y desactiva
-- |         | la fila de prueba. Las administra el admin (PB-29)
-- | Afecta  | dbo.lineas_ayuda
-- =====================================================
-- USE Mindzyxs;
-- GO

UPDATE dbo.lineas_ayuda SET estado = 'Inactiva' WHERE nombre = 'Linea Prueba 123';

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea 106')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, url, horario, cobertura, estado, descripcion)
VALUES ('Linea 106', '106', NULL, '24 horas', 'Colombia',
 'Activa', 'Ayuda psicologica y crisis emocional, gratuita, 24 horas.');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea 192')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, url, horario, cobertura, estado, descripcion)
VALUES ('Linea 192', '192', NULL, '24 horas', 'Colombia',
 'Activa', 'Orientacion en salud mental y apoyo psicosocial.');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea 123')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, url, horario, cobertura, estado, descripcion)
VALUES ('Linea 123', '123', NULL, '24 horas', 'Colombia',
 'Activa', 'Emergencias y urgencias generales.');

-- VERIFICACION
SELECT id_linea, nombre, telefono, horario, estado FROM dbo.lineas_ayuda ORDER BY id_linea;
