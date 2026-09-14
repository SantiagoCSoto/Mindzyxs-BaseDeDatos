USE [master];
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'mindzyxs_app')
BEGIN
    CREATE LOGIN [mindzyxs_app]
    WITH PASSWORD = N'Mind123!', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
END
ELSE
BEGIN
    ALTER LOGIN [mindzyxs_app] WITH PASSWORD = N'Mind123!';
END
GO
ALTER LOGIN [mindzyxs_app] ENABLE;
GO

USE [Mindzyxs];
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'mindzyxs_app')
BEGIN
    CREATE USER [mindzyxs_app] FOR LOGIN [mindzyxs_app];
END
GO
ALTER ROLE [db_datareader] ADD MEMBER [mindzyxs_app];
ALTER ROLE [db_datawriter] ADD MEMBER [mindzyxs_app];
GO
IF IS_ROLEMEMBER('db_ddladmin', 'mindzyxs_app') = 1
    ALTER ROLE [db_ddladmin] DROP MEMBER [mindzyxs_app];
IF IS_ROLEMEMBER('db_owner', 'mindzyxs_app') = 1
    ALTER ROLE [db_owner] DROP MEMBER [mindzyxs_app];
GO
DENY CREATE TABLE TO [mindzyxs_app];
DENY CREATE PROCEDURE TO [mindzyxs_app];
DENY CREATE VIEW TO [mindzyxs_app];
DENY CREATE FUNCTION TO [mindzyxs_app];
DENY ALTER ON SCHEMA::[dbo] TO [mindzyxs_app];
GO