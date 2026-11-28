# Main static-assertion source witness

Implementation `151da45db6` mirrors native Main change
`babbcc7e3916ee0c8b4454520beedc1f55f27164` (the private equivalent is
`d2627fee57`). It retains all twelve declaration-level Static assertions and
the named `Input` value in the typed tree. Assertions have their own typed
function symbols, are scope-checked before the following declaration, and
supply no runtime assumptions. `Declaration.eval_staticAssertions` proves
evaluation independence for every annotation list.

The Main execution theorem still quantifies over arbitrary call dictionaries
and initial local environments. Its proof composes body-completion,
declaration-reading and argument-handling equations, each valid for every
continuation. The grouping changes no rendered tokens. The complete header and
628-token body candidate pass kernel equality checks; the original body fragment
SHA-256 is
`3f7f7abac31594aadd81ffcd35ac50002b2a6b98b843ab35acbf7ff412dbef18`.
The Main semantic model and its input domain were not changed.

Final focused run **20261127T191054-df5ffb22aaf2** passed
`Silver.ApplicationPackageMainEquations` and
`Silver.ApplicationPackageMainSourceCandidate`, with a fresh **22,162-declaration**
axiom audit. Its build finished at 2026-11-27 19:11:18 UTC and its audit at
19:11:22 UTC. The final run reused the complete Main equation compiled in the
preceding failed candidate run; it freshly compiled the corrected source
candidate and audited both targets. This is cached focused Linux x86-64 evidence,
not a clean rebuild or a complete source/assurance checkpoint.

Selected agent settings were GPT-6 Astra Max; live runtime model/effort and token
or cost measurements were not independently exposed. Managed checks reserved
two workers with two threads per Lean process and requested 8192 MiB per process,
with explicit resource reasons to share the eight-CPU host. Exact allocations,
affinities, durations, inputs and tool hashes are in the retained records. No
heartbeat budget increase, axiom, `sorry`, domain restriction or kernel bypass
was used.

The failed normalization attempts remain failed. Early declaration-erasure
drafts needed dependent record/initializer decomposition. Full Main simplification
then exhausted the evaluator's 200,000-heartbeat reduction context, even after
general annotation erasure. A first-rejection control with arbitrary continuation
contained neither assertions nor `Input` and reproduced that failure. Its direct
expression equation and ordered rewrites passed in
`20261127T190049-7ab124401d35`; small explicit expression equations also passed in
`20261127T190535-84e30adc5b83`. Expanding all commands before simplifying guards
instead exhausted the existing 2,000,000 theorem budget in
`20261127T190216-4b671d69c19d`.

The final repair uses staged continuation equations. All three stages passed
in **20261127T190827-4014c51250d3** with 22,099 audited declarations; the restored
complete Main equation compiled in 5.1 seconds during
`20261127T190925-cb4121011798`. That run failed only because kernel decision of the
source candidate stopped at the nested Static renderer. Explicitly expanding
that renderer produced the final successful candidate check. The unused general
list/command/body erasure machinery and diagnostic-only expression equations
were removed; the declaration-level independence law remains.

Prepared but **unbuilt** final-source targets are
`Silver.ApplicationPackageMainSourceChecks` and
`Silver.ApplicationAdmissionSourceChecks`. They extract Main, Analyze_Application,
the four admission aliases and the result representation from the full certified
Output Profile source. The Main aggregate also connects its universal execution
equation. Admission execution and all callee interpretations are composed
separately. These files were prepared after the focused run and are not covered
by its result. No full OutputBody build was started for this packet.

The final shared frozen-source checkpoint must build these targets, the pending
namespace aggregates, and the complete semantic/source closure, then perform the
required complete native/Lean audits and regressions. This packet does not close
#416 or establish merge readiness. The lead owns issue and publication updates;
this subthread made no GitHub changes and did not update CLI memory.

[Input summary](input-summary.json) and [managed runs](runs.json) identify the
exact evidence. Per-run compressed logs, evidence and complete event streams
retain failures and successes. Where a failed log was preserved by the next
managed run, `runs.json` records that original retention path.
