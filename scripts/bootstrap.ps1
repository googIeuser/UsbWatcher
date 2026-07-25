[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repositoryRoot 'app'
$windowsRoot = Join-Path $appRoot 'windows'
$metadataPath = Join-Path $appRoot '.metadata'
$appIcon = Join-Path $repositoryRoot 'installer\assets\usb_watcher.ico'

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name was not found in PATH. Read docs/INSTALLATION.md."
    }
}

Assert-Command -Name 'flutter'
Assert-Command -Name 'cargo'

if (-not (Test-Path $windowsRoot)) {
    Write-Host 'Generating the Flutter Windows runner...'
    $temporaryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("usb-watcher-flutter-" + [Guid]::NewGuid().ToString('N'))

    try {
        flutter create --platforms=windows --org io.github.usbwatcher --project-name usb_watcher $temporaryRoot
        if ($LASTEXITCODE -ne 0) {
            throw 'flutter create failed.'
        }

        Copy-Item -Path (Join-Path $temporaryRoot 'windows') -Destination $windowsRoot -Recurse -Force
        Copy-Item -Path (Join-Path $temporaryRoot '.metadata') -Destination $metadataPath -Force
    }
    finally {
        if (Test-Path $temporaryRoot) {
            Remove-Item -Path $temporaryRoot -Recurse -Force
        }
    }
}

$runnerIcon = Join-Path $windowsRoot 'runner\resources\app_icon.ico'
if (Test-Path $appIcon) {
    Copy-Item -Path $appIcon -Destination $runnerIcon -Force
}

$runnerMain = Join-Path $windowsRoot 'runner\main.cpp'
if (Test-Path $runnerMain) {
    $mainContent = Get-Content -Path $runnerMain -Raw
    $mainContent = $mainContent.Replace('L"usb_watcher"', 'L"USB Watcher"')
    Set-Content -Path $runnerMain -Value $mainContent -Encoding UTF8
}

$runnerResources = Join-Path $windowsRoot 'runner\Runner.rc'
if (Test-Path $runnerResources) {
    $resourceContent = Get-Content -Path $runnerResources -Raw
    $resourceContent = $resourceContent.Replace('"usb_watcher"', '"USB Watcher"')
    Set-Content -Path $runnerResources -Value $resourceContent -Encoding UTF8
}

Push-Location $appRoot
try {
    Write-Host 'Downloading Flutter dependencies...'
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw 'flutter pub get failed.'
    }
}
finally {
    Pop-Location
}

Write-Host 'USB Watcher bootstrap completed.'
