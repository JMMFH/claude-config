# claude-config — Configuración global de Claude Code (Tecnintegra / JMMFH)

Configuración de usuario de Claude Code, versionada para tenerla idéntica en todos los equipos.

## Contenido

| Archivo | Destino | Qué hace |
|---|---|---|
| `settings.json` | `%USERPROFILE%\.claude\settings.json` | Ajustes globales: retención del historial (365 días), modelo de subagentes, permisos comunes, bloqueo de `git commit`/`push`, contexto de la organización |
| `CLAUDE.md` | `%USERPROFILE%\.claude\CLAUDE.md` | Normas globales que Claude aplica en todos los proyectos |
| `instalar.ps1` | — | Copia los dos archivos anteriores a `.claude` (con copia de seguridad de los existentes) |
| `backup-claude.ps1` | — | Copia acumulativa del historial de sesiones y la configuración a OneDrive |
| `programar-backup.ps1` | — | Crea la tarea programada diaria que ejecuta el backup |
| `nuevo-proyecto.ps1` | — | Crea un proyecto nuevo a partir de [`JMMFH/plantilla-proyecto`](https://github.com/JMMFH/plantilla-proyecto) |

## Instalación en un equipo nuevo

```powershell
git clone https://github.com/JMMFH/claude-config.git D:\Proyectos\claude-config
cd D:\Proyectos\claude-config
.\instalar.ps1 -ProgramarBackup
```

Si PowerShell bloquea los scripts: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

## Después de cambiar algo

1. Edita el archivo en este repositorio, nunca directamente en `%USERPROFILE%\.claude`.
2. Commit y push.
3. En cada equipo: `git pull` y `.\instalar.ps1`.

## Crear un proyecto nuevo

```powershell
.\nuevo-proyecto.ps1 -Nombre MiProyecto -Cliente "Nombre del cliente"
```

## Copia de seguridad del historial

- Destino: `%OneDrive%\Backups\ClaudeCode\projects-<EQUIPO>\`.
- Es acumulativa: nunca borra en el destino. Lo que Claude Code elimine por antigüedad sigue en la copia.
- Cada equipo escribe en su propia subcarpeta, así dos PCs no se pisan.
- Registro en `backup.log` dentro del destino.
- Ejecutar a mano: `.\backup-claude.ps1`. Probar la tarea: `Start-ScheduledTask -TaskName 'Backup Claude Code'`.

## Qué no se versiona ni se respalda

- `%USERPROFILE%\.claude.json`: tokens de sesión y estado interno.
- Configuración por proyecto: va en el `.claude/settings.json` de cada repositorio.
