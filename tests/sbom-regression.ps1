[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
$generator = Join-Path $repositoryRoot 'scripts/generate-sbom.ps1'
$metadata = Join-Path $repositoryRoot 'sbom'
$installRoot = Join-Path ([System.IO.Path]::GetTempPath()) "winlibs-sbom-$([guid]::NewGuid())"

try {
    New-Item -Path $installRoot -ItemType Directory | Out-Null
    Set-Content -Path (Join-Path $installRoot 'payload.txt') -Value 'test payload'

    & $generator -Library libssh2 -Version 1.11.1-4 -InstallRoot $installRoot `
        -Vs vs16 -Arch x64 -PhpVersion 8.2 -MetadataPath $metadata

    $cycloneDx = Get-Content -Raw (Join-Path $installRoot 'share/sbom/libssh2.cdx.json') | ConvertFrom-Json
    $openVex = Get-Content -Raw (Join-Path $installRoot 'share/sbom/libssh2.openvex.json') | ConvertFrom-Json
    $fixedAnalyses = @($cycloneDx.vulnerabilities | Where-Object { $_.analysis.state -eq 'resolved_with_pedigree' })
    $fixedStatements = @($openVex.statements | Where-Object { $_.status -eq 'fixed' })
    $sourceOrigin = $cycloneDx.metadata.component.properties |
        Where-Object { $_.name -eq 'php:source-origin' } |
        Select-Object -ExpandProperty value -First 1
    if ($fixedAnalyses.Count -eq 0 -or $fixedAnalyses.Count -ne $fixedStatements.Count -or $sourceOrigin -ne 'winlibs-fork') {
        throw 'A package-form patched version did not produce its fixed-CVE data.'
    }

    & $generator -Library libssh2 -Version 1.11.1 -InstallRoot $installRoot `
        -Vs vs16 -Arch x64 -PhpVersion 8.2 -MetadataPath $metadata

    if (Test-Path -LiteralPath (Join-Path $installRoot 'share/sbom/libssh2.openvex.json')) {
        throw 'A stale OpenVEX document survived generation without VEX statements.'
    }
} finally {
    Remove-Item -LiteralPath $installRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host 'SBOM regression tests passed.'
