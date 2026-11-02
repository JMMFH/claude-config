# ============================================================
# Objeto  : programar-backup.ps1
# Autor   : JMMFH (José María Mena)
# Fecha   : 02/11/2026
# Desc.   : Crea (o sustituye) la tarea programada de Windows
#           que ejecuta backup-claude.ps1 cada día.
#           La tarea apunta a la copia de este repositorio, así
#           que no muevas la carpeta después de programarla.
# Uso     : .\programar-backup.ps1 [-Hora 21:37]
# ============================================================

param(
    [string]$Hora = '21:37'
)

$ErrorActionPreference = 'Stop'

$nombre = 'Backup Claude Code'
$script = Join-Path $PSScriptRoot 'backup-claude.ps1'

if (-not (Test-Path $script)) {
    throw "No se encuentra $script"
}

$accion  = New-ScheduledTaskAction -Execute 'powershell.exe' `
           -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`""
$trigger = New-ScheduledTaskTrigger -Daily -At $Hora
$ajustes = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)

Register-ScheduledTask -TaskName $nombre -Action $accion -Trigger $trigger -Settings $ajustes `
    -Description 'Copia acumulativa del historial de Claude Code a OneDrive' -Force | Out-Null

Write-Host "Tarea '$nombre' programada a diario a las $Hora."
Write-Host "Se ejecuta con el usuario actual; si el equipo estaba apagado, se lanza al encenderlo."
Write-Host "Para probarla ahora: Start-ScheduledTask -TaskName '$nombre'"
