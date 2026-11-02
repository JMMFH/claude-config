# ============================================================
# Objeto  : backup-claude.ps1
# Autor   : JMMFH (José María Mena)
# Fecha   : 02/11/2026
# Desc.   : Copia de seguridad acumulativa del historial de
#           sesiones de Claude Code (%USERPROFILE%\.claude\projects)
#           y de la configuración global a OneDrive.
#           Nunca borra nada en el destino: lo que Claude Code
#           elimine por antigüedad sigue en la copia.
#           Cada equipo escribe en su propia subcarpeta.
# Uso     : .\backup-claude.ps1 [-Destino <ruta>]
# ============================================================

param(
    [string]$Destino
)

$ErrorActionPreference = 'Stop'

if (-not $Destino) {
    if (-not $env:OneDrive) {
        throw 'No se encuentra la variable OneDrive. Indica la carpeta con -Destino.'
    }
    $Destino = Join-Path $env:OneDrive 'Backups\ClaudeCode'
}

$origen  = Join-Path $HOME '.claude'
$equipo  = $env:COMPUTERNAME
$ahora   = Get-Date -Format 'yyyy-MM-dd HH:mm'

New-Item -ItemType Directory -Force -Path $Destino | Out-Null
$log = Join-Path $Destino 'backup.log'
"[$ahora] Inicio en $equipo" | Add-Content $log

# --- Historial de sesiones (acumulativo, sin purga) ---------
$srcProjects = Join-Path $origen 'projects'
$dstProjects = Join-Path $Destino "projects-$equipo"

if (Test-Path $srcProjects) {
    robocopy $srcProjects $dstProjects /E /R:2 /W:5 /NFL /NDL /NJH /NP /LOG+:$log | Out-Null
    $codigo = $LASTEXITCODE
    # robocopy: 0-7 = correcto (0 sin cambios, 1 copiados...), 8+ = error
    if ($codigo -ge 8) {
        "[$ahora] ERROR robocopy (código $codigo)" | Add-Content $log
        Write-Warning "robocopy terminó con código $codigo. Revisa $log"
    } else {
        "[$ahora] Historial copiado (robocopy código $codigo)" | Add-Content $log
    }
} else {
    "[$ahora] No existe $srcProjects" | Add-Content $log
}

# --- Configuración global ----------------------------------
$dstConfig = Join-Path $Destino "config-$equipo"
New-Item -ItemType Directory -Force -Path $dstConfig | Out-Null

foreach ($archivo in @('settings.json', 'CLAUDE.md')) {
    $src = Join-Path $origen $archivo
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $dstConfig $archivo) -Force
    }
}

"[$ahora] Fin" | Add-Content $log
Write-Host "Copia terminada en $Destino"
