# Remaining expected-literal recovery — 2026-11-15

## Precise caller failure

Caller run `20261115T181631-ffc5a0d4c6b1` used committed production inputs
`c38f0eedc`, one Lake worker, default 12 Lean threads and the original 8,192 MiB
threshold. Every declaration header, all seven expression-body leaves and the
ordinary return-after leaf built successfully. The next module,
`DeclarationOrdinaryFunctionBodyAt`, failed after 60 s at **line 25**, in its
second theorem, `declaration_metadata_append_header`. The preceding ordinary
body theorem is not the diagnostic location; the failed module has no completed
object or fresh audit. The 690-character / 149-token metadata header still uses
the same unnormalized expected-string lexer path as the measured failures.

The explicit kernel-memory diagnostic triggered a source-process-group SIGINT,
stopping the newly started `DeclarationOrdinaryFunctionDeclarationAt` before it
completed. This is a module memory failure followed by a controlled interruption,
not a caller success or an unexplained interruption. No caller audit occurred.
The managed build elapsed 195.040 s before interruption; the monitor elapsed
205.245 s. Sampled process peak was 8,391,760 KiB, tree peak 9,427,056 KiB and
minimum host availability 5,779,440 KiB. Neither the 10 GiB tree guard nor the
1.5 GiB host guard fired. Productive earlier objects are retained.

The exact managed log, outer launcher log, resource samples, monitor summary and
failure identity are retained. The current source/scripts are still byte-identical
to `8a03ab122`. The previous six-header success is retained in the sibling packet;
it is not reused or presented as evidence for the failed caller.

## Inventory and next focused check

A read-only inventory found ten remaining expected-literal checks in this caller
whose text is longer than its largest successfully unnormalized declaration
header (433 characters): the metadata header, two loop bodies and seven call
specifications. The established character normalization can preserve their exact
original strings, complete tokens, source extractors and public theorem domains.
Only the metadata header is a newly observed failure; the others are candidates
selected by the shared literal representation and size. The lead authorized this complete ten-check batch after reviewing the failure
and inventory. The 433-character boundary is only an evidence-based selection
rule, not a proven memory threshold. The nine additional selections are not
misrepresented as individually failed checks.


## Authorized repair and preflight strategy

The production delta contains exactly these ten proof bodies and the isolated
`FunctionRemainingExpectedTokens` helper. The metadata module's preceding
ordinary-body theorem and proof are unchanged. All original public statements,
source bytes, whole-source extractors, duplicate rejection, terminators, native
contracts, domains and existing helpers remain unchanged. Shorter and already
successful checks are not rewritten. `selection-inventory.json` records the
exact ten text/token sizes; `input-review.json` records statement comparisons
and every changed proof hash before the batch starts.

Each new helper theorem applies the existing checked `String.toList_ofList`
identity to its complete expected text, then kernel-checks the unchanged
alphabet, fuel and lexer computation. Each leaf rewrites that token result and
kernel-checks the original whole-source equality. The call-spec namespace's
`expectedTokens` is definitionally the same `(Source.lexLine text).getD []`
operation as the shared helper; the existing definitions are not changed.

The next focused batch includes all ten target modules and the helper's complete
contracts. It uses one Lake worker, default 12 Lean threads, 8,192 MiB per process,
a 10 GiB source-tree guard, 1.5 GiB host-availability guard and source-only
controlled interruption on an explicit kernel-memory diagnostic. The lead
coordinates the parallel native two-worker run and certificate line-only work.
This allocation is retained because of host headroom, not as a new default.
Independent exact-data and complete-source extraction review runs concurrently.

Existing wrong-character and omitted-token controls cover the unchanged checked
normalization/lexer mechanism. No ordinary-body fixture is claimed to exercise
`procedureHeader` or `functionHeader`; those exact extractors are unchanged, and
the full-source uniqueness and equality checks remain kernel obligations. The
focused outcome and exact managed log will be retained before another caller
attempt. No complete-assurance success is inferred from this preparation.


## Focused result

Managed run `20261115T182359-36d64a7ff504` passed all ten selected modules and
the new helper on Linux aarch64, Lean 4.34.1. Its fresh imported-module axiom
audit covered **119 modules / 16,368 declarations**, with only `propext`,
`Classical.choice` and `Quot.sound`. Build elapsed was 211.534 s, audit 0.903 s
and managed elapsed 218.591 s. The helper completed in 2.0 s; ParameterFrame
loop in 93 s, ParametersAt loop in 75 s, metadata/ordinary module in 8.7 s and
each call-spec leaf in 4.1–4.3 s. Unchanged dependencies were reused; this was
not a clean build, independent replay or complete source checkpoint.

Sampled process peak was 5,566,992 KiB RSS and process-tree peak 6,612,816 KiB;
minimum host availability was 8,622,528 KiB. The one-worker/default-12-thread/
8,192-MiB allocation remained unchanged. The monitor recorded normal exit 0,
no interruption and no triggered guard.

The detailed evidence retains every input, workspace, tool and artifact hash.
All 1,109 recorded input files were compared against the frozen final files
before commit. The exact managed log decompresses from
`focused-success-runner.log.gz` and matches the evidence SHA-256:
`1517dcb06af002b44adcb2227ea6d763605d59aa1129165edd1e85dd088f399b`.
The outer launcher log, monitor summary and resource samples are separate.
The original failing two-theorem module is retained as
`metadata-header-failed-baseline.lean`; only its second proof changed.

The lead authorized the next `Silver.FunctionSourceCandidate` caller check on
these exact frozen production bytes while independent review finalizes its
report. It retains the same allocation and first-new-memory-diagnostic stop.
Full native, complete source/facade, module/axiom, provenance and regression
assurance remain parent-owned and are not established by this focused result.
