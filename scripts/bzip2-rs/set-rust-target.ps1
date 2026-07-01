param(
  [Parameter(Mandatory)]
  [ValidateSet('x64', 'x86')]
  [string] $Arch
)

$ErrorActionPreference = 'Stop'

$target = if ($Arch -eq 'x64') {
  'x86_64-pc-windows-msvc'
} else {
  'i686-pc-windows-msvc'
}

"RUST_TARGET=$target" | Out-File -FilePath $env:GITHUB_ENV -Append
Write-Host "Rust target: $target"
