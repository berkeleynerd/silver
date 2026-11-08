# Remaining parser postconditions — six focused native successes

All six authorized complete selected-subprogram checks succeeded on native Linux
x86-64. Each managed run recorded success and each actual child exited 0. The
sequential runner was polled through its actual exit 0. There was one attempt per
target, no retry, no failure or suppressed obligation. These are focused native
results; complete compiler obligation/coverage/provenance and Lean/source
assurance remain separate required work.

Source-only commit `ee02fce26ac8f3cbe911022b2f9f1611f33594ab` applies only the
exact reviewed five-site patch to the already reviewed Parameter_Frame guard.
Parser SHA-256 is
`036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`.
Patch SHA-256 is
`a6c87808887548b8723e7febfce0823a6679312b55fb3b21da5873d27355ee21`.
The before/after source, exact patch, reviewer plan and inventory are retained.

Scalar and Boolean declaration successful-result postconditions now export
preservation of Functions, First_Parameter and Pure. Actuals_Model and its
matching Actuals_After loop reject a failed comma token explicitly; the return
reader rejects a failed return keyword before reading an actual. Preconditions,
input domains, old postcondition clauses, loop invariants and variants stay
intact. The unchanged Function_Local_At contract is checked against the stronger
callee exports. Correspondence with unchanged Lean zero-input models belongs to
the coordinator's separate proof work; a new pin alone does not establish it.

| Full body | Selector line | Managed run | Checks | Proof-tree branches | Postcondition branches | Seconds |
| --- | ---: | --- | ---: | ---: | ---: | ---: |
| Scalar_Declaration_At | 1512 | `20261108T091045-bbad5e1bc42a` | 23 | 137 | 13 | 220.044 |
| Boolean_Declaration_At | 4457 | `20261108T091430-82e1dc49e0e1` | 40 | 217 | 13 | 668.885 |
| Actuals_Model | 4803 | `20261108T092545-9e7bbff4ca54` | 14 | 73 | 1 | 191.898 |
| Actuals_After | 4828 | `20261108T092903-fba617d20124` | 22 | 194 | 2 | 510.861 |
| Function_Local_At | 5628 | `20261108T093741-791fda34c956` | 7 | 49 | 13 | 88.437 |
| Function_Return_After | 5747 | `20261108T093913-9f0356646570` | 9 | 34 | 1 | 110.116 |

All 115 checks (101 proof and 14 flow records) have severity `info`. All 704
proof-tree branches and all 43 postcondition branches are discharged. The checks
include the complete strengthened or existing contracts, runtime checks, call
preconditions, recursive/loop obligations and new guard paths for the selected
whole bodies. No line/check limit narrows their scope. All reports reached
PROGRESS_PROOF/STOP_REASON_NONE with no skipped proof/flow, pragma Assume,
warning or unresolved record. Each per-run obligation inventory retains exact
locations/rules/branch counts; the full SPARK reports retain complete trees.
Saved Why3 roots and goal nodes are separately counted in coverage-summary.json
and all are marked proved.

Every run keeps original `--mode=all --report=all --warnings=error`,
`--checks-as-errors=on --level=2`, CVC5/Z3/Alt-Ergo and the 30-second timeout,
using the standard project and exactly one `--limit-subp` whole-body selector.
Four managed workers were reserved per run. Runs were sequential, with distinct
`explore/remaining-three-<target>` output and separate scratch caches. Exact
commands, tools, captured inputs and finished events are retained per run;
all 141 retained native input hashes match each managed preflight snapshot.
No source or declared runner input changed during the sequence.

The canonical failed full-run reports, saved sessions and solver cache remain
preserved. The before/after path/size/mtime inventories match across 114,530 files
and 2,895,997,324 bytes. This is metadata preservation evidence, not fresh byte
hashing of those canonical directories. Earlier failed and interrupted full-run
packets remain immutable and retain their actual outcomes.

The common index and each per-run index resolve artifact_root from their own
directory. All 221 gzip artifacts are exhaustively indexed and verified by
uncompressed SHA-256 and length. They retain source/generated/project/toolchain
inputs, reviewed patch and plan, canonical baseline, pre-run resources, managed
logs/events, full SPARK/SARIF/text reports, solver configuration, generated tasks,
sessions and shapes. See artifact-verification.json and coverage-summary.json.

This packet completes the six bounded checks. It does not establish complete
native provenance, a build, samples/regressions, macOS validation, Lean/source
closure or language delivery. No additional repair, push, integration or merge
is part of this evidence commit.
