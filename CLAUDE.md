# Guía global — Tecnintegra (JMMFH)

Se aplica a todos los proyectos. La guía de cada proyecto (`CLAUDE.md` en su raíz) completa o matiza lo que hay aquí; en caso de conflicto, manda la del proyecto.

## Idioma y estilo

- Responde siempre en español. Breve y concreto; sin preámbulos.
- Si no sabes algo, pregunta antes de decidir.
- Al proponer o modificar un archivo, entrega el archivo completo listo para copiar y pegar, no fragmentos.
- Cuando se diseña desde la lógica (análisis, arquitectura, flujos), no escribas código hasta que se pida.

## Gestión del proyecto

Todo proyecto Tecnintegra tiene en su raíz:

| Archivo | Qué es |
|---|---|
| `CLAUDE.md` | Contexto, estructura y reglas del proyecto |
| `ESTADO.md` | Punto exacto en que está el trabajo |
| `PENDIENTES.md` | Lista completa de tareas por prioridad |
| `Documentacion/decisiones/` | Registro de decisiones de diseño |
| `.claude/commands/` | `/inicio`, `/cierre`, `/decision`, `/importar-diseno` |

- Si un proyecto no tiene estos archivos, propón crearlos desde la plantilla `JMMFH/plantilla-proyecto` antes de empezar a trabajar.
- Al empezar una sesión, lee `ESTADO.md` y `PENDIENTES.md` (el hook de inicio los carga; si no aparecen, léelos tú).
- Una tarea por sesión. Al terminar, sigue los pasos de `.claude/commands/cierre.md` aunque el usuario no invoque `/cierre`.
- `Documentos/` contiene documentación externa recibida (cliente, terceros): solo lectura. `Documentacion/` contiene la documentación propia del proyecto: todo lo que necesites como referencia va ahí, nunca solo en tu memoria local, porque debe viajar con el repositorio.

## Git

- No hagas commits ni push. El usuario gestiona git a mano.
- Al cerrar una tarea, propón el mensaje de commit y la lista de archivos a incluir.

## Código (.NET / SQL Server)

- Cabeceras `// ===` obligatorias en todos los `.cs` (formato exacto en el `CLAUDE.md` de cada proyecto). Nunca comentarios XML `///`.
- Acceso a datos solo mediante procedimientos almacenados. DDL en el proyecto SSDT (`.sqlproj`). `CREATE PROCEDURE`, no `CREATE OR ALTER`. Sin FK salvo autorización expresa.
- Cadenas de conexión por variable de entorno `ConnectionStrings__<Proyecto>`; nunca en código ni en el repositorio.
- Escrituras en bases de datos reales, despliegues y cualquier acción sobre servidores de producción: siempre con confirmación previa del usuario.
- Secretos (credenciales, API keys, tokens) nunca en código, repositorio ni logs.
