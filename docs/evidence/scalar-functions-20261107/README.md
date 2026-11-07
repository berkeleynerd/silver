# Scalar-function implementation evidence

Implementation and validation of #298 are in progress. This packet retains
focused Linux checks and producer observations; it is not a complete delivery
checkpoint. The [capability record](../../scalar-functions.md) states the
remaining requirements.

`focused/` contains verbatim, gzip-compressed managed records, input identities
and streamed logs from the shared run registry. Each listed run completed its
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
