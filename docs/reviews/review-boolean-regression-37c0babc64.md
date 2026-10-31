# Boolean terminal regression applicability

Reviewed target: `37c0babc64312387a82d2e5c53a6f063acf881ad`, against full-suite
snapshot `927cc5e178` and the branching repair `29bc1d44d7`. Independent reviewer
selected GPT-6 Astra / Extra High; runtime confirmation and token/cost
measurements unavailable. Preliminary inspection: 2026-10-30
14:44:23–14:48:05 UTC (3m42s). Terminal inspection: 16:07:57–16:10:45 UTC
(2m48s). The reviewer inspected records read-only, without tests, builds, proofs,
repository writes or GitHub writes. The lead retained this report from the
reviewer's returned conclusions.

## Result and scope

The development policy's regression reuse provision is satisfied for the
reviewed target: **565 applicable retained passes plus three fresh passes cover
all 568 required executions**. The planned final Rosetta metadata refresh
remains outstanding. Complete native proof/audit and Lean/source correspondence
remain separate obligations; this review does not establish feature completion.

There are 568 distinct literal unittest IDs representing 559 underlying methods.
Nine preexisting SharedBindings methods execute under both
`test_shared_bindings...` and `tests.test_shared_bindings...`; both sets remain
covered. Standard discovery, the full-suite wrapper and the retained inventory
agree. The wrapper adds no test identity and does not alter assertions or
production proof options.

| Run | Verified result |
| --- | --- |
| `20261030T133820-8804240ce92e` | Completed 568 tests in 7,866.238 seconds: 566 passed; three obsolete rejection subcases failed within one branching method; the maximum-expression test timed out. The whole run remains failed. |
| `20261030T155127-bf12fb89db9a` | Both corrected branching methods passed; the unchanged maximum-expression test again exceeded its 300-second deadline. The whole run remains failed. |
| `20261030T160408-2c742ff18bd0` | The unchanged maximum-expression method passed in 150.108 seconds; the managed run succeeded. |

The three fresh passing IDs are:

- `test_branching.BranchingTests.test_admitted_literals_binding_and_layout`
- `test_branching.BranchingTests.test_rejected_guard_equality_and_branch_neighbours`
- `test_samples.SupportedSampleTests.test_maximum_dynamic_expression`

Every execution in the terminal full-suite log was reconciled against the
retained inventory. Removing the original pass of the changed positive
branching method leaves 565 reusable passes. Adding the three fresh passes
leaves no uncovered or failing identity.

## Input and dependency applicability

All 839 terminal managed hashes equal their starting hashes; all 12,053 terminal
snapshot hashes equal the recorded snapshot. The terminal check occurred before
mutation, including after the failed run, whose runner does not itself perform
the successful-run input comparison.

Across the three runs, the sole changed governed input is the reviewed branching
fixture. The temporary wrappers account for the other capture differences. The
corrected branching file matches the target and changes only the two specified
method bodies. Shared helpers, setup, assertions and imports are unchanged;
`test_statement_sequencing` imports the unchanged `source_for` helper and needs
no additional refresh for this repair.

The three moved subcases are 378, 354 and 384 bytes. Their newly admitted inner
Boolean conditions preserve the outer validity guard. The neighboring outer
`Input_Is_Valid=True` and `if True` rejections remain because those conditions
do not establish the needed validity facts. The repaired file hashes to
`be16a4293c65e2feff11b290f9568c0de4eb289607f58dcbac662c230d2e3252`;
the original hashes to
`fc8da3e247ba5ee717db5ce7d9faa8102b62af9250c4786988325699cce72220`.

The sample test, its 300-second deadline, generated configuration, compiler
binary and other captured dependencies are unchanged. Every captured snapshot
file in the successful final rerun matches the integration target. The retained
final events, log and wrapper match their managed records.

The full suite and first rerun used affinity `[0,1]` with two reserved workers.
The successful isolated maximum-expression rerun used affinity `[0–7]` with
eight reserved workers. Production proof flags and assertions were unchanged.
The observations support the allocation remedy; they are not a controlled
performance experiment or application-cache reuse evidence. The late
orphan-producer audit is diagnostic and was not counted as a test pass.

The inspected packet is
[`full-suite/`](../evidence/boolean-objects-20261030/full-suite/) and
[`terminal-reruns/`](../evidence/boolean-objects-20261030/terminal-reruns/), together
with the original managed records. The native subthread retained those files
in its evidence worktree before integration by the lead.

## Remaining metadata refresh

After final Rosetta metadata changes, rerun all three
`test_rosetta.RosettaRenderTests` IDs and confirm their final dependencies.
Replace their three retained passes with those fresh passes in the final census;
any additional governed change needs its own applicability check. No native or
Lean success is inferred from these regression results.
