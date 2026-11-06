# Native proof and build refresh — 2026-11-06

At native source `22d698b8aef4976a1aaa8313e73ba39e7c740598`, Linux x86-64 full
run `20261106T145116-6582d1e5fcb5` passed all **17,496 checks** and the complete
coverage/report/provenance audit in **75.121431286 seconds**, with eight workers
on twelve available CPUs. The audit covered 76 units, 1,104 entities,
1,496 flow checks and 16,000 proof checks. This is full reanalysis with existing
sessions/result cache, not cold proof. The strict production options and
original `review-final` installation/output path were preserved.

Build `20261106T145251-335323a924fa` passed in **5.814380124 seconds** with eight
workers. Both `silver` and `silver_image_adapter` were up to date; the command
performed no fresh compilation or link.

[Summary](summary.json) retains exact commands, resource reasons, timing and
scope. [Input applicability](input-applicability.json) verifies all **2,586 native
input hashes** and all **12 tool executable hashes** after both terminal runs.
The complete 143-path tracked native input inventory matches immutable native
source `22d698b8ae` and the current native, integration and stable-cache worker
workspaces. No captured input changed between proof and build.

The only changed input since the
[previous native refresh](../../lean-source-parallelism-20261106/native/README.md)
is `scripts/check_lean.py`, containing the eight-module runner registration.
All other native inputs and tool identities match that earlier manifest. Lean
modules, `proof/generate_source_certificate.py`, tests and documentation are
outside the native input inventory. Their later changes preserve applicability
while the captured native sources/configuration, recursive `scripts/*.py`,
host-generated inputs and tools remain exact; the applicability record includes
the compared workspace heads and input hashes.

[Artifact hashes](artifacts-index.json) bind the compressed immutable ledgers
and logs. The [proof archive](proof-evidence.tar.gz) contains all 78 report files,
the input snapshot and complete manifest. [Member hashes](archive-members.json)
identify all 80 files, with reports checked against the completed manifest.
Original toolchains, sessions, cache and build objects remain at the native
validation path; they are not duplicated here.

The explicit eight-worker proof reservation left capacity for an independent
tiny Lean fixture, as the retained run reason records. Per-obligation cache-hit
counts and CPU/RAM/process-sample telemetry are unavailable in this packet.
This refresh adds no macOS, cold-proof, Lean checkpoint or regression result.

Retention selected GPT-6.1 Sol / Extra High; runtime confirmation and token/cost
measurements are unavailable. Terminal retention, post-terminal input/tool
hashing, report checks and archive construction took 3.291 seconds, with no
rework. This packet launches no native tool, build, test or cache mutation.
