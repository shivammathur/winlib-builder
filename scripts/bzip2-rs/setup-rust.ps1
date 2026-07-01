param(
  [string] $RustTarget = $env:RUST_TARGET
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

if (-not $RustTarget) {
  throw 'Rust target is not set'
}

choco install rustup.install -y --no-progress
"$env:USERPROFILE\.cargo\bin" | Out-File -FilePath $env:GITHUB_PATH -Append
$env:PATH = "$env:USERPROFILE\.cargo\bin;$env:PATH"

rustup toolchain install stable --profile minimal --no-self-update
rustup target add --toolchain stable $RustTarget
rustc +stable --version
cargo +stable --version
