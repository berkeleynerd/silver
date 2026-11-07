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
