# ============================================================
# Objeto  : instalar.ps1
# Autor   : JMMFH (José María Mena)
# Fecha   : 02/11/2026
# Desc.   : Copia la configuración global de Claude Code
#           (settings.json y CLAUDE.md) a %USERPROFILE%\.claude,
#           guardando copia de los archivos existentes.
#           Con -ProgramarBackup crea además la tarea diaria
#           de copia de seguridad del historial.
# Uso     : .\instalar.ps1 [-ProgramarBackup]
# ============================================================

param(
    [switch]$ProgramarBackup
)

$ErrorActionPreference = 'Stop'

$origen  = $PSScriptRoot
$destino = Join-Path $HOME '.claude'
$marca   = Get-Date -Format 'yyyyMMdd-HHmmss'

if (-not (Test-Path $destino)) {
    New-Item -ItemType Directory -Path $destino | Out-Null
    Write-Host "Creada carpeta $destino"
}

foreach ($archivo in @('settings.json', 'CLAUDE.md')) {
    $src = Join-Path $origen  $archivo
    $dst = Join-Path $destino $archivo

    if (-not (Test-Path $src)) {
        Write-Warning "No se encuentra $src; se omite."
        continue
    }

    if (Test-Path $dst) {
        $copia = "$dst.$marca.bak"
        Copy-Item $dst $copia
        Write-Host "Copia de seguridad: $copia"
    }

    Copy-Item $src $dst -Force
    Write-Host "Instalado: $dst"
}

if ($ProgramarBackup) {
    & (Join-Path $origen 'programar-backup.ps1')
}

Write-Host ''
Write-Host 'Listo. Abre una sesión nueva de Claude Code para que cargue la configuración.'
