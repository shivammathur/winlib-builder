param (
    [Parameter(Mandatory)] [string] $Arch,
    [Parameter(Mandatory)] [string] $PcrePackage
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

$sharedTriplet = "$Arch-windows"
$staticTriplet = "$Arch-windows-static-md"
$sharedPackages = @(
    'apr[private-headers]',
    'apr-util[crypto]',
    'brotli',
    'curl[tool,openssl,http2,brotli]',
    'expat',
    'jansson',
    'lua[tools]',
    'nghttp2',
    'openssl[tools]',
    $PcrePackage,
    'zlib'
)
$staticPackages = @(
    'apr',
    'apr-util',
    'expat',
    $PcrePackage,
    'zlib'
)

& vcpkg install --triplet $sharedTriplet @sharedPackages
& vcpkg install --triplet $staticTriplet @staticPackages
