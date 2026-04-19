param (
    [string] $HttpdRoot = (Join-Path $env:GITHUB_WORKSPACE 'httpd')
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'common.ps1')

$cmakeListsPath = Join-Path $HttpdRoot 'CMakeLists.txt'
$sslEngineInitPath = Join-Path $HttpdRoot 'modules\ssl\ssl_engine_init.c'

$cmakeLists = Get-Content -Path $cmakeListsPath -Raw
$supportsPcre2 = $cmakeLists -match 'FIND_PACKAGE\(PCRE2'
$supportsOpenSsl3 = $false

if (Test-Path $sslEngineInitPath) {
    $supportsOpenSsl3 = (Get-Content -Path $sslEngineInitPath -Raw) -match 'OPENSSL_VERSION_NUMBER < 0x30000000L'
}

$pcrePackage = if ($supportsPcre2) { 'pcre2' } else { 'pcre' }
$pcreLibPath = if ($supportsPcre2) { 'lib/pcre2-8.lib' } else { 'lib/pcre.lib' }
$pcreFlags = if ($supportsPcre2) { '-DHAVE_PCRE2' } else { '' }
$disableOpenSsl = if ($supportsOpenSsl3) { 'FALSE' } else { 'TRUE' }

"supports_pcre2=$($supportsPcre2.ToString().ToLowerInvariant())" | Add-Content -Path $env:GITHUB_OUTPUT
"pcre_package=$pcrePackage" | Add-Content -Path $env:GITHUB_OUTPUT
"pcre_lib_path=$pcreLibPath" | Add-Content -Path $env:GITHUB_OUTPUT
"pcre_flags=$pcreFlags" | Add-Content -Path $env:GITHUB_OUTPUT
"disable_openssl=$disableOpenSsl" | Add-Content -Path $env:GITHUB_OUTPUT
