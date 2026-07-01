param(
  [string] $RustTarget = $env:RUST_TARGET,
  [string] $SourcePath = 'bzip2-rs',
  [string] $WrapperPath = 'php-sdk-libbz2-rs-wrapper',
  [string] $InstallPath = 'install'
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

if (-not $RustTarget) {
  throw 'Rust target is not set'
}

$includePath = Join-Path $InstallPath 'include'
$libPath = Join-Path $InstallPath 'lib'
New-Item -ItemType Directory -Force -Path $includePath, $libPath | Out-Null
Copy-Item (Join-Path $SourcePath 'bzip2-sys\bzip2-1.0.8\bzlib.h') $includePath -Force

$releaseRoot = Join-Path (Join-Path (Join-Path $SourcePath 'target') $RustTarget) 'relwithdebinfo'
$debugRoot = Join-Path (Join-Path (Join-Path $SourcePath 'target') $RustTarget) 'debug'
$wrapperSource = Join-Path $WrapperPath 'bz2_wrapper.c'

function Build-WrappedLibrary {
  param(
    [Parameter(Mandatory)] [string] $Root,
    [Parameter(Mandatory)] [string] $Runtime,
    [Parameter(Mandatory)] [string[]] $OptimizeFlags,
    [Parameter(Mandatory)] [string] $ObjectDirectory,
    [Parameter(Mandatory)] [string] $LibraryDestination,
    [Parameter(Mandatory)] [string] $PdbDestination
  )

  $rustLibrary = Join-Path $Root 'bz2_rs.lib'
  if (-not (Test-Path $rustLibrary)) {
    throw "Missing built Rust static library: $rustLibrary"
  }

  New-Item -ItemType Directory -Force -Path $ObjectDirectory | Out-Null
  $wrapperObject = Join-Path $ObjectDirectory 'bz2_wrapper.obj'
  $clArgs = @(
    '/nologo',
    '/c',
    "/I$includePath",
    $Runtime
  ) + $OptimizeFlags + @(
    '/Zi',
    "/Fd$PdbDestination",
    "/Fo$wrapperObject",
    $wrapperSource
  )

  & cl.exe @clArgs
  if ($LASTEXITCODE -ne 0) {
    throw "cl.exe failed building $wrapperObject"
  }

  & lib.exe /nologo "/OUT:$LibraryDestination" $wrapperObject $rustLibrary
  if ($LASTEXITCODE -ne 0) {
    throw "lib.exe failed building $LibraryDestination"
  }
}

Build-WrappedLibrary `
  -Root $releaseRoot `
  -Runtime '/MD' `
  -OptimizeFlags @('/O2') `
  -ObjectDirectory 'wrapper\release' `
  -LibraryDestination (Join-Path $libPath 'libbz2_a.lib') `
  -PdbDestination (Join-Path $libPath 'libbz2_a.pdb')

Build-WrappedLibrary `
  -Root $debugRoot `
  -Runtime '/MDd' `
  -OptimizeFlags @('/Od') `
  -ObjectDirectory 'wrapper\debug' `
  -LibraryDestination (Join-Path $libPath 'libbz2_a_debug.lib') `
  -PdbDestination (Join-Path $libPath 'libbz2_a_debug.pdb')

$files = @(
  (Join-Path $includePath 'bzlib.h'),
  (Join-Path $libPath 'libbz2_a.lib'),
  (Join-Path $libPath 'libbz2_a.pdb'),
  (Join-Path $libPath 'libbz2_a_debug.lib'),
  (Join-Path $libPath 'libbz2_a_debug.pdb')
)
foreach ($file in $files) {
  if (-not (Test-Path $file)) {
    throw "Missing required file: $file"
  }
}

Get-ChildItem $InstallPath -Recurse -File | Sort-Object FullName | ForEach-Object {
  "{0} {1}" -f $_.Length, $_.FullName
}
