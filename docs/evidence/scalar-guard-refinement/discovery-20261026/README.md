# Retained #237 native discovery, 2026-10-26

The [discovery report](../native-discovery-20261026.md) states the conclusions and
limits. This directory contains completed native evidence, not a Silver
capability admission or universal-proof certificate.

| Artifact | Purpose |
| --- | --- |
| [retention-index.json](retention-index.json) | Original absolute paths, retained paths, decompressed sizes/SHA-256, and stored SHA-256 for 334 exact original files. |
| [analysis.json](analysis.json) | Exact source/check inventory, separate raw and SARIF records, 27 run summaries with commands/input hashes/phases, and 60 nonempty source/project/runtime comparisons to immutable prepared events. |
| [main-checks.md](main-checks.md) | Every actual Main proof record mapped to its exact retained source line and location, plus both static frontend errors. |
| [run-index.md](run-index.md) | Managed run IDs, UTC intervals, worker reservations and outcomes, linked to complete event streams. |
| [verification.json](verification.json), [verify.py](verify.py) | Portable read-only evidence verification and the observed result; no native tools are invoked. |
| [retain.py](retain.py) | One-time extraction recipe from original completed scratch results and native ledgers; never invokes a native/proof tool. |
| `native/<case>/` | Exact Main/project files, full `.spark`, SARIF, `gnatprove.out`, compiler/proof stdout/stderr and original per-run metadata for seven cases. Doors also contains build/execution outputs and expected bytes. |
| `negative/<case>/` | Six exact isolated expected-failure sources/projects with full reports/diagnostics and original before/after-source metadata. |
| `runtime/` | Exact original Silver_IO spec/body and imported libc specification used by both doors proof and build. |
| `runs/<id>/` | Unmodified managed `events.jsonl` and `native.log`, compressed separately. Prepared events contain input hashes, tool hashes/versions, exact command arrays and execution timestamps. |
| `frame/proxy/`, `frame/results/` | Original proxy source/project, stack-usage files, twelve complete stdout/stderr pairs, build logs and summary. No concrete parser run was made. |
| `frame/recognizer-shapes/` | Ten exact 4,096-byte shape sources and ten 4,097-byte source-limit neighbors, with generator metadata; prepared but unexecuted. |
| `recipes/` | Original preparation/execution recipes, frozen expectation manifests and independent doors oracle bytes. Their historical “prepared only” text is preserved; completed results are recorded above. |

Large solver sessions, objects and binaries are omitted. Retained `.spark` files
include their complete proof trees. Compressed originals use gzip with `mtime=0`;
for example, `gzip -cd native/edges/reports/main~1.spark.gz` prints the complete
raw report. The manifest's `bytes` and `sha256` describe the decompressed bytes.
`stored_sha256` describes the checked-in file itself. No macOS validation is
claimed.
