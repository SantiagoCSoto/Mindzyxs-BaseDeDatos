-- =====================================================
-- | Objeto  | 11_store_procedures.sql
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | 6 SPs que simplifican el back: mantenimiento (1 llamada),
-- |         | crear sesion, registrar auth, cuestionario completo,
-- |         | dashboard admin y recomendaciones priorizadas
-- | Afecta  | dbo.codigos_verificacion, dbo.sesiones, dbo.auth,
-- |         | dbo.cuestionarios, dbo.recomendaciones (+ conteos)
-- =====================================================
-- USE Mindzyxs;
-- GO

-- =====================================================
-- | Objeto  | sp_mantenimiento_limpieza
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Borra en 1 llamada: codigos expirados, sesiones expiradas
-- |         | y auth con mas de @diasAuth dias. Devuelve conteos
-- | Afecta  | dbo.codigos_verificacion, dbo.sesiones, dbo.auth
-- | Back    | Reemplaza LimpiarCodigos/Sesiones/AuthAsync (3 queries -> 1 EXEC)
-- =====================================================
CREATE OR ALTER PROCEDURE dbo.sp_mantenimiento_limpieza
    @diasAuth INT = 180
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @c INT, @s INT, @a INT;
    DELETE FROM dbo.codigos_verificacion WHERE expira_en < SYSDATETIME();
    SET @c = @@ROWCOUNT;
    DELETE FROM dbo.sesiones WHERE expira_en < SYSDATETIME();
    SET @s = @@ROWCOUNT;
    DELETE FROM dbo.auth WHERE fecha < DATEADD(DAY, -@diasAuth, SYSDATETIME());
    SET @a = @@ROWCOUNT;
    SELECT @c AS codigos, @s AS sesiones, @a AS auth;
END;
GO

-- =====================================================
-- | Objeto  | sp_sesion_crear
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Inserta la sesion del login y devuelve id_sesion.
-- |         | TR_sesiones_Limite3 y TR_sesiones_AuditCreacion hacen el resto
-- | Afecta  | dbo.sesiones -> dbo.auth (via triggers)
-- | Back    | Reemplaza ISesionRepository.CrearAsync
-- =====================================================
CREATE OR ALTER PROCEDURE dbo.sp_sesion_crear
    @idUsuario INT,
    @tokenHash VARCHAR(500),
    @expiraEn DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.sesiones (id_usuario, token_hash, expira_en, creada_en)
    VALUES (@idUsuario, @tokenHash, @expiraEn, SYSDATETIME());
    SELECT SCOPE_IDENTITY() AS id_sesion;
END;
GO

-- =====================================================
-- | Objeto  | sp_auth_registrar
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Inserta un log en dbo.auth con fecha del servidor
-- | Afecta  | dbo.auth
-- | Back    | Reemplaza EfAuthLogRepository.LogAsync (ExecuteSqlRaw)
-- =====================================================
CREATE OR ALTER PROCEDURE dbo.sp_auth_registrar
    @actorId INT = NULL,
    @targetId INT = NULL,
    @accion VARCHAR(100),
    @detalle VARCHAR(MAX) = NULL,
    @ip VARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.auth (actor_id_usuario, target_id_usuario, accion, detalle, fecha, ip_address)
    VALUES (@actorId, @targetId, @accion, @detalle, SYSDATETIME(), @ip);
END;
GO

-- =====================================================
-- | Objeto  | sp_cuestionario_completo
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Devuelve cuestionario + preguntas + opciones (3 sets, en orden)
-- |         | Solo si esta Predeterminado + Publicado
-- | Afecta  | Lectura: dbo.cuestionarios, dbo.preguntas, dbo.opciones_pregunta
-- | Back    | Reemplaza 3 queries de EfCuestionarioRepository (1 round-trip)
-- =====================================================
CREATE OR ALTER PROCEDURE dbo.sp_cuestionario_completo
    @idCuestionario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_cuestionario, titulo, descripcion, tipo, estado, id_creador, fecha_creacion
    FROM dbo.cuestionarios
    WHERE id_cuestionario = @idCuestionario AND tipo = 'Predeterminado' AND estado = 'Publicado';
    SELECT id_pregunta, id_cuestionario, texto, orden, tipo, puntaje_max
    FROM dbo.preguntas WHERE id_cuestionario = @idCuestionario ORDER BY orden;
    SELECT o.id_opcion, o.id_pregunta, o.texto, o.valor, o.orden
    FROM dbo.opciones_pregunta o JOIN dbo.preguntas p ON p.id_pregunta = o.id_pregunta
    WHERE p.id_cuestionario = @idCuestionario
    ORDER BY o.id_pregunta, o.orden;
END;
GO

-- =====================================================
-- | Objeto  | sp_dashboard_admin
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | 4 sets: usuarios por rol, usuarios por estado, contadores
-- |         | (sesiones activas, respaldos, cuestionarios publicados) y
-- |         | ultimos 10 eventos de auth. Base de la consola admin (PB-25)
-- | Afecta  | Lectura: dbo.usuarios, dbo.sesiones, dbo.respaldos,
-- |         | dbo.cuestionarios, dbo.auth
-- | Back    | Lo consume el futuro AdminService (1 EXEC en vez de N queries)
-- =====================================================
CREATE OR ALTER PROCEDURE dbo.sp_dashboard_admin
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.nombre AS rol, COUNT(u.id_usuario) AS total
    FROM dbo.roles r LEFT JOIN dbo.usuarios u ON u.id_rol = r.id_rol
    GROUP BY r.nombre ORDER BY r.nombre;
    SELECT e.nombre AS estado, COUNT(u.id_usuario) AS total
    FROM dbo.estados e LEFT JOIN dbo.usuarios u ON u.id_estado_cuenta = e.id_estado
    GROUP BY e.nombre ORDER BY e.nombre;
    SELECT
        (SELECT COUNT(*) FROM dbo.sesiones WHERE expira_en > SYSDATETIME()) AS sesiones_activas,
        (SELECT COUNT(*) FROM dbo.respaldos) AS respaldos,
        (SELECT COUNT(*) FROM dbo.cuestionarios WHERE estado = 'Publicado') AS cuestionarios_publicados,
        (SELECT COUNT(*) FROM dbo.usuarios) AS usuarios_total;
    SELECT TOP 10 id_auth, actor_id_usuario, accion,
        CAST(detalle AS VARCHAR(200)) AS detalle, fecha
    FROM dbo.auth ORDER BY id_auth DESC;
END;
GO

-- =====================================================
-- | Objeto  | sp_recomendaciones_priorizadas
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Lista de autocuidado con el nivel de la sesion primero,
-- |         | luego transversales (NULL) y luego el resto
-- | Afecta  | Lectura: dbo.recomendaciones
-- | Back    | Reemplaza el OrderBy en memoria de RecomendacionService
-- =====================================================
CREATE OR ALTER PROCEDURE dbo.sp_recomendaciones_priorizadas
    @nivel VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_recomendacion, titulo, contenido, nivel_riesgo, intro, pasos,
        duracion, instrucciones, icono
    FROM dbo.recomendaciones
    ORDER BY
        CASE WHEN @nivel IS NOT NULL AND nivel_riesgo = @nivel THEN 0
             WHEN nivel_riesgo IS NULL THEN 1 ELSE 2 END,
        id_recomendacion;
END;
GO

-- VERIFICACION
SELECT SCHEMA_NAME(schema_id) + '.' + name AS sp
FROM sys.procedures
WHERE name LIKE 'sp[_]%' AND name NOT LIKE 'sp[_]%diagram%'
ORDER BY sp;
