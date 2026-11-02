# ============================================================
# Objeto  : instalar.ps1
# Autor   : JMMFH (José María Mena)
# Fecha   : 02/11/2026
# Desc.   : Copia la configuración global de Claude Code
#           (settings.json, CLAUDE.md y referencias *.md) a
#           %USERPROFILE%\.claude. Antes guarda copia de los
#           archivos existentes en D:\ClaudeBackup\<fecha-hora>\.
#           Con -ProgramarBackup crea además la tarea diaria
#           de copia de seguridad del historial.
# Uso     : .\instalar.ps1 [-ProgramarBackup] [-CarpetaCopias D:\ClaudeBackup]
# ============================================================

param(
    [switch]$ProgramarBackup,
    [string]$CarpetaCopias = 'D:\ClaudeBackup'
)

$ErrorActionPreference = 'Stop'

$origen  = $PSScriptRoot
$destino = Join-Path $HOME '.claude'
$marca   = Get-Date -Format 'yyyyMMdd-HHmmss'
$copias  = Join-Path $CarpetaCopias "config-anterior-$marca"

if (-not (Test-Path $destino)) {
    New-Item -ItemType Directory -Path $destino | Out-Null
    Write-Host "Creada carpeta $destino"
}

# settings.json, CLAUDE.md y cualquier referencia *.md (wpf.md, ...), salvo README.md
$archivos = @('settings.json', 'CLAUDE.md') +
            (Get-ChildItem $origen -Filter *.md | Where-Object { $_.Name -notin 'CLAUDE.md', 'README.md' } | Select-Object -ExpandProperty Name)

foreach ($archivo in $archivos) {
    $src = Join-Path $origen  $archivo
    $dst = Join-Path $destino $archivo

    if (-not (Test-Path $src)) {
        Write-Warning "No se encuentra $src; se omite."
        continue
    }

    if (Test-Path $dst) {
        New-Item -ItemType Directory -Force -Path $copias | Out-Null
        Copy-Item $dst (Join-Path $copias $archivo)
        Write-Host "Copia previa: $(Join-Path $copias $archivo)"
    }

    Copy-Item $src $dst -Force
    Write-Host "Instalado: $dst"
}

if ($ProgramarBackup) {
    & (Join-Path $origen 'programar-backup.ps1')
}

Write-Host ''
Write-Host 'Listo. Abre una sesión nueva de Claude Code para que cargue la configuración.'