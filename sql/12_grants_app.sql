-- =====================================================
-- | Objeto  | 12_grants_app.sql
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Otorga EXECUTE en los 6 SPs al usuario de la API
-- |         | (mindzyxs_app solo tiene db_datareader/db_datawriter y sin
-- |         | esto el back falla con Msg 229 en cada LogAsync/sesion)
-- | Afecta  | Permisos: mindzyxs_app sobre dbo.sp_* (sin datos)
-- =====================================================
-- USE Mindzyxs;
-- GO

GRANT EXECUTE ON dbo.sp_mantenimiento_limpieza TO mindzyxs_app;
GRANT EXECUTE ON dbo.sp_sesion_crear TO mindzyxs_app;
GRANT EXECUTE ON dbo.sp_auth_registrar TO mindzyxs_app;
GRANT EXECUTE ON dbo.sp_cuestionario_completo TO mindzyxs_app;
GRANT EXECUTE ON dbo.sp_dashboard_admin TO mindzyxs_app;
GRANT EXECUTE ON dbo.sp_recomendaciones_priorizadas TO mindzyxs_app;
GO

-- VERIFICACION (como admin: lista grants; la prueba real es EXEC como app):
SELECT p.name AS sp, dp.permission_name, USER_NAME(dp.grantee_principal_id) AS usuario
FROM sys.database_permissions dp JOIN sys.objects p ON p.object_id = dp.major_id
WHERE dp.permission_name = 'EXECUTE' AND USER_NAME(dp.grantee_principal_id) = 'mindzyxs_app'
ORDER BY p.name;;
