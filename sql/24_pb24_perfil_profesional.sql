-- ============================================================
-- Mindzyxs-BD · Script 24 — PB-24: perfil profesional del psicólogo
-- Columnas en dbo.usuarios (referenciado en Back README PB-24).
-- Todo NULL salvo tarjeta_profesional_verificada (BIT DEFAULT 0).
-- Idempotente: solo agrega lo que falta.
-- ============================================================

IF COL_LENGTH('dbo.usuarios', 'años_experiencia') IS NULL
BEGIN
    ALTER TABLE dbo.usuarios
        ADD años_experiencia INT NULL;
END
GO

IF COL_LENGTH('dbo.usuarios', 'descripcion_profesional') IS NULL
BEGIN
    ALTER TABLE dbo.usuarios
        ADD descripcion_profesional VARCHAR(4000) NULL;
END
GO

IF COL_LENGTH('dbo.usuarios', 'datos_contacto') IS NULL
BEGIN
    ALTER TABLE dbo.usuarios
        ADD datos_contacto VARCHAR(500) NULL;
END
GO

IF COL_LENGTH('dbo.usuarios', 'tarjeta_profesional_verificada') IS NULL
BEGIN
    ALTER TABLE dbo.usuarios
        ADD tarjeta_profesional_verificada BIT NOT NULL DEFAULT 0;
END
GO

-- PB-24 fix: TR_usuarios_PasswordSeguro (INSTEAD OF INSERT/UPDATE, script 10)
-- lista columnas explícitas; sin las nuevas, todo UPDATE las ignora en silencio.
-- Se recrea aquí con la lista completa (válido también en builds frescos 01..24).
CREATE OR ALTER TRIGGER dbo.TR_usuarios_PasswordSeguro
ON dbo.usuarios INSTEAD OF INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE password_hash NOT LIKE 'v1$%' OR LEN(password_hash) < 40)
    BEGIN
        RAISERROR('Password sin hash PBKDF2: password_hash debe tener formato v1$...', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    IF NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.usuarios (nombre, apellido, correo, password_hash, fecha_nacimiento,
            id_rol, id_estado_cuenta, id_estado_aprobacion, id_genero, id_institucion, id_especialidad,
            file_path, fecha_registro, ultimo_acceso,
            años_experiencia, descripcion_profesional, datos_contacto, tarjeta_profesional_verificada)
        SELECT nombre, apellido, correo, password_hash, fecha_nacimiento,
            id_rol, id_estado_cuenta, id_estado_aprobacion, id_genero, id_institucion, id_especialidad,
            file_path, fecha_registro, ultimo_acceso,
            años_experiencia, descripcion_profesional, datos_contacto, tarjeta_profesional_verificada
        FROM inserted;
    END;
    ELSE
    BEGIN
        UPDATE u SET
            nombre = i.nombre, apellido = i.apellido, correo = i.correo,
            password_hash = i.password_hash, fecha_nacimiento = i.fecha_nacimiento,
            id_rol = i.id_rol, id_estado_cuenta = i.id_estado_cuenta,
            id_estado_aprobacion = i.id_estado_aprobacion, id_genero = i.id_genero,
            id_institucion = i.id_institucion, id_especialidad = i.id_especialidad,
            file_path = i.file_path, fecha_registro = i.fecha_registro, ultimo_acceso = i.ultimo_acceso,
            años_experiencia = i.años_experiencia, descripcion_profesional = i.descripcion_profesional,
            datos_contacto = i.datos_contacto, tarjeta_profesional_verificada = i.tarjeta_profesional_verificada
        FROM dbo.usuarios u JOIN inserted i ON i.id_usuario = u.id_usuario;
    END;
END;
GO
