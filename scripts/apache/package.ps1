param (
    [Parameter(Mandatory)] [string] $Arch,
    [Parameter(Mandatory)] [string] $DepsRoot,
    [Parameter(Mandatory)] [string] $StaticRoot,
    [Parameter(Mandatory)] [string] $ApriconvRoot
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'common.ps1')

$installRoot = Join-Path $env:GITHUB_WORKSPACE 'apache-install'
$packageRoot = Join-Path $env:GITHUB_WORKSPACE 'install'
$packageIncludeRoot = Join-Path $packageRoot 'include\apache2_4'
$packageLibRoot = Join-Path $packageRoot 'lib\apache2_4'

if (Test-Path $packageRoot) {
    Remove-Item -Path $packageRoot -Recurse -Force
}

New-Item -Path $packageIncludeRoot -ItemType Directory -Force | Out-Null
New-Item -Path $packageLibRoot -ItemType Directory -Force | Out-Null

Copy-TreeContents -Source (Join-Path $DepsRoot 'include') -Destination $packageIncludeRoot
Copy-TreeContents -Source (Join-Path $ApriconvRoot 'include') -Destination $packageIncludeRoot
Copy-TreeContents -Source (Join-Path $installRoot 'include') -Destination $packageIncludeRoot

# Normalize APR's GNU-attribute fallback so MSVC consumers can compile against
# the packaged headers even when __has_attribute is predefined.
$aprHeader = Join-Path $packageIncludeRoot 'apr.h'
if (Test-Path $aprHeader) {
    $aprAttributeFallback = @'
#if !(defined(__attribute__) || defined(__has_attribute))
#define __attribute__(__x)
#endif
'@
    $msvcAprAttributeFallback = @'
#if !defined(__GNUC__) && !defined(__attribute__)
#define __attribute__(__x)
#endif
'@

    $aprContents = Get-Content -Path $aprHeader -Raw
    $normalizedAprContents = $aprContents.Replace($aprAttributeFallback, $msvcAprAttributeFallback)

    if ($normalizedAprContents -ne $aprContents) {
        Set-Content -Path $aprHeader -Value $normalizedAprContents -NoNewline
    }
}

Copy-TreeContents -Source (Join-Path $DepsRoot 'lib') -Destination $packageLibRoot
Copy-TreeContents -Source (Join-Path $ApriconvRoot 'lib') -Destination $packageLibRoot
Copy-TreeContents -Source (Join-Path $installRoot 'lib') -Destination $packageLibRoot

$staticLibRoot = Join-Path $StaticRoot 'lib'
if (Test-Path $staticLibRoot) {
    Get-ChildItem -Path $staticLibRoot -Filter *.lib -File | ForEach-Object {
        $sharedDestination = Join-Path $packageLibRoot $_.Name
        $staticSuffix = if ($_.BaseName -match '[-.]') { '-static' } else { 'static' }
        $staticDestination = Join-Path $packageLibRoot "$($_.BaseName)$staticSuffix$($_.Extension)"

        if (Test-Path $sharedDestination) {
            Copy-Item -Path $_.FullName -Destination $staticDestination -Force
        } else {
            Copy-Item -Path $_.FullName -Destination $sharedDestination -Force
        }
    }
}

Get-ChildItem -Path $packageLibRoot -Filter 'lib*.lib' -File | ForEach-Object {
    $aliasName = $_.Name.Substring(3)
    $aliasTarget = Join-Path $packageLibRoot $aliasName
    if (-not (Test-Path $aliasTarget)) {
        Copy-Item -Path $_.FullName -Destination $aliasTarget -Force
    }
}

foreach ($buildTree in @(
    (Join-Path 'C:/vcpkg/buildtrees/apr' "$Arch-windows-rel"),
    (Join-Path 'C:/vcpkg/buildtrees/apr-util' "$Arch-windows-rel")
)) {
    if (-not (Test-Path $buildTree)) {
        continue
    }

    Get-ChildItem -Path $buildTree -Filter *.exp -File | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $packageLibRoot -Force
    }
}

$xmlCompatTarget = Join-Path $packageLibRoot 'xml.lib'
if (-not (Test-Path $xmlCompatTarget)) {
    $xmlCompatSource = Get-ChildItem -Path $packageLibRoot -Filter '*expat*.lib' -File |
        Sort-Object Length -Descending |
        Select-Object -First 1

    if ($xmlCompatSource) {
        Copy-Item -Path $xmlCompatSource.FullName -Destination $xmlCompatTarget -Force
    }
}
