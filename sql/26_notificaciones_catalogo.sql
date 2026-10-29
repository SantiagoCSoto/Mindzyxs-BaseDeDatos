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
        VALUES (@idAdmin, 'CODE_SENT', 'correo', 'Mindzyxs - Código de verificación', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'PASSWORD_RECOVERY')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, activo)
        VALUES (@idAdmin, 'PASSWORD_RECOVERY', 'correo', 'Mindzyxs - Código de recuperación', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'APPROVAL_GRANTED')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, activo)
        VALUES (@idAdmin, 'APPROVAL_GRANTED', 'correo', 'Mindzyxs - Credenciales aprobadas', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'APPROVAL_REJECTED')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, activo)
        VALUES (@idAdmin, 'APPROVAL_REJECTED', 'correo', 'Mindzyxs - Credenciales no aprobadas', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'REMINDER')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, activo)
        VALUES (@idAdmin, 'REMINDER', 'correo', 'Mindzyxs - Recordatorio diario', 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.notificaciones_config WHERE tipo = 'RISK_HIGH')
        INSERT INTO dbo.notificaciones_config (id_admin, tipo, canales, asunto, activo)
        VALUES (@idAdmin, 'RISK_HIGH', 'correo', 'Mindzyxs - Alerta de riesgo alto', 1);
END
GO
