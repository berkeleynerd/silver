# Common String expressions

Status: complete on Linux x86-64 on 2026-10-13, authorized by the owner's
“Proceed” following the proposed next roadmap unit. The implementation/review
target is the commit introducing `samples/common_expressions.adb`, based on
`7547b3d07d`. This extends the completed [shared-binding capability](shared-bindings.md).

## Supported scope and rules

Use the same String-expression grammar in ordinary declaration initializers,
assignment values, both operands of the existing inner equality, and output:

```text
expression ::= atom { "&" atom }
atom       ::= string_literal | initialized_name | "(" expression ")"
```

Names retain case-insensitive resolution and initialized reads. Copies retain
snapshot semantics. Every expression and intermediate String is bounded by
4096 bytes, an explicit value-resource policy matching the existing argument
and output domains. Parentheses preserve grouping; concatenation preserves byte
order. Assignment must preserve the target's fixed length.

The existing inner equality compares two such expressions. At least one operand
must contain an initialized String name: without an expected type, comparing
two entirely literal expressions is ambiguous in Ada. Initialization, assignment
and output already provide the expected String type. This is inherited type
resolution, not a restriction needed by the arithmetic proof.

An expression's length is `S + K*d`, where `S` counts static bytes, `K` counts
dynamic references including aliases, and `d` is the selected argument length.
Declarations run before body guards and must satisfy the bound with `d = 4096`.
Later guards cannot justify earlier concatenation. Guarded body expressions can
use the established capacity `C`, requiring `S + K*C <= 4096`. Assignment requires
the same static/symbolic length as its target; general path refinement is deferred.

The sixteen-leaf expression limit is retained. The source now has at most thirty
actual concatenation operators across all declaration initializers, comparison
operands, assignments and outputs, counting both branches. Literals and comments
are skipped by a verified lexical precheck, so ampersands inside them do not
consume the budget. This carries forward the previous two-output maximum
`2 * (16 - 1)` and distributes those operators among the newly usable positions. Different
positions can have different native proof costs; equal counts do not imply equal
runtimes.
It is an explicit translation/proof/report resource policy, not an Ada rule or
an unexplained larger replacement threshold. Atomic copies and grouping consume
no operator budget. Parenthesis depth follows the existing source bound.

Native flat/right-nested/balanced expressions with sixteen leaves passed.
Some thirty-two-leaf exploratory programs also passed; a sixty-four-leaf mutable
static case left a range check unproved under the production solver budget,
in addition to the earlier sixty-four-dynamic-reference failure. These results
do not establish a universally safe larger threshold. The larger fragment stays
outside admission. Parenthesis depths 64, 512 and 1900 proved and executed.

The existing body arrangements, sole first immutable argument initializer,
context rules and returning I/O behavior remain. General statement sequencing,
nested conditionals, repeated output and additional argument APIs remain later
roadmap work.

## Evidence and preservation

`tmp/common-expressions-active.json` identifies the task evidence directory,
preserved native/proof state and isolated model/equation/bridge workspaces.
The task directory is `.silver/linux-x86_64/common-expressions-20261013T152350Z/`.
Previous caches, complete evidence, unrelated scratch and the archived unfinished
repeated-output draft are preserved. Successful focused objects were reused
at the complete stable-input checkpoint. The canonical
`.silver/linux-x86_64/proof/` is the preferred warm cache, including all sidecars
and Lake metadata.

The host exposes 12 CPUs and about 31 GiB RAM, without swap; this differs from
the owner's 96 GB physical capacity. Linux is primary, macOS proof work is out
of scope, GitHub Actions remains disabled and independent replay is optional.
Native compiler verification, build and test coverage, universal Lean semantics/
obligations, actual-source correspondence, a fresh full axiom/coverage audit and
independent review passed. Publication remains authorized; Git history identifies
the implementation commit and the local recovery pointer records closing Git state.

## Native capacity and policy evidence

The independent probe record is
`.silver/linux-x86_64/common-expressions-probes/20261013T152332Z/validation-summary.md`.
It links exact sources, commands, reports, outputs and original failed/interrupted
experiments. Four boundary programs use the entire thirty-operator budget:

| Distribution | Source bytes | Native proof time | Main report bytes | Result |
| --- | ---: | ---: | ---: | --- |
| Initializer 7, equality 12, assignment branches 8, output 3 | 421 | 16.52 s | 51,314 | 25 range and 2 length checks proved; exact execution |
| Two repeated-input sixteen-leaf expressions | 378 | 17.66 s | 55,101 | 30 range checks proved; exact execution |
| Dense atomic declarations plus expressions | 4,096 | 56.50 s | 137,245 | 28 range checks proved, 230 precisely classified advisories; exact execution |
| Long overwritten name plus expressions | 4,096 | 11.60 s | 51,846 | 28 range checks proved, two advisories; exact execution |

All are accepted by the compiler with the aggregate bound and by both the native
and Python evidence policies. The report buffers remain 262,144 bytes. These
observations support the resource choice; they are not a universal serialization
or solver-time theorem. The existing faithful and complete producer/report-shape
and pinned solver-completion premises remain explicit in the
[trusted boundary](trusted-boundary.md#source-identity-and-program-proof-evidence).
Every initializer, RHS, comparison operand, output and intermediate group has a
universal affine range argument; assignments also have exact-length schemas.
Native generation must correspond to those schemas and include every obligation.

Larger exploratory programs are distinct evidence. Four sixteen-leaf declarations
(sixty operators) proved in 40.04 seconds with a 104,729-byte report. Eight and
sixteen declarations exceeded separate 120-second experiment budgets without
reports. A reduced-step diagnostic with counterexamples disabled produced an
eight-declaration report of 202,004 bytes, with 29 of 120 range checks unproved;
it is not production proof success. Other diagnostic runs were externally
interrupted. No report overflow was observed, and no buffer increase is inferred
from unfinished experiments.

Typed constant equality can emit `INEFFECTIVE` / `statement has no effect` and
`DEAD_CODE` / `this statement is never reached`. Argument and selected-result
Main policies permit exactly those messages with warning/flow/Main provenance,
positive locations and the existing nonsuppression checks. Static and assigned
policies retain their narrower messages. Genuine reports and adversarial mutations
exercise both independent native traversals and the Python helper. Safety
obligations, library report requirements and numeric message-ID policy remain.

## Sample and proof structure

The [sample](../samples/common_expressions.adb) uses grouped initializers, an
expression equality and assignment, a snapshot of the earlier mutable value,
and repeated selected-input references in common output. Its default output is
`Hello, guest / guest: guest! [wait??]` followed by LF. Nine native executions
exercise default/selected/empty values, the 2000-byte capacity, overflow, invalid
bytes and extra arguments. The retained compile took 21.40 seconds and proved
53 checks. It remains part of the complete manifest test as well.

`Bindings` provides affine summaries, immediate declaration snapshots and fixed-
length assignments. `ComposeSemantics` records the exact source scanner steps,
operand order and successful balanced terminal state; grouped evaluation and
every intermediate subtree have the same byte/length bounds. `ComposeGrammar`
records the typed-name anchor for equality. Decode/execution proofs use evaluated
comparison operands in the current store, before the selected assignment.
`ComposeObligations` includes every declaration and body expression and the exact
assignment-length channel. Typed helper equations and checked adapter contracts
connect these models to the actual SPARK recognizer and its resource precheck.
Matching source pins accompany that argument; they do not establish it alone.

## Completion checkpoint

| Check | Current result |
| --- | --- |
| Full native compiler audit | Passed: 2,602 checks (443 flow, 2,159 proof), 17 units, 234 entities, 54 classified limitation notes and 14 imports; 613.589 seconds with existing sessions/cache. |
| Native build and catalogue | Passed; native export equals the checked-in catalogue. |
| Universal model and examples | Passed focused build and fresh audit: 5,330 declarations, standard axioms only. Build 431.334 seconds, including 359 seconds in examples; audit 4.471 seconds. |
| Typed helper equations and recognition | Passed focused build and fresh audit, including the aggregate budget, scanner and comparison. |
| Final source specification/body certificates | Passed: 1,134.589-second build, 3.392-second fresh audit, 8,654 declarations. Successful objects and sidecars are reused in final integration. |
| Complete project Lean validation | Passed: 114 modules, 33,994 declarations, standard axioms only; build 1,137.575 seconds, fresh audit 3.217 seconds, total runner 1,142.486 seconds. Reused the completed focused/certificate objects; no independent replay. |
| Full native/Python test suite | All 256 methods covered successfully across the 864.049-second full invocation and a 0.890-second focused repair. The original run had two stale-certificate subtest failures in one method; after promotion, all twelve regeneration comparisons passed. Native/tool/test/sample/catalogue inputs stayed unchanged. |
| Independent review | Native/model, root-owned source interpretation and report-policy reviews found no remaining material mismatch. Review added an explicit checked equality between the model budget and native constant. |

The complete checkpoint passed. Optional independent kernel replay
and macOS proofs were not requested. The initial pre-budget source-certificate
pass remains retained separately and is not evidence for the final native bytes.
All failed/interrupted development attempts, the previous checkpoint, separate
workspaces, prior cache generations and unrelated scratch remain preserved.

The test evidence retains `full-tests.log`, `full-tests-result.json`,
`certificate-parity-rerun.log` and `certificate-parity-rerun.json` in the probe
directory above. The initial full invocation was not clean; the focused rerun
repairs exactly its two failing source comparisons without repeating successful
validation. The generated Lean certificates were promoted separately and are
covered by the certificate and complete Lean checks.

Independent reviews are retained in `native-independent-source-review.md`,
`lean-model-review.md`, `root-policy-review.json` and
`final-documentation-review.json` in the task directory, and `native-review.json`
and `semantic-review.json` in the probe directory. The explicit model/native
budget equality and stale advisory/fallback documentation were corrected.
The spec comment at `src/silver_output_profile.ads:9` still describes the retained
operator count as unchanged total work. The normative language and assurance
documents clarify that proof costs differ by position. Correct that low-severity
comment with the next required recognizer source edit, preserving this
checkpoint's native and source-certificate inputs in the meantime.

Final native evidence is retained in `native-full-proof.log`,
`native-full-proof-timing.json`, `native-proof-provenance.json`,
`native-full-reports/` and `native-evidence-final-check.log`. The final Lean log
is `lean-complete-01.log`, with its content-bound result copied to
`lean-complete-evidence.json`. Focused phases and failed attempts have separate
logs; their times are not the complete integration duration. Native full analysis
reused existing sessions and solver cache; this was not a cold proof measurement.
The final integration spent 912 seconds in `ComposeSourceChecks`, compared with
1.2 seconds in its consuming `ComposeSourceBridge`. This source-fact work is a
measured remaining cost; the completed certificate objects were already cached.
