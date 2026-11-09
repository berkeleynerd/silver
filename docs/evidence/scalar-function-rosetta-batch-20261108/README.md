# Scalar-function Rosetta batch — combined checkpoint, 2026-11-08

## Current-main integration — 2026-11-09

PR #354 now includes main `023a60f80b7` and preserves the accepted Rosetta
metadata/render plus current main's assessor corrections. The only merge
conflict was in session memory; both histories are retained.
[The integration packet](integration-20261109/result.json) records matching
current-main compiler/proof/tool/test/sample inputs, unchanged accepted
metadata, byte-identical rendering, and the fresh three-test Rosetta result.
Managed run `20261109T203227-4742be5f3187` passed with actual driver exit 0:
3.673 seconds unittest time and 5.792 seconds managed duration.

Current assurance is the accepted
[review-response checkpoint](../review-response-74ea2edeaa/README.md), including
complete native and Lean validation and the fresh 648-execution suite with all
84 programs / 147 executable cases. All 645 non-Rosetta executions remain
applicable; the three affected Rosetta identities passed the new focused run.
The older 645-identity accounting below describes the November 8 checkpoint.
No new complete native, Lean or regression run was needed for this record and
metadata integration. The existing PR merge hold remains in place.

## Original combined checkpoint — 2026-11-08

This packet records #345's final integration of twelve previously validated
programs and their narrow Rosetta assessments. The sample groups merged in
PRs #351/#352/#353. The metadata/render target is `c9d8f3352296503e314174ce6b552af65ba9a5e0`,
integrating authored commit `3c2e1a6224e048bd76099cec735749b7f1cbcee5`. No new
language, compiler, runtime, proof, auditor or resource-budget change belongs
to this checkpoint.

Managed Linux test `20261108T225101-0e909fa50875` passed all three Rosetta
identities in **7.213803704 seconds** (unittest: 4.891 seconds), with one
reserved worker for the serial Python-only runner. It finished at
**2026-11-08 22:51:09.969052 UTC**. The command was:

```sh
python3 scripts/dev.py test --task "#345 combined Rosetta delivery" \
  --reason "Three affected Rosetta tests on frozen twelve-task metadata; compiler/proofs/samples unchanged and successful evidence reuse independently reviewed. One worker for the serial Python-only test runner." \
  --jobs 1 -- -p test_rosetta.py
```

The original events retain the exact argument array and input map. Every
captured input was rehashed after completion and still matches, including the
three Rosetta producer/metadata inputs. The final render has 83 supported
mappings, up from 71, with the same 1,576 candidates in 44 stages. Independent
review subsequently accepted metadata target `c9d8f3352296` and this packet
at retention commit `e4284899cd`, with no material finding. The final
acceptance wording and this README checksum were updated after that review;
all other retained payloads are unchanged.

The retained application packets are
[callable examples](../callable-integer-examples-20261108/README.md),
[divisor examples](../divisor-examples-20261108/README.md) and
[digit/prime examples](../digit-prime-examples-20261108/README.md).
They hold the original source snapshots, production reports, exact outputs and
full-domain task arguments. Their three production runs passed on the first
attempt and total 208.273612477 seconds. No successful application proof/build
or execution was repeated for this metadata-only checkpoint.

The accepted [#339 compiler/native/Lean assurance](../../scalar-functions.md#delivery-assurance-and-validation)
remains applicable to unchanged governed inputs. The
[final independent review](../../reviews/review-scalar-function-rosetta-delivery-20261108.md)
records the exact reuse argument. The test inventory is 645 unittest identities:
three Rosetta identities run freshly, and 642 retain applicable results. The
manifest identity among those retained results composes all 84 programs and
147 executable cases: 72 baseline programs with 135 cases, plus twelve new
programs with one invocation each. Their 454 printed demonstration lines are
not separate executable cases. This is not a fresh full regression or Lean run;
earlier failed baseline runs remain failed. macOS validation is not claimed.

`combined-inventory.json` contains agent-written final inventory observations
and input identities, not a runner-produced proof result. `batch-timing.json`
links the original three managed intervals and records overall wall-clock time
separately. `stage-fields.json` compares the seven tracked stage fields with the
render; all values remain correct, so no board-stage mutation was necessary.
The managed test's original events and native log are retained losslessly under
`managed-run/`; its test input map includes the actual Rosetta renderer,
manifest and coverage bytes. `SHA256SUMS` covers every packet file except itself.

Validation wall-clock time from the first implementation authorization on main
at 19:37:37 UTC through the final affected test is **3 h 13 m 33 s** (rounded).
This includes authoring, reviews, record work and owner handoffs; pause/active
agent timing is not separately available. Final review/publication follows this
interval. No production application run failed or was interrupted; the original
group records retain admission-only draft corrections. No compiler/Lean rebuild
was attempted for this sample-only batch.
