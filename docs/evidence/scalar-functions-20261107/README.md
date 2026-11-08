# Scalar-function implementation evidence

Implementation and validation of #298 are in progress. This packet retains
focused Linux checks and producer observations; it is not a complete delivery
checkpoint. The [capability record](../../scalar-functions.md) states the
remaining requirements.

`focused/` contains verbatim managed records, input identities and streamed logs
from the shared run registry, normally gzip-compressed. Each run in the table below completed its
focused build and a fresh axiom audit with only `propext`, `Classical.choice`
and `Quot.sound`. Cached dependency objects were accepted by Lake; no clean
rebuild or independent kernel replay is claimed.

| Run | Scope | Audit declarations |
| --- | --- | --- |
| `20261107T190725-f2c18256bc3f` | Function-declaration exported-state validity | 13,770 |
| `20261107T190752-25ffaaf049d5` | Argument/call source readings and checkedness | 10,953 |
| `20261107T193620-fbc422c6bb56` | Body-flow counts and loop shape/progress; 91 modules | 9,690 |
| `20261107T193723-1fb396ba26de` | Declaration source requirements, visibility and formal-frame native equations; 109 modules | 16,509 |
| `20261107T194714-5bf92f00c822` | Call-aware body bounds, control and flow preservation | 10,363 |
| `20261107T195608-5b7d48919380` | Local declaration semantics and closed initializer check transport | 20,104 |
| `20261107T200333-cc7bd8262cba` | Catalogue-aware recursive native body equations, helper domains and loop sizing | 21,629 |
| `20261107T200353-32e76e9cf75c` | Nested body source readings, soundness, uniqueness and meaning | 16,176 |
| `20261107T200431-78784ce9217b` | Mixed Integer/Boolean formal installation and semantic analyses | 18,663 |
| `20261107T201138-218cb4b8c7bd` | State-preserving native outer adapter and catalogue-aware body candidates | 22,668 |
| `20261107T203419-acb04c0069db` | Accepted function header/body source, complete initializer checks, checked definition and uniqueness | 21,742 |
| `20261107T204542-e1a7564b967a` | Ordered accepted-function trace and whole-program grammar, including Sequence declaration consumers | 22,602 |
| `20261107T205716-06beedcb3070` | Function-aware assignment selectors and actual String-bound assurance for Main call arguments/initializers | 23,722 |
| `20261107T210546-e2448c2f2aec` | Inherited scalar/String/array source equations, typed call equations and predicate structural guards | 38,037 |
| `20261107T210649-a6e98d8a9788` | Exact function declaration/body equations, imported-call composition and native domains | 17,226 |

These scopes overlap; the declaration counts must not be added. Their captured
inputs identify their individual worktree snapshots. Integration and a complete
check on the final inputs remain required. Later successful module compilations
inside failed runs are useful cache objects, not successful run outcomes.

`unused-formal-discovery/` retains the unchanged application source and producer
reports used to identify the exact unused-variable advisory for unused formals.
Its index names the managed discovery run. The
[producer and capacity account](../../scalar-functions-report-capacity.md)
explains the classification and source-bound storage argument.

The [report fixture/producer packet](report-readings/README.md) retains the
39-test native policy fixture result and pinned producer inputs. It does not
claim that the compiler's complete native audit has passed.

The [early mechanism probes](mechanism-probes/README.md) retain the exact
application sources, projects, historical producer reports and managed records
for the initial no-inlining/full-domain experiments. The first run remains
failed because its declared inputs changed; the later seven- and nine-check
successes remain scoped producer observations rather than compiler validation.

## Native repair and source integration checkpoint

The [parser equality packet](parser-equality/README.md) retains the original
failed observations, the isolated diagnosis, and successful selected checks.
The [report repair packet](report-readings/native-repair/README.md) now accounts
for all seven original report failures with scoped successful repairs. Neither
packet replaces a complete audit of the integrated native source.

The named-word Lean check `20261107T222609-601d7f7b780d` passed a fresh audit
of 20,013 declarations after compiling the changed tree and evaluator modules.
Its [record](focused/20261107T222609-601d7f7b780d/README.md) distinguishes this
model result from the still-required authoritative source candidates. The
[bounded source review](../../reviews/review-scalar-function-source-integration-20261107.md)
identified the derivation gap tracked as #340. Its
[raw-source repair](focused/20261107T230226-02ff494be2c6/README.md) passed a fresh
49,907-declaration focused audit. The
[independent re-review](../../reviews/review-scalar-functions-raw-source-r1-e76a3f9420.md)
found no remaining R1 code defect, while retaining the outstanding upper
integration and complete-checkpoint requirements. The final complete native/Lean
and regression checkpoints have not been claimed.

The regenerated certificate parity test passed in managed Linux run
`20261107T223021-ea6081c05e62` across all 30 source certificates and eight
output-body chunks. The preceding run `20261107T222826-c95794092b91` remains
failed: it identified three stale checked-in specification/function certificates,
which were regenerated before the passing rerun. Regeneration and byte parity
are input preparation, not kernel acceptance or source correspondence.

The later parity run `20261107T230745-ca313156b33d` passed after integrating
the two final Static condition assertions. The
[condition-equality packet](condition-equality/README.md) accounts for both new
assertions and the original failing endpoints. All 23 function tests and the
`Is_Prime` sample passed in the separately scoped
[native behavior packet](final-native-behavior/README.md).

Failed Sequence integration runs `20261107T224846-c33ea7d88705` and
`20261107T230246-bef827673692` are retained under `focused/` as failures, outside
the success table. Their successful intermediate objects were reused while
repairing omitted context equalities and initial empty function metadata.
They do not claim a fresh axiom audit or complete validation. The
[bounded capacity/policy review](../../reviews/review-scalar-function-capacity-20261107.md)
records its independently checked producer/storage scope separately from the
complete native and Lean requirements.

## Outer scanner integration checkpoint — 2026-11-08

While focused run `20261107T230910-a15a07ea6dd4` retains its productive source
chunks, it has reported a failure in `PredicateOuterEquations.lean:64`. The
outer expression evaluator and rendering omit the function-assignment flag
already present in native `Scan_Step` and `Predicate.scanStep`. The
[independent bounded repair review](../../reviews/review-scalar-functions-delivery-20261108.md)
found no material defect in the prepared evaluator/render/candidate correction.
The native source, domains and contracts are unchanged. The patch remains
unapplied while the active run's inputs are frozen; named-body kernel checking
and the complete validation checkpoint remain required. Successful source
objects inside this run do not establish a successful focused audit.

The same run exposed two stale Boolean-initializer context adapters: they omit
the existing `pure` and `integerHidden` fields and use the earlier readiness/
validity conjunction shape. A two-file proof-only correction is prepared while
the run finishes; it changes no theorem statement, domain or native source.
It is additional to the three-file outer repair reviewed above.

## Native warning checkpoint — 2026-11-08

Complete native run `20261107T231059-a9f0c12c8350` finished with **failure**.
The [retained native packet](native-checkpoint/README.md) records all 12,558
checks as discharged and all 585 saved Why3 roots as proved, but three compiler
flow warnings caused exit code 1: an overwritten initializer and two unused
private `Source` formals. Successful complete provenance was not generated.
The compiler warning policy remains unchanged; application advisory exceptions
do not apply to these diagnostics.

The coordinator reviewed a minimal cleanup of the initializer and unused
private parameters/actuals. Source-derived name matching, exact entity coverage,
contracts, domains and output-profile bytes are preserved. The native owner is
authorized to apply the exact reviewed cleanup after retaining this failed run,
then check unit flow, rebuild and complete the native audit with retained
sessions. Those later results remain pending. The independent integration
certificate continues on frozen inputs; both regression build and full tests
wait for the integrated native and proof repair snapshot.

## Applied integration repairs — 2026-11-08

The [frozen focused run](focused/20261107T230910-a15a07ea6dd4/README.md)
finished with exactly the two known failure groups. Its output certificate and
source bridges compiled successfully and remain cached. After retaining that
failed outcome, the coordinator applied all five reviewed proof-file repairs
and integrated the native warning cleanup as `cd705e9bba`. The
[review supplement](../../reviews/review-scalar-functions-delivery-20261108.md#supplemental-static-review--boolean-context-and-report-warnings)
found no material defect in the additional Boolean adapters or report cleanup.

Focused repair checking, including named `scan_step` extraction, and the complete
Lean/source audit remain outstanding. The native cleanup passed focused flow
without warnings and an ordinary build; complete native run
`20261108T014042-81a35c010d1f` is still active. Full regressions are queued for
the exact integrated repair snapshot. None of these pending checks is claimed
as completed support.

## Expanded source-check continuation — 2026-11-08

The [expanded focused run](focused/20261108T021648-bb06ac912aef/README.md)
compiled all five repaired modules but failed on two stale body candidates and
a Boolean import proof's local let binder. Commit `6a74bccc5a` corrects only
those three proof files. Its retained token inventory compares each candidate
with the unchanged native body and existing semantic rendering; the native
implementation, theorem statements, domains and contracts are unchanged.

In [follow-up run `20261108T022400-531d5c89d319`](focused/20261108T022400-531d5c89d319/README.md),
both candidate rendering proofs and the Boolean import proof compiled. The run
finished with failure: the named-body leaf found stale catalog/header and type
declaration requirements, alongside the known `ComposeSourceBridge` layout
error. Commit `f00205b5f8` updates those source requirements against the unchanged
native definitions and semantic models, preserving the typed contract renderers,
and aligns the four unchanged record-update fields. Its exact token deltas and
failed log are retained. The same four focused targets are being checked again
with the existing objects before the required complete Lean/source/module/axiom
audit. The [bounded review supplement](../../reviews/review-scalar-functions-delivery-20261108.md#supplemental-static-review--body-candidates-and-wrapper-projection)
found no material defect in these corrections or the three preceding proof
repairs. Follow-up checking compiled the new requirements and Compose bridge,
then exposed a wrapper-projection rewrite mismatch in `PredicateEquations`.
The same supplement inspected the prepared explicit type annotation for the
existing refinement; it remains unapplied while the named-body check uses
frozen inputs. This static review is not complete source or delivery acceptance.

The regression build passed and the full 637-method suite is running on frozen
`c437a41d30`. It has reported errors in the output-body chunk object-reuse
and symlinked temporary-directory platform-routing tests; their exact tracebacks
are deferred by unittest until suite completion.
The full inventory is being preserved before diagnosis or any targeted rerun.
Later changes are proof-only; final regression applicability and any affected
reruns will be recorded after its actual full outcome. The suite's
managed two-worker reservation is not an enforced application cap: the existing
application recipe uses `-j0`, resolving to 22 on this host. Its owner retains
observed process/load evidence; no source, proof option or timeout was changed.
The corrected native run `20261108T014042-81a35c010d1f` was subsequently
interrupted without a finished event or successful provenance. Its recorded
processes and persistent tool sessions disappeared after a monitoring handoff
ended the owning agent's turn. The assumed lifetime across agent finalization
was not established; the exact cause remains unconfirmed. Source hashes are
unchanged. The owner retained the partial reports, saved sessions and cache
before starting `20261108T040128-2651963b8574` with the identical source, proof
options and twelve workers. The continuation reuses retained sessions; it is
not a cold run. The owner remains active through the actual outcome. Neither
the interrupted run nor its saved-session inventory establishes complete audit
success; final native provenance and coverage remain required.
