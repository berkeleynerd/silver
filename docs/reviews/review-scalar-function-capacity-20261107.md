# Scalar-function report capacity and policy review — 2026-11-07

**Disposition: no material finding in this bounded review.** The function
extension fits the inherited 32 MiB retained-report allocation under the
documented producer/tool premises. The inspected production recipe and report
auditors require the exact declared local functions, complete SPARK coverage,
successful termination witnesses and discharge of every emitted safety check.
This is not a completed scalar-function assurance or delivery review.

Reviewed integration commit:
`9469d5632b7e21a60ee10606b947a59532ad380e`, for
[#298](https://github.com/berkeleynerd/silver/issues/298) and draft
[PR #339](https://github.com/berkeleynerd/silver/pull/339). The owner authorization
supplied by the lead covers implementation through reviewable publication;
implementation merge is not authorized. Review changes are confined to this
report in a separate worktree.

## Scope and inputs

Read the Oracle, repository review guidance, the function language/selected-scope
sections, relevant assurance/trusted-boundary sections, the feature capacity
account and inherited report/array/String capacity accounts. Reviewed the
production command in `src/silver.adb`, bounded report-policy implementation in
`src/silver_library_reports.adb`, `scripts/check_evidence.py`, the sample manifest
and retained reports. Parser/model/source correctness and full compiler proof
discharge are separate lead-assigned reviews; this review does not duplicate them.

Primary input hashes at the target commit:

| Input | SHA-256 |
| --- | --- |
| `docs/scalar-functions-report-capacity.md` | `b01229257e63ab3de4d1816ca69de64e898d43675a7691aa269843e5652d99b6` |
| `src/silver.adb` | `3aa56f5bc6df2cadca049235948cc56a3ebf74dd43b7d6738a439253e1fc15e1` |
| `src/silver_library_reports.adb` | `700e6fb94d4d722cb3d95a8c145c03bee44dd36a6384bb693772dd6bc8531459` |
| `scripts/check_evidence.py` | `503e8d3b3ab9178af3a12e546aaa1d6da4c24598224210237d634c5a4d14ab9e` |
| `samples/manifest.json` | `aac2f976d16cf0c8aacc5fc80a23f9f2782455e830beefb2cdbe4d84057c1757` |

The five SPARK producer files were read from the retained scratch directory
`tmp/scalar-functions-reports-298/tmp/producer/` in the original checkout.
Their SHA-256 values independently match all five entries in the
[feature capacity account](../scalar-functions-report-capacity.md#inspected-inputs-and-observations),
which identifies revision `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`.
This retains the existing external-tool/source qualification, without an
installed-binary correspondence claim.

## Capacity argument

The inspected `gnat2why-expr.adb` actual-parameter route (4579–4585,
4818–4877) translates each scalar actual with its expected formal type.
`Transform_Simple_Return_Expression` (29243–29359) translates the result once;
the extra validity, tagged and access/borrow branches are outside this fragment.
Modular `--no-inlining` removes contextual body expansion from this accounting.
Existing scalar conversion, arithmetic, comparison and check-identity premises
therefore continue to apply across the separately analyzed function bodies.

The added Integer-actual reservations are disjoint: each actual owns its call
delimiter and a value-token byte; an indexed read owns its inner parentheses,
and an Integer actual contains no comparison. Return roots own two bytes of
their separate `return` keyword. Call-result stores retain their `:=` bytes.
Boolean actual/result conversions introduce no separate Boolean range check.
Thus these sites fit the inherited `floor(S/2)` shared bucket, rather than
adding a second overlapping maximum. Function-local counted loops introduce no
shorter loop syntax and cannot contain array state or writes. Main's indexed
actual reads do not add array-write initialization advisories. The unchanged
63-operator budget remains shared across the complete source.

In `gnat2why-assumptions.adb:48–69,85–110,133–156`, sets/maps deduplicate
claims and caller/callee tokens. For a contract-free local callee, one Effects
token belongs to the caller's Effects claim and Effects/AoRTE tokens to its
AoRTE claim: at most three tokens per distinct textual-call edge. Registration
at 164–191 excludes the Post claim without an explicit postcondition. The
serialization in `assumptions.adb:93–111` and
`assumption_types.adb:266–320` uses numeric IDs and interns entity names.
There is no per-safety-record or per-dependency repetition of a function name.

The function and call ceilings are conservative: a complete admitted function
uses more than 32 disjoint source bytes, and even `R:=F(0);` uses eight. Their
independent maxima may be added safely despite overcounting joint source use.
The inherited fixed-record/numeric/timing-key allowances remain applicable;
new entries reserve additional per-entity timing and claim structure. Two name
occurrences per function fit the additional `4*S` allowance. The exact
termination success route at `flow-analysis.adb:6712–6722` emits one fixed
record per function. Its unused-object route at 1275–1366 iterates a set and
emits at most one advisory per unused formal. These formal declarations occupy
their own source spans, so their one-record/one-name contribution fits the
inherited `2*S` flow and aggregate-name allowances.

Independent integer arithmetic reproduced the entire combined ledger:

| Quantity | Result |
| --- | ---: |
| Inherited safety-record ceiling | 5,689 |
| Inherited nested-array-advisory ceiling | 21,845 |
| Inherited retained envelope | 31,822,336 bytes |
| Function/call ceilings | 128 / 512 |
| Added metadata, termination and name allowance | 1,327,104 bytes |
| Combined envelope | 33,149,440 bytes |
| Existing allocation | 33,554,432 bytes |
| Remaining headroom | 404,992 bytes |

This validates the feature-local extension of the retained producer account.
It is not a solver-time, process-memory or arbitrary-JSON bound. The inherited
projection removes only designated `check_tree` values, preserving every
obligation record and its acceptance-relevant fields.

## Report policy and retained observations

`src/silver.adb:85–86,124–132` obtains the function inventory from the admitted
source and adds `--no-inlining` whenever it is nonempty. It retains `-U`, full
flow/proof reporting, checked errors, existing provers/budgets and disabled loop
unrolling. The source is not replaced by annotated or restricted-domain code.

In `src/silver_library_reports.adb`, `Function_Spelling`/`Function_Name` match
the exact source-derived name after `Main.` under Ada case equivalence.
`Expected_Entity`, `Expected_Coverage` and the map fold require every declared
function exactly once with `all` coverage. `Termination_OK` validates the exact
successful flow record; the ordinary flow fold validates every record, while
the per-function witness folds require exactly one termination record for each
function. `Record_OK` keeps the existing proved/prover safety-rule whitelist,
exact application entities and all suppression/justification exclusions.
`Reference_OK` and `Dependencies_OK` traverse all claims and dependency lists,
allowing only Effects/AoRTE for local functions. Unknown entities and local
Post claims are rejected. These checks include unused declarations.

The Python auditor independently uses the supplied exact function inventory,
requires full entity/coverage correspondence and unique termination coverage,
checks all safety/dependency records and requires `--no-inlining`. The existing
sample manifest supplies exactly `Is_Prime`. No generic `Main.` prefix replaces
that list. Complete and accurate producer evidence remains the documented
trusted premise; this review does not add an adversarial-artifact requirement.

Read-only inspection of the retained
[native behavior packet](../evidence/scalar-functions-20261107/final-native-behavior/README.md)
confirmed the 658-byte unchanged sample source, SHA-256
`6e2d5263135fb3aa0c36554425303c3b87a375315207c37ee897c5ed71b457a4`.
Its 7,493-byte raw Main report, SHA-256
`0e0a6c2b010e97ae14bfe6b961b321744dca3cb6d23717d7c1c06d80d98a5398`,
contains Main and Main.Is_Prime with `all` coverage, one successful function
termination record and two proved division records attached to Is_Prime. Its
numeric dependency references and 27-key function timing map corroborate the
inspected shape; SARIF records the required production options.

The earlier selected-grammar probe `20261107T173133-e00faebcc964` was also read
from `tmp/scalar-functions-plan-298/tmp/native-function-probes/selected/`.
Its source/report SHA-256 values are respectively
`844977832049bb3811901ae0c86117882276ad9776ee3f0075d225746081b31f` and
`5556d3921789bbd0a9e5f4cb1237dcac2011eca9c5a323eff0d7a72ce2e6b05c`.
All five Main/local entities have full coverage; four termination records and
five safety records include the uncalled `Unused` function's division check.
The repeated Is_Prime calls share dependency tokens. This is producer-mechanism
corroboration, not final compiler evidence or universal assurance.

The native packet belongs to its recorded `0b24ae95f8` snapshot. The production
driver, report-policy implementation, Python auditor, sample and manifest
inspected above have no changes between that snapshot and this review target;
that observation does not extend the packet to unrelated later proof changes.
Complete compiler Bronze/Silver verification and complete Lean/source checking
remain pending outside this review. No support promotion or merge conclusion
follows from this bounded clean result.

## Review execution

Selected reviewer setting: GPT-6 Astra / Extra High, as supplied by the lead.
Independent runtime model/effort confirmation and token/cost telemetry are
unavailable. Host confirmed as Linux x86_64; `scripts/dev.py paths` was read.
Work consisted of source/report reads, hash comparisons, analytical accounting
and elementary arithmetic. No native proof, Lean build or test suite was run;
no native workers were reserved. Source/report examination and report preparation
took 274 seconds (23:08:37–23:13:11 UTC), excluding final staging/commit.
The live harness goal returned `null`. CLI recall was not updated by this
bounded subthread.
