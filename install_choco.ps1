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

foreach ($Package in $Aplicaciones) {
       choco install $Package -y
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

Set-ExecutionPolicy Restricted
