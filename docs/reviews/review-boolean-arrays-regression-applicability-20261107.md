# Boolean arrays: regression applicability review — 2026-11-07

**Disposition: the complete current regression inventory has applicable passing
coverage through the recorded composition. No required method remains uncovered
or failing on this reviewed snapshot.** The original full run remains **failed**.
This finding satisfies only the regression-reuse review in
[development.md](../../development.md#proof-loop-and-validation); it does not
approve complete feature assurance or merging PR #335.

## Scope and review record

- Authorized work: Boolean arrays #297, following the owner's selection of the
  next regular unit after PR #332. No #298 work or implementation merge approval.
- Reviewed integration HEAD: `689aef86bf9a0b33d0fcf13dee212e069d07cb64` in
  `tmp/boolean-arrays`; governed `src/`, `proof/` and `scripts/` remain identical
  to `1b7140d90b`.
- Original full-suite snapshot: `b63e81aa98c5cf02357a3fdf1dedd47e1a3f9613`.
  Catalogue/manifest rerun snapshot:
  `9d9c786dceac6160c6fff521ed273fddfdfa628b`, the validation checkout's copy of
  the integration fixture fix.
- Selected independent reviewer: **GPT-6 Astra / Extra High**. Runtime setting
  confirmation and token/cost measurements are unavailable. UTC evidence
  inspection: **2026-11-07 01:18:42–01:22:55**, 253 seconds. This is inspection
  wall time, not native execution time or whole-team cost.
- Read AGENTS.md, the Oracle, applicable development/proof-iteration and review
  requirements, agent reporting guidance, `docs/boolean-arrays.md`, and the
  [final regression packet](../evidence/boolean-arrays-20261106/final-regressions/README.md).
  Inspected fixture implementation and dependencies, primary logs/events,
  capture maps, Git differences and resource observations. Ran only read-only
  extraction/comparison and report checks; no test, native or proof jobs.

The [reviewed-input inventory](../evidence/boolean-arrays-20261106/regression-review/reviewed-inputs.json)
records the exact packet-index hash, comparisons and run identities. Its
[method coverage table](../evidence/boolean-arrays-20261106/regression-review/method-coverage.tsv.gz)
assigns each of the 603 required class-qualified methods one successful result.
All 49 artifacts covered by the packet's `artifact-sha256.json` matched their
recorded hashes, with no unindexed packet artifact besides that index itself.

## Inventory and coverage

Reconstructed every original outcome directly from
`original-full-native.log.gz`, including multiline test descriptions and the
manifest subtest error. All 612 identities and outcomes match
`test-identities.txt.gz` and `full-suite-result.json.gz`: **602 passes, eight
skips, one error and one failure**. The terminal unittest summary and managed
`finished` event independently retain failure.

Static inspection of the current test files gives exactly the same **603
class-qualified test methods**. This includes 598 direct method definitions and
five inherited image/array fixture methods; the latter remain distinct fixtures
under their concrete classes. The nine extra executions are the existing
`SharedBindingsTests` methods exposed through both `tests.test_shared_bindings`
and `test_shared_bindings`. They are not nine additional required methods.

| Disjoint coverage assignment | Distinct methods | Evidence |
| --- | ---: | --- |
| Retained original passes | 593 | `20261106T230401-5dde322e2782` |
| Corrected catalogue assertion | 1 | `20261107T003941-d065e68c8b90` |
| Complete manifest fixture rerun | 1 | `20261107T005845-c136b4eb6271` |
| Previously skipped native Lean controls | 7 | `20261107T004018-4c44e5aa8153` |
| Retained native certificate control | 1 | `20261106T225857-e507df7ab57e` |
| **Total** | **603** | **No uncovered method** |

The 55-test Lean selection passed all 55; only seven fill original gaps in this
partition. The retained certificate run passed all 16 selected tests; only one
fills a gap. These overlapping successes are not added to the suite total.
All selected outcomes were checked against their primary native logs and
managed events, not just the executor's summaries. The reviewed-input inventory
lists each of the ten originally nonpassing methods and its covering run.

## Applicability to the reviewed inputs

Independently hashed the current **8,686 captured paths** and compared their
tracked path set with `inputs-before-build.json.gz`. There are no additions or
removals within that capture, and exactly one changed file:
`tests/test_silver.py`. Every other captured source, proof, script, fixture,
sample, catalogue, Rosetta and project input is byte-identical.

The fixture delta consists of exactly two string constants inside
`SilverIntegrationTests.test_catalogue_is_json`: both now explicitly say
“Integer-array components.” Comparing the parsed old/current Python files after
normalizing those constants produces identical ASTs. Imports, module setup,
shared `HOST`/`ROOT`/`SILVER` values, `invoke`, its 120-second deadline and every
other method are unchanged. Callers importing those helpers therefore retain
the same behavior. No test/tooling reference was found that executes the changed
catalogue method as a shared fixture. The rerun checks the complete catalogue
method, including exact binary-to-JSON equality, rather than only the first
previously failing assertion.

The original, catalogue and manifest managed maps each contain 932 inputs.
After normalizing worktree prefixes, their only differing hash is that fixture
file. Native compiler hash remains
`c3f97c7f6477931ad01c76c3be658db06fc4c02f997a6475f921eee9a5362790`;
generated native inputs and captured build/toolchain configuration also match.
The successful build has its own original managed record and log. This review
does not promote build success to native proof/audit success.

The complete manifest rerun uses unchanged `tests/test_samples.py` and the
unchanged helper. Its single successful method necessarily traverses all
**61 sources / 117 execution cases** under the existing assertions, source-byte
checks, required report audits and effective prover-policy checks. It closes
the original `rosetta_shell_one_liner.adb` compilation timeout without increasing
the deadline or relaxing proof settings. The separate maximum dynamic-expression
method passed originally, including both execution cases and its report-policy
checks; its relevant inputs and helper behavior did not change, so no repeated
execution is required for this delta.

The seven fresh native Lean controls are exactly the seven applicable original
skips listed in `native-lean-fixtures-summary.json`. Their source files and
dependencies match the capture. The recorded tools are native Linux Lean
4.34.1/Lake with explicit executable identities. That checkout's prepared map
has 925 inputs: the seven absent entries are the application compiler and its
generated/native build configuration, which these synthetic Lean controls do
not use. The remaining common-map change is only the catalogue fixture hash.

For the eighth skip,
`NativeCertificateTests.test_generated_certificates_and_witnesses_remain_kernel_checked`,
independently compared all **802 selected inputs** in the retained record
against both the original capture and current bytes: all match. The selection
contains all 659 proof inputs, 131 native sources, nine scripts, two project
files and the selected source fixture. Its complete 925-entry prepared map
matches the original common map, **not the final whole map**: it still contains
the old `tests/test_silver.py` hash outside those 802 inputs.

That distinction is harmless for this selected control. Its inspected imports
do not reach `test_silver`; it loads the unchanged certificate generator and
copies current Lean source modules into a fresh temporary tree. It uses the
host-local Lean selector and sanitized Lean environment, compiling with `-j1`,
`-M2048`, warnings as errors and the existing 60-second subprocess deadline.
Its positive witnesses/certificates, axiom audits and deliberately invalid
witnesses/source mutations are covered by the explicit retained `... ok` result.
The application binary/generated configuration absent from its map is not used.
No whole-final-map identity or new tool attestation is inferred from this reuse.

## Resource event and limits

The original sample exception is specifically `TimeoutExpired` after 120 seconds
during compilation; its failed workspace/source and orphan inspection remain
retained. Original observations reach **217,660 KiB** available memory, compared
with **12,271,084 KiB** at the lowest observed point of the manifest rerun.
The application runs retain CPU affinity 8–11 after four-worker reservation;
the rerun retains the same fixture and prover settings. This evidence establishes
a failed timed execution and a successful unchanged-input rerun. It does not
establish that the timeout was a source defect, or prove memory pressure was its
sole cause. The host's separate OOM event does not erase explicit completed
test assertions; no recorded pass is being inferred from an interrupted job.

**Required follow-up:** final Rosetta delivery metadata has not changed in this
reviewed capture. Its three `tests/test_rosetta.py` methods currently retain
original passes. After the planned metadata update, inspect the exact delta and
confirm successful execution of all three methods on those final inputs before
extending this verdict. Any additional fixture, sample, tooling, generated-input
or implementation delta needs its own applicability assessment.

Complete native proof/audit and complete Lean/source-correspondence checkpoints,
their recovery outcomes, final capability/metadata integration and closing
feature assurance review remain outside this regression-only disposition.
The Oracle's universal guarantees cannot be discharged by composing sample or
regression passes. No blocking regression finding remains at the exact reviewed
snapshot; the later metadata confirmation is an explicitly open follow-up.
