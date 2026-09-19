USE [master];
GO
-- =====================================================
-- Mindzyx - 04b_crear_usuario_backup.sql
-- Usuario de BD dedicado SOLO para respaldos (BACKUP DATABASE).
-- Rol: db_backupoperator -> puede ejecutar BACKUP DATABASE / LOG
--      pero NO leer datos ni modificar esquema (sin db_datareader/db_datawriter).
-- La app SOLO usa esta credencial cuando la sesion validada es de un Administrador
-- (endpoint POST /api/admin/backup, blindado por token + rol).
-- =====================================================
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'mindzyxs_backup')
BEGIN
    CREATE LOGIN [mindzyxs_backup]
    WITH PASSWORD = N'Backup2026!', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
END
ELSE
BEGIN
    ALTER LOGIN [mindzyxs_backup] WITH PASSWORD = N'Backup2026!';
END
GO
ALTER LOGIN [mindzyxs_backup] ENABLE;
GO

USE [Mindzyxs];
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'mindzyxs_backup')
BEGIN
    CREATE USER [mindzyxs_backup] FOR LOGIN [mindzyxs_backup];
END
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [mindzyxs_backup];
GO

-- Defensa en profundidad: asegurar que no tenga roles de lectura/escritura/DDL.
IF IS_ROLEMEMBER('db_datareader', 'mindzyxs_backup') = 1
    ALTER ROLE [db_datareader] DROP MEMBER [mindzyxs_backup];
IF IS_ROLEMEMBER('db_datawriter', 'mindzyxs_backup') = 1
    ALTER ROLE [db_datawriter] DROP MEMBER [mindzyxs_backup];
IF IS_ROLEMEMBER('db_ddladmin', 'mindzyxs_backup') = 1
    ALTER ROLE [db_ddladmin] DROP MEMBER [mindzyxs_backup];
IF IS_ROLEMEMBER('db_owner', 'mindzyxs_backup') = 1
    ALTER ROLE [db_owner] DROP MEMBER [mindzyxs_backup];
GO

-- =====================================================
-- NOTA IMPORTANTE - Permiso de carpeta para el .bak:
-- BACKUP DATABASE escribe el archivo USANDO la cuenta de servicio de SQL Server
-- (no la de la app). La carpeta de respaldos debe ser escribible por esa cuenta.
-- Por defecto la app escribe en: C:\uploads\mindzyxs\backups
--
-- Para averiguar la cuenta de servicio del motor:
--   Get-CimInstance Win32_Service -Filter "Name LIKE 'MSSQL%'" |
--     Select-Object Name, StartName
--
-- Para conceder acceso (ejecutar PowerShell como Administrador):
--   icacls "C:\uploads\mindzyxs\backups" /grant "<StartName>:(OI)(CI)M"
--   (reemplazar <StartName> con la cuenta, p.ej. NT Service\MSSQL$SQLEXPRESS)
-- =====================================================