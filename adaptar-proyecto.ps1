# ============================================================
# Objeto  : adaptar-proyecto.ps1
# Autor   : JMMFH (José María Mena)
# Fecha   : 06/11/2026
# Desc.   : Adapta un proyecto EXISTENTE al modelo de la plantilla
#           (JMMFH/plantilla-proyecto). Es idempotente y no pisa
#           nada que ya exista: solo añade lo que falta.
#           - MAPA.md, ESTADO.md, PENDIENTES.md si no existen
#           - .claude/commands/* y hooks/* (siempre, son de la casa)
#           - .claude/settings.json solo si no existe (si existe, avisa)
#           - Documentacion/{decisiones,diseno,memoria,claude-ai} y Documentos/
#             (si el proyecto ya usa Docs/, se usa Docs/ y se avisa)
#           - Sustituye NOMBRE_PROYECTO / CLIENTE_PROYECTO en lo copiado
#           - Copia las memorias locales de Claude Code a <docs>/memoria
#           Lo que no automatiza (CLAUDE.md, fusionar tareas, /mapa, commit)
#           lo imprime al final.
# Uso     : .\adaptar-proyecto.ps1 -Proyecto D:\Proyectos\ACOBA\SIA -Cliente "ACOBA"
#           [-Nombre SIA] [-Plantilla D:\Proyectos\plantilla-proyecto]
# ============================================================

param(
    [Parameter(Mandatory = $true)] [string]$Proyecto,
    [Parameter(Mandatory = $true)] [string]$Cliente,
    [string]$Nombre,
    [string]$Plantilla = 'D:\Proyectos\plantilla-proyecto'
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$raiz = (Resolve-Path $Proyecto).Path.TrimEnd('\')
if (-not (Test-Path (Join-Path $raiz '.git'))) { throw "$raiz no es un repositorio git." }
if (-not (Test-Path (Join-Path $Plantilla 'MAPA.md'))) { throw "No encuentro la plantilla en $Plantilla (haz git pull)." }
if (-not $Nombre) { $Nombre = Split-Path $raiz -Leaf }

$hoy      = Get-Date -Format 'yyyy-MM-dd'
$copiados = New-Object System.Collections.Generic.List[string]
$avisos   = New-Object System.Collections.Generic.List[string]

function CopiarSiFalta([string]$rel) {
    $src = Join-Path $Plantilla $rel
    $dst = Join-Path $raiz $rel
    if (Test-Path $dst) { $avisos.Add("Ya existe, no se toca: $rel"); return }
    New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
    Copy-Item $src $dst
    $copiados.Add($rel)
}

function CopiarSiempre([string]$rel) {
    $src = Join-Path $Plantilla $rel
    $dst = Join-Path $raiz $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
    Copy-Item $src $dst -Force
    $copiados.Add($rel)
}

# --- Archivos de gestión (solo si faltan) -------------------
foreach ($f in @('MAPA.md', 'ESTADO.md', 'PENDIENTES.md')) { CopiarSiFalta $f }

# --- .claude: comandos y hook siempre; settings solo si falta
Get-ChildItem (Join-Path $Plantilla '.claude\commands') -File | ForEach-Object { CopiarSiempre ".claude\commands\$($_.Name)" }
Get-ChildItem (Join-Path $Plantilla '.claude\hooks')    -File | ForEach-Object { CopiarSiempre ".claude\hooks\$($_.Name)" }
if (Test-Path (Join-Path $raiz '.claude\settings.json')) {
    $avisos.Add('.claude\settings.json ya existe: comprueba que tiene el hook SessionStart y el soft_deny de git commit/push (mira el de la plantilla).')
} else {
    CopiarSiFalta '.claude\settings.json'
}

# --- Carpeta de documentación: Documentacion/ o Docs/ si ya la usa
$docs = 'Documentacion'
if (-not (Test-Path (Join-Path $raiz 'Documentacion')) -and (Test-Path (Join-Path $raiz 'Docs'))) {
    $docs = 'Docs'
    $avisos.Add("El proyecto usa Docs/: se crean las subcarpetas ahí. Dilo en CLAUDE.md (como en IA).")
}
foreach ($sub in @('decisiones', 'diseno', 'memoria', 'claude-ai')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $raiz "$docs\$sub") | Out-Null
}
New-Item -ItemType Directory -Force -Path (Join-Path $raiz 'Documentos') | Out-Null

# Plantillas de documentación (si faltan), adaptando la ruta si es Docs/
$pares = @(
    @('Documentacion\decisiones\0000-plantilla.md',        "$docs\decisiones\0000-plantilla.md"),
    @('Documentacion\decisiones\README.md',                "$docs\decisiones\README.md"),
    @('Documentacion\diseno\README.md',                    "$docs\diseno\README.md"),
    @('Documentacion\memoria\README.md',                   "$docs\memoria\README.md"),
    @('Documentacion\claude-ai\instrucciones-proyecto.md', "$docs\claude-ai\instrucciones-proyecto.md"),
    @('Documentacion\claude-ai\cierre-diseno.md',          "$docs\claude-ai\cierre-diseno.md"),
    @('Documentos\README.md',                              'Documentos\README.md')
)
foreach ($p in $pares) {
    $src = Join-Path $Plantilla $p[0]
    $dst = Join-Path $raiz $p[1]
    if (Test-Path $dst) { continue }
    Copy-Item $src $dst
    $copiados.Add($p[1])
}

# --- Sustituir marcadores SOLO en lo copiado ---------------
foreach ($rel in $copiados) {
    $ruta = Join-Path $raiz $rel
    if ($ruta -notmatch '\.(md|json)$') { continue }
    $c = [System.IO.File]::ReadAllText($ruta, $utf8)
    $n = $c.Replace('NOMBRE_PROYECTO', $Nombre).Replace('CLIENTE_PROYECTO', $Cliente)
    $n = $n.Replace('**Última actualización**: AAAA-MM-DD — equipo: NOMBRE-EQUIPO', "**Última actualización**: $hoy — equipo: $env:COMPUTERNAME")
    $n = $n.Replace('**Última actualización**: AAAA-MM-DD', "**Última actualización**: $hoy")
    if ($docs -eq 'Docs') { $n = $n.Replace('Documentacion/', 'Docs/').Replace('Documentacion\', 'Docs\') }
    if ($n -ne $c) { [System.IO.File]::WriteAllText($ruta, $n, $utf8) }
}

# --- Memorias locales -> <docs>/memoria --------------------
$migrar = Join-Path $PSScriptRoot 'migrar-memorias.ps1'
if (Test-Path $migrar) {
    if ($docs -eq 'Docs') {
        $avisos.Add("Memorias: ejecuta a mano migrar-memorias.ps1 y mueve el resultado de Documentacion\memoria a Docs\memoria (el script solo conoce Documentacion).")
    } else {
        & $migrar -Proyecto $raiz
    }
}

# --- Resumen ------------------------------------------------
Write-Host ''
Write-Host "== $Nombre ($raiz) ==" -ForegroundColor Cyan
Write-Host "Copiados ($($copiados.Count)):"
$copiados | ForEach-Object { Write-Host "  + $_" }
if ($avisos.Count) {
    Write-Host 'Avisos:' -ForegroundColor Yellow
    $avisos | ForEach-Object { Write-Host "  ! $_" }
}
Write-Host ''
Write-Host 'Queda a mano:' -ForegroundColor Green
Write-Host "  1. CLAUDE.md: añade las secciones de la plantilla (Archivos de gestión, Continuidad, Carpetas de documentación, Diseño en claude.ai)."
Write-Host "  2. Si había roadmap o guía de tareas: en Claude Code, modo directo: 'pasa las tareas abiertas a PENDIENTES.md y deja nota de archivo'."
Write-Host "  3. Abre Claude Code en $raiz, comprueba el hook y los comandos, y ejecuta /mapa."
Write-Host "  4. Commit."