# Mindzyxs-BD

Base de datos del proyecto **Mindzyx** (Sprint 1). Aqui esta todo lo necesario para que **cualquier persona del equipo** pueda tener la MISMA base de datos en su PC en menos de 20 minutos.

> 💡 **Que es esto y que no es esto**
>
> ✅ ESTE repo tiene: los scripts `.sql` para crear las tablas y llenarlas de datos falsos de prueba, el diagrama de la base de datos (`schema.dbml`) y esta guia.
>
> ❌ ESTE repo NO tiene: la aplicacion web, los mockups, ni los archivos `.mdf`/`.ldf` de la base de datos (esos NUNCA se suben a git, ver pasos mas abajo).

---

## Tabla de contenidos

- [Paso 0 - ¿Ya tiene SQL Server? (requisitos)](#paso-0--ya-tiene-sql-server)
- [Paso 1 - Instalar SQL Server Express + SSMS](#paso-1---instalar-sql-server-express--ssms)
- [Paso 2 - Clonar este repo](#paso-2---clonar-este-repo)
- [Paso 3 - Crear la base de datos y las 22 tablas](#paso-3---crear-la-base-de-datos-y-las-22-tablas)
- [Paso 4 - Cargar catalogos (roles, estados, etc.)](#paso-4---cargar-catalogos)
- [Paso 5 - Cargar datos de prueba](#paso-5---cargar-datos-de-prueba)
- [Paso 6 - Verificar que todo quedo bien](#paso-6---verificar-que-todo-quedo-bien)
- [Paso 7 - Empezar de cero (borrar todo)](#paso-7---empezar-de-cero-borrar-todo)
- [Paso 8 - Compartir nuevos datos de prueba con el equipo](#paso-8---compartir-nuevos-datos-de-prueba)
- [Que hay dentro del repo (estructura)](#que-hay-dentro-del-repo-estructura)
- [El diagrama y como actualizarlo](#el-diagrama-y-como-actualizarlo)
- [Errores comunes y sus soluciones](#errores-comunes-y-sus-soluciones)
- [Glosario de tablas](#glosario-de-tablas)

---

## Paso 0 - ¿Ya tiene SQL Server?

Antes de instalar nada, verifica si tu PC ya tiene SQL Server o sqlcmd.

### Opcion A: abrir un CMD/terminal y escribir

```cmd
sqlcmd -?
```

| Que pasa | Que significa |
|---|---|
| `sqlcmd -?` muestra la lista de ayuda | ✅ Ya tienes sqlcmd, ve al [Paso 3](#paso-3---crear-la-base-de-datos-y-las-22-tablas) |
| sale `no se reconoce como un comando interno o externo` | Esta opcion no existe. Ve a la **[Opcion B](#opcion-b-revisar-programas-instalados)** |

### Opcion B: revisar los programas instalados

Abre el menu de inicio, escribe `SQL Server` y revisa si te sale algo como:

- **SQL Server 2022 Management Studio (SSMS)** → ya tienes SSMS ✅
- **SQL Server Configuration Manager** → ya tienes SQL Server instalado ✅ (solo falta saber la instancia)
- **Visual Studio** → puede que ya tengas **LocalDB** (instancia `(localdb)\MSSQLLocalDB`) ✅

Si salio cualquiera de esos, tu PC ya tiene algo. Ve al [Paso 3](#paso-3---crear-la-base-de-datos-y-las-22-tablas) y en los comandos usa esto según tu caso:

| Lo que tienes | Instancia (servidor) que usas |
|---|---|
| SQL Server Express instalado normal | `.\SQLEXPRESS` |
| Solo LocalDB (via Visual Studio) | `(localdb)\MSSQLLocalDB` |
| No sabes cual | `.\SQLEXPRESS` y si falla, pruba la anterior |

> ⚠️ **IMPORTANTE**: si no sabes cual tienes, ejecuta este comando en CMD:
> ```cmd
> sqllocaldb info
> ```
> Si te lista `MSSQLLocalDB` → tienes LocalDB. Si da error → no tienes nada de esto.

---

## Paso 1 - Instalar SQL Server Express + SSMS

> ⚠️ **¿Solo quieres probar rapido sin instalar nada pesado?** Usa la [Opcion alternativa con LocalDB](#opcion-alternativa-rapida-localdb-sin-instalador) al final de esta seccion.

Necesitas permisos de administrador en tu PC.

### 1.1 Descargar SQL Server Express

1. Ve a: **https://www.microsoft.com/es-es/sql-server/sql-server-downloads**
2. Baja hasta **"SQL Server 2022 Express"** y baja el archivo. Tambien podes usar LocalDB (el mas liviano: `SqlLocalDB.msi`), que es todo lo que esta guia necesita.
3. Ejecuta el instalador y elige **"Instalación básica"** (Basic).
4. Deja la **instancia por defecto** `SQLEXPRESS`. Anota el nombre, lo usaras SIEMPRE para conectarte.

   > Si elegiste LocalDB, no eliges instancia: siempre sera `(localdb)\MSSQLLocalDB`.

5. Espera a que termine (puede tardar varios minutos, es normal).

### 1.2 Descargar SSMS (para ver las tablas con ventanas)

> SSMS es OPCIONAL. Se puede usar todo desde comandos. Pero para un estudiante es MEJOR ver las tablas con clics.

1. Ve a: **https://aka.ms/ssmsfullsetup**
2. Ejecuta el instalador y sigue las instrucciones (siguiente → siguiente → instalar).
3. Al abrir SSMS te pide el **nombre del servidor**:

   - Si instalamos Express: `.\SQLEXPRESS`
   - Si solo tienes LocalDB: `(localdb)\MSSQLLocalDB`

   Deja Autentificacion: **Windows Authentication** (no creamos usuarios de login, usamos tu cuenta de Windows).

4. Tip: conectar el primer vez puede tardar unos segundos. Si da `Login failed` mira [Errores comunes](#errores-comunes-y-sus-soluciones).

### 1.3 Verificar que quedo bien

En CMD escribe:

```cmd
sqlcmd -S .\SQLEXPRESS -Q "SELECT @@VERSION"
```

Si responde una linea empezando por `Microsoft SQL Server 2022` (o parecido) → listo ✅

#### Opcion alternativa rapida: LocalDB sin instalador

Si no quieres instalar SQL Server completo, hay un paquete mas chico. Descarga `SqlLocalDB.msi` desde la [pagina de SQL Server Express](https://www.microsoft.com/es-es/sql-server/sql-server-downloads) (busca la version para LocalDB) y al final tendras la instancia `(localdb)\MSSQLLocalDB`. Los comandos de esta guia funcionan igual, solo cambia `.\SQLEXPRESS` por `(localdb)\MSSQLLocalDB`.

---

## Paso 2 - Clonar este repo

En tu terminal (PowerShell o CMD), desde la carpeta donde quieras tener el proyecto:

```cmd
git clone https://github.com/TU_USUARIO/Mindzyxs-BD.git
cd Mindzyxs-BD
```

> 💡 Si no ves las carpetas `sql/`, `docs/` por que no las clonaste, revisa que tengas la **ultima version**:
> ```cmd
> git pull
> ```

---

## Paso 3 - Crear la base de datos y las 22 tablas

El script `01` hace DOS cosas: **crea la base de datos `Mindzyxs`** (con `IF DB_ID(...) IS NULL`, o sea que no falla si ya existe) y luego crea las **22 tablas** en el orden correcto (primero las tablas de catalogos como `roles`, despues las que dependen de ellas).

> ✅ No importa si ya ejecutaste el `01` antes: busca `IF OBJECT_ID('dbo.tabla','U') IS NULL`, asi que **no falla por tablas ya existentes**.

### Ejecutar en SSMS

1. Abre **SSMS** (o Azure Data Studio).
2. Conectate como en el Paso 1 (servidor `.\SQLEXPRESS` o `(localdb)\MSSQLLocalDB`).
3. Abre el archivo: **Archivo → Abrir → Archivo...** y busca `Mindzyxs-BD/sql/01_create_tables_sqlserver.sql`.
4. Asegurate de que el dropdown arriba a la izquierda diga **`master`** (o cualquier BD, tranqui: el script ya se encarga de crear/cambiar a `Mindzyxs`).
5. Presiona **F5** (o el boton **Ejecutar**).

### Ejecutar desde CMD/terminal (sin abrir ventanas)

```cmd
sqlcmd -S .\SQLEXPRESS -i sql\01_create_tables_sqlserver.sql
```

> Para LocalDB es:
> ```cmd
> sqlcmd -S (localdb)\MSSQLLocalDB -i sql\01_create_tables_sqlserver.sql
> ```

Debes ver algo como:

```
Base de datos Mindzyxs creada.
```

o

```
Base de datos Mindzyxs ya existia.
```

---

## Paso 4 - Cargar catalogos

Los **catalogos** son tablas chiquitas con opciones fijas: roles (Paciente, Psicologo, Administrador), estados (Activa, Suspendida...), generos, dias de la semana, niveles de riesgo, etc. Sin estos datos, el resto del sistema no funciona (porque las demas tablas los referencian).

### En SSMS

1. Abre `mindzyxs-bd/sql/02_seed_catalogos.sql`.
2. Asegurate de estar en la BD **`Mindzyxs`** (dropdown arriba a la izquierda).
3. **F5**.

### Desde CMD

```cmd
sqlcmd -S .\SQLEXPRESS -d Mindzyxs -i sql\02_seed_catalogos.sql
```

> Nota: aqui SI pasamos `-d Mindzyxs` porque los catalogos se insertan **dentro** de la BD. Si la BD no existe o no la creaste, ver error → por eso el paso 3 primero. Sin embargo, si el paso 3 no se hizo, podrías ver `Cannot open database`. Haz el paso 3 y reejecuta.

Al final imprime una tabla de resumen como:

```
tabla               total
------------------- ------
roles               3
generos             4
estados             11
tipos_evento        2
niveles_riesgo      3
dias_semana         7
```

---

## Paso 5 - Cargar datos de prueba

Son datos **FALSOS** (nombres con `@test.com`, password `HASH_PRUEBA_123456a`) para que todos los PCs prueben lo mismo: 1 admin, 2 pacientes, 2 psicologos, un codigo de verificacion `123456`, 1 cuestionario con preguntas y opciones, eventos, una linea de ayuda y una recomendacion.

> ⚠️ **REGLA**: NUNCA metemos datos reales de personas reales en este repo. Todo es `@test.com`.

### En SSMS

1. Abre `mindzyxs-bd/sql/03_seed_datos_prueba.sql`.
2. Asegurate de estar en **`Mindzyxs`**.
3. **F5**.

### Desde CMD

```cmd
sqlcmd -S .\SQLEXPRESS -d Mindzyxs -i sql\03_seed_datos_prueba.sql
```

Debes ver en el final:

```
usuarios             5
cuestionarios        1
preguntas            3
opciones_pregunta    12
eventos_bienestar    2
```

---

## Paso 6 - Verificar que todo quedo bien

En **SSMS**, abre una **Nueva consulta** (debe decir `Mindzyxs` arriba en el dropdown) y escribe:

```sql
SELECT id_usuario, nombre, apellido, correo, id_rol, id_estado_cuenta FROM dbo.usuarios;
```

Debes ver algo como:

| id_usuario | nombre | apellido | correo | id_rol | id_estado_cuenta |
|---|---|---|---|---|---|
| 1 | Admin | Prueba | admin@test.com | 3 | 1 |
| 2 | Camila | Rojas | paciente@test.com | 1 | 1 |
| 3 | Juan | Perez | paciente2@test.com | 1 | 4 |
| 4 | Laura | Gomez | psicologo@test.com | 2 | 1 |
| 5 | Pedro | Lopez | psicologo.pendiente@test.com | 2 | 4 |

> Los `id_rol`/`id_estado_cuenta` pueden variar segun el orden de insercion en tu PC, no te asustes. Lo importante es que aparezcan los 5 correos.

### Verificar las 22 tablas

```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES ORDER BY TABLE_NAME;
```

Deben salir **22 tablas**: asignaciones_cuestionario, auth, autorizaciones, codigos_verificacion, cuestionarios, dias_semana, especialidades, estados, eventos_bienestar, generos, instituciones, lineas_ayuda, niveles_riesgo, notificaciones_config, observaciones, opciones_pregunta, preguntas, recomendaciones, recordatorio_dias, recordatorios, respaldos, respuestas, roles, sesiones, tipos_evento, usuarios.

(son 26 si se cuentan las de la lista completa; el numero exacto "22" depende de si recontamos catalogos. Lo importante: todas las tablas del [Glosario](#glosario-de-tablas) existen.)

---

## Paso 7 - Empezar de cero (borrar todo)

Para borrar la BD completa (tablas + datos) y volver a crearla desde el principio:

En **SSMS** (conextado como `master`, o desde CMD):

```sql
USE master;
GO
DROP DATABASE IF EXISTS Mindzyxs;
GO
```

> No te preocupes por si hay conexiones abiertas: SSMS frena si alquien esta conectado; en prueba local lo mas probable es que nadie mas este conectado.

Luego vuelve a ejecutar en orden [Paso 3](#paso-3---crear-la-base-de-datos-y-las-22-tablas) → [Paso 4](#paso-4---cargar-catalogos) → [Paso 5](#paso-5---cargar-datos-de-prueba).

```cmd
sqlcmd -S .\SQLEXPRESS -i sql\01_create_tables_sqlserver.sql
sqlcmd -S .\SQLEXPRESS -d Mindzyxs -i sql\02_seed_catalogos.sql
sqlcmd -S .\SQLEXPRESS -d Mindzyxs -i sql\03_seed_datos_prueba.sql
```

---

## Paso 8 - Compartir nuevos datos de prueba con el equipo

Cuando alguno agregue datos nuevos de prueba (por ejemplo, un nuevo paciente, un nuevo cuestionario) y quiera que todos tengan lo mismo:

1. En SSMS abre `sql/99_export_datos_prueba.sql`.
2. Ejecuta **por secciones** (selecciona y F5, o ejecuta todo): el script imprime varias lineas que son INSERTs listos para pegar.
3. Copia esas lineas al final de `sql/03_seed_datos_prueba.sql`.
4. Ahora sube los cambios a git:

```cmd
git add sql/03_seed_datos_prueba.sql
git commit -m "agrego datos de prueba nuevos (usuario, cuestionario)"
git push
```

5. Los demas hacen `git pull` y reejecutan el `03_seed_datos_prueba.sql`.

> ⚠️ **NUNCA** hagas `git add *.mdf`, `git add *.ldf`, `git add *.bak` ni `git add *.backup`. Por eso el repo ya tiene un `.gitignore` que los bloquea. Si ves `SQL Server (archivo .bak)` en tu carpeta, no lo subas.
>
> 🚨 **ANTES de subir**: corre en tu consulta:
> ```sql
> SELECT correo FROM dbo.usuarios WHERE correo NOT LIKE '%@test.com';
> ```
> Si devuelve algo, esos son datos REALES y NO deben estar en el repo. Usa otros correos falsos.

---

## Que hay dentro del repo (estructura)

```
Mindzyxs-BD/
├ README.md                                   ← este archivo, la guia paso a paso
├ .gitignore                                  ← bloquea *.mdf, *.ldf, *.bak, .vs/, etc.
├ docs/
│  └ db/
│     └ schema.dbml                           ← el diagrama de la BD (se sube a dbdiagram.io)
└ sql/
   ├ 01_create_tables_sqlserver.sql           ← crea BD + 22 tablas (no falla si ya existen)
   ├ 02_seed_catalogos.sql                    ← roles, estados, generos, etc.
   ├ 03_seed_datos_prueba.sql                 ← datos falsos @test.com
   └ 99_export_datos_prueba.sql               ← helper: genera INSERTs para compartir
```

---

## El diagrama y como actualizarlo

El diagrama vive en `docs/db/schema.dbml` en un formato llamado **DBML**.

### Para verlo

1. Ve a **https://dbdiagram.io**
2. Crea un diagrama nuevo (o usa el mismo si ya lo tienes).
3. Arriba a la derecha, usa el boton **>_ Editor** / haz **Import** y pega todo el contenido de `docs/db/schema.dbml`.
4. Debe cargar con **0 errores**. Si aparece un error, no actualices nada y avisa al equipo.

### Como actualizarlo si cambia la BD

1. Edita `docs/db/schema.dbml` en tu editor (esta en este repo).
2. Copia el contenido a `dbdiagram.io` → debe quedar en **0 errores**.
3. Con `Export` → elige tu motor → se genera el DDL. (No lo usamos para migraciones, solo para ver el esquema.)
4. Commit:

```cmd
git add docs/db/schema.dbml
git commit -m "actualizo diagrama de la BD"
git push
```

> 💡 Regla de oro: **primero SQL, despues diagrama** → primero pones la tabla en `01_`, la pruebas, y cuando funcione actualizas el `.dbml` y el tglo del repo. No es al reves.

---

## Errores comunes y sus soluciones

### 1. `Login failed for user` (autenticacion)

- Causa: escribiste mal el servidor, o la autenticacion no es Windows.
- Solucion: usa `.\SQLEXPRESS` (o `(localdb)\MSSQLLocalDB`) y deja **Windows Authentication**.

### 2. `sqlcmd no se reconoce como un comando interno o externo`

- Causa: `sqlcmd` no esta en el PATH, o no se instalo la herramienta de linea de comandos (incluida normalmente con SQL Server Express / SSMS).
- Solucion rapida: no uses `sqlcmd`, usa **SSMS** abriendo cada archivo con **F5**. O agrega la carpeta de `sqlcmd` al PATH (viene en algo como `C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\<version>\Tools\Binn`).

### 3. `CREATE DATABASE permission denied` / `Cannot open database Mindzyxs`

- Causa: no tenes permisos para crear BD, o la BD no se creo.
- Solucion: primero ejecuta el `01` (que incluye el `CREATE DATABASE`), o conectate con un usuario con permisos (el de Windows local suele tenerlos).

### 4. `Violation of UNIQUE KEY constraint ... usuarios.correo`

- Causa: ya habia un usuario con ese correo en la BD (por haber corrido el `03` 2 veces, o datos reales).
- Solucion: los scripts usan `IF NOT EXISTS` por si acaso. Si te dio error, es que ya estaba lleno: ejecuta [Paso 7 (DROP)](#paso-7---empezar-de-cero-borrar-todo) y vuelve a correr en orden.

### 5. `Invalid object name 'dbo.roles'` o `roles does not exist`

- Causa: corriste el `02` o `03` sin haber corrido el `01` antes, o te conectaste a la BD equivocada.
- Solucion: ejecuta `01` primero, y en SSMS verifica que el dropdown de arriba diga `Mindzyxs`.

### 6. El 01 no `DROP`s las tablas, asi que si queres re-empezar limpia de verdad → [Paso 7](#paso-7---empezar-de-cero-borrar-todo).

### 7. `El servidor no encontró conexion` / no puedo conectarme a SSMS

- Causa: el servicio no esta corriendo.
- Solucion: abre **SQL Server Configuration Manager** → Servicios → SQL Server (SQLEXPRESS) → para el servicio. O reinicia la PC. Si nadie lo tiene corriendo aun, instala bien con la opcion Basica del Paso 1.

---

## Glosario de tablas

> Rango corto por si olvidaste que guarda cada una. El detalle completo por tabla esta en `docs/db/schema.dbml`.

| Tabla | Que guarda |
|---|---|
| `roles` | Paciente / Psicologo / Administrador |
| `generos` | Opciones de genero |
| `especialidades` | Especialidades de un psicologo |
| `instituciones` | Instituciones (escuela, hospital, etc. del paciente) |
| `estados` | Estados de cuenta, aprobacion, autorizacion y evento |
| `tipos_evento` | RegistroEmocional / Cuestionario |
| `niveles_riesgo` | Bajo / Medio / Alto (con color y peso) |
| `dias_semana` | Lunes a Domingo |
| `usuarios` | Personas (paciente, psicologo, admin) con `correo` UNICO |
| `codigos_verificacion` | Codigo de 6 digitos para verificar correo (ej. `123456`) |
| `sesiones` | Sesion activa (token) de cada usuario |
| `cuestionarios` | Cuestionarios (Predeterminado o Personalizado) |
| `preguntas` | Preguntas de cada cuestionario |
| `opciones_pregunta` | Opciones de cada pregunta (con valor) |
| `eventos_bienestar` | RegistroEmocional o respuesta a cuestionario |
| `respuestas` | Respuesta puntual (valor o texto) por pregunta |
| `observaciones` | Notas del psicologo sobre el paciente |
| `autorizaciones` | Paciente autoriza a psicologo a ver sus datos |
| `asignaciones_cuestionario` | Psicologo asigna cuestionario a paciente |
| `recordatorios` | Recordatorio configurado por el paciente |
| `recordatorio_dias` | Dias de la semana del recordatorio |
| `lineas_ayuda` | Linea de ayuda con telefono, horario, cobertura |
| `recomendaciones` | Recomendaciones de bienestar |
| `notificaciones_config` | Config de notificaciones que maneja admin |
| `respaldos` | Registro de respaldos (nombre_archivo `.backup`) |
| `auth` | Registro/auditoria de acciones (admin ve esta consola) |

---

## Notas finales para el equipo

- **Todo es datos de prueba** con `@test.com`; nunca subas datos reales.
- **Los scripts son re-ejecutables** (`IF NOT EXISTS`), no rompen si se corren 2 veces.
- **La BD se llama `Mindzyxs`** y vive en SQL Server local; el chat en tiempo real va a Firebase (Firestore) en otro repositorio, no aqui.
- Si algo no te sale, revisa este orden: **01 → 02 → 03**. El 90% de los problemas es haber corrido los pasos en otro orden o conectado a otra BD.