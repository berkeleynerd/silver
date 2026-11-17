# Complete native validation for #392

The complete native audit and subsequent build passed on Linux aarch64 (`silver-m4pro`) using frozen native commit `f4ed7cd513047df7c8a24c04b3fd107ee704db1c`.

| Run | Managed run ID | Result |
| --- | --- | --- |
| `dev.py prove --full --jobs 4` | `20261117T034048-8c22c1e6a33d` | Original lead-local exec session 87037 exited 0; all 19,726 checks proved; complete coverage/provenance audit passed |
| `dev.py build --jobs 0` | `20261117T055412-08a00820e2ef` | Original collector-local exec session 53113 exited 0; both executables up to date; actual reservation 11 workers |

The proof ran from 03:40:48 to 05:53:49 UTC on 2026-11-17 (7,981 seconds). It used the canonical all/all, level 2, cvc5/z3/Alt-Ergo, 30-second policy and forced analysis of every unit. The 16 MiB stack and four-worker allocation were recorded before launch to preserve headroom alongside guarded serial Lean work on the 16 GiB, no-swap host. The build reconsidered resources after proof completion: the registry showed 12 CPUs and one paused Lean worker reservation, so automatic scheduling selected 11 workers. Its stack was also 16 MiB; it completed in 1.217 seconds.

The complete audit covers 78 units and 1,252 entities, with 1,751 flow checks and 17,975 proof checks. Its accepted note counts are retained exactly in [audit-verification.json](audit-verification.json): 357 limitation notes, 18 imported entities, 6,268 trusted-math notes, 62 vendor-spec entities, 6 array-initialization advisories and 27 operator-reassociation advisories.

The initial workspace had no native reports or Why3 sessions. The private native cache overlay was seeded from 179,821 existing files; full validation permits solver-cache reuse. Cache presence does not establish any actual cache hit, and no cache-hit count was observed. This is a fresh complete report/audit with cache reuse permitted. The subsequent build was incremental and reported both executables up to date.

The collector checked all 2,622 native input hashes, 12 tool identities and 80 report hashes against the completed provenance manifest. It compared 147 tracked source, Python-script and project inputs to the frozen commit, checked the manifest against the initial proof-input snapshot, and re-audited complete report coverage. All 78 unit `.spark` reports, SARIF and text summary are retained in `native-reports.tar.gz`; archive member names and content hashes match the manifest exactly. After the build, the complete native manifest still validates, and the build's captured inputs and tool identities match the proof's. Binary hashes are in the verification record.

`proof-inputs.json`, `proof-provenance.json`, the initial-state record, managed-run metadata, original-terminal exit observations, compressed original run logs/events, and compressed resource/progress observations are included. Progress observations describe incomplete saved Why3 goals and solver attempts; the complete audit totals above are authoritative. Original native filesystem artifacts, sessions and caches remain preserved. The included collector scripts document the read-only extraction and verification. `SHA256SUMS.json` hashes every other packet file.

This packet covers native proof/audit and build. The lead coordinates final-input applicability, regression tests and Lean/source-correspondence evidence. The collector was assigned GPT-6.1 Sol High; runtime model identity is not independently exposed.
