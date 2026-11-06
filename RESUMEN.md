# Sistema de trabajo con Claude Code — Tecnintegra (JMMFH)

> Resumen del sistema montado el 02/11/2026. Léelo si no sabes cómo está organizado el trabajo con Claude Code en esta casa.

## Problema que resuelve

El historial de sesiones de Claude Code vive en `%USERPROFILE%\.claude\projects\` de cada equipo: no viaja entre PCs y Claude Code lo borra por antigüedad. Se perdieron sesiones por eso. La solución: todo lo que importa se escribe en archivos versionados en git, y la configuración global se versiona en un repositorio propio.

## Dos repositorios

### `JMMFH/claude-config` — configuración global (este repositorio)

| Archivo | Destino | Qué es |
|---|---|---|
| `settings.json` | `~/.claude/settings.json` | Ajustes globales: retención del historial 365 días, subagentes con Opus, permisos (`dotnet build/restore/test` permitidos; `sqlcmd`, `git commit`, `git push` bloqueados), contexto de la organización |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Normas globales: idioma, cómo se decide, qué ejecuta Claude y qué el usuario, gestión del proyecto, estilo C#, SQL Server, SSDT, WPF, UI/UX, trampas del entorno |
| `wpf.md` | `~/.claude/wpf.md` | Patrones técnicos recurrentes de WPF |
| `Normas_Desarrollo_Corporativas.md` | `~/.claude/Normas_Desarrollo_Corporativas.md` | Norma corporativa completa de código y BD (maestro; se edita aquí) |
| `instalar.ps1` | — | Copia los anteriores a `~/.claude`, guardando los previos en `D:\ClaudeBackup\config-anterior-<fecha>\` |
| `backup-claude.ps1` | — | Copia acumulativa del historial de sesiones a `%OneDrive%\Backups\ClaudeCode\projects-<EQUIPO>\`; nunca borra en destino |
| `programar-backup.ps1` | — | Tarea programada diaria (21:37) que ejecuta el backup |
| `nuevo-proyecto.ps1` | — | Crea un proyecto desde la plantilla, sustituye marcadores, `git init` y primer commit |
| `migrar-memorias.ps1` | — | Copia `~/.claude/projects/<slug>/memory/*.md` a `Documentacion/memoria/` del repositorio del proyecto |

Regla: se edita en el repositorio, nunca directamente en `~/.claude`. Tras cambiar: commit, push, y en cada equipo `git pull` + `instalar.ps1`.

### `JMMFH/plantilla-proyecto` — plantilla de proyecto (template repository)

Lo que tiene todo proyecto Tecnintegra en su raíz:

| Archivo | Qué es | Quién lo mantiene |
|---|---|---|
| `CLAUDE.md` | Contexto, estructura y reglas del proyecto | Usuario; Claude propone cambios |
| `ESTADO.md` | En curso, siguiente paso, bloqueos, decisiones y diseño recientes, hecho recientemente (máx. 15) | Claude, al cerrar (`/cierre`) |
| `PENDIENTES.md` | **La única lista de tareas** (alta/media/baja), con origen de cada una | Claude y usuario |
| `README.md` | README del proyecto | Usuario |
| `.claude/settings.json` | Hook de inicio + bloqueo git + bloque `environment` del proyecto (servidores, secretos, objetivos sensibles) | Usuario |
| `.claude/hooks/inicio-sesion.ps1` | Hook `SessionStart`: inyecta `ESTADO.md`, `PENDIENTES.md`, `git log -8` y `git status` en cada sesión | — |
| `.claude/commands/` | `/inicio`, `/cierre`, `/decision`, `/importar-diseno` | — |
| `Documentacion/` | Documentación **propia**: `<Modulo>_Funcionalidad.md`, `decisiones/`, `diseno/`, `memoria/`, `ManualTecnico/`, `Manual/`, `claude-ai/` | Claude y usuario |
| `Documentos/` | Documentación **externa** recibida (cliente, terceros). Solo lectura | Usuario |
| `rellenar-plantilla.ps1` | Sustituye `NOMBRE_PROYECTO`, `CLIENTE_PROYECTO`, fecha y equipo; se autoelimina | — |

## Flujo de trabajo

1. **Crear proyecto**: `nuevo-proyecto.ps1 -Nombre X -Cliente "Y"` → crear repo vacío en GitHub → `remote add` + `push` → rellenar `RELLENAR` de `CLAUDE.md` y `README.md` (Claude Code puede hacerlo desde la solución) y `environment` de `.claude/settings.json` → proyecto en claude.ai con `Documentacion/claude-ai/instrucciones-proyecto.md` y `CLAUDE.md`, `ESTADO.md`, `PENDIENTES.md` como conocimiento.
2. **Cada sesión**: `/inicio` → **una tarea** → `/cierre` (actualiza `ESTADO.md` y `PENDIENTES.md`, registra decisiones, propone commit) → el usuario hace el commit → `migrar-memorias.ps1 -Proyecto <ruta>`.
3. **Decisiones**: `/decision <título>` → `Documentacion/decisiones/NNNN-titulo.md` (contexto, opciones, decisión, consecuencias). No se editan: se sustituyen por una nueva.
4. **Diseño en claude.ai**: al cerrar el chat, pegar `Documentacion/claude-ai/cierre-diseno.md` → guardar la respuesta en `Documentacion/diseno/AAAA-MM-DD-tema.md` → `/importar-diseno <ruta>` en Claude Code, que contrasta con el código antes de aplicar.
5. **Documentación**: cada cambio funcional actualiza en el mismo cambio el `<Modulo>_Funcionalidad.md`, `ManualTecnico/` y `Manual/` (si hay cliente final). Markdown es la fuente; Word se genera después.

## Reglas clave (detalle en CLAUDE.md global)

- Español de España en todo. Respuestas cortas. Prohibido inventar; preguntar si falta información, mirar el repositorio si la respuesta está ahí.
- Acordar antes de codificar. Varias decisiones abiertas → tabla numerada con opciones A/B y recomendación.
- Claude compila y prueba (`dotnet build/test`, Build del `.sqlproj`) para verificar lo suyo. **Nunca**: `publish`, `pack`, `nuget push`, publish SSDT, despliegues, commits, push, ejecuciones contra BD, cambios en servidores. Entrega el comando y lo ejecuta el usuario.
- Una sola organización: tareas solo en `PENDIENTES.md`. Nada de roadmaps ni documentos de estado paralelos.
- Nada importante solo en la memoria local de Claude: va a `Documentacion/`.
- Nada en la nube de Claude desde Claude Code: HTML o Word en local.
- `Documentos/` = externo, solo lectura. `Documentacion/` = propio.

## Decisiones tomadas al montar el sistema (02/11/2026)

- `ESTADO.md` y `PENDIENTES.md` en la raíz, no en `Docs/`.
- Carpeta estándar `Documentacion/` (sin tilde); `Documentos/` para lo externo. TSIA y SIA conservan `Docs/` hasta que se adapten.
- `PENDIENTES.md` sustituye a cualquier árbol o roadmap de tareas (incluida la guía de módulos de TSIA): las tareas se mueven ahí y el documento antiguo queda con nota de archivo.
- Pendientes en `PENDIENTES.md`, no en GitHub Issues.
- Memorias locales de Claude Code versionadas en `Documentacion/memoria/` de cada proyecto.
- Backup de chats en OneDrive (acumulativo, por equipo); copias previas de configuración en `D:\ClaudeBackup`.
- Los chats de claude.ai no se pueden respaldar: lo que importa de ellos se captura con `cierre-diseno.md`.

## Equipos

- BE-DELL (usuario `JOSEMARIAMENAFERNAND`) y el equipo `Josemari`, que es el que tiene los proyectos actualizados y las memorias históricas. Ambos con `claude-config` instalado y backup programado.

## Pendiente de comprobar

- Que el hook `SessionStart` se ejecuta bien en Windows (al abrir Claude Code debe aparecer `ESTADO.md` en el contexto).
- Si las reglas `autoMode` del proyecto se suman a las globales o las sustituyen (`/permissions`); si las globales no aparecen, copiarlas al `settings.json` del proyecto.
- Adaptar TSIA, SIA, GestionEnvios, SGA, Infraestructura y TECNINTEGRA a la plantilla (procedimiento en `PLANTILLA.md`, sección "Adaptar un proyecto existente").