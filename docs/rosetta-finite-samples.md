# Five finite current-language Rosetta samples

## Scope and authorization

The owner instructed on 2026-10-25: “Please merge 221 and 227 and then proceed
with 226.” PR #221 merged as `ab9d0cee053c2ec6d38a0a312427cb380466a84b` and
PR #227 as `8002d5ac5508c7603dc411f7457b32c80f160245`. The
[dated authorization](session-memory.md#2026-10-25--merge-deliveries-and-implement-the-five-finite-samples)
reached main before [#226](https://github.com/berkeleynerd/silver/issues/226)
was claimed in [milestone 6](https://github.com/berkeleynerd/silver/milestone/6).

The [planning assessment](../rosetta/assessment-reconciliation-20261025.md)
selected five finite programs already expressible in the current language.
This delivery adds those programs and their manifest execution cases. It
does not expand #9's original scope, add a construct or change admission,
capacity, the Oracle, tool pins, the catalogue or Rosetta's supported list.
Integer sequence remains outside this batch; its full implementation-limit
domain has not been capped or represented as an executed sample.

## Programs and observable behavior

Implementation and independent review target:
`3aae49385f2c432faf2495d4d9ec177b0e852b7e`, against main
`8002d5ac5508c7603dc411f7457b32c80f160245`. All five sources use only permitted
ASCII bytes and are below the 4,096-byte source bound. Each has one execution
case, with empty stderr and status 0 on successful output. The
[manifest](../samples/manifest.json) retains exact stdout, including Ada Image
spaces and final LF bytes.

| Task | Source | Behavior and selected proof-report policy |
| --- | --- | --- |
| [Compile-time calculation](../rosetta/c/compile-time-calculation/task.wiki) | [rosetta_compile_time_calculation.adb](../samples/rosetta_compile_time_calculation.adb), 765 bytes | Ada-static grouped multiplication computes 10!; prints `10! = 3628800` and explains static-expression and capacity limits. Static policy. |
| [Loops/N plus one half](../rosetta/l/loops/n-plus-one-half/task.wiki) | [rosetta_loops_n_plus_one_half.adb](../samples/rosetta_loops_n_plus_one_half.adb), 313 bytes | Separate number/comma calls inside a counted loop; the final iteration skips its comma. Image supplies the initial and inter-number spaces. Static policy. |
| [Enforced immutability](../rosetta/e/enforced-immutability/task.wiki) | [rosetta_enforced_immutability.adb](../samples/rosetta_enforced_immutability.adb), 750 bytes | Constants and a loop index remain immutable while a separate mutable copy changes from 42 to 43. Commented illegal assignments explain the rule and are not claimed as executed negative tests. Assigned policy. |
| [Literals/Integer](../rosetta/l/literals/integer/task.wiki) | [rosetta_literals_integer.adb](../samples/rosetta_literals_integer.adb), 1,499 bytes | Demonstrates representative bases, delimiters, separators, exponents and signed endpoints; explains all bases 2–16. `7#1#E3` evaluates to 343. Static policy. |
| [Minimum cells in an NxN square](../rosetta/m/minimum-number-of-cells-after-before-above-and-below-nxn-squares/task.wiki) | [rosetta_minimum_number_of_cells.adb](../samples/rosetta_minimum_number_of_cells.adb), 633 bytes | Computes the 10-by-10 grid of minima of four edge distances. Each RHS independently fits the mutable object's `0 .. 9` range; no scalar guard refinement is assumed. Assigned policy. |

The reviewed planning prototypes are preserved under
[assessment evidence](evidence/rosetta-assessment-20261025/candidates.json).
Delivery adds explanatory comments and one explicit space in
`Integer spans -2147483648 .. 2147483647`; that is the only executable/output
adaptation. Expected stdout sizes are respectively 14, 31, 82, 155 and 210
bytes. The other 35 manifest samples are unchanged.

The progression already placed these five approaches in stage 1 after the
planning reconciliation. This sample-only delivery requires no re-render or
change to `coverage.json`. Samples exercise existing rules; universal assurance
remains in the [assurance record](assurance.md), under the existing
[trusted boundary](trusted-boundary.md).

## Validation

All required validation passed. The
[evidence index](evidence/rosetta-finite-samples/validation.json) records actual
commands, source comparisons, run identities, sample hashes and results.

The lead is the sole proof-workspace writer. The native installation at
`tmp/bounded-mutable-integers-native` and Lean installation at
`tmp/review-b79-b1-lean` are both detached at implementation `3aae49385f`.
Original paths, caches and unrelated scratch are preserved. Linux x86-64 is
the actual validation platform; no native macOS or hosted CI run is claimed.

The compiler, runtime, scripts, proof sources and build configuration are
byte-unchanged from the previous successful compiler checkpoint. The retained
full GNATprove reports and build from runs `20261025T070959-fd3da7c63f7a` and
`20261025T071056-2f783520af81` therefore remain applicable. A fresh
`python3 scripts/check_evidence.py` passed the complete report, source and tool
provenance checks: 75 units, 1,000 entities, 1,295 flow checks and 13,860 proof
checks. All 141 tracked compiler-proof inputs match this implementation.
[Retained native evidence](evidence/rosetta-finite-samples/retained-native-evidence.json)
records the provenance manifest, binary hash and input comparison. This is
reuse with fresh auditing, not a new GNATprove or build run.

Complete cached Lean/source run `20261025T144732-3f0c19eb35cc` passed the fresh
whole-project module/axiom audit: 466 modules and 89,369 declarations, with only
`propext`, `Classical.choice` and `Quot.sound`. All 581 authoritative inputs
match the implementation; the runner used four workers and two threads per
process and reported 37.116 seconds. The
[Lean summary](evidence/rosetta-finite-samples/lean-evidence-summary.json)
identifies actual commands, phases and retained artifacts. This reused source
certificates and is not an independent kernel replay.

Full regression run `20261025T144837-3d46e7fa201f` passed all **474 tests**,
including all **40 manifest samples** and their **96 execution cases** (five new
cases), with six reserved workers. Unittest time was 2,690.823 seconds;
managed elapsed time was 2,692.423 seconds. Its manifest test admits, proves and
builds each source's byte-identical
snapshot, audits every required application/library report and effective prover
option, executes the built program and compares stdout, stderr and exit status.
The application workspaces are audited and then cleaned by the test; successful
suite evidence is not an archive of per-program proof reports. The existing
platform and Lean-fixture symlinked-TMPDIR regressions both passed. All 698
captured tracked test inputs match implementation `3aae49385f`; eight additional
captured identities describe the executable, installation and environment.
The [summary](evidence/rosetta-finite-samples/full-suite-summary.txt) and
[compressed complete log](evidence/rosetta-finite-samples/full-suite.log.gz)
retain the successful run. Documentation-only delivery edits followed; no
source or proof input changed and no successful expensive check was repeated.

The implementation and evidence are published through
[PR #228](https://github.com/berkeleynerd/silver/pull/228). #226 is In review
until its completing commit reaches main. No validation obligation remains;
the next step is review/merge of this delivery. A later construct increment
under #11 still requires a separate owner instruction.

## Review and rounds

| Work | Selected or confirmed settings | Result | Measurements |
| --- | --- | --- | --- |
| Sample implementation | Selected GPT-6.1 Sol, Extra High; runtime settings not independently exposed | Five reviewed prototypes adapted into samples and exact manifest cases; no language change. | Elapsed not instrumented; token/cost data unavailable. |
| Independent implementation review | Selected GPT-6.1 Sol, Extra High; runtime settings not independently exposed; exact `8002d5ac55..3aae49385f -- samples/` | No findings: task fidelity, independently derived expected bytes, source bounds, comments, policy tags and specification links agree. Static review, separate from native validation. | Reviewer-measured 97 seconds; token/cost data unavailable. |
| Integration and validation | Live lead model/effort not exposed; no setting change claimed | Native evidence freshly audited, complete cached Lean check and all 474 regression tests passed; exact input correspondence verified. | Lean and suite timing above; complete elapsed, tokens and whole-team cost unavailable. |

The remaining #11 constructs and deferred #119/#88–#94 work are outside this
delivery. No new goal was created; the earlier capacity harness remains paused.
CLI memory was unavailable and was not updated. The issue and this record are
the continuation pointers.
