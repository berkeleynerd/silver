# Compiler array-initialization advisory evidence

`index.json` records failed managed native run `20261026T084316-ffe7696c9a8a`:
GNATprove proved all 16,357 checks, then the evidence audit rejected five exact
information warnings. Compressed events, complete reports and native log retain
that distinction; this package is not a successful full-audit manifest.

`assessment.json` records the exact warnings, matching SARIF and vendor-source
hashes examined in the [producer and patch review](../../../reviews/review-scalar-guard-array-initialization-advisory-20261026.md).
`tests.json` and its retained events/log record all 60 evidence-auditor tests
passing after the reviewed compiler-only classification. Complete native audit,
source/input correspondence and full-suite completion are separate delivery
obligations, tracked in the [capability record](../../../scalar-guard-refinement.md).
