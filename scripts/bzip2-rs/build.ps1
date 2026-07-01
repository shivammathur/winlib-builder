param(
  [string] $RustTarget = $env:RUST_TARGET,
  [string] $CratePath = 'php-sdk-libbz2-rs-staticlib',
  [string] $TargetDir = 'bzip2-rs\target'
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

if (-not $RustTarget) {
  throw 'Rust target is not set'
}

$env:LIBBZ2_RS_SYS_PREFIX = 'bzip2_rs_'
$env:RUSTFLAGS = '-Cdebuginfo=2'

$manifestPath = Join-Path $CratePath 'Cargo.toml'

cargo +stable build `
  --manifest-path $manifestPath `
  --profile relwithdebinfo `
  --target $RustTarget `
  --target-dir $TargetDir

cargo +stable build `
  --manifest-path $manifestPath `
  --profile dev `
  --target $RustTarget `
  --target-dir $TargetDir
