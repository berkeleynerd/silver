# Independent review: quiet CVC5 route and solver-output consumers

2026-10-20 UTC, authorized continuation of #119 / #153.

**The controlled configuration route and conditional clean-response JSON
refinement are accepted at the scopes below.** They remove identified output
producers and unnecessary downstream payload charges. They establish neither a
complete raw-output bound q nor the whole capacity rule. The owner directed the
capacity work to continue; the earlier research stop is historical evidence,
not the completion outcome for this resumed task.

## Exact inputs and setting

Review worktree: `tmp/quiet-output-review`, branch
`review/quiet-output-20261020`, base
`421486c4e33271c02fc59f54d71182cc98c9558c`.

| Component | Final author freeze | Review-worktree import |
| --- | --- | --- |
| [CVC5 quiet route](../research/retained-cvc5-quiet-route.md) | `3755756124a8c8b9c6edefecab016415048a965d` | `b7bce7760a` |
| [Solver-output relevance](../research/retained-solver-output-relevance.md) | `e83340ebc9a27efddbcf59ec8f674bce54164b66` | `9985cc2f96`, after the earlier import `4a599145f7` |

Combined reviewed target: `b7bce7760a6e47d94309d0ebc4cceee425161b4f`. All author files match their final
freezes byte-for-byte. The [review packet](../evidence/retained-quiet-output-review-20261020/README.md)
retains exact input identities, focused checker outputs, independently selected
source witnesses and finite-response arithmetic.

Read AGENTS.md, the Oracle, relevant development/agent-reporting rules, the
existing trusted tool/report boundary, the final relevant-behavior section of
`retained-tool-source-identity.md`, parser/options and predecessor output results,
the Round 47 review and the whole-scope requirement matrix. Reviewed the new
notes, packets and their selected source paths; reused the accepted native rule,
task-language envelope and standard-JSON algebra without replaying their old
captures or expensive validations.

Reviewer `/root/quiet_output_review` was selected as **GPT-6 Astra / Extra High**.
Runtime model/effort confirmation and token/cost telemetry are unavailable.
The child's `get_goal` returned null; the parent reports the existing goal is
active and incomplete, with full capacity work resumed. Actual host is Linux
x86_64; `scripts/dev.py paths` confirmed isolated worktree routing. No native,
compiler, solver, proof or capture run occurred. The reviewer authored neither
component and spawned no other agent. The packet records the measured interval
from the first retained UTC clock separately from unavailable full-subthread
elapsed time.

The measured review/check interval was **466.410 seconds**. Final focused
checks passed: configuration 36 source members/16 retained inputs/10 driver
files; consumer 23 inputs/13 source members/10 affine bases; independent review
21 frozen-file matches/8 source members/12 finite response cases. The two
author checks reported 2.168 seconds internal time and 0.294 seconds tool wall
time respectively; these are different measurement scopes, not team cost.
The review packet records its own check timing and four local link targets.

## Configuration and required behavior

The base-file route is concrete at source/configuration scope. Gnatwhy3 reads
cwd `why3.conf` before reading the optional extra configuration, and rejects
built-in prover redefinitions only in the latter. Changing the ordinary CVC5
command in the base preserves the nine prover identities and the built-in-only
plugin branch. Zero-step selection uses that ordinary command; the unchanged
positive-step and CE commands do not inherit the reduction. Warning selection
and its independent timeout are explicit. The private no-StepRegexp driver
closure and its response directives stay unchanged.

The candidate has exactly one changed command field. Its absolute executable
token fixes CVC5's PATH-selection gap under stable identified-file assumptions.
The 123-byte increase is carried into command/configuration length interfaces;
neither captured heap positions nor lexical/parser/formatter states are assumed
unchanged. The generated filename argument now follows from fresh session,
debug-off and absent proof-script ownership through the `.smt2` template. File
completion, pathname/protocol exclusions and actual producer/request ownership
remain named inputs to that route.

Stock GNATprove regenerates the base file. Consequently this accepted research
route requires controlled direct producer/server orchestration in later #88,
with original source/entity/obligation and final report correspondence. It is
not an already adopted override for an ordinary stock-GNATprove run. The
distinct CVC5Q alias is correctly deferred: it changes plugin loading and
leaves stock `--warn-prover cvc5` on the old command.

The quiet/statistics projection preserves the required answer/status paths.
Quiet suppresses WarningChannel/Env-warning bytes, while normal check/reason
results and non-ok command statuses remain emitted. It does not make Env
warning operands unevaluated. With stats=false, ordinary and safe print
functions skip registry retrieval/traversal; this removes those print-path
allocation/numeric obligations, not all registry construction or counter work.

Independently inspected the potentially consequential `statisticsInternal`
consumer. `ProofFinalCallback::initializeUpdate` uses
`statisticsInternal || checkProofsComplete`. Pedantic checking and
`ensureChecked` precede that branch; complete-proof checking keeps the branch
enabled and independently guards its incomplete-proof error. Subsequent
checkProofSteps work also remains outside the statistics guard. Removing the
flag therefore does not disable a proof-check option. It can change histogram
work, exception opportunities and timing; no identical-execution claim is
accepted or needed for this component.

The no-step driver extracts no CVC5 registry statistic. Missing step/time
matches use -1/server CPU time, and GNAT report statistics use the resulting
attempt fields and counts. Their representation and outcome obligations remain.
Existing Why3 answer precedence, including Valid priority, is preserved; the
notes do not claim a new policy rejecting every signaled/nonzero exit.

## Capture versus downstream JSON

Raw output remains proof-essential on the selected consumer path. The server
merges fd 1 and fd 2 into a file and reports its pathname. Why3 reads the whole
file into Buffer/string storage, eagerly splits/maps it, then retains `pr_output`
before result callbacks. A Valid callback in another attempt cannot erase work
already required to parse that batch. The server's pathname-message bound is
separate from the captured-file q; chunked reads do not provide a constant
retained-storage bound.

Queued cancellation with empty filename has its own fixed interrupted result
and no file. Running cancellation retains a file prefix and does not inherit
that zero charge. The final consumer freeze explicitly limits the clean pair to
ordinary nonsignaled termination, while preserving native exit status. This
clarification followed review feedback; it avoids an unnecessary status/prefix
extension of the result. No defect in the displayed affine algebra was found.

For that exact clean language, source inspection of the driver patterns and
Why3 reductions supports at most 64 formatted answer bytes and no
consecutive-answer warning. Unsat has Valid priority; sat discards the fixed
`(not unknown!)` reason marker; an unknown/reason pair reduces or joins two
Unknown values. Independent extraction of all ten finite reason spellings
checks the 84-byte pair maximum and the 64-byte answer allowance. This is a
finite-language calculation plus source review, not execution of OCaml regexps
or a theorem that any actual task already has this output language.

Partitioning actual occurrences into prospectively justified clean and
exceptional classes preserves all A answer occurrences. Only exceptional
weighted payloads/invocations contribute to `4*O_Ax`, `O_Px+N_x` and
`514*O_Px+512*N_x`; the standard JSON substitution follows. Early Buffer,
regexp and raw-result owners still charge clean file bytes. Debug-error raw
copies remain excluded by their existing controls; other warnings, abort text,
timing fields and duplicate/abandoned occurrences remain charged. The packet
correctly assigns no actual attempts to the smaller class yet.

## Reuse and next sufficient input/output relation

The useful next question is bounded: for the selected authoritative typed task
family and unchanged transform/driver relation, establish correct
symbol-to-syntax association and exclude wrong/empty/Float80 template use.
Then attach the selected well-formed task/command execution to its ordinary
response language under the documented relevant external behavior premise.
That can instantiate the clean q<=84 and JSON component for its covered
normal-service domain. It does not require a general proof of arbitrary SMT
parsers or a historical source-to-binary attestation. The actual file prefixes
handled outside that domain still need their relevant input/output relation;
they are not made zero by labeling a channel diagnostic.

This acceptance preserves the existing trust boundary: exact reviewed source
behavior for identified installed tools/configuration is an explicit external
premise, not a historical build-identity claim. It does not replace Silver-owned
source correspondence, complete obligation generation/discharge, source-derived
caller bounds or required report auditing. No new general tool-verification
requirement or circular assumption that accepted programs fit/prove is added.

The whole-scope matrix continues to govern #119 beyond these two components.
The global Why3 allowance remains two save-entering callbacks, three saves and
e<=2 across all classes and attempts. Oracle, pins and admission are unchanged;
production #88–#94 remains unstarted. Matching integration may reuse these
accepted reductions while keeping the active capacity goal incomplete.
