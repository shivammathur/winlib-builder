# Winlibs SBOM metadata

The files under `sbom/` are used by `scripts/generate-sbom.ps1` to write
per-library compliance data into each dependency artifact:

- `share/sbom/<library>.cdx.json`
- `share/sbom/<library>.spdx.json`
- `share/sbom/<library>.openvex.json`, only when a patched build lists fixed CVEs
- `share/licenses/<library>/...`

Shared document metadata lives in `sbom/document.json`. Each library has its
own file under `sbom/libraries/`; all files are validated against
`sbom/schema.json` before an SBOM is generated.

For a normal build, the generator uses the canonical upstream repository and
tag template. For example, brotli `v1.2.0` is identified as brotli `1.2.0`
from `google/brotli`. The generator separately records the checkout repository,
ref, and commit when a Git checkout is available, including builds made from a
`winlibs` fork.

The full Winlibs package version is retained as the artifact version. A trailing
Winlibs rebuild suffix such as `-1` is removed from the default upstream version.
Set `version.stripRebuildSuffix` to `false` when a trailing dash-number is part
of the upstream version itself, as it is for ImageMagick releases.
Tag templates can use `{version}`, `{versionDash}`, or `{versionUnderscore}` to
match an upstream project's tag convention.

Architecture, compiler, and target PHP version are recorded as properties. They
are not part of the component identity because all Windows variants built from
the same Winlibs tag use the same source.

Use `components` for source-built libraries embedded in an artifact. SBOMs
found below `deps/share/sbom` and vcpkg SPDX files found below
`deps-install/share` are merged automatically, so they do not need duplicate
metadata.

For packages covered by both standard and custom licenses, put the complete
SPDX expression in `license.expression` and define custom license text in
`license.extractedLicenses`.

When a Winlibs tag differs from the upstream release, add a `patchedBuilds`
entry. `fixedCves` is optional; use it only for security fixes that can be
asserted for that exact Winlibs artifact.

```json
{
  "tag": "libssh2-1.11.1-2",
  "upstream": {
    "repository": "libssh2/libssh2",
    "tag": "libssh2-1.11.1",
    "version": "1.11.1"
  },
  "fork": {
    "repository": "winlibs/libssh2",
    "tag": "libssh2-1.11.1-2"
  },
  "fixedCves": [
    {
      "id": "CVE-2026-7598",
      "source": "NVD",
      "url": "https://nvd.nist.gov/vuln/detail/CVE-2026-7598",
      "detail": "Fixed by backporting the upstream bounds check."
    }
  ]
}
```

This produces CycloneDX pedigree and `resolved_with_pedigree` analysis plus an
OpenVEX `fixed` statement scoped to the exact Winlibs artifact identity. It does
not claim that the generic upstream package is fixed.
