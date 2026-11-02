# Guía global — Tecnintegra (JMMFH)

Se aplica a todos los proyectos. La guía de cada proyecto (`CLAUDE.md` en su raíz) completa o matiza lo que hay aquí; en caso de conflicto, manda la del proyecto.

## Idioma y comunicación

- Responder siempre en **español de España**. Respuestas cortas y directas; sin preámbulos ni resúmenes de lo hecho.
- No mostrar código hasta que se solicite explícitamente. Cuando se diseña desde la lógica (análisis, arquitectura, flujos), se diseña; el código viene después.
- Si falta información, **preguntar** antes de decidir o inventar.
- **Nunca inventar** tablas, columnas, Stored Procedures, clases, estilos, rutas ni nombres.
- Al proponer o modificar un archivo, entregar el archivo completo listo para copiar y pegar, no fragmentos.
- Cuando se detecten mejoras plausibles en código existente, proponerlas con justificación. No aplicar sin aprobación.

## Gestión del proyecto y continuidad

Todo proyecto Tecnintegra tiene en su raíz (plantilla `JMMFH/plantilla-proyecto`):

| Archivo | Qué es |
|---|---|
| `CLAUDE.md` | Contexto, estructura y reglas del proyecto |
| `ESTADO.md` | Punto exacto en que está el trabajo: en curso, siguiente paso, bloqueos |
| `PENDIENTES.md` | Lista completa de tareas por prioridad (incluye el backlog de versiones futuras) |
| `Documentacion/decisiones/` | Registro de decisiones de diseño, una por archivo |
| `Documentacion/diseno/` | Resúmenes de los chats de diseño hechos en claude.ai |
| `.claude/commands/` | `/inicio`, `/cierre`, `/decision`, `/importar-diseno` |

- Si un proyecto no tiene estos archivos, proponer crearlos desde la plantilla antes de empezar.
- Al empezar una sesión, leer `ESTADO.md` y `PENDIENTES.md` (el hook de inicio los carga; si no aparecen, leerlos).
- **Una tarea por sesión.** Al terminar, seguir los pasos de `.claude/commands/cierre.md` aunque no se invoque `/cierre`.
- Al cerrar una sesión con aprendizajes de dominio o decisiones de diseño, registrarlos en `Documentacion/` (decisiones con `/decision`). Nada importante queda solo en la memoria local de Claude: no viaja entre equipos y se borra con el tiempo.
- `Documentos/` = documentación externa recibida (cliente, terceros): solo lectura. `Documentacion/` = documentación propia del proyecto.

### Documentación funcional por módulo
- En `Documentacion/`, un fichero **`NombreModulo_Funcionalidad.md`** por cada módulo del sistema (ej: `Envios_Funcionalidad.md`, `Scraper_Funcionalidad.md`). Describe la funcionalidad implementada: qué hace, cómo funciona, flujos principales y particularidades.
- Se actualiza cuando cambia la funcionalidad del módulo. Sirve de base para el manual de usuario y para retomar el desarrollo sin perder contexto.

## Proceso de trabajo (Tecnología, Integración y Talento, S.L.)

- Tareas no triviales (informes, rediseños, nuevos módulos): proponer diseño primero (columnas, reglas de cálculo, patrón de UI, contratos de API/SPs) y obtener OK antes de escribir.
- Ante ambigüedad de negocio: enumerar opciones con pros/contras y pedir decisión, no asumir.
- Cuando el usuario valida con una preferencia concisa ("vía B", "ok"), asumir validación de la propuesta previa completa; no reabrir la negociación.

## Control de código fuente

- Trabajamos con **Git**. **No hacer commit ni push** salvo que se pida explícitamente; el usuario gestiona git a mano. Al cerrar una tarea, proponer el mensaje de commit y la lista de archivos.
- Todos los cambios de BD quedan versionados en el proyecto SQL.

## Stack tecnológico habitual

- **C# / .NET** (últimas versiones estables) · **WPF** · **SQL Server** · **FluentValidation**
- IDE: **Visual Studio** (no VS Code para proyectos .NET de escritorio)

## Estilo de código C#

- Cabeceras `// ===` obligatorias en todos los `.cs` (formato exacto en el `CLAUDE.md` de cada proyecto). **Nunca** comentarios XML `///`.
- `Nullable: enable` — Nullable reference types obligatorio.
- `ImplicitUsings: enable`
- Encoding: **UTF-8** en todos los archivos. Line endings: **CRLF** (Windows).
- Indentación: **4 espacios** en C# y XAML, **2 espacios** en XML/JSON.
- Campos privados: `_camelCase` (`_nombre`, `_repoEmpresas`).
- Propiedades y métodos: `PascalCase` (`CargarDatos()`, `NombreCompleto`).
- Interfaces: `IPrefijo` (`IRepoProductores`, `IServicioDialogos`).

## Convenciones SQL Server

- Tablas: **Plural**, PascalCase (`Productores`, `SociosCampañas`).
- Columnas:
  - PK: `Id` + nombre tabla en **singular** (`IdCultivo`, `IdProductor`).
  - Nombre principal: nombre tabla en **singular** (`Cultivo`, `Variedad`, `Productor`).
  - Resto de campos: PascalCase descriptivo (`Descripcion`, `Activo`, `FechaAlta`).
- Stored Procedures: `sp_AccionEntidad` (`sp_CargarProductores`, `sp_InsertarEmpresa`), definidos con `CREATE PROCEDURE` (no `CREATE OR ALTER`).
- Constantes de SP en clase dedicada del proyecto de datos.
- **Sin Foreign Keys** (salvo autorización expresa) — la integridad referencial se gestiona en la aplicación. **Sin ON DELETE CASCADE**.
- **Todo acceso a datos mediante Stored Procedures** — nunca SQL inline.
- En los SELECT con JOIN, usar alias + `AS` para mapear al nombre del modelo C# (ej: `cu.Cultivo AS CultivoNombre`).
- Cadenas de conexión por variable de entorno `ConnectionStrings__<Proyecto>`; nunca en código ni en el repositorio.
- Secretos (credenciales, API keys, tokens) nunca en código, repositorio ni logs.
- Escrituras en bases de datos reales, despliegues y cualquier acción sobre servidores de producción: siempre con confirmación previa del usuario.
- Scripts de cambios en producción: idempotentes y filtrando por claves estables (códigos, rutas), nunca por IDs numéricos (difieren entre instancias).
- Ficheros seed = instalaciones nuevas. Cambios en BD desplegadas = patches versionados.

## Proyectos con SQL Server Database Project (SSDT / .sqlproj)

- Cuando se cree o modifique cualquier objeto de base de datos (SP, tabla, vista, tipo, etc.), **SIEMPRE**:
  1. Crear/editar el fichero `.sql` en la carpeta correspondiente del proyecto SQL (`dbo/Stored Procedures/`, `dbo/Tables/`, etc.).
  2. Registrar el fichero en el `.sqlproj` añadiendo `<Build Include="..." />` en el `<ItemGroup>` correspondiente.
- El usuario publica el proyecto SQL desde Visual Studio para desplegar cambios en la BD. **No ejecuta scripts manualmente.** Si un objeto no está en el `.sqlproj`, no se desplegará.
- Esta regla es **innegociable** y aplica a cualquier proyecto que tenga un `.sqlproj`.

## Arquitectura habitual (proyectos WPF + SQL Server)

- Patrón **MVVM estricto**: lógica en ViewModel, no en code-behind.
- Arquitectura en capas: Presentación → Aplicación → Negocio → Datos → SQL Server.
- Modelos de dominio con `INotifyPropertyChanged` para binding.
- ViewModels con Commands (`ICommand` / `RelayCommand`).
- Validación con **FluentValidation** mediante DTOs antes de persistir.
- Inyección de dependencias con `Microsoft.Extensions.DependencyInjection`.

## Diseño de informes y semántica del dominio

- Un informe = una opción de menú. Si admite varios ejes de agrupación, se hace UNA vista con selector de eje y UN servicio/SP con flags. Las opciones viejas se ocultan (no se redirigen).
- Capa semántica en BD (vistas/SPs dedicados) como única fuente de verdad; UI, PDFs e integraciones PowerBI leen de ahí.
- Columnas que dependen del contexto (campaña/producto/cliente) no se hardcodean: se descubren en runtime desde tablas de configuración.
- Coherencia numérica: validar contra el Excel/fuente original del usuario.
- No colapsar cifras con significado distinto en una sola columna (entregado vs. aceptado, estimado vs. real, comprometido vs. facturado).
- Proyectos con jerarquía de usuarios: siempre aplicar alcance de sesión en los listados/informes (RLS a nivel SP).

## Normas UI/UX (universales: WPF, Web, Móvil, etc.)

Aplican a **cualquier tipo de proyecto** (WPF, ASP.NET, Blazor, React, móvil nativo, etc.) para mantener uniformidad entre todas las aplicaciones.

### Tablas/Grids de datos
- **Altura de fila suficiente** para ver botones de acción y contenido sin apretar (equivalente a 34px en desktop; en móvil/web usar espaciado proporcional con `padding` en filas).
- **Doble click / doble tap siempre abre el registro en edición/visualización**. Patrón obligatorio en cualquier framework:
  - WPF: `DataGrid.InputBindings` con `MouseBinding Gesture="LeftDoubleClick"`.
  - Web: handler `onDoubleClick` en la fila.
  - Móvil: gesto `onDoublePress` o acción principal configurable.
  - Si la fila no es editable por permisos/estado, el comando debe estar **deshabilitado** (visual greyed-out), **nunca** quitar el binding/handler.
- **Primera columna fija/congelada** con botones de acción (editar, eliminar, ver).
- **Sin filas extra de edición inline** por defecto (prefiere diálogo modal o navegación a vista detalle).
- **Cabeceras de columna visibles**, sin cabecera de fila.
- Todos los grids del mismo tipo deben usar el **mismo estilo base** definido en el sistema de diseño del proyecto.

### Ventanas/Diálogos modales con cabecera personalizada
- Los botones de **maximizar/cerrar** deben quedar **pegados al borde superior derecho** de la ventana, sin padding ni margen intermedio.
- Implementación:
  - **No** poner `padding` en el contenedor de la cabecera.
  - Poner el margen/padding en el contenido interno (título, datos), no en el contenedor exterior.
  - Los botones alineados arriba-derecha (`top: 0; right: 0`).
- La cabecera debe permitir arrastrar la ventana cuando aplique (WPF: `DragMove()`; Web: librerías de modales draggable; móvil: no aplica).

### Tipos de pantallas (a catalogar en cada proyecto)
- **Listado con filtros/búsqueda** — grid principal con filtros arriba, búsqueda global, botones de acción masiva.
- **Formulario embebido con subtablas** — formulario padre con grids de hijos (detalle/cláusulas/etc.).
- **Diálogo modal de edición** — cabecera con título + botones cerrar, contenido con campos, footer con Guardar/Cancelar.
- **Grid de baremos/rangos** — tabla editable con soporte de paste desde portapapeles (Excel).

### Estilos visuales comunes
- **Campos de entrada** de la misma altura en un mismo formulario (no mezclar alturas distintas para TextBox, ComboBox, DatePicker).
- **Labels** siempre encima del campo, nunca al lado, para soportar responsive.
- **Botones primarios** (acciones principales): color fuerte, posición derecha en footers.
- **Botones secundarios** (cancelar, cerrar): menos prominentes, posición izquierda.
- **Iconos coherentes** en botones de acción (editar=lápiz, eliminar=papelera, guardar=disquete/check).

## Referencias por plataforma

- **WPF**: patrones técnicos recurrentes (doble click en DataGrid, selección estilo Excel, columnas dinámicas, export a Excel, eliminación diferida…) en `~/.claude/wpf.md`. Consultarlo al arrancar un proyecto WPF nuevo o al añadir un listado/formulario con esos patrones.