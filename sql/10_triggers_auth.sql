-- =====================================================
-- | Objeto  | 10_triggers_auth.sql
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | 6 triggers de auth/auditoria sobre dbo.auth (TR1-TR4, mas
-- |         | TR5 password seguro y TR6 borrado protegido). Correr DESPUES
-- |         | de 09_purga_usuarios_prueba.sql
-- | Afecta  | dbo.usuarios, dbo.sesiones, dbo.codigos_verificacion -> dbo.auth
-- =====================================================
-- USE Mindzyxs;
-- GO

-- =====================================================
-- | Objeto  | TR_usuarios_AuditEstado
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | AFTER UPDATE: si cambia id_estado_cuenta, registra
-- |         | CAMBIO_ESTADO_CUENTA en dbo.auth (actor = afectado)
-- | Afecta  | dbo.usuarios -> dbo.auth
-- =====================================================
CREATE OR ALTER TRIGGER dbo.TR_usuarios_AuditEstado
ON dbo.usuarios AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.auth (actor_id_usuario, target_id_usuario, accion, detalle, fecha, ip_address)
    SELECT i.id_usuario, i.id_usuario, 'CAMBIO_ESTADO_CUENTA',
        'Cuenta ' + CAST(i.id_usuario AS VARCHAR(10)) + ' (' + i.correo + '): estado '
        + (SELECT nombre FROM dbo.estados WHERE id_estado = d.id_estado_cuenta)
        + ' -> ' + (SELECT nombre FROM dbo.estados WHERE id_estado = i.id_estado_cuenta),
        SYSDATETIME(), NULL
    FROM inserted i JOIN deleted d ON d.id_usuario = i.id_usuario
    WHERE i.id_estado_cuenta <> d.id_estado_cuenta;
END;
GO

-- =====================================================
-- | Objeto  | TR_sesiones_Limite3
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | AFTER INSERT: por usuario conserva las 3 sesiones mas nuevas
-- |         | y borra el resto (la 4ta expulsa a la mas vieja)
-- | Afecta  | dbo.sesiones
-- =====================================================
CREATE OR ALTER TRIGGER dbo.TR_sesiones_Limite3
ON dbo.sesiones AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
    WITH Ranked AS (
        SELECT s.id_sesion,
            ROW_NUMBER() OVER (PARTITION BY s.id_usuario ORDER BY s.creada_en DESC, s.id_sesion DESC) AS rn
        FROM dbo.sesiones s
        WHERE s.id_usuario IN (SELECT DISTINCT id_usuario FROM inserted)
    )
    DELETE FROM dbo.sesiones WHERE id_sesion IN (SELECT id_sesion FROM Ranked WHERE rn > 3);
END;
GO

-- =====================================================
-- | Objeto  | TR_sesiones_AuditCreacion
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | AFTER INSERT: registra SESION_CREADA en dbo.auth por cada login
-- | Afecta  | dbo.sesiones -> dbo.auth
-- =====================================================
CREATE OR ALTER TRIGGER dbo.TR_sesiones_AuditCreacion
ON dbo.sesiones AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.auth (actor_id_usuario, target_id_usuario, accion, detalle, fecha, ip_address)
    SELECT id_usuario, id_usuario, 'SESION_CREADA',
        'Sesion creada para usuario ' + CAST(id_usuario AS VARCHAR(10)),
        SYSDATETIME(), NULL
    FROM inserted;
END;
GO

-- =====================================================
-- | Objeto  | TR_codigos_ConsumoUnico
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | AFTER INSERT: expira codigos previos del mismo usuario+tipo
-- |         | (nunca hay 2 codigos validos a la vez)
-- | Afecta  | dbo.codigos_verificacion
-- =====================================================
CREATE OR ALTER TRIGGER dbo.TR_codigos_ConsumoUnico
ON dbo.codigos_verificacion AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
    UPDATE c SET expira_en = DATEADD(MINUTE, -1, SYSDATETIME())
    FROM dbo.codigos_verificacion c
    JOIN inserted i ON i.id_usuario = c.id_usuario AND i.tipo = c.tipo
    WHERE c.id_codigo <> i.id_codigo AND c.expira_en > SYSDATETIME();
END;
GO

-- =====================================================
-- | Objeto  | TR_usuarios_PasswordSeguro
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | INSTEAD OF INSERT/UPDATE: solo permite password_hash con
-- |         | formato PBKDF2 (v1$...); rechaza texto plano con RAISERROR
-- | Afecta  | dbo.usuarios (bloquea escritura invalida)
-- =====================================================
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
            id_rol, id_estado_cuenta, id_estado_aprobacion, id_genero, file_path, fecha_registro, ultimo_acceso)
        SELECT nombre, apellido, correo, password_hash, fecha_nacimiento,
            id_rol, id_estado_cuenta, id_estado_aprobacion, id_genero, file_path, fecha_registro, ultimo_acceso
        FROM inserted;
    END;
    ELSE
    BEGIN
        UPDATE u SET
            nombre = i.nombre, apellido = i.apellido, correo = i.correo,
            password_hash = i.password_hash, fecha_nacimiento = i.fecha_nacimiento,
            id_rol = i.id_rol, id_estado_cuenta = i.id_estado_cuenta,
            id_estado_aprobacion = i.id_estado_aprobacion, id_genero = i.id_genero,
            file_path = i.file_path, fecha_registro = i.fecha_registro, ultimo_acceso = i.ultimo_acceso
        FROM dbo.usuarios u JOIN inserted i ON i.id_usuario = u.id_usuario;
    END;
END;
GO

-- =====================================================
-- | Objeto  | TR_usuarios_BloqueoBorrado
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | INSTEAD OF DELETE: bloquea borrar usuarios con historial
-- |         | (eventos, observaciones, autorizaciones, asignaciones,
-- |         | respaldos, cuestionarios, auth); si esta limpio, borra
-- |         | sesiones/codigos/recordatorios y luego el usuario
-- | Afecta  | dbo.usuarios (+ hijas con y sin CASCADE)
-- =====================================================
CREATE OR ALTER TRIGGER dbo.TR_usuarios_BloqueoBorrado
ON dbo.usuarios INSTEAD OF DELETE AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM deleted d WHERE EXISTS (
            SELECT 1 FROM dbo.eventos_bienestar e WHERE e.id_paciente = d.id_usuario
            UNION ALL SELECT 1 FROM dbo.observaciones o WHERE o.id_paciente = d.id_usuario OR o.id_psicologo = d.id_usuario
            UNION ALL SELECT 1 FROM dbo.autorizaciones a WHERE a.id_paciente = d.id_usuario OR a.id_psicologo = d.id_usuario
            UNION ALL SELECT 1 FROM dbo.asignaciones_cuestionario ac WHERE ac.id_paciente = d.id_usuario OR ac.id_psicologo = d.id_usuario
            UNION ALL SELECT 1 FROM dbo.respaldos r WHERE r.id_admin = d.id_usuario
            UNION ALL SELECT 1 FROM dbo.cuestionarios c WHERE c.id_creador = d.id_usuario
            UNION ALL SELECT 1 FROM dbo.notificaciones_config n WHERE n.id_admin = d.id_usuario
            UNION ALL SELECT 1 FROM dbo.auth a WHERE a.actor_id_usuario = d.id_usuario OR a.target_id_usuario = d.id_usuario
        )
    )
    BEGIN
        RAISERROR('No se puede eliminar: el usuario tiene historial (eventos, logs u otros). Suspenda la cuenta en vez de borrarla.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    DELETE s FROM dbo.sesiones s JOIN deleted d ON d.id_usuario = s.id_usuario;
    DELETE c FROM dbo.codigos_verificacion c JOIN deleted d ON d.id_usuario = c.id_usuario;
    DELETE r FROM dbo.recordatorios r JOIN deleted d ON d.id_usuario = r.id_paciente;
    DELETE u FROM dbo.usuarios u JOIN deleted d ON d.id_usuario = u.id_usuario;
END;
GO

-- VERIFICACION
SELECT name AS trigger_name, OBJECT_NAME(parent_id) AS tabla
FROM sys.triggers WHERE parent_id <> 0 AND name LIKE 'TR[_]%'
ORDER BY trigger_name;
