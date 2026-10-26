# Final guard frame evidence — 2026-10-26

Logical checked-in destination:
`docs/evidence/scalar-guard-refinement/final-frames-20261026`.
This package retains already completed Linux x86_64 scratch compiler-frame,
admission-only and recognizer-boundary observations for parser SHA-256
`956eff6874727f95fcb1ede29b537705f96bf916d05483d1813198aeb0f1ea74`.
No proof, compiler, build, test or probe runner was launched by the retention
thread. The prior evidence remains unchanged.

[validation.json](validation.json) records the three managed runs, commands,
outcomes, times, exact source/executable identities, nonempty input comparisons,
frame changes and limits. The runs captured frozen source inputs before final
integration. At retention, all 129 tracked source files match commit
`7c5db25b8e1849cac4b7f9953193c64134ae155b` with zero source differences.

[retention-index.json.gz](retention-index.json.gz) indexes all 304 compressed
payloads with original byte count and compressed/decompressed SHA-256 hashes.
They include all 132 source snapshots, both GPRs, runner scripts, all captured
repository script/test inputs, 28 `.su` records, parser assembly, generated
binder source, console/managed logs, event streams, all three complete input
comparisons, and the shape fixtures and outputs. Executable and tool bytes are
represented by their captured/current hashes; binaries and unrelated objects
are not replicated.

[fresh-frame-comparison.json.gz](fresh-frame-comparison.json.gz) records the
Body_Tail 416→368 and Bare_Target 240→256 frame changes, all source-level
allocation-site counts, and the missing Body_Tail mark/release pair. Its
conditional payload applicability and limitations supersede the old
per-iteration sibling-release statement for this build. The proposed narrative
is [append-ready.md](append-ready.md).

`retain.py` reads the named original scratch paths, managed records and Git
objects, preserving these frozen inputs without running validators. It is a
retention reproducer, not a portable proof runner. `verify.py` independently
checks this package using only retained files; it checks the package manifest,
compressed/decompressed payloads, managed success outcomes and input/source
correspondence. `PACKAGE-MANIFEST.json` records every package file except itself.

Run `python3 verify.py` from any directory. This checks retention integrity; it
does not rerun native proof, compilation, admission tests or Lean. Complete
native/compiler and Lean/actual-source validation remain outside these claims.

Retention selected GPT-6.1 Sol at Extra High. Runtime settings are not
independently exposed; token and cost measurements are unavailable. Actual
retention times are in the validation record.
