# ============================================================
# Objeto  : nuevo-proyecto.ps1
# Autor   : JMMFH (José María Mena)
# Fecha   : 02/11/2026
# Desc.   : Crea un proyecto nuevo a partir de la plantilla
#           JMMFH/plantilla-proyecto: clona, sustituye los
#           marcadores, inicializa git y hace el primer commit.
# Uso     : .\nuevo-proyecto.ps1 -Nombre MiProyecto -Cliente "Nombre del cliente"
#           [-Carpeta D:\Proyectos] [-Plantilla <url git>]
# ============================================================

param(
    [Parameter(Mandatory = $true)] [string]$Nombre,
    [Parameter(Mandatory = $true)] [string]$Cliente,
    [string]$Carpeta   = 'D:\Proyectos',
    [string]$Plantilla = 'https://github.com/JMMFH/plantilla-proyecto.git'
)

$ErrorActionPreference = 'Stop'

$destino = Join-Path $Carpeta $Nombre
if (Test-Path $destino) {
    throw "Ya existe la carpeta $destino"
}

Write-Host "Clonando plantilla en $destino ..."
git clone --depth 1 --quiet $Plantilla $destino
if ($LASTEXITCODE -ne 0) { throw 'Error al clonar la plantilla.' }

# Quitar el historial de la plantilla
$gitDir = Join-Path $destino '.git'
Get-ChildItem $gitDir -Recurse -Force | ForEach-Object { $_.Attributes = 'Normal' }
Remove-Item $gitDir -Recurse -Force

# Sustituir marcadores (el script se autoelimina al terminar)
& (Join-Path $destino 'rellenar-plantilla.ps1') -Nombre $Nombre -Cliente $Cliente

# Repositorio nuevo con primer commit
Push-Location $destino
try {
    git init -b main --quiet
    git add -A
    git commit -m "Estructura inicial desde plantilla-proyecto" --quiet
} finally {
    Pop-Location
}

Write-Host ''
Write-Host "Proyecto '$Nombre' creado en $destino"
Write-Host ''
Write-Host 'Siguientes pasos:'
Write-Host "  1. Crea el repositorio vacío https://github.com/JMMFH/$Nombre (privado)."
Write-Host "  2. git -C `"$destino`" remote add origin https://github.com/JMMFH/$Nombre.git"
Write-Host "  3. git -C `"$destino`" push -u origin main"
Write-Host '  4. Rellena las secciones RELLENAR de CLAUDE.md y el bloque environment de .claude/settings.json.'
Write-Host '  5. Abre Claude Code en la carpeta y ejecuta /inicio.'
