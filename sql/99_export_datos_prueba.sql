-- =====================================================
-- Mindzyx - 99_export_datos_prueba.sql
-- HELPER: genera INSERTs para copiar nuevos datos de prueba
-- a 03_seed_datos_prueba.sql y compartirlos por git.
-- NO exporta passwords reales: aqui solo es para datos FALSOS.
-- Uso en SSMS: ejecuta por partes y copia el resultado.
-- USE Mindzyxs;
-- =====================================================

-- 1) Exportar usuarios de prueba (sin password real, usa HASH_PRUEBA)
SELECT
  'IF NOT EXISTS (SELECT 1 FROM dbo.usuarios WHERE correo=''' + correo + ''') ' +
  'INSERT INTO dbo.usuarios (nombre, apellido, correo, password_hash, fecha_nacimiento, id_rol, id_estado_cuenta, id_genero, fecha_registro) VALUES (' +
  '''' + nombre + ''',''' + apellido + ''',''' + correo + ''',''HASH_PRUEBA_123456a'',''' +
  CONVERT(VARCHAR(10), ISNULL(fecha_nacimiento,'2000-01-01'), 120) + ''',' +
  CAST(id_rol AS VARCHAR) + ',' + CAST(id_estado_cuenta AS VARCHAR) + ',' +
  ISNULL(CAST(id_genero AS VARCHAR),'NULL') + ',SYSDATETIME());'
  AS insert_sql
FROM dbo.usuarios
WHERE correo LIKE '%@test.com';
GO

-- 2) Exportar cuestionarios de prueba
SELECT
  'IF NOT EXISTS (SELECT 1 FROM dbo.cuestionarios WHERE titulo=''' + titulo + ''') ' +
  'INSERT INTO dbo.cuestionarios (titulo, descripcion, tipo, estado, id_creador, fecha_creacion) VALUES (' +
  '''' + titulo + ''',''' + ISNULL(descripcion,'') + ''',''' + tipo + ''',''' + estado + ''',' +
  CAST(id_creador AS VARCHAR) + ',SYSDATETIME());'
  AS insert_sql
FROM dbo.cuestionarios
WHERE titulo LIKE '%Prueba%';
GO

-- 3) Ver que NO haya datos reales antes de commitear
-- Si esto devuelve >0 y no son @test.com, NO los subas al repo.
SELECT correo, nombre, apellido FROM dbo.usuarios WHERE correo NOT LIKE '%@test.com';
GO
