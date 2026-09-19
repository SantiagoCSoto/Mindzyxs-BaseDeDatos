-- =====================================================
-- Mindzyx - 05_insertar_admin_sankie.sql
-- Inserta un ADMIN real de desarrollo: sankie453@gmail.com
-- Password: abc123 (hash PBKDF2-SHA256 v1$210000, compatible con la API).
-- Cuenta ya verificada: id_estado_cuenta = Activa.
-- Se puede re-ejecutar (usa NOT EXISTS por correo).
-- USE Mindzyxs;
-- =====================================================

DECLARE @rolAdmin INT = (SELECT id_rol FROM dbo.roles WHERE nombre='Administrador');
DECLARE @estActiva INT = (SELECT id_estado FROM dbo.estados WHERE nombre='Activa');

IF @rolAdmin IS NULL OR @estActiva IS NULL
BEGIN
  PRINT 'Faltan catalogos. Ejecuta primero 02_seed_catalogos.sql';
END
ELSE IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE correo='sankie453@gmail.com')
BEGIN
  INSERT INTO dbo.usuarios (nombre, apellido, correo, password_hash, id_rol, id_estado_cuenta, fecha_registro)
  VALUES ('Sankie','Mindzyx','sankie453@gmail.com','v1$210000$eY5WyN0Pokk936zi8o/GQg==$syG1YBCwId0i41E6s5m6iMgN6hjS4V2ATfFNXCFYg44=',@rolAdmin,@estActiva,SYSDATETIME());

  PRINT 'ADMIN sankie453@gmail.com insertado (rol Administrador, cuenta Activa).';
END
ELSE
BEGIN
  PRINT 'El correo sankie453@gmail.com ya existe en dbo.usuarios. No se inserto nada.';
END
GO

-- Verificacion
SELECT id_usuario, nombre, apellido, correo, id_rol, id_estado_cuenta, password_hash, fecha_registro
FROM dbo.usuarios
WHERE correo='sankie453@gmail.com';
GO