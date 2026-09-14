-- =====================================================
-- Mindzyx - 02_seed_catalogos.sql
-- Llena SOLO catalogos (sin usuarios de prueba).
-- Es seguro re-ejecutarlo: usa NOT EXISTS.
-- Ejecutar despues de 01_create_tables_sqlserver.sql
-- USE Mindzyxs;
-- =====================================================

-- Roles
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE nombre='Paciente')
  INSERT INTO dbo.roles (nombre, descripcion) VALUES ('Paciente','Usuario que registra su estado emocional');
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE nombre='Psicologo')
  INSERT INTO dbo.roles (nombre, descripcion) VALUES ('Psicologo','Profesional que hace seguimiento');
IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE nombre='Administrador')
  INSERT INTO dbo.roles (nombre, descripcion) VALUES ('Administrador','Gestiona usuarios y BD');
GO

-- Generos
IF NOT EXISTS (SELECT 1 FROM dbo.generos WHERE nombre='Masculino') INSERT INTO dbo.generos (nombre) VALUES ('Masculino');
IF NOT EXISTS (SELECT 1 FROM dbo.generos WHERE nombre='Femenino') INSERT INTO dbo.generos (nombre) VALUES ('Femenino');
IF NOT EXISTS (SELECT 1 FROM dbo.generos WHERE nombre='Otro') INSERT INTO dbo.generos (nombre) VALUES ('Otro');
IF NOT EXISTS (SELECT 1 FROM dbo.generos WHERE nombre='Prefiero no decir') INSERT INTO dbo.generos (nombre) VALUES ('Prefiero no decir');
GO

-- Estados (una sola tabla para cuenta, aprobacion, autorizacion y evento)
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Activa') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Activa','Cuenta con acceso permitido');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Suspendida') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Suspendida','Bloqueada por admin');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Inactiva') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Inactiva','Sin acceso');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='PendienteVerificacion') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('PendienteVerificacion','Creada, falta codigo de correo');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='PendienteAprobacion') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('PendienteAprobacion','Psicologo esperando aprobacion admin');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Aprobado') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Aprobado','Psicologo aprobado');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Rechazado') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Rechazado','Psicologo rechazado');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Autorizado') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Autorizado','Psicologo autorizado por paciente');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Revocado') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Revocado','Acceso revocado');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Borrador') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Borrador','Cuestionario en borrador');
IF NOT EXISTS (SELECT 1 FROM dbo.estados WHERE nombre='Publicado') INSERT INTO dbo.estados (nombre, descripcion) VALUES ('Publicado','Cuestionario publicado');
GO

-- Tipos de evento
IF NOT EXISTS (SELECT 1 FROM dbo.tipos_evento WHERE nombre='RegistroEmocional') INSERT INTO dbo.tipos_evento (nombre, descripcion) VALUES ('RegistroEmocional','Escala 1-5 del paciente');
IF NOT EXISTS (SELECT 1 FROM dbo.tipos_evento WHERE nombre='Cuestionario') INSERT INTO dbo.tipos_evento (nombre, descripcion) VALUES ('Cuestionario','Respuesta a cuestionario');
GO

-- Niveles de riesgo
IF NOT EXISTS (SELECT 1 FROM dbo.niveles_riesgo WHERE nombre='Bajo') INSERT INTO dbo.niveles_riesgo (nombre, color, peso) VALUES ('Bajo','#1BBF6B',1);
IF NOT EXISTS (SELECT 1 FROM dbo.niveles_riesgo WHERE nombre='Medio') INSERT INTO dbo.niveles_riesgo (nombre, color, peso) VALUES ('Medio','#E8A347',2);
IF NOT EXISTS (SELECT 1 FROM dbo.niveles_riesgo WHERE nombre='Alto') INSERT INTO dbo.niveles_riesgo (nombre, color, peso) VALUES ('Alto','#E85D7A',3);
GO

-- Dias semana
IF NOT EXISTS (SELECT 1 FROM dbo.dias_semana WHERE nombre='Lunes') INSERT INTO dbo.dias_semana (nombre) VALUES ('Lunes');
IF NOT EXISTS (SELECT 1 FROM dbo.dias_semana WHERE nombre='Martes') INSERT INTO dbo.dias_semana (nombre) VALUES ('Martes');
IF NOT EXISTS (SELECT 1 FROM dbo.dias_semana WHERE nombre='Miercoles') INSERT INTO dbo.dias_semana (nombre) VALUES ('Miercoles');
IF NOT EXISTS (SELECT 1 FROM dbo.dias_semana WHERE nombre='Jueves') INSERT INTO dbo.dias_semana (nombre) VALUES ('Jueves');
IF NOT EXISTS (SELECT 1 FROM dbo.dias_semana WHERE nombre='Viernes') INSERT INTO dbo.dias_semana (nombre) VALUES ('Viernes');
IF NOT EXISTS (SELECT 1 FROM dbo.dias_semana WHERE nombre='Sabado') INSERT INTO dbo.dias_semana (nombre) VALUES ('Sabado');
IF NOT EXISTS (SELECT 1 FROM dbo.dias_semana WHERE nombre='Domingo') INSERT INTO dbo.dias_semana (nombre) VALUES ('Domingo');
GO

-- Especialidades / areas de especializacion (lista oficial del equipo)
INSERT INTO dbo.especialidades (nombre, descripcion)
SELECT v.nombre, v.descripcion
FROM (VALUES
  ('Psicologia clinica','Evaluacion, diagnostico y tratamiento de trastornos mentales'),
  ('Psicologia clinica infantil y adolescente','Atencion clinica en ninos y adolescentes'),
  ('Psicologia de la salud','Relacion entre procesos psicologicos y salud'),
  ('Neuropsicologia','Evaluacion y rehabilitacion de funciones cerebrales'),
  ('Neuropsicologia clinica','Aplicacion clinica de la neuropsicologia'),
  ('Psicologia educativa','Procesos de aprendizaje en contextos educativos'),
  ('Psicologia escolar','Acompanamiento psicologico dentro de las escuelas'),
  ('Psicologia organizacional','Comportamiento humano en organizaciones'),
  ('Psicologia laboral','Factores humanos en el ambito laboral'),
  ('Psicologia juridica','Psicologia aplicada al ambito del derecho'),
  ('Psicologia forense','Peritajes psicologicos en procesos judiciales'),
  ('Psicologia social','Influencia social en el comportamiento'),
  ('Psicologia comunitaria','Intervencion en comunidades y colectivos'),
  ('Psicologia de pareja','Evaluacion y terapia de las relaciones de pareja'),
  ('Psicologia familiar','Dinamica y terapia de las relaciones familiares'),
  ('Psicologia de grupos','Comportamiento dentro de grupos y equipos'),
  ('Psicologia cognitivo-conductual','Terapia basada en cogniciones y conductas'),
  ('Psicologia conductual','Analisis y modificacion de la conducta'),
  ('Psicologia cognitiva','Estudio de procesos como memoria, atencion y lenguaje'),
  ('Psicologia psicoanalitica','Enfoque basado en el psicoanalisis'),
  ('Psicologia psicodinamica','Enfoque basado en procesos inconscientes'),
  ('Psicologia gerontologica','Atencion psicologica al adulto mayor'),
  ('Psicologia de la rehabilitacion','Rehabilitacion de capacidades psicologicas y fisicas'),
  ('Psicologia del deporte','Factores mentales en la actividad deportiva'),
  ('Psicologia del ejercicio','Motivacion y adherencia al ejercicio fisico'),
  ('Psicologia militar','Apoyo psicologico en ambito militar'),
  ('Psicologia policial','Apoyo psicologico en ambito policial'),
  ('Psicologia de emergencias y desastres','Intervencion en situaciones de emergencia'),
  ('Psicologia de la adiccion','Tratamiento de conductas adictivas'),
  ('Psicologia de las adicciones','Tratamiento de conductas adictivas (sin. adiccion)'),
  ('Psicologia de la salud ocupacional','Salud y bienestar psicologico en el trabajo'),
  ('Psicologia ambiental','Relacion entre personas y su entorno fisico'),
  ('Psicologia del consumidor','Comportamiento y decision de compra'),
  ('Psicologia economica','Factores psicologicos en la economia'),
  ('Psicologia politica','Factores psicologicos en la politica'),
  ('Psicologia cultural','Cultura y procesos psicologicos'),
  ('Psicologia intercultural','Comparacion entre culturas'),
  ('Psicologia del desarrollo','Cambios psicologicos a lo largo de la vida'),
  ('Psicologia evolutiva','Desarrollo psicologico por etapas'),
  ('Psicologia experimental','Investigacion mediante experimentos'),
  ('Psicologia fisiologica','Base biologica de la conducta'),
  ('Psicologia comparada','Comparacion del comportamiento entre especies'),
  ('Psicologia de la personalidad','Estudio de la personalidad'),
  ('Psicologia de las diferencias individuales','Variacion de rasgos entre personas'),
  ('Psicologia positiva','Fortalezas, bienestar y felicidad'),
  ('Psicologia de la sexualidad','Comportamiento y salud sexual'),
  ('Psicologia de genero','Identidad, roles y temas de genero'),
  ('Psicologia de la familia','Dinamica y terapia familiar (sin. familiar)'),
  ('Psicologia infantil','Atencion psicologica en la ninez'),
  ('Psicologia adolescente','Atencion psicologica en la adolescencia'),
  ('Psicologia del adulto','Atencion psicologica en la adultez'),
  ('Psicologia del envejecimiento','Procesos psicologicos del envejecimiento'),
  ('Psicologia perinatal','Atencion psicologica antes y despues del parto'),
  ('Psicologia de la maternidad y paternidad','Apoyo psicologico en la crianza'),
  ('Psicologia de la reproduccion','Factores psicologicos en la reproduccion'),
  ('Psicologia de la salud mental','Promocion y cuidado de la salud mental'),
  ('Psicologia de crisis','Intervencion breve en crisis'),
  ('Psicologia del trauma','Tratamiento de experiencias traumaticas'),
  ('Psicologia de cuidados paliativos','Apoyo psicologico en etapas finales'),
  ('Psicologia hospitalaria','Atencion psicologica en hospitales'),
  ('Psicooncologia','Apoyo psicologico a pacientes con cancer'),
  ('Psicologia del dolor','Manejo psicologico del dolor cronico'),
  ('Psicologia cardiovascular','Factores psicologicos en salud cardiovascular'),
  ('Psicologia de la alimentacion','Comportamiento alimentario'),
  ('Psicologia de los trastornos alimentarios','Tratamiento de TCA'),
  ('Psicologia del sueno','Trastornos y habitos del sueno'),
  ('Psicologia del aprendizaje','Procesos de aprendizaje'),
  ('Psicologia de la memoria','Funcionamiento de la memoria'),
  ('Psicologia de la atencion','Procesos atencionales'),
  ('Psicologia del lenguaje','Procesos del lenguaje'),
  ('Psicologia de la percepcion','Procesos perceptivos'),
  ('Psicologia de las emociones','Emociones y su regulacion'),
  ('Psicologia de las relaciones interpersonales','Vincuulos y relaciones sociales'),
  ('Psicologia de la inteligencia','Estudio de la inteligencia'),
  ('Psicologia de la creatividad','Procesos creativos'),
  ('Psicologia del rendimiento','Optimizacion del rendimiento'),
  ('Psicologia del liderazgo','Liderazgo y habilidades directivas'),
  ('Psicologia de recursos humanos','Gestion del talento en organizaciones'),
  ('Psicologia de seleccion de personal','Procesos de reclutamiento y seleccion'),
  ('Psicologia de orientacion vocacional','Orientacion en la eleccion de estudios'),
  ('Psicologia de carrera','Desarrollo profesional y vocacional'),
  ('Psicologia educativa especial','Educacion de poblaciones especiales'),
  ('Psicologia de necesidades educativas especiales','Atencion a NEE'),
  ('Psicologia de la discapacidad','Atencion a personas con discapacidad'),
  ('Psicologia de la rehabilitacion cognitiva','Rehabilitacion de funciones cognitivas'),
  ('Psicologia penitenciaria','Atencion psicologica en prisiones'),
  ('Psicologia criminologica','Factores psicologicos del delito'),
  ('Psicologia victimologica','Atencion a victimas'),
  ('Psicologia de la violencia','Prevencion e intervencion en violencia'),
  ('Psicologia de la paz','Promocion de la paz y resolucion de conflictos'),
  ('Psicologia de derechos humanos','Psicologia aplicada a los DDHH'),
  ('Psicologia comunitaria de la salud','Salud comunitaria'),
  ('Psicologia ambiental urbana','Entorno urbano y comportamiento'),
  ('Psicologia del trafico y transporte','Seguridad y conducta vial'),
  ('Psicologia aeronautica','Factores humanos en aviacion'),
  ('Psicologia maritima','Factores humanos en el ambito maritimo'),
  ('Psicologia de la seguridad','Prevencion de riesgos y seguridad'),
  ('Psicologia de catastrofes y desastres','Intervencion en catastrofes'),
  ('Psicologia del rendimiento deportivo','Rendimiento mental en deporte'),
  ('Psicologia del deporte de alto rendimiento','Deportistas de alto nivel')
) AS v(nombre, descripcion)
WHERE NOT EXISTS (SELECT 1 FROM dbo.especialidades e WHERE e.nombre = v.nombre);
GO

-- Verificacion rapida
SELECT 'roles' AS tabla, COUNT(*) AS total FROM dbo.roles
UNION ALL SELECT 'generos', COUNT(*) FROM dbo.generos
UNION ALL SELECT 'especialidades', COUNT(*) FROM dbo.especialidades
UNION ALL SELECT 'estados', COUNT(*) FROM dbo.estados
UNION ALL SELECT 'tipos_evento', COUNT(*) FROM dbo.tipos_evento
UNION ALL SELECT 'niveles_riesgo', COUNT(*) FROM dbo.niveles_riesgo
UNION ALL SELECT 'dias_semana', COUNT(*) FROM dbo.dias_semana;
GO
