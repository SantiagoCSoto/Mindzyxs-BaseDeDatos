-- ============================================================
-- Mindzyxs-BD · Script 26 — PB-30: catálogo de notificaciones
-- 6 eventos v1 (CODE_SENT, PASSWORD_RECOVERY, APPROVAL_GRANTED,
-- APPROVAL_REJECTED, REMINDER, RISK_HIGH) con plantillas por defecto
-- (variables {nombre}, {codigo}, {fecha}, {motivo}).
-- Idempotente: solo inserta tipos faltantes.
-- ============================================================

DECLARE @idAdmin INT = (
    SELECT TOP 1 u.id_usuario
    FROM dbo.usuarios u
    JOIN dbo.roles r ON r.id_rol = u.id_rol AND r.nombre = 'Administrador'
    ORDER BY u.id_usuario
);

IF @idAdmin IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'CODE_SENT')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, cuerpo, activo)
        VALUES (@idAdmin, 'CODE_SENT', 'correo', 'Mindzyxs - Código de verificación',
        '<div><p>Hola {nombre},</p><p>Tu código de verificación es:</p><div>{codigo}</div></div>', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'PASSWORD_RECOVERY')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, cuerpo, activo)
        VALUES (@idAdmin, 'PASSWORD_RECOVERY', 'correo', 'Mindzyxs - Código de recuperación',
        '<div><p>Hola {nombre},</p><p>Tu código de recuperación es:</p><div>{codigo}</div></div>', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'APPROVAL_GRANTED')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, cuerpo, activo)
        VALUES (@idAdmin, 'APPROVAL_GRANTED', 'correo', 'Mindzyxs - Credenciales aprobadas',
        '<div><p>Hola {nombre},</p><p>Sus credenciales profesionales han sido validadas. Su cuenta ha sido aprobada y ya puede iniciar sesión.</p></div>', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'APPROVAL_REJECTED')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, cuerpo, activo)
        VALUES (@idAdmin, 'APPROVAL_REJECTED', 'correo', 'Mindzyxs - Credenciales no aprobadas',
        '<div><p>Hola {nombre},</p><p>Sus credenciales profesionales no fueron aprobadas.</p><p>Motivo: {motivo}</p><p>Puede subir una nueva tarjeta profesional para ser evaluado nuevamente.</p></div>', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'REMINDER')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, cuerpo, activo)
        VALUES (@idAdmin, 'REMINDER', 'correo', 'Mindzyxs - Recordatorio diario',
        '<div><p>Hola {nombre},</p><p>Este es su recordatorio de bienestar emocional.</p></div>', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'RISK_HIGH')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, cuerpo, activo)
        VALUES (@idAdmin, 'RISK_HIGH', 'correo', 'Mindzyxs - Alerta de riesgo alto',
        '<div><p>Hola {nombre},</p><p>Se detectó un nivel de riesgo alto el {fecha}. Busque ayuda profesional o comuníquese con una línea de ayuda.</p></div>', 1);
END
GO
