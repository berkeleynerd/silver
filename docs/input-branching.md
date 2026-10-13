# Input-dependent branching

Authorized on 2026-10-10, starting from `4422316`, as the first item in the
[ordered development sequence](../roadmap.md#current-development-sequence).
Implementation and complete local validation passed; all eight productions are
supported. The implementation and review target is the commit introducing
[samples/input_branching.adb](../samples/input_branching.adb), identifiable with
`git log --diff-filter=A -1 --format='%H %s' -- samples/input_branching.adb`.
The Oracle is unchanged; Linux validation is primary, macOS proofs are a non-goal
and GitHub Actions remains disabled.

## Scope

One immutable String is initialized by `Silver_Arguments.First_Or_Default`.
Inside the existing `Input_Is_Valid` guard, one equality between that name and a
literal chooses one of two terminal literal `Put_Line` calls. Invalid argv takes
the existing terminal `Reject` branch. Identifier binding ignores ASCII case;
String equality compares exact decoded bytes and is false for unequal lengths.
Defaults, comparison literals and both outputs range over the existing literal
domain, including empty strings and doubled quotes. No new runtime operation,
mutable state, general Boolean expression, further decision nesting or repeated
output sequence is admitted by this increment.

The motivating sample is [samples/input_branching.adb](../samples/input_branching.adb); the
[roadmap example](../roadmap.md#input-dependent-branching) records the motivating
brief/verbose behavior. The sample does not establish universal assurance.

## Obligation experiment and report decision

Eight native GNATprove 16.1 cases used the original application bytes and the
unchanged selected runtime libraries: ordinary, empty, escaped quotes,
unequal-length comparisons, mixed case, `Dummy`, `Unused_Mode` and a maximum
4096-byte source. Each passed with full Main coverage and empty `flow`, `proof`
and `warn_error` lists. The effects dependencies are the existing
`First_Or_Default`, `Input_Is_Valid`, `Reject` and `Put_Line` operations.

Consequently this form uses the existing strict empty-Main report route with
`--warnings=error` and `--checks-as-errors=on`. The guarded-concatenation and
assignment selectors remain unchanged. Complete selected-library reports,
source/library identity, successful tool status and all existing publication
checks still apply. No driver, runtime, warning flag or report-policy change is
needed. The complete sources, commands, reports and hashes are retained in
`branching-validation/experiment/summary.json` and its sibling case directories.
These reports corroborate the modeled obligation class; samples do not prove
faithful generation or external tool completion universally.

## Assurance and source review

`BranchingAdmission` defines the 67-token grammar and independent ordered-event
relation, including one declared name, its comparison reference and all four
literal occurrences. Admission is decidable and equivalent to that grammar.
`BranchingSemantics` proves binding, unique meaning, literal domains and bounds
for either selected output. Predefined String equality compares decoded bytes;
identifier case folding does not alter the values being compared.

`BranchingMain` uses one typed composition for source rendering, ordered event
consumption and execution. It preserves missing/default and explicit-empty
input behavior, rejects invalid input, and executes exactly one output branch.
Its universal success and failure theorems use the existing argument and output
wrapper semantics. `BranchingDisjoint` separates this grammar from all seven
previous productions. `Current` extends whole-language membership, unique
meaning, safety, effects and the conditional automatic-discharge pipeline.

`BranchingEquations` and `BranchingExpressions` connect the recursive suffix
with shared lexical, literal and name helpers on their legal machine domains.
The source bridges check the actual suffix expression, precondition, recursion
variant, token declaration/spellings and executable refinement contract. The
private `Accepts_Branching` function has an inline postcondition; there is no
separate branching ghost-member function or report-policy selector. The public
membership union and typed Main rendering are included in correspondence.
Source-shape pins are reviewed with those source and semantic changes, and the
candidate certificates reconstruct the authoritative Ada bytes under kernel
checking. No certificate representation or source partition changes are included.

The trusted Ada frontend supplies predefined String equality and statement
interpretation. Faithful complete GNATprove generation, fixed-library proof
completion, bounded solver completion for the already supported guarded form,
and the existing external runtime/environment assumptions remain explicit.
The new form models an empty Main safety-obligation list. See
[assurance](assurance.md#statement-sequences-and-equality-choices) and
[the trusted boundary](trusted-boundary.md).

## Local validation checkpoint

Validation is **complete** on Linux x86-64, with unchanged implementation and
proof inputs throughout the final checkpoint.

- Native build and catalogue equality passed. The isolated focused proof passed
  all 1205 checks for the output recognizer and catalogue.
- Six focused branching test methods passed, including eight compile/prove/link
  runs, all four literal positions at the source-size limit, identifier binding,
  both branch outcomes, invalid argv and failures on both output branches.
- Focused Lean admission, semantics, disjointness, typed Main and public-union
  checks passed. Compact witnesses test independent source bytes and semantic
  cases; no expensive exact-sample payload witness was added.
- Independent native, model and source-correspondence reviews found no material
  mismatch. Scope and exact hashes are retained in `review-native.md`,
  `review-model.md`, `review-lean-source.md` and `review-root.json`.
- A focused fresh-token diagnostic passed the affected catalogue, expression,
  numeric declaration and refinement-contract assertions, including the typed
  branching postcondition. This is a diagnostic against candidate tokens; it
  does not replace the separately completed authoritative-source certificate chain.
- `python3 scripts/dev.py prove --full` passed in 670.493 seconds with retained
  native caches: 3029 checks (412 flow and 2617 proof), 16 units, 215 entities,
  41 classified limitation notes and 14 approved imports. Inputs were unchanged
  and completed provenance independently matched. The summary and retained
  reports are `native-full-summary.json` and `native-full-reports/`.
- `python3 scripts/dev.py test` passed all 174 tests in 925.503 seconds,
  including all eight manifest samples. The start/end input inventory was
  unchanged. `tests-full-summary.json` and `tests-full.log` retain the result.
- The authoritative-source Lean build passed all 94 Lake jobs. Its fresh axiom
  audit covered 83 modules and 23,205 declarations, with only `propext`,
  `Classical.choice` and `Quot.sound`. The independent fresh kernel replay
  passed in 1291.993 seconds.
- Independent final corroboration matched all 108 shared inputs, 85 workspace
  inputs, 166 compiled artifact records and three tool hashes. It independently
  enumerated inventories and the fresh audit's complete module closure,
  including all eight branching modules, checked the successful kernel phase,
  and matched overlapping native/test evidence. There were no findings.
  `lean-final-result.json`, `lean-final-evidence.json`, `lean-final-proof.log`
  and `lean-final-corroboration.json` retain the result and exact identities.

The initial isolated native proof invocation stopped during setup because its
separate cache directory did not exist. After creating that directory, a manual
invocation passed without changing source. Both `focused-native-proof.log` and
`focused-native-proof-cache-created.log` are retained; no automatic retry was added.

Evidence lives under `.silver/linux-x86_64/branching-validation/`. The
`preserved-before-validation/` directory contains baseline native sources,
compiler binary and completed native/Lean reports/manifests. Old root candidate
certificates are also retained there before regeneration. Live proof objects,
solver caches, tools, scratch and foreign-host artifacts remain in place.

The intermediate `source-certificates-*` record covers the successful
source-certificate target build: 10533.007 seconds overall, including 10491
seconds for the output-body certificate. Its selected inputs were unchanged.
It is not a full current-input verification claim. The final full invocation
reuses those completed objects and captures the final input set; its remaining
build took 322.092 seconds and its fresh axiom audit 2.732 seconds. The independent
fresh kernel replay passed in 1291.993 seconds. The final invocation took
1619.188 seconds overall, excluding the intermediate certificate work. These
are cached full-verification timings, not cold-build timings. Lean uses 12 Lake workers,
12 threads per process and a 12288-MiB per-process threshold on this host; the
threshold is not an aggregate memory budget or a demonstrated speedup.
A point observation during the output-body certificate found about 6.3 GiB RSS,
above the prior 6144-MiB setting and within the current threshold. The retained
`lean-memory-observation.json` gives its time and process identity; this is not
a whole-run memory peak.

The owner requested end-of-day checking or serious compartmentalization after
observing the serial cost. The [workflow](../development.md#proof-loop-and-validation)
now batches expensive correspondence checks at a stable end-of-session/day
checkpoint, with focused native/model checks during iteration. The
[architecture follow-up](architecture-review.md#proof-structure-and-the-expensive-rebuild)
prioritizes measured source/dependency compartmentalization before another
language increment. Neither a partition nor a new performance benchmark was
added to this capability; no speedup is claimed from scheduling alone.

GitHub Actions remains disabled. macOS proof work is outside this increment;
retained artifacts are preserved. GNAT Pro remains untested. The historical
GNATprove `DOC_END` failure is not established as repaired by successful runs.

## External review of `1ed039e`

The [full final review](reviews/review-1ed039e.md) arrived in `26737d9` and has
been assessed alongside the [runner review](lean-iteration.md#external-review-of-d375aec).
Its macOS runs remain optional external evidence, not Linux validation.

| Finding | Assessment and disposition |
| --- | --- |
| L1: assignment-member header | Fixed and validated in the runner-review follow-up. |
| L2: prior-review dispositions | All findings from the full assignment review now have a [disposition](string-assignment.md#external-review-disposition), including generation premises and bridge/model wording. |
| L3: in-place byte drift | Added default-mode shared, handwritten workspace and generated-candidate byte edits after build/audit. Candidate edits specifically test workspace hash comparison. |
| L4: branching/driver/Static test expansion | Defer blanket promotion. All reported probes passed; fixed-token admission, existing driver contracts and native/report tests cover the behavior. No demonstrated defect justifies expanding this repair with every adjacency, exclusion, route mutation and Static annotation witness. |
| L5: stale text | Corrected current memory/I/O guidance, README handoff description and obsolete test timeout comment. Defer the `silver_reports.ads` “Both/sole entity” comment until the next source change, avoiding native source/evidence churn for prose alone; the route actually serves the first five forms and branching and requires one full-SPARK coverage entry, not one entity. |
| I1: null-route metadata | Retain the documented genuine-producer premise and current policy; the review found no admitted-source failure. See the assessment below. |
| I2–I3: named theorem list and exclusivity | Fresh whole-module auditing and existing disjointness/driver contracts supply the arguments; no new registry or redundant theorem is needed. |
| I4: extra proved checks | Explained by invariant splitting; no action. |
| I5: helper type/suppression mutants | Defer additional development-helper coverage until that policy changes; the implementation is correct and the admission path uses the SPARK checker. |
| I6: focused command and child cleanup | Focused runner is implemented; added a mocked interrupted-read test requiring child kill and reap. |
| I7: withdrawn findings | No action; the reviewer dropped them. |

The following preserves the interim information received at the earlier checkpoint.

The owner's supplied review reports a matching cold native SPARK total,
174 passing tests, 272 expected branching executions and a successful advisory
helper mutation check. These are the reviewer's optional macOS observations;
its Lean replay, differential comparison and verified findings were still
pending. They are not additional Linux evidence or a completion prerequisite.

Independent read-only inspection confirmed that the empty-Main-report route
checks completion, one numeric-key full-SPARK coverage entry and empty required
lists, but does not resolve entity identity/location or dependency records in
`assumptions`. This route serves the first five forms and branching. Tighter
metadata checks could catch routing or producer/schema mistakes, but fabricated
report acceptance alone establishes no genuine-tool failure for an admitted
program. Fresh workspace/tool execution, source equality and complete separate
library checks remain, together with the documented genuine-producer premise.
No admitted-source failure with genuine tools was demonstrated, so no
report-policy change is warranted now. In particular, legitimate dependency records must not
be rejected merely for being nonempty. The final review supplied no genuine-tool
counterexample that changes this assessment; do not wait on macOS proof work.
