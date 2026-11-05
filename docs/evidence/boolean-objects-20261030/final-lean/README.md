# Complete Boolean Lean/source assurance

> Correction, 2026-11-05 (#315): the retained regression-applicability conclusion
> missed one affected complete-audit fixture. See the [dated capability
> correction](../../../boolean-objects.md). The completed Lean/source evidence is unchanged.

Native Linux run `20261031T104817-379c11d51394` passed the complete cached
project build and fresh module/axiom audit on implementation/proof target
`8f676fc40975781cdcaa50772d4d95f7e40054a1`. It covered **572 project modules
and 122,964 declarations**, with only `propext`, `Classical.choice` and
`Quot.sound`. No missing or unexpected project module remained.

The run used one worker, one thread and a 24 GiB per-process threshold. Its
build took 12.052 s and fresh audit 6.719 s; the managed interval was 25.155 s.
It reused completed objects, including the final-source proofs from
[run `062232`](../source-integration/missing-audit-module/README.md). That
earlier run built the final source successfully but correctly failed the
whole-project coverage check because the standalone declaration candidate was
not imported. Adding its explicit `Audit.lean` import repaired coverage without
changing the source proofs or weakening the checker. The failed run retains
its actual outcome and timings.

All **687 captured source and two tool hashes** matched at terminal. All 28
checked-in certificates equal their freshly generated workspace counterparts,
and the authoritative-source link resolves to the actual repository `src/`.
The final input digest is
`a8ddafbfc7071b0b7f0a878e10f9f84def62aaa4303b2eaa3934026f0bd3cdf8`.
Original successful events, log, evidence and launch metadata are retained here
with uncompressed hashes and measured phases in `retained.json`.

Compared with native/regression snapshot `91de078ed8`, the only changed
governed file is the one-line import in `proof/Silver/Audit.lean`. Native
source/script/project inputs, semantic models, source pins/certificates,
runtime, tests, samples and catalogue are unchanged. The terminal independent
review confirms regression applicability for this aggregate-import change.

This is a complete cached Linux check with freshly executed module/axiom
auditing and actual-source correspondence. No clean build, separate
`leanchecker --fresh` replay, native macOS run or hosted CI result is claimed.
