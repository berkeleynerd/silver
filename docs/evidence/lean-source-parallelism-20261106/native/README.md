# Native proof and build refresh — 2026-11-06

At `a179b4593d5553494d00e425f0ee09b5f35ed01c`, native Linux x86-64 full run
`20261106T104927-7539b94e8f7c` passed all 17,496 checks and the complete
coverage/report/provenance audit in 107.461 seconds with eight workers.
The strict production options, original `review-final` output path, sessions
and result cache were preserved. This is complete full reanalysis with retained
proof work, not a cold proof. Repeated process samples saw no external prover
processes; per-obligation cache-hit counts were not collected.

Build `20261106T105138-972096333176` passed in 10.443 seconds with eight workers.
It compiled six Ada units and linked `silver`; `silver_image_adapter` was up to
date. No native source changed during validation.

[Summary](summary.json) records exact commands, scope, resources and timing.
[Input applicability](input-applicability.json) verifies all 143 tracked native
inputs against the selected implementation and records the sole changed input
among all 2,586 hashes since the [prior complete run](../../interim-review-response-20261105/native-final/README.md):
`scripts/check_lean.py`. Later Lean module, proof-generator, test and documentation
changes preserve this native evidence when the captured native source,
configuration and recursive `scripts/*.py` inputs remain exact.

[Artifact hashes](artifacts-index.json) bind the compressed original ledgers and
logs. [The proof archive](proof-evidence.tar.gz) retains 78 report files plus the
input snapshot and complete manifest; [member hashes](archive-members.json)
identify all 80 members. `summary.json` and the artifact index point to the
original local ledgers. Original toolchains, sessions and cache are retained at
the native validation path; their binaries are not duplicated here.

Selected worker model/effort: GPT-6.1 Sol / Extra High. Runtime confirmation and
token/cost measurements are unavailable. This packet reuses completed evidence;
it is not a new review round. No macOS, cold proof or full regression run is added.
