-- =====================================================
-- | Objeto  | 18_psicologo_especialidades.sql
-- | Fecha   | 2026-09-29
-- | Autor   | Santiago Cortes
-- | Cambio  | Creacion inicial
-- | Hace    | Tabla intermedia psicologo_especialidades: un psicologo
-- |         | puede tener una, varias o ninguna especialidad
-- |         | (de dbo.especialidades). Reemplaza el uso de la columna
-- |         | legacy dbo.usuarios.id_especialidad (queda sin uso).
-- | Afecta  | DDL: dbo.psicologo_especialidades
-- =====================================================
-- USE Mindzyxs;
-- GO

IF OBJECT_ID('dbo.psicologo_especialidades', 'U') IS NULL
BEGIN
CREATE TABLE dbo.psicologo_especialidades (
  id_psicologo INT NOT NULL FOREIGN KEY REFERENCES dbo.usuarios(id_usuario),
  id_especialidad INT NOT NULL FOREIGN KEY REFERENCES dbo.especialidades(id_especialidad),
  CONSTRAINT PK_psicologo_especialidades PRIMARY KEY (id_psicologo, id_especialidad)
);
END
GO

-- VERIFICACION
SELECT COUNT(*) AS filas FROM dbo.psicologo_especialidades;
