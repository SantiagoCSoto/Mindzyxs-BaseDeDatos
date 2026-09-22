-- =====================================================
-- | Objeto  | 14_directorio_lineas.sql
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Extiende lineas_ayuda al modelo de directorio: canales
-- |         | (whatsapp/email/chat/videollamada), tipo_de_atencion,
-- |         | territorio, fuente oficial y fecha de verificacion.
-- |         | Siembra nacionales + territoriales (base: Directorio
-- |         | Nacional Minsalud ago-2025) y enriquece 106/123
-- | Afecta  | DDL + seed: dbo.lineas_ayuda
-- =====================================================
-- USE Mindzyxs;
-- GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'whatsapp')
    ALTER TABLE dbo.lineas_ayuda ADD whatsapp VARCHAR(30) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'email')
    ALTER TABLE dbo.lineas_ayuda ADD email VARCHAR(150) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'chat_url')
    ALTER TABLE dbo.lineas_ayuda ADD chat_url VARCHAR(255) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'videollamada')
    ALTER TABLE dbo.lineas_ayuda ADD videollamada VARCHAR(255) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'tipo_atencion')
    ALTER TABLE dbo.lineas_ayuda ADD tipo_atencion VARCHAR(40) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'departamento')
    ALTER TABLE dbo.lineas_ayuda ADD departamento VARCHAR(60) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'municipio')
    ALTER TABLE dbo.lineas_ayuda ADD municipio VARCHAR(60) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'poblacion')
    ALTER TABLE dbo.lineas_ayuda ADD poblacion VARCHAR(100) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'fuente')
    ALTER TABLE dbo.lineas_ayuda ADD fuente VARCHAR(255) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.lineas_ayuda') AND name = 'fecha_verificacion')
    ALTER TABLE dbo.lineas_ayuda ADD fecha_verificacion DATE NULL;
GO

-- Enriquecer 106 y 123 existentes
UPDATE dbo.lineas_ayuda
SET videollamada = 'Agendamiento oficial Minsalud',
    tipo_atencion = 'apoyo_emocional',
    horario = '24 horas', cobertura = 'Colombia',
    descripcion = 'Teleorientacion en salud mental: escucha, contencion, primeros auxilios psicologicos e intervencion en crisis.',
    fuente = 'Directorio Nacional Minsalud (ago-2025)',
    fecha_verificacion = '2025-08-01'
WHERE nombre = 'Linea 106';

UPDATE dbo.lineas_ayuda
SET tipo_atencion = 'emergencia',
    descripcion = 'Emergencias. No es linea de terapia: derivacion inmediata.',
    fuente = 'Directorio Nacional Minsalud (ago-2025)',
    fecha_verificacion = '2025-08-01'
WHERE nombre = 'Linea 123';

-- 192: de apoyo puntual a orientacion en salud mental
UPDATE dbo.lineas_ayuda
SET nombre = 'Linea 192 (orientacion salud mental)',
    tipo_atencion = 'orientacion_institucional',
    fuente = 'Directorio Nacional Minsalud (ago-2025)',
    fecha_verificacion = '2025-08-01'
WHERE nombre IN ('Linea 192', 'Linea 192 (orientacion salud mental)') AND fuente IS NULL;

-- Seed: usar INSERT con guarda NOT EXISTS por (nombre, municipio)
-- Nacionales
IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea 155')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, poblacion, fuente, fecha_verificacion)
VALUES ('Linea 155', '155', '24 horas', 'Colombia', 'Activa',
 'Violencias basadas en genero: orientacion y primeros auxilios psicologicos.',
 'violencia_genero', 'Victimas de violencia de genero', 'Policia Nacional de Colombia', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'ICBF 141')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, poblacion, fuente, fecha_verificacion)
VALUES ('ICBF 141', '141', '24 horas', 'Colombia', 'Activa',
 'Proteccion a ninos, ninas y adolescentes: maltrato, violencia sexual, acoso escolar. Atienden psicologos, trabajadores sociales y abogados.',
 'infancia_adolescencia', 'NNA y reportantes', 'ICBF', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'ICBF 018000')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, fuente, fecha_verificacion)
VALUES ('ICBF 018000', '01 8000 91 80 80', NULL, 'Colombia', 'Activa',
 'Orientacion institucional ICBF.', 'orientacion_institucional', 'ICBF', '2025-08-01');

-- Bogota
IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea 106 Bogota (WhatsApp)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, municipio, fuente, fecha_verificacion)
VALUES ('Linea 106 Bogota (WhatsApp)', '106', '300 754 8933', '24 horas', 'Bogota D.C.', 'Activa',
 'Linea 106 de Bogota con WhatsApp y correo linea106@saludcapital.gov.co.',
 'apoyo_emocional', 'Bogota D.C.', 'Bogota D.C.', 'Secretaria Distrital de Salud', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Purpura')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, whatsapp, email, horario, cobertura, estado, descripcion, tipo_atencion, departamento, municipio, fuente, fecha_verificacion)
VALUES ('Linea Purpura', '018000 112 137', '300 755 1846', 'lpurpura@sdmujer.gov.co', '24 horas', 'Bogota D.C.', 'Activa',
 'Atencion a mujeres: orientacion y primeros auxilios psicologicos.',
 'violencia_genero', 'Bogota D.C.', 'Bogota D.C.', 'Secretaria Distrital de la Mujer', '2025-08-01');

-- Territoriales destacadas
IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Salud para el Alma (Antioquia)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('Salud para el Alma (Antioquia)', '604 540 7180', '24 horas', 'Antioquia', 'Activa',
 'Linea departamental de salud mental.', 'apoyo_emocional', 'Antioquia', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Amiga Medellin 106')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, departamento, municipio, fuente, fecha_verificacion)
VALUES ('Linea Amiga Medellin 106', '604 444 4448', '24 horas', 'Medellin', 'Activa',
 'Linea Amiga Saludable / 106 de Medellin.', 'apoyo_emocional', 'Antioquia', 'Medellin', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Charlemos (Atlantico)')
INSERT INTO dbo.lineas_ayuda (nombre, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('Linea Charlemos (Atlantico)', '318 804 4000', '24 horas', 'Atlantico', 'Activa',
 'Linea Charlemos por WhatsApp.', 'apoyo_emocional', 'Atlantico', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea de la Vida (Barranquilla)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, departamento, municipio, fuente, fecha_verificacion)
VALUES ('Linea de la Vida (Barranquilla)', '605 339 9999', '24 horas', 'Barranquilla', 'Activa',
 'Linea de la Vida de Barranquilla.', 'intervencion_crisis', 'Atlantico', 'Barranquilla', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea de la Esperanza (Zipaquira)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, departamento, municipio, fuente, fecha_verificacion)
VALUES ('Linea de la Esperanza (Zipaquira)', '322 814 2684', 'Lunes a viernes, 24 h', 'Zipaquira', 'Activa',
 'Linea de la Esperanza de Zipaquira.', 'apoyo_emocional', 'Cundinamarca', 'Zipaquira', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea de Escucha (Cota)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, departamento, municipio, fuente, fecha_verificacion)
VALUES ('Linea de Escucha (Cota)', '315 564 0149', '24 horas', 'Cota', 'Activa',
 'Linea de Escucha de Cota.', 'apoyo_emocional', 'Cundinamarca', 'Cota', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'GLIA (Narino)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('GLIA (Narino)', '317 805 4329', '317 805 4329', '24 horas', 'Narino', 'Activa',
 'Plataforma Integral de Atencion en Salud Mental GLIA: llamada + WhatsApp.',
 'apoyo_emocional', 'Narino', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Amiga (Risaralda)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('Linea Amiga (Risaralda)', '606 333 9610', '315 560 8849', '24 horas', 'Risaralda', 'Activa',
 'Linea Amiga de Risaralda (tambien 106 y 018000 949999).', 'apoyo_emocional', 'Risaralda', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Naranja Yo Te Escucho (Tolima)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('Linea Naranja Yo Te Escucho (Tolima)', '318 607 2341', '318 607 2341', '24 horas', 'Tolima', 'Activa',
 'Linea Naranja Yo Te Escucho: llamada + WhatsApp.', 'apoyo_emocional', 'Tolima', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea 106 Valle (WhatsApp)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('Linea 106 Valle (WhatsApp)', '106', '316 245 8423', '24 horas', 'Valle del Cauca', 'Activa',
 'Linea 106 departamental del Valle con WhatsApp.', 'apoyo_emocional', 'Valle del Cauca', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Amiga (Meta)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('Linea Amiga (Meta)', '312 575 1135', '312 575 1135', '24 horas', 'Meta', 'Activa',
 'Linea Amiga del Meta (tambien #775).', 'apoyo_emocional', 'Meta', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Vital (Cesar)')
INSERT INTO dbo.lineas_ayuda (nombre, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('Linea Vital (Cesar)', '310 566 8234', '24 horas', 'Cesar', 'Activa',
 'Linea Vital por WhatsApp.', 'intervencion_crisis', 'Cesar', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Esperame (Bucaramanga)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, horario, cobertura, estado, descripcion, tipo_atencion, departamento, municipio, fuente, fecha_verificacion)
VALUES ('Linea Esperame (Bucaramanga)', '322 964 3755', '24 horas', 'Bucaramanga', 'Activa',
 'Linea Esperame de Bucaramanga.', 'intervencion_crisis', 'Santander', 'Bucaramanga', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre = 'Linea Departamental (Sucre)')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, whatsapp, horario, cobertura, estado, descripcion, tipo_atencion, departamento, fuente, fecha_verificacion)
VALUES ('Linea Departamental (Sucre)', '310 636 3779', '310 636 3779', '24 horas', 'Sucre', 'Activa',
 'Linea Departamental de Salud Mental: telefono + WhatsApp.', 'apoyo_emocional', 'Sucre', 'Directorio Nacional Minsalud (ago-2025)', '2025-08-01');

-- VERIFICACION
SELECT COUNT(*) AS activas FROM dbo.lineas_ayuda WHERE estado = 'Activa';
SELECT nombre, telefono, whatsapp, tipo_atencion, departamento, fuente FROM dbo.lineas_ayuda WHERE estado = 'Activa' ORDER BY id_linea;
