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

These scopes overlap; the declaration counts must not be added. Their captured
inputs identify their individual worktree snapshots. Integration and a complete
check on the final inputs remain required. Later successful module compilations
inside failed runs are useful cache objects, not successful run outcomes.

`unused-formal-discovery/` retains the unchanged application source and producer
reports used to identify the exact unused-variable advisory for unused formals.
Its index names the managed discovery run. The
[producer and capacity account](../../scalar-functions-report-capacity.md)
explains the classification and source-bound storage argument.
