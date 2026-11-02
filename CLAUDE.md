# Guía global — Tecnintegra (JMMFH)

Se aplica a todos los proyectos. La guía de cada proyecto (`CLAUDE.md` en su raíz) completa o matiza lo que hay aquí, nunca lo contradice.

Norma corporativa completa de código y BD: `~/.claude/Normas_Desarrollo_Corporativas.md` (copia del maestro del repositorio `claude-config`). Leerla antes de crear código o SQL en un proyecto .NET/SQL Server.

## Idioma y comunicación

- **Español de España** en todo: respuestas, código, comentarios, SQL, interfaz, documentación.
- Respuestas cortas y directas; sin preámbulos ni resúmenes de lo hecho.
- No mostrar código hasta que se solicite. Cuando se diseña desde la lógica (análisis, arquitectura, flujos), se diseña; el código viene después.
- **Prohibido inventar**: tablas, columnas, Stored Procedures, clases, estilos, rutas, nombres, campos o heurísticas. Si falta información, **preguntar**.
- Si la duda se resuelve mirando el repositorio, mirarlo en vez de preguntar. Preguntar solo lo que no está en el repositorio.
- Al proponer o modificar un archivo, entregar el archivo completo listo para copiar y pegar, no fragmentos.
- Cuando se detecten mejoras plausibles en código existente, proponerlas con justificación; no aplicarlas sin aprobación.

## Cómo se decide

- **Acordar antes de codificar.** Ante una petición ambigua o no trivial (informes, rediseños, módulos nuevos): diagnosticar y proponer (columnas, reglas de cálculo, patrón de UI, contratos de API/SPs); no editar código hasta que haya acuerdo explícito.
- Ante ambigüedad de negocio: enumerar opciones con pros/contras y pedir decisión, no asumir.
- **Varias decisiones abiertas → tabla numerada**: nº · pregunta · opción A · opción B · recomendación, y debajo solo las notas imprescindibles. El usuario contesta "1.A, 2.B…" y eso es el acuerdo para codificar. Una sola pregunta puede ir en prosa.
- Cuando el usuario valida con una preferencia concisa ("vía B", "ok"), asumir validación de la propuesta previa completa; no reabrir la negociación.
- **Consensuar antes cualquier cambio de producto/UX** (ocultar o quitar elementos, cambiar comportamiento visible, textos, layout): presentar opciones y esperar su elección, aunque la "obvia" parezca clara. En cambios funcionales ya acordados, ejecutar y listar qué se tocó para que pueda vetar.
- **Componente estético** (iconos, pantallas, maquetas): decidir primero la dirección enseñándole varias opciones en una maqueta HTML sobre el mismo contenido; fijar las reglas técnicas después. Verificar mirando el resultado, no solo midiendo.
- Verificar a fondo donde el error cuesta caro (SQL, datos, esquemas, nombres de columnas/SP, dinero); en cambios de bajo riesgo (textos, XAML acotado, logs) ir directo.

## Qué ejecuta Claude y qué ejecuta el usuario

| Claude, sin pedir permiso | Solo el usuario (Claude entrega el comando exacto) |
|---|---|
| `dotnet build`, `dotnet test`, Build del `.sqlproj` con MSBuild, para verificar lo que acaba de escribir | `dotnet publish`, `dotnet pack`, `nuget push`, publish del SSDT, empaquetados, despliegues: **nunca por iniciativa propia, tampoco "para comprobar"**; una autorización no vale para la siguiente vez |
| Ediciones de ficheros, andamiaje de proyectos, lecturas y diagnósticos de solo lectura | **Git**: ni commit ni push, ni ofrecerlo. Al cerrar, proponer mensaje y lista de archivos |
| | **Cualquier ejecución contra una base de datos**: se entrega el script y el paso exacto |
| | **Cambios en servidores**: comandos de uno en uno, un bloque PowerShell por paso con lo que hace y la salida esperada, esperando su salida antes del siguiente |

Entregar código sin comprobar que compila y que las pruebas pasan es trabajo a medias. Anunciar lo que se va a hacer no equivale a pedir permiso.

**Nada en la nube de Claude**: no publicar artefactos ni páginas desde Claude Code. Documentos y maquetas se entregan como `.html` autocontenido o `.docx` en una carpeta local del proyecto.

## Gestión del proyecto y continuidad

Todo proyecto Tecnintegra tiene en su raíz (plantilla `JMMFH/plantilla-proyecto`):

| Archivo | Qué es |
|---|---|
| `CLAUDE.md` | Contexto, estructura y reglas del proyecto |
| `ESTADO.md` | Punto exacto en que está el trabajo: en curso, siguiente paso, bloqueos |
| `PENDIENTES.md` | **La única lista de tareas** del proyecto, por prioridad (incluye el backlog de versiones futuras) |
| `Documentacion/decisiones/` | Registro de decisiones de diseño, una por archivo |
| `Documentacion/diseno/` | Resúmenes de los chats de diseño hechos en claude.ai |
| `Documentacion/memoria/` | Memorias de Claude Code del proyecto (aprendizajes, feedback, referencias), versionadas |
| `.claude/commands/` | `/inicio`, `/cierre`, `/decision`, `/importar-diseno` |

- Si un proyecto no tiene estos archivos, proponer crearlos desde la plantilla antes de empezar.
- Al empezar una sesión, leer `ESTADO.md` y `PENDIENTES.md` (el hook de inicio los carga; si no aparecen, leerlos). Leer también `Documentacion/memoria/` cuando exista.
- **Una tarea por sesión.** Al terminar, seguir los pasos de `.claude/commands/cierre.md` aunque no se invoque `/cierre`.
- **Una sola organización.** Las tareas viven en `PENDIENTES.md` y en ningún otro sitio. Nunca crear documentos paralelos de estado, plan, roadmap o seguimiento; si aparece algo nuevo, es una tarea en `PENDIENTES.md` o una decisión en `decisiones/`. Un documento que quede desfasado lleva nota de archivo en cabecera apuntando al vigente.
- Los aprendizajes de dominio, el feedback del usuario y las referencias técnicas que Claude Code guarde en su memoria local se copian a `Documentacion/memoria/` al cerrar la sesión (script `migrar-memorias.ps1` de `claude-config`, o a mano). Nada importante queda solo en la memoria local: no viaja entre equipos y se borra con el tiempo.
- `Documentos/` = documentación externa recibida (cliente, terceros): solo lectura. `Documentacion/` = documentación propia del proyecto.

### Documentación propia (`Documentacion/`)
- Un fichero **`NombreModulo_Funcionalidad.md`** por cada módulo del sistema: qué hace, cómo funciona, flujos principales y particularidades.
- **`Documentacion/ManualTecnico/`**: manual técnico en Markdown (`manual_tecnico_<proyecto>.md`).
- **`Documentacion/Manual/`**: manual de usuario (`manual_usuario_<producto>.md`), solo en proyectos con cliente final. El Markdown es la fuente; el Word se genera después a partir de él, nunca al revés.
- **Cada cambio funcional actualiza la documentación en el mismo cambio**: el `.md` del módulo afectado, el manual técnico y el manual de usuario. Separar siempre lo implementado de lo previsto, con fecha. Un manual actualizado "cuando haya tiempo" es un manual falso.

## Stack tecnológico habitual

- **C# / .NET** (últimas versiones estables) · **WPF** · **SQL Server** · **FluentValidation**
- IDE: **Visual Studio** (no VS Code para proyectos .NET de escritorio)

## Estilo de código C#

- Cabeceras corporativas obligatorias en todos los `.cs`, antes de los `using`, y en las funciones importantes (no en métodos triviales):
  ```csharp
  // ============================================================
  // Objeto  : NombreFichero.cs
  // Autor   : JMMFH (José María Mena)
  // Fecha   : dd/MM/yyyy
  // Desc.   : Descripción en una o varias líneas,
  //           las continuaciones alineadas.
  // ============================================================
  ```
  Para funciones, `Funcion : NombreMetodo` y `Variables: param1 - descripción` en lugar de `Objeto :`.
- **Prohibidos los comentarios XML** (`/// <summary>`, `/// <param>`…). Sin `Debug.WriteLine` en código entregado.
- **Código en español**: variables, funciones, clases, métodos, rutas y campos JSON propios. Identificadores en ASCII (sin tildes ni eñes); comentarios y literales con ortografía completa. Se conservan en inglés solo los estándares de terceros (OpenAI, MCP, HTTP) y los sufijos .NET idiomáticos (`Async`, `Command`, `VM`); las propiedades C# se mapean con `[JsonPropertyName]`. Nada de calcos del inglés en el dominio: se traducen.
- `Nullable: enable`, `ImplicitUsings: enable`. UTF-8, CRLF, 4 espacios en C# y XAML, 2 en XML/JSON.
- Campos privados `_camelCase`; propiedades y métodos `PascalCase`; interfaces `IPrefijo`; separadores de sección `// ── Título ──`.

## Arquitectura (.NET / SQL Server)

- **Capas**: `Presentacion` → `Aplicacion` → `Negocio`; `Datos` → `Negocio`. `Negocio` es núcleo puro, sin dependencias externas. La presentación nunca referencia `Datos`.
- Validar por DTO (FluentValidation) antes de persistir. Auditar toda alta, modificación y baja.
- Todo se gatea por permiso (`TieneLectura` / `TieneEscritura` / `TieneEliminacion` / `EsAdministrador`) identificando el recurso **por su ruta**, nunca por id numérico fijo; y además por **alcance**, también en escritura y borrado. En listados e informes con jerarquía de usuarios, el alcance se aplica a nivel SP.
- Inyección de dependencias con `Microsoft.Extensions.DependencyInjection`.

## Convenciones SQL Server

- **Todo acceso a datos mediante Stored Procedures**, nunca SQL inline. El nombre del SP se toma de la clase estática de constantes del proyecto de datos. Listas y filtros múltiples por TVP, nunca concatenando cadenas.
- Tablas en **plural** PascalCase (`Productores`). PK `Id` + nombre en singular (`IdProductor`); nombre principal en singular (`Productor`); resto PascalCase descriptivo (`FechaAlta`).
- Stored Procedures `sp_AccionEntidad`, definidos con `CREATE PROCEDURE` (no `CREATE OR ALTER`).
- **SP de escritura**: `SET NOCOUNT ON`, `BEGIN TRY` + transacción + `ROLLBACK`/`THROW`, validaciones con `RAISERROR(...,16,1)` en español. Lecturas con columnas explícitas, nunca `SELECT *`. En JOIN, alias + `AS` para mapear al nombre del modelo C#.
- **Sin Foreign Keys y sin `ON DELETE CASCADE`** (salvo autorización expresa): la integridad la gestiona la aplicación.
- Cadenas de conexión por variable de entorno `ConnectionStrings__<Proyecto>`; nunca en código ni en el repositorio. Secretos (credenciales, API keys, tokens) nunca en código, repositorio ni logs.
- No colapsar cifras con significado distinto en una sola columna (entregado vs. aceptado, estimado vs. real). Un informe = una opción de menú; capa semántica en BD (vistas/SPs) como única fuente de verdad; columnas dependientes del contexto se descubren en runtime desde configuración. Coherencia numérica validada contra el Excel/fuente original.

## Proyectos SSDT (`.sqlproj`)

- **La fuente de verdad del esquema y los SP es el proyecto SSDT**, no los scripts sueltos. Todo objeto nuevo o modificado: fichero `.sql` en su carpeta (`dbo/Stored Procedures/`, `dbo/Tables/`…) **y** `<Build Include="..." />` en el `.sqlproj`. Si no está en el `.sqlproj`, no se despliega. Regla innegociable.
- El usuario publica desde Visual Studio. Si un cambio toca tablas: publish del SSDT antes que el binario.
- **Semillas reentrantes**: los catálogos se rellenan una vez desde el post-deploy (`MERGE` / `INSERT … WHERE NOT EXISTS`); cada publicación mantiene lo que existe y no toca el resto. Nunca "borrar y cargar". Lo dinámico se mantiene desde la aplicación.
- El post-deploy es **un único lote** (sin `GO`): variables con nombre único por migración. Columna nueva en tabla con datos: al final de la definición.
- Scripts de cambios en producción: idempotentes, filtrando por claves estables (códigos, rutas), nunca por IDs numéricos. Ficheros seed = instalaciones nuevas; cambios en BD desplegadas = patches versionados.
- **Renombrar tablas o columnas con datos**: no hay `.refactorlog` en la casa. Guion previo de `sp_rename` en una transacción y un solo lote (`BEGIN TRY … COMMIT … CATCH ROLLBACK; THROW`), ejecutado por el usuario en SSMS antes del publish. Nunca desactivar `BlockOnPossibleDataLoss`; tras un publish fallido, revisar el `.publish.xml`.

## Interfaz (WPF)

- MVVM estricto: lógica en ViewModel, no en code-behind. ViewModels sobre `BaseVistaModelo`, modelos con binding sobre `BaseNegocio` (o `INotifyPropertyChanged` / `RelayCommand` propios según proyecto).
- **No inventar estilos, colores ni converters**: usar los de `Recursos/Estilos/`. Nada de colores literales (rompen los temas Light / Dark / HighContrast). Verificar los tres temas.
- Listados: repoblar con `ColeccionObservable<T>.Reemplazar(...)`, nunca con `Add` por elemento.
- Todo DataGrid con acción de editar lleva `InputBindings` con `LeftDoubleClick` (una sola suscripción; ver `~/.claude/wpf.md`).
- Decimales por magnitud: kilos 0, superficie 2, importes 4, porcentajes 2. El punto del teclado numérico escribe coma; los miles se formatean al perder el foco.
- **UI excelente de oficio**: validación en línea en el ViewModel (no dejar que el único feedback sea el `RAISERROR` del SP), campos obligatorios condicionales marcados, avisos contextuales en vez de MessageBox secos, estados de progreso en procesos largos.
- Microcopia de producto: clara, sin jerga técnica ni nombres de tabla en pantalla (nada de "OCR", "RAG", "hash"). Explicar la aplicación sí; explicar el oficio del usuario o avisar de obviedades, no.
- Patrones técnicos recurrentes de WPF en `~/.claude/wpf.md`: consultarlo al arrancar un proyecto WPF o al añadir un listado/formulario.

### Normas UI/UX universales (WPF, Web, Móvil)
- **Grids**: altura de fila suficiente (34 px en escritorio); doble click/doble tap abre el registro; si no es editable, comando deshabilitado, nunca quitar el binding; primera columna fija con botones de acción; sin edición inline por defecto; cabeceras de columna visibles, sin cabecera de fila; mismo estilo base en todos los grids del proyecto.
- **Diálogos modales con cabecera propia**: botones maximizar/cerrar pegados al borde superior derecho (sin padding en el contenedor de cabecera; margen en el contenido interno); cabecera arrastrable (`DragMove()`).
- **Tipos de pantalla a catalogar**: listado con filtros/búsqueda; formulario con subtablas; diálogo modal de edición; grid de baremos/rangos con pegado desde Excel.
- **Estilos comunes**: campos de la misma altura en un formulario; labels encima del campo; botones primarios a la derecha con color fuerte, secundarios a la izquierda; iconos coherentes (editar=lápiz, eliminar=papelera, guardar=check).

## Trampas del entorno (Windows + Git Bash)

- Un heredoc de Bash largo (más de ~8 k caracteres) llega cortado y falla con "unexpected EOF". Para ficheros o scripts largos, usar Write y ejecutar desde fichero.
- Antes de editar por script, detectar el final de línea de **cada** fichero (`git ls-files --eol`, `od -c` o Python contando bytes) y respetarlo; `grep $'\r$'` en Git Bash no detecta CR. En Python, escribir con `write_bytes` o `newline=''` para no convertir LF en CRLF.
- Compilar a una carpeta temporal (`-p:BaseOutputPath=`) si la aplicación está abierta, para no bloquear la prueba del usuario.
