# Later proof-attempt and save-metadata growth

2026-10-20 UTC, Linux x86_64, owner-resumed research #119 / #153, base
`22c5d9274ac7fe6ab7797aef378a3bcb4b4afafe`.

The captured attempt counts are starting values. For every later selected save,
the source gives the following **conditional binding-visit upper bounds**:

| Process / captured PID | Captured A_stats / A_xml | Selected pair-key allowance K | Later A_stats / A_xml upper | Reached prover-key domain P upper | New shared prover-ID bindings, all later saves |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line / 3085 | 14 / 14 | 192 | 208 / 208 | 4 | 6 |
| Put / 3323 | 12 / 12 | 159 | 173 / 173 | 4 | 6 |
| First_Or_Default / 3470 | 10 / 10 | 96 | 108 / 108 | 4 | 6 |
| Is_Message / 3568 | 1 / 1 | 9 | 12 / 12 | 4 | 6 |
| Input_Is_Valid / 97103 | 4 / 4 | 3 | 9 / 9 | 5 | 7 |

The first four cuts are post-registration, before scheduling. Input_Is_Valid is
the prior first-inline cut: its already-created selected attempt remains in the
starting four, and using the whole three-pair allowance deliberately counts
that pair again. No equality of phases or actual final counts is claimed.

The source transfer closes the missing **growth** question. Its native
application still requires valid entry tables, key/hash behavior and the
interrupted-mutation contract. The parallel Hashtbl work owns that contract and
actual sizes/capacities. No size or backing capacity is inferred from the
captured visit count. [The packet](../evidence/retained-why-save-attempt-growth-20261020/README.md)
retains the exact source, inputs, mutation census, arithmetic application and
unknown-state checks. Independent combined review is lead-owned and pending.

## Fixed continuation and one signal budget

The selected route is the accepted fresh Per_Check, CE-off, non-replay,
three-automatic-prover, serial route. Its
[scheduler envelope](retained-producer-driver-envelope.md) supplies 153
registered-task, 459 pair and 6,120 outer driver-transform applications across
five separate processes. Its finite selected pair-key domain is consumed here;
the interrupted continuation requires the qualification below. It is not a
bound on the 161 raw-forest APn visits, solver work, polling or native storage.
The [captured forests](retained-why-fixed-session-domain.md) retain raw roots
and uninteresting tasks, complete task/formula premises and visit multiplicity.
The [ordinary-ending argument](retained-why-ordinary-ending-control.md) supplies
logical preservation, the nonreturning signal-handler rule and the signal
protocol; its native effect premises remain explicit.

Apply that protocol **once from the selected captured cut through the end of
the ordinary-save interval**. The SIGINT closure is already installed before
registration (`gnat_main.ml:331–338`), and each capture joins its controller to
this session. The selected continuation has exactly two source save callers:
the one ordinary `ending` call at line 274 and `save_session_and_exit` at line
308. `gnat_checks.ml:752–753` is their direct wrapper. The only downstream
signal setters are the three ignore operations in the callback; the main
installer is not revisited. The scheduler's `Exit` handler does not retry
ending, and the outer error route does not restart main.

Require the existing single-worker/native-frame, successful mask/ignore,
no-unmask/no-reinstallation and no-unmodeled-callback-mutator premises to
continue over **this larger interval**, including selected driver preparation
and result handling. This is an explicit attachment condition; the earlier
ordinary-only application does not by itself discharge it. Under that
condition, at most two save-entering SIGINT callbacks remain, and at most one
ordinary save remains: `e <= 2`, `r <= 1+e <= 3`. Unlimited external delivery
and polling do not replenish the stale pending-bit allowance after ignore.
A signal save before ordinary ending consumes this same allowance. These are
post-cut bounds; pre-cut saves or their initial-state effects are not erased.

The captured closure does not prove that no earlier signal save occurred.
The accepted runtime setter retains the old closure-array slot when installing
ignore (`signals.c:482–488`); it changes that slot only for a block-valued new
handler. In particular, closure presence cannot justify an empty prover-ID
table or the initial shape state.

The callback cannot return normally. An exception may be consumed at a named
higher catch and continue with nested writes. Count each of its at most two
escaping exceptions once; the missing-key handlers below consume an exception
without rethrowing it into another missing-key handler. A callback that exits
has no later continuation. The source transfer therefore allows two spurious
or stale-miss insertions, without assuming successful saves or transaction
rollback. If the continued signal condition is not supplied, the executable
leaves `e`, `r` and the corresponding duplicate-growth bounds unknown. It does
not restart an independent budget at ordinary entry.

## Attempts: source insertions and occurrence-weighted visits

The complete session-owned attempt mutation sites are:

| Source site in session_itp.ml | Selected effect / exclusion |
| --- | --- |
| `add_proof_attempt`, 645–660 | One ID increment, one per-goal `Hprover.add`, one global `Hint.replace`; at most one constructor entry per graft entry. |
| `graft_proof_attempt`, 663–675 | Finds an existing record and replaces that record's limits/state, or calls the preceding constructor once. The catch can reach the fallback after an interrupted existing-record replacement; it still invokes the constructor at most once. |
| `update_proof_attempt`, 737–745 | Replaces result/obsolete fields, with no attempt-table addition. |
| `set_proof_script`, 56–58; `change_prover`, 886–900; `mark_obsolete`, 923–925 | Editor/replay/upgrade routes, excluded by the accepted automatic fresh continuation. |
| `remove_proof_attempt` / APa removal, 910–921, 930–969 | Ordinary cleanup is its only selected candidate. `is_ce_prover` short-circuits to false when CE is off (`gnat_config.ml:701–707`), so cleanup removes no attempts. A failure before that decision cannot select the removal branch. |
| Load, merge, copy and detached-proof constructors | Prefix or excluded reload/interactive routes; no selected later caller. The packet retains a lexical full-module reference census to expose these sites for review. |

`controller_itp.ml:591–652` performs one graft per schedule entry. No save adds,
removes or replaces proof attempts. Solver results may change state, not their
prover key, parent, limit record or script path.

There is a necessary difference from the accepted normal-route pair-entry
argument. `has_been_tried_by` catches `Not_found` around its whole query and
returns false (`gnat_checks.ml:471–482`). A nonreturning nested save can raise
that exception and make a completed pair look untried in
`find_best_untried_prover` (`:714–726`). The 459-entry envelope must not simply
be reused for this interrupted scheduler. This packet uses its unchanged
finite **key domain**, and does not claim a new bound on all scheduler entries.

Let K bound the selected `(goal,prover)` key domain. In `add_proof_attempt`,
the guarded per-goal lookup prevents another binding for an existing key.
There are at most K genuine first-key insertions. No selected route removes a
key; at most e callback exceptions can make the guarded lookup spuriously
miss or resume a stale miss. Thus at most **K+e** per-goal bindings are added,
independently of how many calls repeat a present key. Each global new-record
store is preceded by that membership add, so global binding growth is also
at most K+e. An existing graft branch successfully finds the global ID before
its `Hint.replace`; the preservation contract and absence of deletion make
that replacement non-growing, including when a later exception selects the
constructor fallback. This distinction is useful for a no-resize guard.

For a general preserved forest, let `m(g)` count visits to goal g, `k(g)`
bound selected prover keys for that goal, and `e(g)` count charged duplicate
insertions, with `sum e(g) <= e`. Then

```
A_stats <= A_stats0 + K + e
A_xml   <= A_xml0 + sum_g m(g)*(k(g)+e(g))
        <= A_xml0 + max_g(m(g))*(K+e).
```

The new offline join checks all five captured goal domains, distinct per-goal
attempt-table pointers, every initial membership occurrence and their input
identity against the accepted scheduler row. Each goal occurs once in these
five forests, giving the table above. The transfer retains the multiplier and
checks a repeated-occurrence case; it does not silently identify traversal
counts with distinct IDs. Each individual goal table gains at most five
bindings; the two exceptional additions are shared across the process and
cannot be replenished for each goal. The other three
session ID counters do not advance here. Binding growth does not count
constructor prefixes abandoned after the attempt-ID increment but before
membership publication. The executable therefore leaves the later
`next_proofAttemptID` counter upper bound unknown; attaching a bound on all
interrupted scheduler/constructor entries is a separate counter obligation.

The constructor stores the per-goal membership before installing the global
record. A save interrupting that gap can encounter a missing record and fail.
These bounds do not establish lookup coverage, equality of A_stats and A_xml
at every intermediate point, or successful serialization. Initial duplicate
bindings are retained in A_stats0/A_xml0. Boundaries reached during failed
prefixes still require the table contract; a cardinality estimate alone does
not prove an acyclic traversal.

The selected cuts have no suspended mutator of these metadata tables: the four
registration captures precede scheduling, after registration returned, and the
Input_Is_Valid inline cut is inside driver preparation after the graft and
Scheduled callback returned (`controller_itp.ml:409–438,641–652`). A supplied
valid starting-table certificate must still describe the actual cut. It need
not assume a pristine process or undo a prior failed operation. The no-resize
proof and the key-preservation induction can be simultaneous: before the first
hypothetical resize, atomic commits preserve keys, the source growth allowance
holds, and a satisfied guard prevents that first resize.

## Prover keys and the smaller shared-table bound

Every reached attempt uses a captured prover record or one of the three
selected prover records. No selected operation mutates a prover record's
immutable name/version/alternative strings, and `change_prover` is excluded.
Thus `P <= P0+3`: four for the first four rows, five for Input_Is_Valid. This
last upper bound deliberately avoids deciding whether its two absent prover
records are structurally equal. Prover comparison/equality is exactly the
three-string relation (`whyconf.ml:80–105`); pointer inequality is not used as
proof of key inequality. Prover string **lengths** remain missing inputs.

For a persistent-key table with initial binding visits V0, no deletion/clear,
and a finite eligible key domain of size P, at most P ordinary first-key
insertions occur. Repeated correct lookups cannot add another binding. An
interrupted lookup can raise `Not_found` even for a present key; alternatively
the nested save can insert a key while the outer miss continuation is pending.
An outer duplicate insertion is then charged to that nested callback. The
callback does not normally return, so another uncharged outer insertion cannot
resume at an earlier frame. Across the interval these effects cost at most e
additional insertions. This induction requires key preservation at completed
and interrupted table commits; it cannot be used across an unvalidated rehash.

`session_prover_ids` has no selected post-cut mutator except the add at
`session_itp.ml:2014`. Its load-time replace at 1420 and `empty_session ~from`
sharing at 590–596 are not reached. Its missing-key search may catch `Exit`
early and reuse an ID; that affects ID uniqueness but does not add another
source insertion or defeat the `P+e` bound. Nested saving can supply the key
between the initial miss and that Exit handler, which is why the charge covers
**stale miss continuations**, as well as spurious lookup exceptions.

Consequently, over all later saves together,

```
new shared prover-ID bindings <= P+e             (6 or 7 above)
binding visits V <= V0+P+e
scalar size       <= size0+P+e
candidate ID      <= V                         (search starts at zero)
```

The no-resize arithmetic guard is `size0+P+e <= 2*capacity0`, with valid
positive capacity and the native commit/key-preservation premises supplied
separately. If an entry key-coverage certificate is available, P can be
replaced by an upper bound on eligible keys not already present. Existing IDs,
duplicates and their absolute magnitude remain entry inputs. No source fresh
initializer is substituted for those absent captured words.

Each `get_used_provers_with_stats` starts a fresh private prover table. Its
binding count is at most `min(A_stats,P+e)` per save, rather than requiring
A_stats distinct provers. Its frequency values remain bounded by A_stats.
Nested saves do not alias that private table. The persistent `Mprover` map
has at most P keys and the subsequent `Mint` map at most P keys even if IDs
collide. These smaller bounds can replace the coarser A-based prover-entry
counts in the [operational transfer](retained-why-save-operational-bounds.md).
They do not certify private-table representation, hashing, numeric printing
or sufficient resources.

## Transformations, scripts, statuses and status-cache growth

The accepted logical-forest preservation theorem fixes file/theory/goal and
transformation links. The checked packets each have one transformation and an
empty argument list, so **T=1 and Args=0 at every selected later save**. The
transformation record's name/argument fields are immutable; its constructor,
grafting, removal, loading and merge paths belong to the completed registration
or excluded successor routes (`session_itp.ml:677–735,903–908,930–969`). Driver
transformation applications operate on prepared task values and do not append
session transformation records. The 6,120 driver-transform count is therefore
not session transformation-list growth.

The newly identified `has_been_tried_by` exception does not invalidate this
forest premise. `is_full_split_goal` has no catch returning false on an
exception (`gnat_checks.ml:346–353`): an exception aborts that decision or is
consumed by `register_result`'s Exit branch, whose CE-off successor does not
split. It cannot select a new transformation by spuriously returning false.

All captured attempt scripts are `None`. Automatic scheduling supplies no
script filename with debug-save disabled (`gnat_checks.ml:983–1047`), and the
existing graft preserves an existing script while new attempts use that empty
optional argument. `prepare_edition`/`set_proof_script` are excluded. Proof
script path occurrences remain zero; session file paths and restored identifier
paths still need their own captured/source byte bounds.

`save_result` serializes only one of eight fixed status labels and an optional
nonnegative native step integer (`session_itp.ml:2051–2077`). Their maximum
label length is 17. Result output, diagnostic strings, models and exception
payloads are not traversed by this serializer. Their owners elsewhere remain
required. Limits are stored immutable records; result callbacks replace
`proof_state` and the obsolete Boolean, without creating a new scalar field
domain for this serializer. `%g`/integer formatting contracts remain separate.

The status caches contain Booleans and only the following selected writes:

| Table | Source sites | Conservative new binding allowance after the cut |
| --- | --- | ---: |
| pn_state | `update_goal_node` replace, 851 | G |
| tn_state | `update_trans_node` replace, 868 | T |
| th_state | `th_proved` miss-add, 753–757; `update_theory_node` replace, 822 | Th + e |
| file_state | `file_proved` miss-add, 759–764; `update_file_node` replace, 809 | F + e |

There is no removal or clear of these caches in the selected continuation.
`pn_proved`/`tn_proved` use `find_def`; a spurious missing result can cause an
update, but `replace` still replaces a present key under the table contract.
The theory/file miss-adds can duplicate keys after a nested save, hence e.
All update propagation stays in the captured parent chain and sibling lists.
Empty theories count in Th because `update_file_node` can query them even
though XML skips them. With the captured domains the growth allowances are
G=`65/54/33/4/5`, T=`1/1/1/1/1`, Th+2=`48/48/43/14/23`, F+2=`3/3/3/3/3`.
These are additions to separately supplied entry visits/size, not final totals.
Existing-key coverage can reduce each domain term; existing duplicates stay.

Round 29 clarification: this finite-key allowance requires key-preserving table
prefixes. In particular, `Th+e` is not an unconditional whole-continuation
insertion bound after an interrupted theory-cache resize has published partial
buckets. Lost keys can be inserted again. It bounds the valid prepublication
phase, or a continuation with the required preservation contract; it cannot
establish that contract for the three failing no-resize cases. The selected
[resize analysis](retained-why-theory-cache-resize.md) separates the first
published resize from this unresolved later continuation. The retained numeric
outputs and false native-contract flags keep their original conditional scope.

This leaves a specific possible no-resize failure. With `th_state` size0=0
and capacity0=16, the first three domain allowances (48,48,43) exceed 32.
Replacing Th with the one nonempty theory would be unsound: when the root
becomes proved, `update_theory_node` can call `update_file_node`, whose sibling
iteration queries empty theories too. A normal false-to-true propagation can
therefore reach the theory-status rehash path before ordinary saving. The
no-resize theorem alone does not cover this path; the required additional
contract is specifically the interrupted `th_state` resize while a nested save
can query its nonempty theory. This packet does not expand into that contract
or claim that an arithmetic guard passed for unretained entry values.

This finite-key argument does not require a bound on polling or status-update
calls. For clarity, the selected GNAT scheduler is blocking, and
`Call_provers.get_new_results` drops ProverStarted notifications in that mode
(`call_provers.ml:550–561`). Finished entries are removed before callback
dispatch, so later duplicates cannot replay that transition
(`controller_itp.ml:450–490`). Preparation failures can pass through both
build/idle failure handlers; the table bound does not mistakenly assume one
callback or one status replacement per attempt. The selected notification
function is empty (`gnat_checks.ml:991`).

## Application boundary and remaining inputs

The packet's executable computes the numerical conditional table above and
preserved transformation/argument/script counts directly from hash-bound
captured data plus the accepted scheduler rows. It exports table-growth
allowances and separate visits/size/capacity arithmetic. Unknown initial state
and an absent continued signal condition stay unknown. Supplying a mathematical
guard does not set the native table-contract flag; the default actual usable
attempt-visit result is withheld until that contract is joined.

The smallest outstanding joins are therefore concrete: valid entry tables and
actual size/capacity/key coverage sufficient for the no-resize guards (or a
different proved rehash contract); initial shared prover-ID binding visits and
ID magnitudes; the continued signal/native-effect condition over the post-cut
interval; attempt-ID counter headroom for interrupted constructor prefixes;
and the already identified missing serializer strings, shape state,
Buffer, formatter/native and live-lookup contracts. Source initialization alone
does not reconstruct a captured state after possible earlier saves. The source
growth allowances need no new native attempt/forest capture. Complete save or
process capacity, issue completion, production 88–94, admission, tools and pins
remain unchanged.

Selected author model/effort: GPT-6 Astra / Extra High, as assigned by the lead.
Runtime setting confirmation and token/cost measurements are unavailable.
The packet records actual offline check timing and the bounded work interval.
No native/compiler/prover/solver/capture run, source fetch, predecessor proof
replay, GitHub write or CLI-memory update occurred. Root owns integration and
durable/issue bookkeeping.
