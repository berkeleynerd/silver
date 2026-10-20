# Entry status facts for the five selected saves

2026-10-20 UTC; authorized #119/#153 Round 30 research;
base `0937ca4a44d012893c7c95517e990f019d1489e6`.
Selected worker setting: GPT-6.1 Sol / Extra High. Runtime settings and
token/cost measurements are unavailable. Independent review is pending.

The [packet](../evidence/retained-why-status-entry-20261020/README.md) extracts
the initial status caches, attempt results and parent/task relationships from
retained fresh stopped captures. Every needed status/result/parent field is
available. It establishes the entry comparison below; it does not prove the
status invariant through later scheduling, callbacks or signal exceptions.

| Case | Actual PID | Leaf IDs | Trivial leaves, all `Some Valid`, nonobsolete | Other initial attempt |
| --- | ---: | --- | --- | --- |
| Put_Line | 17310 | 1–64 | 1,4,13,14,17,18,31,32,35,36,41,42,57,64 | none |
| Put | 17514 | 1–53 | 1,4,13,14,17,18,31,32,35,36,47,53 | none |
| First_Or_Default | 17631 | 1–32 | 1,2,3,6,12,14,17,25,26,27 | none |
| Is_Message | 17704 | 1–3 | 3 | none |
| Input_Is_Valid | 17869 | 1–4 | 1,2,4 | CVC5 attempt 3 on leaf 3: `None`, nonobsolete |

Every forest has root goal 0, no root attempt, and one transformation 0 with
exactly the listed direct leaf children. Root parent is the nonempty theory;
every leaf's raw parent variant is `Trans 0`. All file/theory/transformation
detached flags are false. Every goal has a captured `session_raw_tasks`
binding, so the source `goal_is_detached` lookup returns false on these entry
fields. The result includes each goal's exact raw task pointer.

The observed `pn_state` has one true binding per Trivial leaf and no other
bindings. Root 0 and nontrivial leaves are **absent**, not observed cached false.
`tn_state` contains one explicit false binding for transformation 0.
`th_state` and `file_state` are empty. There are no duplicates, stale-domain keys
or unreferenced attempts in these selected entries. Every attempt has one
membership and the recorded parent/prover agrees with that membership.

`session_itp.ml:750–775` defines status getters and attempt status; 788–877
defines the update formulas. The extractor evaluates these formulas over the
entry fields without calling the target. `pn_proved`/`tn_proved` default false
on an absent binding. A missing theory cache entry defaults to whether its
root-goal list is empty; a missing file cache entry defaults to whether its
theory list is empty. Consequently every empty theory's getter derives true,
while its observed cache entry remains absent. The nonempty theory and file
derive false. Every present cache value and every getter default agrees with
the corresponding entry update formula; all inputs to that comparison are
known. This is kept separate from observed cache completeness and later
continuation correctness.

Source `pa_proved` tests `Valid` independently of obsolete; update helper
`pa_ok` additionally requires nonobsolete. Both values are retained separately.
The new narrow projection reads the result option and the six-field
`Call_provers.prover_result` record from accumulated `session-blocks.jsonl`;
it does not infer a result from the Trivial prover name. The source definitions
of the prover-answer constructors and synthetic Trivial record are retained
as hash-bound excerpts. The established little-endian 64-bit OCaml tagged
record/variant layout remains the representation boundary, rather than a new
compiler soundness result.

The first four stops are pre-scheduling registration. Their retained summary
records zero hits for scheduling, running and driver-preparation guards, and
their attempt tables contain only Trivial records. Input_Is_Valid is the first
cvc5 inline entry. Its manifest-bound `session-observer.json` reports one driver
input task pointer equal to `session_raw_tasks[3]`; its inline output task
matches the summary's inline-entry pointer and differs from the leaf raw task.
There is exactly one driver-preparation record and one nontrivial pending
attempt. These are cut observations and pointer joins. Scheduler queues and
`Gnat_checks.explmap`/`goalmap` check sets were not projected; future scheduling
order and per-check set uniqueness are not fresh observations here. Their
source-derived continuation properties belong to the status worker's proof.

Provenance checks bind each actual process to its root/controller/session,
following the retained SIGINT closure and controller first field. All consumed
members match the capture manifest. The projection matches the accepted repaired
state join and overlapping correspondence/replay raw identities agree. Raw
table/record/list fields are cross-checked against the fresh typed projection;
immutable graph correspondence alone is not used to validate mutable status.
No new capture, native target/solver/proof execution, source fetch or old
collector/binder/alpha replay is performed. Oracle, tools/pins and admission are
unchanged. The status worker and root own subsequent proof, integration and
review.
