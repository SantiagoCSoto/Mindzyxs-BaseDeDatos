-- =====================================================
-- Mindzyx - 01_create_tables_sqlserver.sql
-- SQL Server 2022 Express / LocalDB
-- Crea la base de datos Mindzyxs (si no existe) y las 22 tablas.
-- Orden pensado para NO dar error de FK (roles primero, etc.)
-- Para re-ejecutar en limpio ver README (DROP DATABASE primero)
-- =====================================================

-- ---------- 0. Crear la base de datos si no existe ----------
IF DB_ID(N'Mindzyxs') IS NULL
BEGIN
  CREATE DATABASE Mindzyxs;
  PRINT 'Base de datos Mindzyxs creada.';
END
ELSE
BEGIN
  PRINT 'Base de datos Mindzyxs ya existia.';
END
GO

-- Nos conmutamos a la BD recien creada (o la ya existente)
USE Mindzyxs;
GO

-- ---------- Catalogos base ----------

IF OBJECT_ID('dbo.roles', 'U') IS NULL
BEGIN
CREATE TABLE dbo.roles (
  id_rol INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255) NULL
);
END
GO

IF OBJECT_ID('dbo.generos', 'U') IS NULL
BEGIN
CREATE TABLE dbo.generos (
  id_genero INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
);
END
GO

IF OBJECT_ID('dbo.especialidades', 'U') IS NULL
BEGIN
CREATE TABLE dbo.especialidades (
  id_especialidad INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion VARCHAR(255) NULL
);
END
GO

IF OBJECT_ID('dbo.instituciones', 'U') IS NULL
BEGIN
CREATE TABLE dbo.instituciones (
  id_institucion INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  direccion VARCHAR(255) NULL,
  telefono VARCHAR(20) NULL
);
END
GO

IF OBJECT_ID('dbo.estados', 'U') IS NULL
BEGIN
CREATE TABLE dbo.estados (
  id_estado INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255) NULL
);
END
GO

IF OBJECT_ID('dbo.tipos_evento', 'U') IS NULL
BEGIN
CREATE TABLE dbo.tipos_evento (
  id_tipo_evento INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255) NULL
);
END
GO

IF OBJECT_ID('dbo.niveles_riesgo', 'U') IS NULL
BEGIN
CREATE TABLE dbo.niveles_riesgo (
  id_nivel_riesgo INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  color VARCHAR(7) NULL,
  peso INT NULL
);
END
GO

IF OBJECT_ID('dbo.dias_semana', 'U') IS NULL
BEGIN
CREATE TABLE dbo.dias_semana (
  id_dia INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(20) NOT NULL UNIQUE
);
END
GO

-- ---------- Usuarios (depende de los 5 catalogos de arriba) ----------

IF OBJECT_ID('dbo.usuarios', 'U') IS NULL
BEGIN
CREATE TABLE dbo.usuarios (
  id_usuario INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  correo VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  fecha_nacimiento DATE NULL,
  id_rol INT NOT NULL FOREIGN KEY REFERENCES dbo.roles(id_rol),
  id_estado_cuenta INT NOT NULL FOREIGN KEY REFERENCES dbo.estados(id_estado),
  id_estado_aprobacion INT NULL FOREIGN KEY REFERENCES dbo.estados(id_estado),
  id_genero INT NULL FOREIGN KEY REFERENCES dbo.generos(id_genero),
  id_institucion INT NULL FOREIGN KEY REFERENCES dbo.instituciones(id_institucion),
  id_especialidad INT NULL FOREIGN KEY REFERENCES dbo.especialidades(id_especialidad),
  file_path VARCHAR(500) NULL,
  fecha_registro DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  ultimo_acceso DATETIME2 NULL
);
CREATE INDEX IX_usuarios_correo ON dbo.usuarios(correo);
CREATE INDEX IX_usuarios_rol ON dbo.usuarios(id_rol);
END
GO

-- ---------- Sprint 1: verificacion y sesiones ----------

IF OBJECT_ID('dbo.codigos_verificacion', 'U') IS NULL
BEGIN
CREATE TABLE dbo.codigos_verificacion (
  id_codigo INT IDENTITY(1,1) PRIMARY KEY,
  id_usuario INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario) ON DELETE CASCADE,
  codigo VARCHAR(6) NOT NULL,
  tipo VARCHAR(20) NOT NULL,
  expira_en DATETIME2 NOT NULL,
  creado_en DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
CREATE INDEX IX_codigos_usuario ON dbo.codigos_verificacion(id_usuario);
END
GO

IF OBJECT_ID('dbo.sesiones', 'U') IS NULL
BEGIN
CREATE TABLE dbo.sesiones (
  id_sesion INT IDENTITY(1,1) PRIMARY KEY,
  id_usuario INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario) ON DELETE CASCADE,
  token_hash VARCHAR(500) NOT NULL,
  expira_en DATETIME2 NOT NULL,
  creada_en DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
END
GO

-- ---------- Cuestionarios unificados ----------

IF OBJECT_ID('dbo.cuestionarios', 'U') IS NULL
BEGIN
CREATE TABLE dbo.cuestionarios (
  id_cuestionario INT IDENTITY(1,1) PRIMARY KEY,
  titulo VARCHAR(100) NOT NULL,
  descripcion VARCHAR(500) NULL,
  tipo VARCHAR(20) NOT NULL DEFAULT 'Personalizado',
  estado VARCHAR(20) NOT NULL DEFAULT 'Borrador',
  id_creador INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
END
GO

IF OBJECT_ID('dbo.preguntas', 'U') IS NULL
BEGIN
CREATE TABLE dbo.preguntas (
  id_pregunta INT IDENTITY(1,1) PRIMARY KEY,
  id_cuestionario INT NOT NULL FOREIGN KEY REFERENCES dbo.cuestionarios(id_cuestionario) ON DELETE CASCADE,
  texto VARCHAR(500) NOT NULL,
  orden INT NOT NULL DEFAULT 1,
  tipo VARCHAR(50) NULL,
  puntaje_max INT NULL
);
END
GO

IF OBJECT_ID('dbo.opciones_pregunta', 'U') IS NULL
BEGIN
CREATE TABLE dbo.opciones_pregunta (
  id_opcion INT IDENTITY(1,1) PRIMARY KEY,
  id_pregunta INT NOT NULL FOREIGN KEY REFERENCES dbo.preguntas(id_pregunta) ON DELETE CASCADE,
  texto VARCHAR(255) NOT NULL,
  valor INT NOT NULL DEFAULT 0,
  orden INT NOT NULL DEFAULT 1
);
END
GO

-- ---------- Eventos y respuestas ----------

IF OBJECT_ID('dbo.eventos_bienestar', 'U') IS NULL
BEGIN
CREATE TABLE dbo.eventos_bienestar (
  id_evento INT IDENTITY(1,1) PRIMARY KEY,
  id_paciente INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  id_tipo_evento INT NOT NULL FOREIGN KEY REFERENCES dbo.tipos_evento(id_tipo_evento),
  id_cuestionario INT NULL FOREIGN KEY REFERENCES dbo.cuestionarios(id_cuestionario),
  id_estado INT NULL FOREIGN KEY REFERENCES dbo.estados(id_estado),
  id_nivel_riesgo INT NULL FOREIGN KEY REFERENCES dbo.niveles_riesgo(id_nivel_riesgo),
  fecha_evento DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  puntaje_total INT NULL,
  nivel_ansiedad INT NULL
);
CREATE INDEX IX_eventos_paciente ON dbo.eventos_bienestar(id_paciente, fecha_evento DESC);
END
GO

IF OBJECT_ID('dbo.respuestas', 'U') IS NULL
BEGIN
CREATE TABLE dbo.respuestas (
  id_respuesta INT IDENTITY(1,1) PRIMARY KEY,
  id_evento INT NOT NULL FOREIGN KEY REFERENCES dbo.eventos_bienestar(id_evento) ON DELETE CASCADE,
  id_pregunta INT NOT NULL FOREIGN KEY REFERENCES dbo.preguntas(id_pregunta),
  valor INT NULL,
  texto VARCHAR(500) NULL,
  fecha_respuesta DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
END
GO

IF OBJECT_ID('dbo.observaciones', 'U') IS NULL
BEGIN
CREATE TABLE dbo.observaciones (
  id_observacion INT IDENTITY(1,1) PRIMARY KEY,
  id_psicologo INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  id_paciente INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  id_evento INT NULL FOREIGN KEY REFERENCES dbo.eventos_bienestar(id_evento),
  contenido TEXT NOT NULL,
  firma VARCHAR(255) NULL,
  fecha_observacion DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
END
GO

IF OBJECT_ID('dbo.autorizaciones', 'U') IS NULL
BEGIN
CREATE TABLE dbo.autorizaciones (
  id_autorizacion INT IDENTITY(1,1) PRIMARY KEY,
  id_paciente INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  id_psicologo INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  id_estado INT NOT NULL FOREIGN KEY REFERENCES dbo.estados(id_estado),
  fecha_solicitud DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  fecha_respuesta DATETIME2 NULL,
  CONSTRAINT UQ_autorizacion UNIQUE (id_paciente, id_psicologo)
);
END
GO

IF OBJECT_ID('dbo.asignaciones_cuestionario', 'U') IS NULL
BEGIN
CREATE TABLE dbo.asignaciones_cuestionario (
  id_asignacion INT IDENTITY(1,1) PRIMARY KEY,
  id_cuestionario INT NOT NULL FOREIGN KEY REFERENCES dbo.cuestionarios(id_cuestionario),
  id_paciente INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  id_psicologo INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  fecha_asignacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  fecha_limite DATETIME2 NULL,
  estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
);
END
GO

-- ---------- Recordatorios ----------

IF OBJECT_ID('dbo.recordatorios', 'U') IS NULL
BEGIN
CREATE TABLE dbo.recordatorios (
  id_recordatorio INT IDENTITY(1,1) PRIMARY KEY,
  id_paciente INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario) ON DELETE CASCADE,
  titulo VARCHAR(100) NOT NULL,
  mensaje VARCHAR(500) NULL,
  hora TIME NOT NULL,
  activo BIT NOT NULL DEFAULT 1
);
END
GO

IF OBJECT_ID('dbo.recordatorio_dias', 'U') IS NULL
BEGIN
CREATE TABLE dbo.recordatorio_dias (
  id_recordatorio INT NOT NULL FOREIGN KEY REFERENCES dbo.recordatorios(id_recordatorio) ON DELETE CASCADE,
  id_dia INT NOT NULL FOREIGN KEY REFERENCES dbo.dias_semana(id_dia),
  PRIMARY KEY (id_recordatorio, id_dia)
);
END
GO

-- ---------- Admin: lineas, recomendaciones, notificaciones, respaldos ----------

IF OBJECT_ID('dbo.lineas_ayuda', 'U') IS NULL
BEGIN
CREATE TABLE dbo.lineas_ayuda (
  id_linea INT IDENTITY(1,1) PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(20) NULL,
  url VARCHAR(255) NULL,
  horario VARCHAR(100) NULL,
  cobertura VARCHAR(255) NULL,
  estado VARCHAR(20) NOT NULL DEFAULT 'Activa',
  descripcion VARCHAR(500) NULL
);
END
GO

IF OBJECT_ID('dbo.recomendaciones', 'U') IS NULL
BEGIN
CREATE TABLE dbo.recomendaciones (
  id_recomendacion INT IDENTITY(1,1) PRIMARY KEY,
  titulo VARCHAR(200) NOT NULL,
  contenido TEXT NOT NULL,
  nivel_riesgo VARCHAR(20) NULL
);
END
GO

IF OBJECT_ID('dbo.notificaciones_config', 'U') IS NULL
BEGIN
CREATE TABLE dbo.notificaciones_config (
  id_config INT IDENTITY(1,1) PRIMARY KEY,
  id_admin INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  tipo VARCHAR(50) NOT NULL,
  canales VARCHAR(100) NOT NULL DEFAULT 'correo',
  asunto VARCHAR(255) NULL,
  cuerpo TEXT NULL,
  activo BIT NOT NULL DEFAULT 1
);
END
GO

IF OBJECT_ID('dbo.respaldos', 'U') IS NULL
BEGIN
CREATE TABLE dbo.respaldos (
  id_respaldo INT IDENTITY(1,1) PRIMARY KEY,
  nombre_archivo VARCHAR(255) NOT NULL,
  tamano VARCHAR(20) NULL,
  fecha_hora DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  id_admin INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario)
);
END
GO

IF OBJECT_ID('dbo.auth', 'U') IS NULL
BEGIN
CREATE TABLE dbo.auth (
  id_auth INT IDENTITY(1,1) PRIMARY KEY,
  actor_id_usuario INT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  target_id_usuario INT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  accion VARCHAR(100) NOT NULL,
  detalle TEXT NULL,
  fecha DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  ip_address VARCHAR(45) NULL
);
CREATE INDEX IX_auth_fecha ON dbo.auth(fecha DESC);
END
GO

-- =====================================================
-- FIN 01_create_tables_sqlserver.sql
-- Siguiente paso: 02_seed_catalogos.sql
-- Para verificar: SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES ORDER BY TABLE_NAME;
-- Deben salir 22 tablas.
-- =====================================================
