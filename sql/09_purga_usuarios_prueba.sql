-- =====================================================
-- | Objeto  | 09_purga_usuarios_prueba.sql
-- | Fecha   | 2026-09-22
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Elimina usuarios de prueba sin hash PBKDF2 (seed 03) y su
-- |         | rastro: reasigna cuestionarios a sankie453, borra eventos,
-- |         | respuestas, auth y sesiones/codigos asociados
-- | Afecta  | dbo.cuestionarios, dbo.eventos_bienestar, dbo.respuestas,
-- |         | dbo.auth, dbo.sesiones, dbo.codigos_verificacion, dbo.usuarios
-- | Nota    | Correr ANTES de 10_triggers_auth.sql (TR_usuarios_BloqueoBorrado
-- |         | bloquearia estos DELETE por historial)
-- =====================================================
-- USE Mindzyxs;
-- GO

DECLARE @sankie INT = (SELECT id_usuario FROM dbo.usuarios WHERE correo = 'sankie453@gmail.com');

-- 1. Reasignar cuestionarios creados por usuarios de prueba al admin real.
UPDATE dbo.cuestionarios SET id_creador = @sankie
WHERE id_creador IN (SELECT id_usuario FROM dbo.usuarios WHERE LEFT(password_hash, 3) <> 'v1' + CHAR(36));
PRINT 'Cuestionarios reasignados.';

-- 2. Borrar respuestas y eventos de usuarios de prueba.
DELETE r FROM dbo.respuestas r
JOIN dbo.eventos_bienestar e ON e.id_evento = r.id_evento
JOIN dbo.usuarios u ON u.id_usuario = e.id_paciente
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
DELETE e FROM dbo.eventos_bienestar e
JOIN dbo.usuarios u ON u.id_usuario = e.id_paciente
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
PRINT 'Eventos y respuestas de prueba borrados.';

-- 3. Borrar observaciones, autorizaciones, asignaciones y recordatorios asociados.
DELETE o FROM dbo.observaciones o
JOIN dbo.usuarios u ON u.id_usuario = o.id_paciente OR u.id_usuario = o.id_psicologo
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
DELETE a FROM dbo.autorizaciones a
JOIN dbo.usuarios u ON u.id_usuario = a.id_paciente OR u.id_usuario = a.id_psicologo
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
DELETE a FROM dbo.asignaciones_cuestionario a
JOIN dbo.usuarios u ON u.id_usuario = a.id_paciente OR u.id_usuario = a.id_psicologo
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
DELETE r FROM dbo.recordatorios r
JOIN dbo.usuarios u ON u.id_usuario = r.id_paciente
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
PRINT 'Observaciones, autorizaciones, asignaciones y recordatorios borrados.';

-- 4. Borrar logs, sesiones y codigos de usuarios de prueba.
DELETE a FROM dbo.auth a
JOIN dbo.usuarios u ON u.id_usuario = a.actor_id_usuario OR u.id_usuario = a.target_id_usuario
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
DELETE s FROM dbo.sesiones s
JOIN dbo.usuarios u ON u.id_usuario = s.id_usuario
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
DELETE c FROM dbo.codigos_verificacion c
JOIN dbo.usuarios u ON u.id_usuario = c.id_usuario
WHERE LEFT(u.password_hash, 3) <> 'v1' + CHAR(36);
PRINT 'Auth, sesiones y codigos de prueba borrados.';

-- 5. Borrar los usuarios de prueba sin hash.
DELETE FROM dbo.usuarios WHERE LEFT(password_hash, 3) <> 'v1' + CHAR(36);
PRINT 'Usuarios de prueba borrados.';

-- VERIFICACION
SELECT COUNT(*) AS usuarios_fake_restantes FROM dbo.usuarios WHERE LEFT(password_hash, 3) <> 'v1' + CHAR(36);
SELECT id_usuario, correo FROM dbo.usuarios ORDER BY id_usuario;
