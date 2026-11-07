# Boolean-array flag repair review — 2026-11-07

**Disposition: the reviewed source repairs correctly classify Boolean-array
writes as assignments and preserve output flags.** The review found the same
missing constructor in the immediately dependent selector module; the lead
repaired it during this review, and those exact additional bytes are included
below. No further source correction was found in this bounded inspection.
Focused and complete Lean/source validation remain required.

## Target and review record

Review baseline: `689aef86bf9a0b33d0fcf13dee212e069d07cb64`, with the following
uncommitted proof-only repairs:

| File | Reviewed SHA-256 |
| --- | --- |
| `proof/Silver/PredicateFlags.lean` | `68abbc4300749bec2700c9e6875e3b3e741d68062af737bf3ca8240431855e42` |
| `proof/Silver/PredicateSelectors.lean` | `997e39338371dbf5235c2dc2bdc34dd174b03df8cf0ea55418b792ab8d4c535c` |

The [exact diff](../evidence/boolean-arrays-20261106/regression-review/flags-reviewed.diff)
and [reviewed-input inventory](../evidence/boolean-arrays-20261106/regression-review/flags-reviewed-inputs.json)
retain baseline/current hashes and dependency evidence. The initial requested
scope was `PredicateFlags`; inspection of its direct consumer exposed the
selector omission. This extension is limited to that same flag/lowering path.
No native source, script, certificate, test, sample or catalogue changed from
the review baseline.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort confirmation
and token/cost measurements are unavailable. UTC inspection interval:
**2026-11-07 01:40:36–01:43:09**, 153 seconds. This is reviewer inspection wall
time, not native execution time. No proof/test jobs, staging, commits or GitHub
writes were performed by this reviewer.

## Semantics and premises

`PredicateBodyAdmission.booleanArrayAssignmentBody` has two outcomes. Invalid
target/type/mutability/index/read conditions return `invalidBody scan`. Success
returns `{scan with position := value.after, assigned := true}`, preserving
`scan.output`. `BasicPayload.booleanArrayAssignment` retains the concrete kind,
Boolean-array indexed-target reading and condition reading; `BasicAt` additionally
requires the successful scanner equation and a nonzero result position.

The new `Flag.source` alternative consequently has the correct values:
assignment is true and output is false. In `basic_flags`, the existing successful
`BasicAt` premises imply raw scanner success. Splitting the unchanged admission
guard eliminates the invalid branch by its zero position. The success branch
then uses the existing `bodyToken_flags` fact and the actual record update to
prove the original equation
`flag.observe result = (flag.observe scan || flag.source item)` for both flags.
The payload's indexed and condition witnesses remain premises; the flag proof
does not need their internals because it observes only the scanner's two flags.

No theorem statement, admissibility premise, failure branch, recursion measure
or trusted assumption is weakened. The repair adds an omitted constructor case
using the adjacent Integer-array/Boolean assignment proof pattern. Existing
choice/loop/list propagation still computes flags from written statements,
including untaken arms; it does not substitute runtime-path reachability for
the compiler's syntactic assignment/output policy.

The native `Boolean_Array_Assignment_Body` in `src/silver_output_profile.adb`
likewise checks the existing target, Boolean element type, mutability, indexed
target and advancing condition result, then returns
`(Scan with delta Position => Value.After, Assigned => True)`. The corresponding
ghost model has the same flag update. The inspected unchanged
`PredicateBooleanArrayBodyNative.assignment_model`, helper
`assignment_meaning`, `PredicateBasicLibraries.booleanArrayAssignment` linkage
and `PredicateBooleanArrayBodySource.Checked` headers/body requirements carry
this model through the native source route. The patch neither changes these
source checks nor replaces their required complete validation with this review.

## Finding and disposition

The original `PredicateSelectors.lean` omitted `.booleanArrayAssign` from both
`Flag.statement` and `source_lower_flags`. Because `Statement` and
`SourceStatement` already contain that constructor, repairing only the upstream
flag module would leave this immediate consumer incomplete.

The lead's reviewed repair adds the constructor to the assignment classification
and the corresponding lowering proof case. `SourceStatement.lower` preserves
the Boolean-array update as `.booleanArrayAssign update`, so simplification of
the existing definitions proves the unchanged source/lowered flag identity for
both flags. The downstream `meaning_selectors` statement retains its original
assignment/output correspondence. **Disposition: source correction reviewed;
machine-checked integration remains pending.**

## Effect on retained regressions

The [earlier regression applicability review](review-boolean-arrays-regression-applicability-20261107.md)
retains its exact historical target and verdict. This report supplies the
additional dependency assessment for these two proof-file changes; it does not
silently replace that earlier input inventory.

Rehashing the 8,686-path capture finds only the previously reviewed
`tests/test_silver.py` expectation correction plus these two proof files. The
603-method test inventory, native compiler inputs, fixtures and samples remain
unchanged. In particular, **the earlier 802-selected-input equality is no longer
true of the current tree**: 800 match and these two proof inputs differ.

The retained native certificate control nevertheless remains applicable. Its
actual compiled project import closure is exactly `Lexical`, `Admission`,
`Cursor`, `SourceLexer`, `CertificateWitness` and `AxiomAudit`; all six still
match their captured bytes. The fixture's generator, Python dependencies and
synthetic positive/negative controls are unchanged. Neither repaired flag module
is compiled, imported or read by that control. Its larger 802-file capture is
not a claim that every captured proof file participates in this test.

The seven native Lean repair controls similarly use unchanged synthetic modules,
source bindings, audit/generator modules and configuration. The remaining
regression readers of real proof files inspect import closure, `include_str`
occurrences or the `module` declaration. Those exact projections are unchanged
in both repaired files, as recorded in the inventory. Runner/provenance controls
use their synthetic workspaces; the native/application tests do not compile
these Lean modules. Therefore this delta creates **no additional uncovered
regression method and requires no repeated certificate or full-suite test run**.

It does invalidate the relevant Lean proof artifacts: the public flag definitions
and their downstream consumers must be rebuilt/checked on current inputs, with
the complete final source/module/axiom checkpoint still mandatory. The lead's
reported focused run is not assumed successful here, and no failed complete run
is relabelled. Native full-audit completion is also outside this report.

The previously recorded final Rosetta metadata update and three-method rerun
remain an open, separate follow-up. This review approves neither full Boolean-
array assurance nor merging PR #335.
