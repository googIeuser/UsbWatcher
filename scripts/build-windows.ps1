[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version = '0.1.0',

    [Parameter(Mandatory = $false)]
    [switch]$SkipInstaller
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repositoryRoot 'app'
$coreRoot = Join-Path $repositoryRoot 'core'
$coreManifest = Join-Path $coreRoot 'Cargo.toml'
$artifactsRoot = Join-Path $repositoryRoot 'artifacts'
$packageRoot = Join-Path $artifactsRoot "USB-Watcher-v$Version-win-x64"
$zipPath = "$packageRoot.zip"
$installerPath = Join-Path $artifactsRoot "USB_Watcher_Setup_$Version.exe"
$checksumsPath = Join-Path $artifactsRoot 'SHA256SUMS.txt'

& (Join-Path $PSScriptRoot 'bootstrap.ps1')

Write-Host 'Building the Rust USB core in release mode...'
cargo build --release --manifest-path $coreManifest
if ($LASTEXITCODE -ne 0) {
    throw 'The Rust release build failed.'
}

Push-Location $appRoot
try {
    Write-Host 'Running Flutter analysis...'
    flutter analyze --no-fatal-infos
    if ($LASTEXITCODE -ne 0) {
        throw 'Flutter analysis failed.'
    }

    Write-Host 'Running Flutter tests...'
    flutter test
    if ($LASTEXITCODE -ne 0) {
        throw 'Flutter tests failed.'
    }

    Write-Host 'Building the Flutter Windows application...'
    flutter build windows --release --build-name $Version
    if ($LASTEXITCODE -ne 0) {
        throw 'The Flutter Windows build failed.'
    }
}
finally {
    Pop-Location
}

$applicationExe = Get-ChildItem -Path (Join-Path $appRoot 'build\windows') -Filter 'usb_watcher.exe' -File -Recurse |
    Where-Object { $_.FullName -match '[\\/]Release[\\/]' } |
    Select-Object -First 1

if (-not $applicationExe) {
    throw 'The built usb_watcher.exe file was not found.'
}

$bundleRoot = $applicationExe.Directory.FullName
$coreExe = Join-Path $coreRoot 'target\release\usb_watcher_core.exe'
if (-not (Test-Path $coreExe)) {
    throw 'The built usb_watcher_core.exe file was not found.'
}

if (Test-Path $packageRoot) {
    Remove-Item -Path $packageRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null

Copy-Item -Path (Join-Path $bundleRoot '*') -Destination $packageRoot -Recurse -Force
Copy-Item -Path $coreExe -Destination (Join-Path $packageRoot 'usb_watcher_core.exe') -Force
Copy-Item -Path (Join-Path $repositoryRoot 'README.md') -Destination $packageRoot -Force
Copy-Item -Path (Join-Path $repositoryRoot 'LICENSE') -Destination $packageRoot -Force

@"
USB Watcher v$Version

Start usb_watcher.exe.
Keep usb_watcher_core.exe in the same directory.

The displayed speed is the negotiated USB connection speed reported by Windows.
It is not a cable certification result.
"@ | Set-Content -Path (Join-Path $packageRoot 'START_HERE.txt') -Encoding UTF8

if (Test-Path $zipPath) {
    Remove-Item -Path $zipPath -Force
}
Compress-Archive -Path $packageRoot -DestinationPath $zipPath -CompressionLevel Optimal
Write-Host "Portable Windows package created: $zipPath"

if (-not $SkipInstaller) {
    $installerPath = & (Join-Path $PSScriptRoot 'build-installer.ps1') -Version $Version -SourceDirectory $packageRoot -OutputDirectory $artifactsRoot
}

$checksumLines = @()
foreach ($asset in @($zipPath, $installerPath)) {
    if ($asset -and (Test-Path $asset)) {
        $hash = Get-FileHash -Path $asset -Algorithm SHA256
        $checksumLines += "$($hash.Hash.ToLowerInvariant())  $([System.IO.Path]::GetFileName($asset))"
    }
}
$checksumLines | Set-Content -Path $checksumsPath -Encoding ASCII

Write-Host "Checksums created: $checksumsPath"
