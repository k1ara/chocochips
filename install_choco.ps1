<#
.SYNOPSIS
    Instala aplicaciones necesarias despues de formatear
.NOTES
    Se ejecutará como administrador si no lo es.
    Luego, habilitar la ejecución de script
    Ruta de logs: C:\ProgramData\chocolatey\logs\chocolatey.log
.EXAMPLE
    Set-ExecutionPolicy Bypass -Scope Process
    ó
    Set-ExecutionPolicy Unrestricted
.LINK
    Si deseas agregar programas, antes revisar en:
    https://chocolatey.org/packages
#>
# Fragmento obtenido de https://gist.github.com/apfelchips/792f7708d0adff7785004e9855794bc0
# Revisa si PowerSHell esta como administrador
#
# Forzar la ejecución de PowerShell como Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

# # ==========================================================
# # INSTALANDO CHOCOLATELY
# # ==========================================================
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# # ==========================================================
# # AJUSTES EN CHOCOLATELY
# # ==========================================================
# $ChocoDirCache = "$env:ALLUSERSPROFILE\ChocolateyAppsCache"
# $ChocoDirLog   = "$ChocoDirCache/$env:COMPUTERNAME"
# $ChocoLibPath  = "$env:ChocolateyInstall\lib"
# $ChocoLog      = "$ChocoDirLog\chocolatey_log_$(Get-Date -UFormat "%Y-%m-%d").log"
# $ChocoTaskName = "Chocolatey Daily Upgrade"

# Write-Host "* Ruta para la descarga de Aplicaciones"
# choco config set cacheLocation $ChocoDirCache
# Write-Host "* Limite de ejecucion de comandos a 30 minutos"
# choco config set commandExecutionTimeoutSeconds 1800
# Write-Host "* Habilitando confirmacion global para instalacion de Aplicaciones"
# choco feature enable -n=allowGlobalConfirmation

# #choco feature enable -n=useEnhancedLASTEXITCODEs
# # ==========================================================
# # DECORACIONES DE PANTALLA
# # ==========================================================
# $host.UI.RawUI.WindowTitle = "Instalando aplicaciones con Chocolatey"
# Write-Host "`n Instalando aplicaciones " -ForegroundColor Black -BackgroundColor Yellow -NoNewline; Write-Host ([char]0xA0)

# $ChocoDate = {
#     Write-Host "====================" -ForegroundColor Yellow -NoNewline; Write-Host ([char]0xA0)
#     Write-Host " Fecha: $(Get-Date -UFormat "%d %b %Y") " -ForegroundColor DarkYellow -NoNewline; Write-Host ([char]0xA0)
#     Write-Host " Hora:  $(Get-Date -f "HH:mm:ss") " -ForegroundColor DarkYellow -NoNewline; Write-Host ([char]0xA0)
#     Write-Host "====================" -ForegroundColor Yellow -NoNewline; Write-Host ([char]0xA0)
# }


# # ==========================================================
# # QUITANDO PAQUETES INUTILES PREINSTALADOS EN EL SISTEMA
# # ==========================================================
Get-AppxPackage *Teams* | Remove-AppxPackage


#$ChocoDate
# ==========================================================
# LISTA DE APLICACIONES
# ==========================================================
$Aplicaciones = @(
    # ------------------------------------------------------
    # DE USUARIO
    # ------------------------------------------------------
    "7zip",
    "anydesk.install",
    "chocolateygui",
    "open-shell",
    #"forticlientvpn",
    "microsoft-teams-new-bootstrapper",
    "notepadplusplus.install",
    "adobereader",
    #"office365business",
    # ------------------------------------------------------
    # NAVEGADORES
    # ------------------------------------------------------
    # "brave",
    "firefox",
    "googlechrome",
    # ------------------------------------------------------
    # SYSINTERNALS
    # ------------------------------------------------------
    "powershell-core",
    "winget.powershell",
    "winget",
    # ------------------------------------------------------
    # COMANDOS
    # ------------------------------------------------------
    # "nmap",
    # "whois",
    # "yt-dlp",
    # ------------------------------------------------------
    # HARDWARE MONITORING
    # ------------------------------------------------------
    # "cpu-z",
    "crystaldiskinfo",
    "treesizefree"
)
# ==========================================================
# INSTALANDO PROGRAMAS
# ==========================================================
# Fragmento obtenido de: https://gist.github.com/RafaelM1994/791cb40d8df4994dd1371bd40e346424
# function Install-ChocoApps {
#     param (
#         [String]$ChocoApps,
#         [String]$ChocoParams
#     )
#     if (!((test-path "$ChocoLibPath\$ChocoApps"))) {
#         $StartTime = Get-Date
#         Write-Host "[INFO] Instalando $ChocoApps" -ForegroundColor Black -BackgroundColor Yellow -NoNewline; Write-Host ([char]0xA0)
#         choco install $ChocoApps --params='$ChocoParams' --nocolor --limitoutput --log-file=$ChocoLog | Out-Null

#         if ($LASTEXITCODE -ne 0) {
#             Write-Host "[FALLO] No se pudo instalar: $ChocoApps" -ForegroundColor DarkRed -NoNewline; Write-Host ([char]0xA0)
#         }
#         elseif ($LASTEXITCODE -eq 0) {
#             Write-Host "[ OK ] Completada la instalacion" -ForegroundColor DarkGray -NoNewline; Write-Host ([char]0xA0)
#             Write-Host "Tiempo de ejecucion: $((Get-Date).Subtract($StartTime).Seconds) segundos" -ForegroundColor DarkGray -NoNewline; Write-Host ([char]0xA0)
#         }
#     }
#     else {
#         Write-Host "[ OK ] $ChocoApps $ChocoParams" -ForegroundColor Green -NoNewline; Write-Host ([char]0xA0)
#     }
# }
foreach ($Package in $Aplicaciones) {
    switch ($Package) {
        "firefox" { $Params = "/l:es-MX" }
        # "audacity" { $Params = "--some-params" }
        default { $Params = "" }
    }
    Install-ChocoApps -ChocoApps $Package -ChocoParams $Params
}

# # ==========================================================
# # INSTALANDO PROGRAMAS CON WINGET
# # ==========================================================
$paquetes = @(
    'Fortinet.FortiClientVPN',
    'RustDesk.RustDesk',
    'teamviewer.teamviewer.host',
    'microsoft.office'
)
foreach ($paquete in $paquetes) {
    $comando = Start-Process -FilePath 'winget' -ArgumentList "install $paquete --accept-package-agreements --accept-source-agreements" -PassThru -Wait -NoNewWindow
    if ($comando.ExitCode -eq 0) {
        Write-Output "Paquete atendido: $paquete"
    } else {
        Write-Error "Error al instalar el paquete: $paquete"
    }
}
