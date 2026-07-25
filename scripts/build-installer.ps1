[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [string]$SourceDirectory,

    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$installerScript = Join-Path $repositoryRoot 'installer\USBWatcher.iss'

if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $repositoryRoot 'artifacts'
}

if (-not (Test-Path $SourceDirectory)) {
    throw "Installer source directory was not found: $SourceDirectory"
}

function Find-InnoCompiler {
    $command = Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        (Join-Path ${env:ProgramFiles} 'Inno Setup 7\ISCC.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 7\ISCC.exe'),
        (Join-Path ${env:ProgramFiles} 'Inno Setup 6\ISCC.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe')
    ) | Where-Object { $_ -and (Test-Path $_) }

    return $candidates | Select-Object -First 1
}

$iscc = Find-InnoCompiler
if (-not $iscc) {
    throw 'Inno Setup compiler (ISCC.exe) was not found. Install it with: winget install --id JRSoftware.InnoSetup -e -s winget -i'
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$outputName = "USB_Watcher_Setup_$Version"

Write-Host "Building Inno Setup installer with $iscc..."

# Capture the native compiler output locally so it cannot leak into this
# script's success pipeline. The caller expects this script to return only
# the final installer path.
$isccOutput = & $iscc "/Qp" "/DMyAppVersion=$Version" "/DMySourceDir=$SourceDirectory" "/O$OutputDirectory" "/F$outputName" $installerScript 2>&1
$isccExitCode = $LASTEXITCODE
$isccOutput | ForEach-Object { Write-Host $_ }

if ($isccExitCode -ne 0) {
    throw "Inno Setup compilation failed with exit code $isccExitCode."
}

$installerPath = Join-Path $OutputDirectory "$outputName.exe"
if (-not (Test-Path $installerPath)) {
    throw "The expected installer was not created: $installerPath"
}

Write-Host "Installer created: $installerPath"
return $installerPath
