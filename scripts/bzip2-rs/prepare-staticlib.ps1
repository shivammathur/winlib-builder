param(
  [string] $SourcePath = 'bzip2-rs',
  [string] $CratePath = 'php-sdk-libbz2-rs-staticlib',
  [string] $WrapperPath = 'php-sdk-libbz2-rs-wrapper'
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

$cargoToml = Get-Content (Join-Path $SourcePath 'Cargo.toml') -Raw
if ($cargoToml -notmatch '(?s)\[dependencies\.libbz2-rs-sys\].*?version\s*=\s*"([^"]+)"') {
  throw "Could not find libbz2-rs-sys dependency version in $SourcePath\Cargo.toml"
}

$libbz2RsSysVersion = $Matches[1]
Write-Host "libbz2-rs-sys version: $libbz2RsSysVersion"

$templatePath = Join-Path $PSScriptRoot 'templates'
New-Item -ItemType Directory -Force -Path (Join-Path $CratePath 'src'), $WrapperPath | Out-Null

$cargoTemplate = Get-Content (Join-Path $templatePath 'Cargo.toml.in') -Raw
$cargoTemplate.Replace('@LIBBZ2_RS_SYS_VERSION@', $libbz2RsSysVersion) |
  Set-Content -Path (Join-Path $CratePath 'Cargo.toml') -Encoding ascii

Copy-Item (Join-Path $templatePath 'lib.rs') (Join-Path $CratePath 'src\lib.rs') -Force
Copy-Item (Join-Path $templatePath 'bz2_wrapper.c') (Join-Path $WrapperPath 'bz2_wrapper.c') -Force
