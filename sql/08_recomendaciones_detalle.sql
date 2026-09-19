-- =====================================================
-- Mindzyx - 08_recomendaciones_detalle.sql
-- Detalle de recomendaciones basicas (PB-09): intro, pasos
-- (separados por salto de linea), duracion, instrucciones e icono.
-- nivel_riesgo NULL = transversal (para todos los niveles).
-- Re-ejecutable (guardas de columna / titulo / NULL). Despues de 01 y 02.
-- USE Mindzyxs;
-- =====================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.recomendaciones') AND name = 'intro')
    ALTER TABLE dbo.recomendaciones ADD intro VARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.recomendaciones') AND name = 'pasos')
    ALTER TABLE dbo.recomendaciones ADD pasos TEXT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.recomendaciones') AND name = 'duracion')
    ALTER TABLE dbo.recomendaciones ADD duracion VARCHAR(100) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.recomendaciones') AND name = 'instrucciones')
    ALTER TABLE dbo.recomendaciones ADD instrucciones TEXT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.recomendaciones') AND name = 'icono')
    ALTER TABLE dbo.recomendaciones ADD icono NVARCHAR(10) NULL;
-- Por si se ejecuto una version previa con VARCHAR (los emoji necesitan NVARCHAR):
IF EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id = t.user_type_id
           WHERE c.object_id = OBJECT_ID('dbo.recomendaciones') AND c.name = 'icono' AND t.name = 'varchar')
    ALTER TABLE dbo.recomendaciones ALTER COLUMN icono NVARCHAR(10) NULL;
GO

-- Iconos por NCHAR (surrogate pairs): 1=U+1F32C 2=U+1F331 3=U+1F6A8 4=U+1F486 5=U+1F9D8 6=U+1F319.
DECLARE @nl CHAR(2) = CHAR(13) + CHAR(10);

-- Backfill 1: Respiracion guiada (Bajo).
UPDATE dbo.recomendaciones
SET titulo = 'Respiracion guiada',
    contenido = 'Ejercicio simple de respiracion consciente para reducir la tension del momento.',
    intro = 'Ejercicio simple de respiracion consciente para reducir la tension del momento.',
    pasos = 'Sientate o recuestate en una posicion comoda y cierra los ojos si lo prefieres.' + @nl
     + 'Inhala lentamente por la nariz contando hasta 4.' + @nl
     + 'Sosten la respiracion contando hasta 4.' + @nl
     + 'Exhala por la boca contando hasta 6.' + @nl
     + 'Repite el ciclo durante 5 minutos, llevando tu atencion solo a la respiracion.',
    duracion = 'Duracion sugerida: 5 minutos',
    instrucciones = 'Realiza este ejercicio en un lugar tranquilo. Si sientes mareo, vuelve a la respiracion normal y descansa. No reemplaza la supervision de un profesional de la salud.',
    icono = NCHAR(0xD83C)+NCHAR(0xDF2C)
WHERE titulo LIKE 'Respiraci_n guiada%' AND intro IS NULL;

-- Backfill 2: Puedes mejorar paso a paso (Medio).
UPDATE dbo.recomendaciones
SET intro = 'Esta bien no sentirse bien siempre: pequenos pasos tambien cuentan.',
    pasos = 'Haz una pausa consciente de 3 minutos y observa como te sientes.' + @nl
     + 'Elige una sola cosa pequena de la lista de recomendaciones y pruebala hoy.' + @nl
     + 'Registra como te sientes manana para notar tu propio avance.',
    duracion = 'Duracion sugerida: 5 minutos',
    instrucciones = 'No te exijas resultados inmediatos: el bienestar se cultiva por pasos. Si lo necesitas, revisa las demas recomendaciones basicas.',
    icono = NCHAR(0xD83C)+NCHAR(0xDF31)
WHERE titulo = 'Puedes mejorar paso a paso' AND intro IS NULL;

-- Backfill 3: Alerta (Alto).
UPDATE dbo.recomendaciones
SET intro = 'Si estas en riesgo, busca apoyo ahora: no te quedes solo con esto.',
    pasos = 'Contacta ahora a una linea de ayuda de tu pais.' + @nl
     + 'Si puedes, avisa a alguien de confianza como te sientes.' + @nl
     + 'Busca ayuda profesional o acude al servicio de urgencias mas cercano.',
    duracion = 'Ahora mismo',
    instrucciones = 'En riesgo: consulta a las lineas de ayuda o a un profesional de la salud mental. Ante urgencia, usa los servicios de emergencia.',
    icono = NCHAR(0xD83D)+NCHAR(0xDEA8)
WHERE titulo = 'Alerta: busca apoyo ahora' AND intro IS NULL;

-- Seed: Relajacion muscular (Medio).
IF NOT EXISTS (SELECT 1 FROM dbo.recomendaciones WHERE titulo = 'Relajacion muscular')
INSERT INTO dbo.recomendaciones (titulo, contenido, nivel_riesgo, intro, pasos, duracion, instrucciones, icono)
VALUES ('Relajacion muscular',
 'Tecnica de tension y distension muscular para soltar la tension acumulada.',
 'Medio',
 'Tecnica de tension y distension muscular para soltar la tension acumulada.',
 'Acuestate o sientate comodamente.' + @nl
  + 'Tensa los musculos de los pies durante 5 segundos y luego suelta.' + @nl
  + 'Sube por cada grupo muscular: piernas, abdomen, manos, brazos, hombros, cuello y rostro.' + @nl
  + 'En cada zona tensa 5 segundos y relaja 10 segundos.' + @nl
  + 'Termina respirando despacio durante 1 minuto.',
 'Duracion sugerida: 10 minutos',
 'Evita tensar zonas con dolor o lesion. Si el dolor aumenta, deten el ejercicio. Es autocuidado basico y no sustituye un tratamiento clinico.',
 NCHAR(0xD83D)+NCHAR(0xDC86));

-- Seed: Pausa consciente (transversal).
IF NOT EXISTS (SELECT 1 FROM dbo.recomendaciones WHERE titulo = 'Pausa consciente')
INSERT INTO dbo.recomendaciones (titulo, contenido, nivel_riesgo, intro, pasos, duracion, instrucciones, icono)
VALUES ('Pausa consciente',
 'Toma un momento para reconectar con el presente y calmar la mente.',
 NULL,
 'Toma un momento para reconectar con el presente y calmar la mente.',
 'Deten cualquier actividad y deja a un lado distracciones.' + @nl
  + 'Observa tu entorno: nombra 3 cosas que ves, 2 que escuchas y 1 que sientes.' + @nl
  + 'Lleva tu atencion a la respiracion durante 1 minuto.' + @nl
  + 'Preguntate como te sientes en este momento, sin juzgar la respuesta.',
 'Duracion sugerida: 3 minutos',
 'Puedes hacer esta pausa varias veces al dia cuando te sientas abrumado. Es autocuidado basico, no un tratamiento clinico.',
 NCHAR(0xD83E)+NCHAR(0xDDD8));

-- Seed: Higiene del sueno (transversal).
IF NOT EXISTS (SELECT 1 FROM dbo.recomendaciones WHERE titulo = 'Higiene del sueno')
INSERT INTO dbo.recomendaciones (titulo, contenido, nivel_riesgo, intro, pasos, duracion, instrucciones, icono)
VALUES ('Higiene del sueno',
 'Habitos simples para favorecer un descanso de mejor calidad.',
 NULL,
 'Habitos simples para favorecer un descanso de mejor calidad.',
 'Define una hora fija para ir a dormir y para despertar.' + @nl
  + '30 minutos antes, apaga pantallas y baja las luces.' + @nl
  + 'Evita cafeina y comidas pesadas cerca de la hora de dormir.' + @nl
  + 'Crea una rutina relajante: lectura breve, respiracion suave o musica tranquila.' + @nl
  + 'Manten el dormitorio oscuro, fresco y silencioso.',
 'Duracion sugerida: 15 minutos (rutina nocturna)',
 'Establece estos habitos de forma progresiva. Si los problemas de sueno persisten, consulta a un profesional de la salud. Es autocuidado basico, no tratamiento clinico.',
 NCHAR(0xD83C)+NCHAR(0xDF19));

-- VERIFICACION
SELECT id_recomendacion, titulo, nivel_riesgo, icono,
 DATALENGTH(COALESCE(pasos,'')) AS bytes_pasos
FROM dbo.recomendaciones ORDER BY id_recomendacion;
