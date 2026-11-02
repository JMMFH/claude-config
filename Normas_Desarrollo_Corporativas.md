# Normas de Desarrollo Corporativas — ACOBA / JMMFH

> Norma común de creación de **código** y **base de datos** para todos los proyectos.
> Extraída de la práctica real del proyecto SIA y generalizada.
> **DOCUMENTO MAESTRO.** Ubicación oficial:
> `D:\proyectos\Desarrollo Estandares y normas\Normas_Desarrollo_Corporativas.md`
> Cualquier cambio en la norma se hace **aquí**, y desde aquí se copia a cada repositorio.
> **Este fichero se copia tal cual en cada repositorio** (raíz o `Docs/`). Lo específico
> de cada proyecto (entidades, stack concreto, rutas) va en su `CLAUDE.md` / `AGENTS.md`,
> que **complementa** pero nunca contradice esta norma.

Versión: 1.0 · Fecha: 19/08/2026 · Autor: JMMFH (José María Mena)

---

## 0. Principios innegociables

1. **No inventar.** Ni tablas, ni columnas, ni Stored Procedures, ni clases, ni estilos,
   ni rutas, ni nombres. Si falta información: **preguntar**.
2. **Acordar antes de codificar.** Ante una duda o una petición ambigua: diagnosticar y
   **proponer**; no tocar código hasta que haya acuerdo explícito.
3. **Idioma: español de España** en código, comentarios, commits, SQL, interfaz y
   documentación. Los identificadores del dominio van en español (`Productor`, `Campaña`,
   `IdCultivo`).
4. **Cada cambio funcional actualiza la documentación** (ver §9). Código sin documentar
   no se considera terminado.
5. **Nunca commitear ni publicar por iniciativa propia.** Git y los despliegues los
   gestiona la persona responsable.
6. **Nunca ejecutar nada contra la base de datos por iniciativa propia.** Se entrega el
   script y el paso exacto; lo ejecuta la persona responsable.

---

## 1. Arquitectura en capas (obligatoria)

```
Presentacion/     → UI: Views, ViewModels, Controles, Servicios de UI, Estilos
      ↓
Aplicacion/       → Servicios transversales: Sesión, Diálogos, Validación (DTOs)
      ↓
Negocio/          → Modelos de dominio + Interfaces de repositorio (IRepos) + Constantes
      ↓
Datos/            → Repositorios concretos + acceso a BD exclusivamente por SP
      ↓
SQL Server        → Proyecto SSDT (fuente de verdad del esquema)
```

Reglas de dependencia:

- `Presentacion` → `Aplicacion` → `Negocio`
- `Datos` → `Negocio`
- `Negocio` **no tiene dependencias externas**: es el núcleo puro (sin SqlClient, sin WPF,
  sin paquetes de interfaz).
- La capa de presentación **nunca** referencia `Datos`; recibe interfaces `IRepo*` por
  inyección de dependencias.
- Las interfaces viven en `Negocio/IRepos/`; las implementaciones en `Datos/`.

Contratos entre capas:

- Cuando la implementación depende de la tecnología de interfaz, el contrato se declara como
  interfaz en la capa inferior o en `Aplicacion` y se implementa en `Presentacion`
  (p. ej. `IServicioDialogos`).

---

## 2. Convenciones de nomenclatura

| Elemento | Patrón | Ejemplo |
|---|---|---|
| Tablas SQL | Plural, PascalCase | `Productores`, `SociosCampañas` |
| Columnas clave | `Id` + entidad singular | `IdCultivo`, `IdContrato` |
| Stored Procedures | `sp_AccionEntidad` | `sp_CargarProductores`, `sp_ActualizarCultivo` |
| Tipos tabla (TVP) | `NombreList` | `dbo.IntList`, `dbo.AlcanceList` |
| Interfaz repositorio | `IRepoEntidad` | `IRepoProductores` |
| Repositorio | `RepoEntidad` | `RepoProductores` |
| Modelo de dominio | Singular PascalCase | `Productor`, `Campaña` |
| DTO de validación | `EntidadDto` | `ContratoDto` |
| Validador | `EntidadValidator` | `ContratoValidator` |
| Vista / formulario | `EntidadForm.xaml` | `ProductorForm.xaml` |
| Diálogo selector | `SeleccionarEntidad.xaml` | `SeleccionarSocios.xaml` |
| ViewModel | `EntidadFormViewModel` | `ProductorFormViewModel` |
| Campo privado | `_camelCase` | `_nombre` |
| Propiedad / método | `PascalCase` | `CargarDatos()` |
| Constante de SP | PascalCase en la clase estática `Constantes` | `Constantes.CargarProductores` |
| Constante de ruta de recurso | PascalCase en `RutasRecursos` | `RutasRecursos.Productores` |

Gotcha conocido: **`x:Class` puede no coincidir con el nombre del fichero**. Antes de
declarar código muerto, buscar por `x:Class` y por el nombre de tipo, no solo por fichero.

---

## 3. Cabeceras de comentarios (patrón corporativo — OBLIGATORIO)

### 3.1 Cabecera de fichero (todos los `.cs`)

```csharp
// ============================================================
// Objeto  : ColeccionObservable.cs
// Autor   : JMMFH (José María Mena)
// Fecha   : 18/07/2026
// Desc.   : ObservableCollection con reemplazo en bloque. Reemplazar()
//           sustituye todo el contenido y emite UNA sola notificación
//           Reset (no N eventos Add).
// ============================================================
```

### 3.2 Cabecera de función (métodos relevantes o de más de 15 líneas)

```csharp
// ============================================================
// Funcion : NombreFuncion
// Variables: param1 - descripción, param2 - descripción
// Autor   : JMMFH (José María Mena)
// Fecha   : dd/MM/aaaa
// Desc.   : Descripción.
// ============================================================
```

### 3.3 Objetos SQL (tablas, SP, scripts)

Misma cabecera con `--`:

```sql
-- ============================================================
-- Objeto  : sp_ActualizarCultivo
-- Autor   : JMMFH (José María Mena)
-- Fecha   : dd/MM/aaaa
-- Desc.   : Actualiza un cultivo validando que el nombre sea único.
-- ============================================================
```

Reglas:

- La `Desc.` puede ocupar varias líneas; las de continuación se alinean bajo la primera.
- **Prohibidos los comentarios XML**: nada de `/// <summary>`, `/// <param>`,
  `/// <returns>`, `/// <inheritdoc />`. Solo cabeceras `// ===` y comentarios `//`
  normales allí donde la lógica no sea evidente.
- Los comentarios explican **por qué**, no **qué**. Si hay una decisión no obvia (un gotcha
  de la plataforma, una compensación de rendimiento), se documenta en el propio punto.
- Nada de `Debug.WriteLine` ni trazas de depuración en el código entregado.

---

## 4. Normas de código (.NET / C#)

### 4.1 Configuración global (`Directory.Build.props`)

- `LangVersion: latest`
- `Nullable: enable` — *nullable reference types* obligatorio, sin silenciar avisos con `!`
  salvo justificación en comentario.
- `ImplicitUsings: enable`
- Codificación **UTF-8**, finales de línea **CRLF**, indentación **4 espacios** en C# y
  XAML, **2 espacios** en XML/JSON.
- Analizadores activados; no se entrega código con avisos nuevos.

### 4.2 Modelos de dominio

Los modelos que participan en enlace de datos heredan de la clase base de notificación
(`BaseNegocio`) y usan `SetProperty`:

```csharp
public class Productor : BaseNegocio
{
    private string _nombre = string.Empty;
    public string Nombre
    {
        get => _nombre;
        set => SetProperty(ref _nombre, value);
    }
}
```

- Cadenas inicializadas a `string.Empty`, nunca `null` implícito.
- El modelo **no** contiene acceso a datos ni lógica de interfaz.

### 4.3 Repositorios

**Patrón de repositorio dual** — todo repositorio de una entidad editable expone:

```csharp
// Devuelve un objeto nuevo cargado desde BD
EntidadX CargarPorId(int id);

// Rellena un objeto existente (para no romper el enlace activo en la interfaz)
void CargarPorIdBinding(EntidadX destino, int id);
```

Reglas de implementación:

- Acceso **exclusivamente** por Stored Procedure a través del ejecutor genérico `SP`.
  **Nunca SQL inline**, ni siquiera para una consulta trivial.
- El nombre del SP se toma **siempre** de la clase estática `Constantes`, nunca literal.
- Mapeo del lector en un método privado `MapearEntidad(SqlDataReader rs)` reutilizable.
- Los `SqlDataReader` se consumen dentro de un `using`.
- Los valores opcionales se envían como `(object?)valor ?? DBNull.Value`.
- Los identificadores nuevos se devuelven por parámetro **OUTPUT**, no por `SELECT` final.
- Un fallo del SP se traduce en excepción con mensaje propio (`sp.Mensaje`); no se ignora.
- Toda operación de escritura o borrado **registra auditoría** (alta / modificación / baja)
  con entidad, identificador y descripción legible.

Ejemplo canónico:

```csharp
var sp = new SP { Nombre = Constantes.InsertarTenencia };
sp.Parametros.Add("@Tenencia", t.TenenciaNombre);
sp.Parametros.Add("@Descripcion", (object?)t.Descripcion ?? DBNull.Value);
sp.Parametros.AddOut("@IdTenencia", SqlDbType.Int);

if (!sp.Ejecutar())
    throw new Exception("Error al insertar tenencia: " + sp.Mensaje);

var id = sp.Parametros.GetValor<int>("@IdTenencia");
_auditoria.Registrar(AccionAuditoria.Insertar, "Tenencia", id, $"Alta tenencia: {t.TenenciaNombre}");
```

Las listas de identificadores y los filtros múltiples se pasan como **TVP**
(`AddIntList` / TVP de alcance), nunca concatenando cadenas.

### 4.4 Validación

- Un **DTO por entidad** con su `Validator` (FluentValidation) en `Aplicacion/Validacion/`.
- **Se valida el DTO antes de persistir**, siempre; la base de datos no es el sitio donde se
  descubre que faltaba un campo obligatorio.
- Los validadores se registran en el contenedor de dependencias.
- Los mensajes de validación son texto de usuario final: sin jerga técnica, sin nombres de
  columna.

### 4.5 Inyección de dependencias

- Un único punto de composición (`App.xaml.cs` o equivalente): repositorios, servicios,
  validadores y ViewModels.
- Se inyectan **interfaces**, nunca implementaciones concretas.
- Nada de estáticos globales ni `new` de repositorios dentro de un ViewModel.

### 4.6 Errores y transacciones

- Las operaciones multi-tabla se hacen **transaccionales en el SP** (ver §5.4). Si además
  tocan sistema de ficheros u otro recurso externo, el código de aplicación aporta la
  **compensación** (deshacer lo ya hecho si falla el resto).
- Los mensajes de error mostrados al usuario son comprensibles; el detalle técnico va al
  registro o a la auditoría.

---

## 5. Normas de base de datos (SQL Server)

### 5.1 Fuente de verdad

- **El esquema y los SP viven en el proyecto SSDT** (`*_SQL/dbo/Tables`,
  `*_SQL/dbo/Stored Procedures`) y se despliegan con *publish*.
- Los scripts sueltos de `ScriptsSQL/` son apoyo y migraciones, **no son lo desplegado**.
  Editar un script suelto **no cambia la base de datos**.
- Regla de oro: si un cambio toca tablas, **el publish del SSDT va antes que el binario**.

### 5.2 Reglas estructurales

- **Sin Foreign Keys.** La integridad referencial se gestiona en la aplicación.
- **Sin `ON DELETE CASCADE`.** Las cascadas se implementan explícitamente en SP.
- Clave primaria `PK_<Tabla>` sobre `Id<Entidad>`, con `IDENTITY(1,1)` salvo que la clave
  sea un código externo (p. ej. código PAC); en ese caso se documenta con un comentario en
  la propia columna.
- Restricciones de unicidad de negocio con `UQ_<Concepto>`.
- `NOT NULL` + `DEFAULT` por norma en textos y marcas
  (`NVARCHAR(...) NOT NULL DEFAULT ''`, `BIT NOT NULL DEFAULT ((1))`); `NULL` solo cuando la
  ausencia de valor tiene significado real.
- Baja lógica homogénea: `FechaAlta DATETIME NOT NULL DEFAULT GETDATE()` y
  `FechaBaja DATETIME NULL`. Toda entidad nueva la lleva.
- Tipos: importes `DECIMAL(18,6)` o `DECIMAL(18,2)` según magnitud (nunca `FLOAT` para
  dinero), superficies `DECIMAL(10,2)`, textos `NVARCHAR` (nunca `VARCHAR`), fechas sin
  hora `DATE`.
- Las columnas deprecadas se marcan con comentario en línea indicando el motivo y en qué
  publish desaparecen. **Nunca se sustituye una columna en un solo paso**: primero se añade
  la nueva y se migran los datos, y en un publish posterior se elimina la antigua.

### 5.3 Índices

- Índice por cada columna usada como clave foránea lógica y por las columnas de filtro
  habituales (año o campaña, estado, hash).
- Los índices se declaran en el SSDT junto a la tabla, no como script suelto.

### 5.4 Stored Procedures

- **Todo acceso a datos pasa por SP.** Nombre `sp_AccionEntidad`, esquema `dbo` explícito.
- Cabecera de comentario (§3.3).
- `SET NOCOUNT ON;` siempre como primera instrucción.
- Parámetros opcionales con valor por defecto (`= NULL`).
- Estructura obligatoria de un SP de escritura:

```sql
CREATE PROCEDURE dbo.sp_ActualizarEntidad
    @IdEntidad   INT,
    @Campo       NVARCHAR(100),
    @Activo      BIT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Entidades WHERE IdEntidad = @IdEntidad)
        BEGIN
            RAISERROR('La entidad no existe', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.Entidades WHERE Campo = @Campo AND IdEntidad <> @IdEntidad)
        BEGIN
            RAISERROR('Ya existe otra entidad con ese nombre', 16, 1);
            RETURN;
        END

        UPDATE dbo.Entidades
        SET Campo  = @Campo,
            Activo = @Activo
        WHERE IdEntidad = @IdEntidad;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
```

- SP de lectura: `SELECT` con **columnas explícitas** (nunca `SELECT *`), `ORDER BY`
  determinista y sin transacción.
- SP de inserción: devuelve el nuevo identificador por `OUTPUT`.
- SP de borrado: baja lógica (`FechaBaja`) salvo que el diseño exija borrado físico; si es
  físico y hay dependientes, se borran en cascada explícita dentro de la misma transacción.
- Los mensajes de `RAISERROR` son texto de usuario en español, severidad 16.
- Listas y filtros múltiples por **TVP**, nunca por cadena concatenada.
  Convención: TVP vacío = "sin restricción / todas".
- **SQL dinámico prohibido** salvo caso justificado; en ese caso siempre parametrizado con
  `sp_executesql`, nunca concatenando valores de usuario.

### 5.5 Migraciones

- Cambios incrementales en `ScriptsSQL/ACTUALIZACIONES/`, con numeración correlativa
  (`Migracion_0NN_descripcion.sql`) y **reentrantes**: comprobar `IF NOT EXISTS` antes de
  crear o alterar, de modo que ejecutarlas dos veces no rompa nada.
- Las correcciones puntuales van a `ScriptsSQL/PATCHES/`.
- Las migraciones de una sola vez (siembras, normalizaciones) dejan **marca en la tabla de
  parámetros del sistema** para no repetirse.
- Toda migración la ejecuta la persona responsable, nunca el asistente.

---

## 6. Normas de interfaz (WPF)

### 6.1 MVVM estricto

- La lógica vive en el ViewModel; el código subyacente solo tiene lo que WPF obliga.
- Los ViewModels heredan de `BaseVistaModelo` y usan `SetProperty`.
- Comandos como `ICommand` (`ComandoRelay`). **Gotcha**: si la condición de `CanExecute`
  cambia sobre el mismo objeto ya enlazado, hay que llamar a `RaiseCanExecuteChanged()` o el
  botón se queda deshabilitado para siempre.
- Las colecciones de listado se repueblan con `ColeccionObservable<T>.Reemplazar(...)`
  (una sola notificación `Reset`), **nunca** con un bucle de `Add` por elemento: es la causa
  habitual de listados lentos y parpadeo.

### 6.2 Estilos

- **Prohibido inventar estilos, colores o converters.** Se usan los de `Recursos/Estilos/`.
- Nada de colores literales en las vistas: siempre recurso de la paleta, para que los temas
  (Light / Dark / HighContrast) funcionen.
- Estilos obligatorios por tipo de campo (altura y proporciones uniformes):

| Elemento | Estilo | Altura |
|---|---|---|
| TextBox | `CajaTexto` | 34 px |
| TextBox multilínea | `CajaTextoMultiLinea` | 80 px |
| ComboBox | `ComboCajaTexto` | 34 px |
| ComboBox editable | `ComboCajaTextoEditable` | 34 px |
| CheckBox | `CheckBoxEstilo` | — |
| DatePicker | `CalendarioModerno` | 34 px |
| Etiqueta de campo | `LabelCampo` | — |
| Botón primario | `BotonPrimario` | 32 px |
| Botón secundario | `BotonSecundario` | 32 px |

- Preferir `Setters` simples a `ControlTemplate` cuando el resultado sea equivalente.
- Controles reutilizables en `Controles/`; los específicos de una vista, junto a la vista.

### 6.3 Formularios

- Etiquetas `Margin="0,0,0,4"`, campos `Margin="0,4,0,16"` entre grupos.
- Rejilla de dos columnas: `Width="*"` más separador de 24 px.
- Ventanas modales complejas: `ResizeMode="CanResize"` con `MinWidth` / `MinHeight`.
- Ventanas modales simples: `SizeToContent="WidthAndHeight"`, `WindowStyle="None"` y
  esquinas redondeadas.
- Toda ventana define su `Icon`; si no, hereda el del ejecutable y el resultado es
  incoherente.

### 6.4 DataGrid

- Siempre `Style="{DynamicResource ModernDataGrid}"`.
- **Doble clic obligatorio**: todo DataGrid con acción de editar incluye
  `DataGrid.InputBindings` con `MouseBinding Gesture="LeftDoubleClick"` apuntando al mismo
  comando que el botón de editar.
- Columna de acciones congelada (`FrozenColumnCount="1"`).
- Acceso al ViewModel desde un `DataTemplate` mediante `BindingProxy`.
- **Gotcha de anchos**: un `MaxColumnWidth` en el estilo compartido aplasta todas las
  columnas al maximizar y restaurar; no fijarlo de forma global.

### 6.5 Entrada de datos numéricos

Decimales por magnitud, homogéneos en toda la aplicación:

| Magnitud | Decimales |
|---|---|
| Kilos | 0 |
| Superficie | 2 |
| Importes | 4 |
| Porcentajes | 2 |

- El punto del teclado numérico escribe **coma decimal**.
- El separador de miles se aplica **al perder el foco**; la edición se hace sobre el valor
  crudo.

### 6.6 Redacción de la interfaz

- Microcopia de producto: clara, breve, sin jerga técnica ni nombres de tabla en pantalla.
- Los selectores muestran **solo lo que tiene actividad real**, no el maestro completo:
  antes de crear un combo, mirar cómo lo resuelve una pantalla hermana.
- Textos pensados para quien accede desde fuera de la oficina: nada de "en la oficina" ni
  referencias a la ubicación física.

---

## 7. Seguridad, permisos y alcance

- **Todo se gatea por permiso.** Acción, navegación y visibilidad se comprueban contra el
  recurso afectado: `TieneLectura(ruta)`, `TieneEscritura(ruta)`, `TieneEliminacion(ruta)`
  y `EsAdministrador`.
- El recurso se identifica **por su ruta** (constantes en `RutasRecursos`), que además es la
  clave de navegación. **Nunca** por un identificador numérico fijo; en SQL se localiza por
  nombre.
- Además del permiso, las lecturas de listados se filtran por **alcance** (TVP de alcance);
  y toda escritura o borrado sobre una entidad concreta debe comprobar además que esa
  entidad **está dentro del alcance** del usuario.
- Contraseñas: nunca en claro y nunca versionadas en git. Cadenas de conexión y secretos por
  variable de entorno o configuración externa, jamás en el repositorio.
- Auditoría de toda alta, modificación y borrado (§4.3).
- Consultas siempre parametrizadas (consecuencia directa de "solo SP" con parámetros).

---

## 8. Rendimiento

- Listados: repoblado en bloque (§6.1), virtualización activada, sin recálculos por elemento.
- No cargar el maestro completo cuando basta con lo que tiene actividad.
- Cachés con invalidación explícita; documentar qué invalida cada caché.
- Filtrar en el SP, no en memoria; paginar cuando el volumen lo pida.
- Liberar recursos: `IDisposable` en servicios que abren ficheros, conexiones o
  suscripciones, y desuscribir eventos al cerrar una vista (fuente habitual de fugas).

---

## 9. Documentación (obligatoria en todo proyecto)

Tres destinos, siempre los tres:

1. **`Docs/`** — un documento Markdown **por funcionalidad**: diseño, decisiones y huecos
   pendientes. Es donde se razona.
2. **`Docs/ManualTecnico/`** — salida técnica: cómo está construido, para quien mantiene.
3. **`Docs/Manual/`** — manual de usuario por partes, en lenguaje de usuario final.

Reglas:

- Cada cambio funcional actualiza **el documento de la funcionalidad y los dos manuales**.
- Las fechas se escriben **absolutas** (`19/08/2026`), nunca "la semana pasada".
- Las decisiones cerradas se registran con su motivo; las abiertas, marcadas como tales.

---

## 10. Flujo de creación de una entidad nueva

Siempre en este orden:

1. **Tabla** en el proyecto SSDT (con sus índices) y, si aplica, migración incremental.
2. **Stored Procedures** en el SSDT (`Cargar`, `CargarPorId`, `Insertar`, `Actualizar`,
   `Eliminar`) y sus nombres en la clase `Constantes`.
3. **Modelo** en `Negocio/` (hereda de la base de notificación si va a enlace de datos).
4. **Interfaz** `IRepoEntidad` en `Negocio/IRepos/`.
5. **Repositorio** `RepoEntidad` en `Datos/` (patrón dual y auditoría).
6. **DTO y Validator** en `Aplicacion/Validacion/`.
7. **Vista** `EntidadForm.xaml`.
8. **ViewModel** `EntidadFormViewModel`.
9. **Registro en la inyección de dependencias**.
10. **Navegación y recurso de permisos**: ruta en `RutasRecursos`, alta del recurso y
    asignación a roles.
11. **Documentación** (§9).

---

## 11. Compilación y entrega

```bash
dotnet restore <Solucion>.sln
dotnet build <Solucion>.sln
dotnet build <Solucion>.sln -c Release
```

- Se entrega compilando **sin errores ni avisos nuevos**.
- Orden de despliegue cuando hay cambios de base de datos:
  **1) publish del SSDT → 2) binario**. Nunca al revés.
- Git: ramas, commits y publicación los gestiona la persona responsable. Los mensajes de
  commit, en español, describen el **cambio funcional**, no los ficheros tocados.

---

## 12. Checklist antes de dar por terminado

- [ ] ¿Está en la capa arquitectónica correcta?
- [ ] ¿Respeta los patrones (repositorio dual, clases base, dependencias por interfaz)?
- [ ] ¿Respeta la convención de nombres?
- [ ] ¿Acceso a datos solo por SP, con el nombre tomado de `Constantes`?
- [ ] ¿SQL sin Foreign Keys, con `SET NOCOUNT ON`, transacción y `TRY/CATCH`?
- [ ] ¿Cambios de esquema en el SSDT (no solo en scripts sueltos) y migración reentrante?
- [ ] ¿Valida por DTO antes de persistir?
- [ ] ¿Registra auditoría en altas, modificaciones y bajas?
- [ ] ¿Gateado por permiso **y** por alcance?
- [ ] ¿Cabeceras de fichero y de función, sin comentarios XML, sin trazas de depuración?
- [ ] ¿Estilos existentes, sin colores literales, doble clic en los DataGrid?
- [ ] ¿Listados repoblados en bloque?
- [ ] ¿UTF-8, CRLF, 4 espacios?
- [ ] ¿Documentación actualizada en `Docs/`, `ManualTecnico/` y `Manual/`?
- [ ] ¿No se ha inventado nada?
