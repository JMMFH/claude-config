# ============================================================
# Objeto  : migrar-memorias.ps1
# Autor   : JMMFH (José María Mena)
# Fecha   : 02/11/2026
# Desc.   : Copia las memorias que Claude Code guarda en
#           %USERPROFILE%\.claude\projects\<slug>\memory\*.md
#           a la carpeta Documentacion\memoria\ del repositorio
#           del proyecto, para que viajen con git.
#           No borra nada en origen. Si un fichero ya existe en
#           destino, solo lo sustituye si el de origen es más nuevo.
# Uso     : .\migrar-memorias.ps1 -Proyecto D:\Proyectos\TSIA
#           .\migrar-memorias.ps1 -Proyecto D:\Proyectos\TSIA -OrigenClaude "E:\ruta\.claude"
#           .\migrar-memorias.ps1 -Todos          (todos los proyectos bajo D:\Proyectos)
# ============================================================

param(
    [string]$Proyecto,
    [switch]$Todos,
    [string]$Carpeta      = 'D:\Proyectos',
    [string]$OrigenClaude = (Join-Path $HOME '.claude')
)

$ErrorActionPreference = 'Stop'

# Claude Code convierte "D:\Proyectos\APIS\SGA" en "D--Proyectos-APIS-SGA"
function ObtenerSlug([string]$ruta) {
    $r = $ruta.TrimEnd('\')
    return ($r -replace ':', '-' -replace '\\', '-')
}

function MigrarUno([string]$rutaProyecto) {
    $slug    = ObtenerSlug $rutaProyecto
    $origen  = Join-Path $OrigenClaude "projects\$slug\memory"
    $destino = Join-Path $rutaProyecto 'Documentacion\memoria'

    if (-not (Test-Path $origen)) {
        Write-Host "  (sin memorias) $rutaProyecto" -ForegroundColor DarkGray
        return
    }

    $ficheros = Get-ChildItem $origen -Filter *.md -File
    if ($ficheros.Count -eq 0) {
        Write-Host "  (memoria vacía) $rutaProyecto" -ForegroundColor DarkGray
        return
    }

    New-Item -ItemType Directory -Force -Path $destino | Out-Null
    $copiados = 0
    foreach ($f in $ficheros) {
        $dst = Join-Path $destino $f.Name
        if ((Test-Path $dst) -and ((Get-Item $dst).LastWriteTime -ge $f.LastWriteTime)) { continue }
        Copy-Item $f.FullName $dst -Force
        $copiados++
    }
    Write-Host "  $rutaProyecto : $copiados de $($ficheros.Count) ficheros copiados a Documentacion\memoria"
}

if ($Todos) {
    Get-ChildItem $Carpeta -Directory -Recurse -Depth 1 |
        Where-Object { Test-Path (Join-Path $_.FullName '.git') } |
        ForEach-Object { MigrarUno $_.FullName }
} elseif ($Proyecto) {
    MigrarUno (Resolve-Path $Proyecto).Path
} else {
    throw 'Indica -Proyecto <ruta> o -Todos.'
}

Write-Host ''
Write-Host 'Revisa los ficheros copiados y añade Documentacion\memoria al commit de cada proyecto.'
