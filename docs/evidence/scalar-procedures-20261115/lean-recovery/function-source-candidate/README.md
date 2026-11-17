# Function-source caller recovery — 2026-11-15

## Passed boundary

`Silver.FunctionSourceCandidate` passed on frozen production commit `91858a579`
in managed run **`20261115T182909-e353e1507833`**. The fresh imported-module audit
covered **197 modules / 17,516 declarations**, with only `propext`,
`Classical.choice` and `Quot.sound`. This assembles every inherited declaration,
loop, visibility and call proof against the complete reviewed source token list.
All original source extractors, uniqueness checks, terminators, theorem domains
and contracts remain intact.

Linux aarch64, Lean 4.34.1: build 264.368 s, audit 0.895 s, managed elapsed
271.065 s. The existing allocation was one Lake worker, automatic 12 Lean
threads and 8,192 MiB per process. Sampled process peak was 4,833,360 KiB RSS,
process-tree peak 5,874,320 KiB and minimum host availability 10,319,088 KiB.
The 10 GiB tree and 1.5 GiB host guards did not fire. There was no diagnostic
interruption; the monitor recorded normal exit 0. Unchanged successful objects
were reused. This is not a clean build or an independent kernel replay.

The focused input digest is exactly the ten-check preflight digest, and all
1,109 recorded input hashes were compared again with the final files. The native
source/scripts remain fixed at `8a03ab122`. The exact managed log in
`focused-success-runner.log.gz` matches the evidence SHA-256:
`8fc14e614312bce112d96ebbacfa131fa1ba6fc6c53f115ee24e30dc4b735b8a`.
Detailed evidence retains input, workspace, tool and artifact identities; the
outer launcher log, monitor summary and resource samples are separate.

## Why the inherited loop rebuilt

The earlier `FunctionLocals` cleanup audit (`20261115T173917-d7a06c23e3ca`)
predates the final native source and reviewed-source shape. The loop leaf and
its expected-token helper are byte-identical, but `src/silver_output_profile.adb`
and `ReviewedOutputShape.lean` changed before the current frozen native revision.
The matching helper object was reused; the whole-source loop leaf rebuilt and
passed in 73 s on the final source. `input-review.json` records the exact old
and new hashes. This is a required source-input refresh, not an intentionally
repeated identical-success expensive run.

## Repair and review lineage

The loop normalization, two largest declaration headers, six parameter/local
headers and final ten expected-literal checks preserve their original public
statements. The six-header implementation `c38f0eedc` passed its own focused
batch and independent review `4e799b0f1`. The final ten-check implementation
`91858a579` passed its complete helper/leaf batch and independent review
`944ed3d08`. Their evidence packets retain exact literal/character/token checks,
complete-source unique extraction, unchanged-data comparisons and the limits of
reused mechanism controls. The 433-character final-batch selection boundary is
not claimed to be a proven memory threshold.

The two earlier caller attempts remain accurately recorded as explicit kernel
memory failures followed by controlled source-only interruption: first the
ParameterStep specification, then the metadata-header theorem inside the
ordinary-body module. Neither failed caller is reclassified as successful, and
their completed objects were preserved for this current-input check.

## Handoff limit

This completes the bounded function-source caller gate and releases its worker
allocation. Actual-source certificate equality, the full source/facade graph,
complete module/axiom and provenance checkpoint, native validation and regression
coverage remain separate parent-owned obligations. This packet does not claim
those larger gates passed. The lead coordinates the next dense certificate or
integrated run; no further Lean job is started by this handoff.
