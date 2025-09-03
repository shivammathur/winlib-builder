param(
    [Parameter(Mandatory)]
    [ValidateSet('15','16')]
    [string]$VS,
    [switch]$AddATL,
    [switch]$AddMFC
)

$ErrorActionPreference = "Stop"

$installer = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"
$vswhere = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (!(Test-Path $installer) -or !(Test-Path $vswhere)) {
    throw "VS Installer tools not found. Expected: `n  $installer `n  $vswhere"
}

$installPath = & $vswhere -latest -products * -property installationPath
if ([string]::IsNullOrWhiteSpace($installPath)) {
    throw "Visual Studio $VS not found on this machine."
}

$components = [System.Collections.Generic.List[string]]::new()

if ($VS -eq '15') {
    $components.Add('Microsoft.VisualStudio.Component.VC.v141.x86.x64') | Out-Null
    if ($AddATL) { $components.Add('Microsoft.VisualStudio.Component.VC.v141.ATL') | Out-Null }
    if ($AddMFC) { $components.Add('Microsoft.VisualStudio.Component.VC.v141.MFC') | Out-Null }
}
elseif ($VS -eq '16') {
    $components.Add('Microsoft.VisualStudio.Component.VC.14.29.16.11.x86.x64') | Out-Null
    if ($AddATL) { $components.Add('Microsoft.VisualStudio.Component.VC.14.29.16.11.ATL') | Out-Null }
    if ($AddMFC) { $components.Add('Microsoft.VisualStudio.Component.VC.14.29.16.11.MFC') | Out-Null }
}

$tmpVsconfig = [IO.Path]::ChangeExtension([IO.Path]::GetTempFileName(), '.vsconfig')
& $installer export "--installPath=$installPath" "--config=$tmpVsconfig" --quiet | Out-Null
$data = Get-Content $tmpVsconfig -Raw | ConvertFrom-Json

$componentsToAdd = $components | Where-Object { $data.components -notcontains $_ }

if ($componentsToAdd.Count -eq 0) {
    Write-Host "All requested components are already installed."
    exit 0
}

$arguments = @(
    'modify',
    "--installPath=$installPath"
)
foreach ($c in $componentsToAdd) { $arguments += @('--add', $c) }
$arguments += @('--quiet','--norestart')

Write-Host "Running: $installer $($arguments -join ' ')"
& $installer @arguments 2>&1 | ForEach-Object { Write-Host $_ }
