# Rebuilds dist/dolby_miaudio_enuma_v1.1.zip from module/
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1
#
# Entry names must use forward slashes: Windows' Compress-Archive writes
# backslashes for nested paths and Android's unzip then produces malformed names.

param(
    [string]$Version = 'v1.1'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root    = $PSScriptRoot
$module  = Join-Path $root 'module'
$distDir = Join-Path $root 'dist'
$zipPath = Join-Path $distDir "dolby_miaudio_enuma_$Version.zip"

if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$files = Get-ChildItem -LiteralPath $module -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($module.Length + 1) -replace '\\', '/'
    [pscustomobject]@{ Entry = $rel; Full = $_.FullName }
}

$fs   = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::Create)
$arch = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
foreach ($f in $files) {
    $entry = $arch.CreateEntry($f.Entry, [System.IO.Compression.CompressionLevel]::Optimal)
    $stream = $entry.Open()
    $bytes = [System.IO.File]::ReadAllBytes($f.Full)
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Dispose()
}
$arch.Dispose()
$fs.Dispose()

Write-Host "Built: $zipPath"
$check = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$check.Entries | ForEach-Object { Write-Host ("  [{0}] {1} bytes" -f $_.FullName, $_.Length) }
$check.Dispose()
Write-Host ("SHA256: {0}" -f (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash)
