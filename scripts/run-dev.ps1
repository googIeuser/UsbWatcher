[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repositoryRoot 'app'
$coreManifest = Join-Path $repositoryRoot 'core\Cargo.toml'

& (Join-Path $PSScriptRoot 'bootstrap.ps1')

Write-Host 'Building the Rust USB core in development mode...'
cargo build --manifest-path $coreManifest
if ($LASTEXITCODE -ne 0) {
    throw 'The Rust core build failed.'
}

Push-Location $appRoot
try {
    Write-Host 'Starting USB Watcher...'
    flutter run -d windows
    if ($LASTEXITCODE -ne 0) {
        throw 'Flutter stopped with an error.'
    }
}
finally {
    Pop-Location
}
