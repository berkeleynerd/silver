# Interrupted preparation and Theory writer charges

2026-10-20 UTC, #119 / #153, Round 34. The selected interrupted continuation
has at most **194 / 161 / 98 / 11 / 5 preparation episodes**, in Put_Line, Put,
First_Or_Default, Is_Message, Input_Is_Valid order. These are new source-derived
bounds, including failed prefixes and the active inline episode; they do not
reuse 459 normal attempts as an interrupted bound. Actual post-cut fresh
`Theory.id_to_path` publications **W remain unknown** because a quantitative
library parse/clone charge is still absent. The
[packet](../evidence/retained-why-path-writer-capacity-20261020/README.md)
provides the episode proof, direct tuple transfer, explicit missing-library
interface and conditional writer arithmetic/storage bounds.

## Actual cut and repeated-pair charge

Reuse the reviewed [serial pending ownership](retained-why-theory-cache-control.md),
[constructor receiving catches](retained-why-attempt-counter-continuation.md),
[metadata preservation](retained-why-save-attempt-growth.md), and fresh status
packet. Four processes are before scheduling, with no selected-prover attempts
and zero recorded preparation/scheduling hits. Their initial attempts are only
nonobsolete Valid Trivial records. Input_Is_Valid is the first cvc5 inline
entry: selected attempt 3 has state None, one prepare entry was observed, and
its driver input corresponds to leaf 3. Its transformed inline task is not
claimed to be the raw leaf task. The raw queue and GNAT check maps remain
unobserved; their ownership is the accepted source argument.

The fixed registered goal domain G is 64 / 53 / 32 / 3 / 1. There are three
selected immutable prover keys; Trivial is different. Initial leaves have no
further split on this Per_Check route. No later clone, CE or interactive route
adds registered goals. Let K=3G. Keep **one global e≤2 escaping signal-save
exception budget per process**, from the cut through ordinary ending. Do not
restart it at a query, callback, preparation or save.

The exact selection/catch argument is:

1. `next` removes a goal before returning it for scheduling. Only a nonvalid
   Done can requeue that same goal. Valid Done ends its owner; InternalFailure,
   Interrupted, Detached and other selected notifications schedule nothing.
   A repeated failure notification may update caches or add another warning,
   but cannot create another preparation owner.
2. Graft/queue/Scheduled precede idle processing. Each published queue item is
   popped once and passed to `build_prover_call` once. Build calls prove_task
   once; prove_task calls prepare_task once. Build's Sys_error and idle's broad
   catches do not repeat the build. The earlier constructor is not dynamically
   below those catches. Escapes from the initial-scheduling or Done scheduling
   callers terminate that scheduling path or enter ending, without restarting
   a partially unpublished constructor.
3. A completed pair has `Some result`, `proof_obsolete=false` and the same
   configured limits used by `has_been_tried_by`. A subtle point is decisive:
   `controller_itp.ml:617–645` computes `adaptlimits` but calls
   `graft_proof_attempt ~limits`, using the original configured limits. Only
   the queued `spa_limits` field receives `adaptlimits`. Thus one exceptional
   retry cannot permanently make the stored limits differ from the query and
   cause an uncharged infinite series of retries.
4. Before a second entry for a pair, the previous owner must have produced
   nonvalid Done. A None-state/failing preparation owner cannot requeue itself.
   The Done callback stores the result before GNAT requeue, and duplicate server
   notifications cannot invoke Done again after the call has been removed.
   The accepted table/counter contract preserves the chosen pair and record.
   No selected operation marks an attempt obsolete or changes its configured
   key/limits between completion and reselection.
5. `find_best_untried_prover` has no obsolete-valid preference on this fresh
   route. Its selected candidate must pass `not (has_been_tried_by ...)`.
   For an already completed pair, that false result requires a signal-origin
   Not_found caught by the whole-query handler at `gnat_checks.ml:471–482`.
   This handler consumes the escape and returns false, rather than rethrowing
   it to justify another repeated-pair selection. Other known lookups/config
   services do not ordinarily fabricate Not_found under the inherited valid
   metadata/fixed-configuration relation. Nonsignal service failures may abort
   an episode; they are not charged to e or assumed to be signals.

Map each first pair episode to its distinct pair, and each subsequent episode
to the consumed escape that selected it. These sets have sizes at most K and e.
Signals caught by earlier eligibility/all-tried queries might merely waste an
escape or requeue a goal that cannot select any prover; this does not increase
the bound. Warnings do not requeue their goal and introduce no additional
prover. Failures before or after publication can remove future episodes, not
supply an uncharged repeated owner. Therefore **E≤K+e** for every executed
prefix, regardless of solver answers, failures or a nonreturning service.

For Input_Is_Valid count the entire already active first episode in its K
allowance. This deliberately overcounts any work before the cut and covers all
remaining work in its frame; do not add a second independent initial episode.
The other cuts have no active preparation. The global exception allowance is
post-cut in both cases. This proof uses the fresh phase/ownership attachment,
not a claim that arbitrary historical scheduler invocations were bounded.

## Directive, library-root and direct tuple counts

The fixed lists have 15 / 13 / 12 directives for cvc5 / z3 / altergo. First
pair episodes contribute at most 40G directives, and each repeated episode at
most 15. Each list has one `eliminate_literal` and one algebraic elimination
entry (possibly conditional). Its initialization is called at most once by
that episode's lookup of its directive; the weak-memo miss body is outside its
lookup catch and cannot restart itself on its own exception.

| Case | G | E≤3G+2 | Outer directives≤40G+30 | Direct library roots≤2E |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 64 | 194 | 2,590 | 388 |
| Put | 53 | 161 | 2,150 | 322 |
| First_Or_Default | 32 | 98 | 1,310 | 196 |
| Is_Message | 3 | 11 | 150 | 22 |
| Input_Is_Valid | 1 | 5 | 70 | 10 |
| Sum of separate processes | 153 | 469 | 6,270 | 938 |

`eliminate_literal` has exactly the direct roots `["int"].Int` and
`["real"].Real`. These counts concern calls from transform initialization,
not all nested reads, parses, declarations, clones or table publications. An
initialization may hit a cache or fail after its first root. The full active
Input_Is_Valid episode is overcounted even if its initializations preceded the
inline cut.

There is at most one `fold_comp` per episode. The other discrimination helper
uses `compile_match`, not the tuple-writing algebraic fold. In
`eliminate_algebraic.ml:469–489`, the second `let comp` is **nonrecursive**:
its local calls to `comp` refer to the previous Task-only function. Only its
direct tuple-Ddata case calls `Theory.tuple_theory`, once. It does not recursively
reenter that new tuple case through its deferred map entries.

`Trans.fold` collects a suffix of the immutable task-prev chain and calls its
rewind callback once per collected occurrence. A spurious cache miss can extend
the suffix; it cannot revisit an earlier Task in that chain. Under the existing
valid persistent Task/source relation, each six-field Task occupies at least
56 represented bytes. Hence the representation-only ceiling

```text
D_rep = floor(2^64 / 56) = 329,406,144,173,384,850
```

bounds nodes of one captured chain. It does not assert that this many nodes
can be allocated or traversed on the host. Task construction only installs
existing predecessors; hash-consing returns an already finite Task or a fresh
node with that predecessor. Tag aliases cannot mutate an existing prev link.

One actual tuple-constructor callback performs at most three `id_to_path`
publication attempts: its type head, constructor head and closing theory.
The projection list consists entirely of None, regardless of arity. Type and
term constructors themselves do not write Theory paths. Each store invokes
replace at most once, including replace's caught-Not_found fallback. Memo hits,
existing keys and interrupted prefixes only reduce the three-publication
ceiling. Thus **direct algebraic tuple publications ≤3*E*D**, for any supplied
D bound, with D_rep available as a very loose representation bound. A tighter D need
only bound tuple-Ddata callback occurrences, rather than every prepared Task
node; this narrower input is T_prepared in the next-step equation below.

## Exact unresolved publication charge

Let C_int and C_real bound all `id_to_path` publications executed within one
corresponding direct read-theory root, **including every nested read, abandoned
prefix, reparse, generated declaration, clone, automatic builtin and tuple
constructor** allowed by the selected entry state. A common bound C_lib gives

```text
W <= E*(3*D + C_int + C_real) <= E*(3*D + 2*C_lib).
```

All selected later Theory writers belong to these two root families by the
[reviewed effect closure](retained-why-path-library-origins.md). C_lib is not
supplied by the bounded filename set, finite tag domain, fixed payload limit
or maximum individual represented chain. The executable leaves it and usable
W null. This is the specific missing quantitative source obligation, not a
claim that the selected parser has an infinite publication execution.

The smallest useful next derivation counts actual source head/namespace/closure
visits over the retained four-file import/clone DAG. For one expanded read,
separate non-tuple declaration-head visits H, Theory namespace clone path
visits N, non-tuple theory closures C, and tuple-constructor callbacks T. Then

```text
C_lib <= H + N + C + 3*T.
```

`Theory.add_decl` contributes one for Dtype/Dparam/Dprop, one per Dlogic head,
Ddata type/constructor/present projection, and Dind predicate/clause head.
`Pmodule.add_pdecl_raw` folds these contributions over `pd_pure`;
`add_pdecl` also visits its generated VC declarations. `clone_export'` folds
expanded module units and nested scopes; clone-generated declarations contribute
through the same actual head visits. The source-origin proof bounds their
names but has not yet supplied those occurrence counts.

T must include **implicit** tuple construction: `Pmodule.add_use` folds the
used-symbol set and can call `tuple_module`; any selected
`Theory.add_decl_with_tuples` route similarly collects tuple arities from
`get_used_syms_decl` before insertion. Counting only lexical heads or explicit
use/clone syntax would miss this charge. A four-file recurrence must count
nested file reads per actual import action and expanded clone/unit/declaration
visits, with generated used-symbol/tuple-arities accounted for. Cached hits can
be ignored for an upper bound; cache preservation is not required to avoid a
reparse. The smallest next package can target
`W <= E*(3*T_prepared + 2*C_lib)`. A predecessor-transform no-new-tuple-Ddata
invariant is a possible way to reuse a counted raw tuple-head domain, but is
**not established here**: it must cover each driver's predecessor list, memo
representative returns, occurrence duplication and selected counter/tag aliases.
Initial/raw or one inline Task count does not supply that invariant.
A separate sharper D bound is needed for useful numerical capacity:
even setting C_lib=0, the D_rep-based W candidate fails the tagged-size guard
for every selected row. This diagnostic does not show that the actual execution
overflows.

## Conditional writer bounds and size drift

Assume a finite actual publication bound W. The focused checker separately
reads the actual scalar `size` from each retained capture metadata member and
compares its full member identity with the reviewed Round 33 manifest. It checks
`size == binding_visits == V0`, yielding 6941/6941/6901/6783/6819 at the actual
cuts. This is an explicit captured scalar attachment; absence of a suspended
writer alone would not establish equality after an earlier failed clean. The
arithmetic interface takes size0 separately from the initial cell count. Put V=min(2^59,V0+W) and L=min(2^59,7+W), as in the
[reviewed lookup argument](retained-why-path-lookup-capacity.md). There is no
resumable pre-cut Theory writer, reentrant pending Theory writer, private clear,
reset or remove. Each replace publication increments size at most once and can
enter resize/clean at most once. Every clean visits at most V current cells;
no correct size value is needed for that topology bound. Therefore, including
all interrupted prefixes,

```text
clean calls <= W
clean node visits / clean Cons requests <= W*V
successful array publications <= min(W,41)
resize-copy node visits / copy Cons requests <= min(W,41)*V
size0 - W*V <= mathematical size <= size0 + W.
```

The 41 successful doublings are from 2^12 to 2^53. Failed Array.make attempts
need not advance capacity and are not bounded by 41. A first-wrap argument
establishes scalar size arithmetic only if both displayed endpoints fit
[-2^62,2^62−1]. The transfer checks that condition rather than silently assuming
size equals current cells after failure. For the actual captured size0=V0,
the exact largest W satisfying this conservative guard is
**2,147,480,177 / 2,147,480,177 / 2,147,480,197 / 2,147,480,256 / 2,147,480,238**,
in the table's case order. In this range V=V0+W; the lower guard is
`W^2 + V0*W <= 2^62 + size0`. The checker tests each maximum and maximum+1.
These are allowable input thresholds, not established actual W values.
Primary unpublished Cons attempts,
ephemerons, closures, arrays, options and allocator metadata are outside these
clean/copy Cons subtotals.

Retained native do_bucket and insert_bucket each reserve 24 bytes and recurse
by call before allocating/copying the next node. Each has at most L+1 own
frames, conservatively **32*(L+1) bytes including their return addresses**.
Their callers, allocator/GC/callback/exception frames and actual available
stack headroom remain separate. This does not inherit find_rec's constant
stack behavior.

There is also a potentially better size-only interface that does not need
lifetime W. Let F bound abandoned **count-changing** table mutations, and
B=2^59. A completed mutation preserves the discrepancy `size-current_cells`.
During clean, only the currently reconstructed bucket can have decrements not
yet matched by its publication, changing that discrepancy by at most B.
A partially copied resize omits at most B old occurrences from the new current
array; a prepend before its size increment changes the discrepancy by one.
Clean finishes before array publication, so these local discrepancies are not
summed within one active prefix. With no reentrant writer, each abandoned
mutation adds at most B in either direction; one active prefix adds at most B.
Starting from exact size gives the conservative interval

```text
-(F+1)*B <= size <= (F+2)*B.
```

This guard passes for F≤5 (in particular a separately established F≤2 would
suffice), and the conservative upper endpoint fails at F=6. The packet does
**not** infer F≤2 from the signal budget: allocator/GC/pending services can
raise nonsignal failures under the presently stated failure-permitting frame
relation. A count of which mutation failures can be caught and followed by
another writer, or an explicitly attached normal-service exception audit,
is needed. Actual F remains null. This provides the next size-only proof
interface without hiding a service-success premise.

Full writer/table/save/pipeline capacity remains false. The packet checks 35
source slices and retained status/domain/dispatch identities, small adversarial
selection/drift models and arithmetic boundaries. It reuses successful native
and predecessor evidence without replay. No target execution/capture, fetch,
disassembler, solver/proof/full-suite, source/pin/Oracle/admission change or
GitHub action occurs. Production #88–#94 stays unstarted and PR #121 stays
draft/unmerged. Independent acceptance is the combined Round 34 review.
