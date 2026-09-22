-- =====================================================
-- Mindzyx - 03_seed_datos_prueba.sql
-- Datos FALSOS de prueba para que todos los PCs prueben lo mismo.
-- NO usar correos reales. Password = placeholder con formato PBKDF2 valido
-- (TR_usuarios_PasswordSeguro exige formato v1$...; este hash NO corresponde
-- a ninguna clave real, esos usuarios no pueden iniciar sesion).
-- Ejecutar despues de 01 y 02. Se puede re-ejecutar (usa NOT EXISTS por correo).
-- USE Mindzyxs;
-- =====================================================

DECLARE @rolPaciente INT = (SELECT id_rol FROM dbo.roles WHERE nombre='Paciente');
DECLARE @rolPsicologo INT = (SELECT id_rol FROM dbo.roles WHERE nombre='Psicologo');
DECLARE @rolAdmin INT = (SELECT id_rol FROM dbo.roles WHERE nombre='Administrador');
DECLARE @estActiva INT = (SELECT id_estado FROM dbo.estados WHERE nombre='Activa');
DECLARE @estPendVerif INT = (SELECT id_estado FROM dbo.estados WHERE nombre='PendienteVerificacion');
DECLARE @estPendAprob INT = (SELECT id_estado FROM dbo.estados WHERE nombre='PendienteAprobacion');
DECLARE @genF INT = (SELECT id_genero FROM dbo.generos WHERE nombre='Femenino');
DECLARE @genM INT = (SELECT id_genero FROM dbo.generos WHERE nombre='Masculino');

-- 1 admin
IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE correo='admin@test.com')
INSERT INTO dbo.usuarios (nombre, apellido, correo, password_hash, fecha_nacimiento, id_rol, id_estado_cuenta, id_genero, fecha_registro)
VALUES ('Admin','Prueba','admin@test.com','v1$210000$AAAAAAAAAAAAAAAAAAAAAA$BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB','1990-01-01',@rolAdmin,@estActiva,@genM,SYSDATETIME());

-- 2 pacientes
IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE correo='paciente@test.com')
INSERT INTO dbo.usuarios (nombre, apellido, correo, password_hash, fecha_nacimiento, id_rol, id_estado_cuenta, id_genero, fecha_registro)
VALUES ('Camila','Rojas','paciente@test.com','v1$210000$AAAAAAAAAAAAAAAAAAAAAA$BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB','2002-05-10',@rolPaciente,@estActiva,@genF,SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE correo='paciente2@test.com')
INSERT INTO dbo.usuarios (nombre, apellido, correo, password_hash, fecha_nacimiento, id_rol, id_estado_cuenta, id_genero, fecha_registro)
VALUES ('Juan','Perez','paciente2@test.com','v1$210000$AAAAAAAAAAAAAAAAAAAAAA$BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB','2001-03-15',@rolPaciente,@estPendVerif,@genM,SYSDATETIME());

-- 2 psicologos (1 activo, 1 pendiente aprobacion)
IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE correo='psicologo@test.com')
INSERT INTO dbo.usuarios (nombre, apellido, correo, password_hash, fecha_nacimiento, id_rol, id_estado_cuenta, id_estado_aprobacion, id_genero, fecha_registro)
VALUES ('Laura','Gomez','psicologo@test.com','v1$210000$AAAAAAAAAAAAAAAAAAAAAA$BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB','1988-07-20',@rolPsicologo,@estActiva,(SELECT id_estado FROM dbo.estados WHERE nombre='Aprobado'),@genF,SYSDATETIME());

IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE correo='psicologo.pendiente@test.com')
INSERT INTO dbo.usuarios (nombre, apellido, correo, password_hash, fecha_nacimiento, id_rol, id_estado_cuenta, id_estado_aprobacion, id_genero, file_path, fecha_registro)
VALUES ('Pedro','Lopez','psicologo.pendiente@test.com','v1$210000$AAAAAAAAAAAAAAAAAAAAAA$BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB','1992-11-05',@rolPsicologo,@estPendAprob,@estPendAprob,@genM,'C:\uploads\tarjeta_pedro.pdf',SYSDATETIME());
GO

-- Codigo de verificacion de prueba (123456, expira en 15 min)
DECLARE @idPaciente2 INT = (SELECT id_usuario FROM dbo.usuarios WHERE correo='paciente2@test.com');
IF @idPaciente2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.codigos_verificacion WHERE id_usuario=@idPaciente2 AND codigo='123456')
INSERT INTO dbo.codigos_verificacion (id_usuario, codigo, tipo, expira_en, creado_en)
VALUES (@idPaciente2,'123456','Registro',DATEADD(MINUTE,15,SYSDATETIME()),SYSDATETIME());
GO

-- Cuestionario predeterminado de prueba (creado por admin)
DECLARE @idAdmin INT = (SELECT id_usuario FROM dbo.usuarios WHERE correo='admin@test.com');
IF @idAdmin IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.cuestionarios WHERE titulo='Cuestionario Base Prueba')
BEGIN
  INSERT INTO dbo.cuestionarios (titulo, descripcion, tipo, estado, id_creador, fecha_creacion)
  VALUES ('Cuestionario Base Prueba','3 preguntas de prueba','Predeterminado','Publicado',@idAdmin,SYSDATETIME());
END
GO

DECLARE @idCuest INT = (SELECT TOP 1 id_cuestionario FROM dbo.cuestionarios WHERE titulo='Cuestionario Base Prueba' ORDER BY id_cuestionario DESC);
-- Preguntas (solo si no existen)
IF @idCuest IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.preguntas WHERE id_cuestionario=@idCuest)
BEGIN
  INSERT INTO dbo.preguntas (id_cuestionario, texto, orden, tipo, puntaje_max) VALUES
  (@idCuest,'En las ultimas 2 semanas, me he sentido nervioso/a?',1,'opcion_multiple',3),
  (@idCuest,'Me cuesta relajarme?',2,'opcion_multiple',3),
  (@idCuest,'Me siento desanimado/a?',3,'opcion_multiple',3);
END
GO

-- Opciones 0-3 para cada pregunta (Nunca, A veces, A menudo, Casi siempre)
DECLARE @idCuest2 INT = (SELECT TOP 1 id_cuestionario FROM dbo.cuestionarios WHERE titulo='Cuestionario Base Prueba' ORDER BY id_cuestionario DESC);
IF @idCuest2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.opciones_pregunta WHERE id_pregunta IN (SELECT id_pregunta FROM dbo.preguntas WHERE id_cuestionario=@idCuest2))
BEGIN
  INSERT INTO dbo.opciones_pregunta (id_pregunta, texto, valor, orden)
  SELECT id_pregunta,'Nunca',0,1 FROM dbo.preguntas WHERE id_cuestionario=@idCuest2
  UNION ALL SELECT id_pregunta,'A veces',1,2 FROM dbo.preguntas WHERE id_cuestionario=@idCuest2
  UNION ALL SELECT id_pregunta,'A menudo',2,3 FROM dbo.preguntas WHERE id_cuestionario=@idCuest2
  UNION ALL SELECT id_pregunta,'Casi siempre',3,4 FROM dbo.preguntas WHERE id_cuestionario=@idCuest2;
END
GO

-- 2 eventos de prueba para paciente@test.com
DECLARE @idPac INT = (SELECT id_usuario FROM dbo.usuarios WHERE correo='paciente@test.com');
DECLARE @idTipoReg INT = (SELECT id_tipo_evento FROM dbo.tipos_evento WHERE nombre='RegistroEmocional');
DECLARE @idTipoCuest INT = (SELECT id_tipo_evento FROM dbo.tipos_evento WHERE nombre='Cuestionario');
DECLARE @idRiesgoBajo INT = (SELECT id_nivel_riesgo FROM dbo.niveles_riesgo WHERE nombre='Bajo');
DECLARE @idCuest3 INT = (SELECT TOP 1 id_cuestionario FROM dbo.cuestionarios WHERE titulo='Cuestionario Base Prueba' ORDER BY id_cuestionario DESC);

IF @idPac IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.eventos_bienestar WHERE id_paciente=@idPac)
BEGIN
  INSERT INTO dbo.eventos_bienestar (id_paciente, id_tipo_evento, id_cuestionario, id_nivel_riesgo, fecha_evento, puntaje_total)
  VALUES (@idPac,@idTipoReg,NULL,@idRiesgoBajo,DATEADD(DAY,-2,SYSDATETIME()),2);

  INSERT INTO dbo.eventos_bienestar (id_paciente, id_tipo_evento, id_cuestionario, id_nivel_riesgo, fecha_evento, puntaje_total)
  VALUES (@idPac,@idTipoCuest,@idCuest3,@idRiesgoBajo,DATEADD(DAY,-1,SYSDATETIME()),3);
END
GO

-- Linea de ayuda + recomendacion de prueba
IF NOT EXISTS (SELECT 1 FROM dbo.lineas_ayuda WHERE nombre='Linea Prueba 123')
INSERT INTO dbo.lineas_ayuda (nombre, telefono, url, horario, cobertura, estado, descripcion)
VALUES ('Linea Prueba 123','123','https://ejemplo.com','24/7','Nacional','Activa','Linea falsa solo para pruebas');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.recomendaciones WHERE titulo='Respiracion guiada (prueba)')
INSERT INTO dbo.recomendaciones (titulo, contenido, nivel_riesgo)
VALUES ('Respiracion guiada (prueba)','Inhala 4s, sostén 4s, exhala 4s. 5 minutos.','Bajo');
GO

-- Verificacion
SELECT 'usuarios' AS tabla, COUNT(*) AS total FROM dbo.usuarios
UNION ALL SELECT 'cuestionarios', COUNT(*) FROM dbo.cuestionarios
UNION ALL SELECT 'preguntas', COUNT(*) FROM dbo.preguntas
UNION ALL SELECT 'opciones_pregunta', COUNT(*) FROM dbo.opciones_pregunta
UNION ALL SELECT 'eventos_bienestar', COUNT(*) FROM dbo.eventos_bienestar;
GO
