# Theory-cache first resize and the remaining continuation obligation

2026-10-20 UTC, Linux x86_64, bounded research #119 / #153; exact base
`466c44c54b6ec777829400108c2f53920827bcc0`.

**The first published theory-cache resize preserves finite lookup chains, but
the complete selected continuation remains unproved.** Its intermediate roots
can share tails and lose lookup coverage. A later resize of that state is not
covered by the first-resize argument. The retained actual-hash model exhibits
a cycle in such a second resize after a hypothetical later file-status query
pass. Whether selected callback control admits that repair pass is the precise
remaining question; the model is not a reachable native-execution claim.

The [offline packet](../evidence/retained-why-theory-cache-resize-20261020/README.md)
binds the five retained capture members, source excerpts, prior native evidence,
198 first-resize model states and three second-resize countermodels. It performs
no capture, native execution, disassembly, source fetch, solver/proof execution,
or replay of accepted observer/binder/alpha/native checkers. Oracle, admission,
tools and pins are unchanged; production 88–94 remains unstarted and PR #121
remains draft/unmerged. The
[combined Round 29 review](../reviews/review-save-capacity-round29-20261020.md)
accepts the first-prefix result and explicit residual at aggregate `7832039860`.

## Inputs and scope

The exact Why3 revision is `9390baf120ef260547dfa14f08e11c890b203d9c`, OCaml is
4.14.2 at `8eb41f72ded84df884c3671734c947f612091f84`, and the retained Linux
executable SHA-256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The accepted [native prefix contract](retained-why-save-hashtbl-prefix.md),
[state join](retained-why-save-state-join.md), and
[Round 28 review](../reviews/review-save-state-continuation-20261020.md) supply
their existing representation, source/native relevance, one-worker, continued
signal/native and nonreturning-handler premises. This is a bounded source
argument with retained native cut-point evidence, not a binary refinement proof.

Each fresh `save-missing-state.json` has a theory table with scalar size zero,
binding visits zero, 16 empty buckets, seed zero and initial size 16. Each ordered
serializer forest has one file, no detached theories, and exactly one nonempty
theory, last in that file. The checker verifies these facts and the exact ordered
identifier tags directly against manifest-bound archive members. It reuses the
accepted graph/capture correspondence rather than decoding or replaying it.

| Capture | Theories `Th` | `Th+2` | Nonempty theory tag | Initial no-resize guard |
| --- | ---: | ---: | ---: | --- |
| Put_Line | 46 | 48 | 63520 | fails |
| Put | 46 | 48 | 62748 | fails |
| First_Or_Default | 41 | 43 | 60244 | fails |
| Is_Message | 12 | 14 | 57057 | passes |
| Input_Is_Valid | 21 | 23 | 57342 | passes |

The admitted post-cut theory-table operations are `find`, `add` from
`th_proved`, and `replace` from `update_theory_node`. The load-time insertion
at `session_itp.ml:1178` is outside this fresh continuation. There is no selected
clear, remove, reset or table traversal. The positive traversal flag therefore
selects in-place resize. The entry control cut must exclude a suspended earlier
link mutator, as required by the accepted prefix contract. The argument assumes
valid immutable identifier tags, valid booleans/cells and the accepted external
runtime/resource premises throughout.

`ident.ml:159–172`, `wstdlib.ml:60–100`, `weakhtbl.ml:50–58`,
`exthtbl.ml:40–48`, and `hashtbl.ml:345–363,477–485` identify `Hid` hashing as
the identifier's integer `id_tag`, with bucket index `tag land (capacity-1)`.
The seed is ignored by this functor. No arbitrary hash callback is admitted.

## First published resize: conditional theorem

Let `N` be the scalar size immediately before the first publication of a new
bucket array. Before that publication, bucket chains remain disjoint, correctly
indexed and finite: additions prepend fresh cells, found replacements preserve
links and equal tags, and an abandoned resize before publication has changed no
table root/link. Thus the scalar and number of cells are both `N` at this cut.

Before this cut, normal queries cannot reinsert a previously present theory
key. The accepted global budget of at most two exceptional signal-save escapes
allows at most two additional fallback insertions. Consequently
`N <= Th+2` for the selected key domain. This use of the key-presence argument
ends at the first publication; **it is not a whole-continuation addition bound
after an interrupted rehash**. The first threshold crossing is at size 33, but
we do not assume `N=33`: a failed/interrupted array allocation before publication
can abandon an earlier resize, and a later insertion can retry it at larger size.

At the first publication, capacity changes from 16 to 32. Fix the order of cells
in each original bucket chain. For `insert_all_buckets` (`hashtbl.ml:113–152`):

1. Each original bucket splits into at most two destinations, `b` and `b+16`.
   Different original buckets have disjoint destination sets and cells.
2. The traversal saves a cell's original `next` before altering a previous tail.
   Each previous tail is an earlier cell of the same original chain. No write
   alters an unvisited cell's `next`, so every input cell is visited once.
3. A rewritten `tail.next` points strictly forward in that original chain;
   an untouched link also points forward. Tail finalization only writes Empty.
   Every intermediate chain is therefore finite and acyclic, although roots
   need not be disjoint and some keys are absent from their proper buckets.
4. At most two new roots draw from each original bucket's cells. The sum of all
   new-array chain lengths is consequently at most `2*N`, counting shared-tail
   occurrences separately. The empty array immediately after publication also
   satisfies this bound. Scalar size remains `N` during relinking.

The same reasoning bounds each reached lookup by `2*N`; it does not promise
successful lookup or accurate cached truth values. A completed first resize
restores correct indexing and disjointness. If it completes without an escaping
interruption, ordinary key preservation and `Th+2 <= 48 < 64` exclude a second
resize. This statement includes no earlier abandoned *published* resize.

Native facts are reused from the already checked
[20-body packet](../evidence/retained-why-save-hashtbl-prefix-20261020/native-bodies.json),
whose instruction-byte correspondence is retained in its check result:

| First-resize operation | Retained native witness |
| --- | --- |
| New array publication | `resize_721` calls `caml_modify` at `0x981826`, before the tail-array/closure allocations. |
| Pending dispatch after publication, before any cell | `insert_all_buckets_702` allocation check at `0x981526`; the new table is empty. |
| Save `next`, then append | `insert_bucket_710` saves `next` at `0x9816a7–0x9816ab`; root/tail write calls are `0x981742/0x981758`. |
| Poll after an inserted cell | Tail bookkeeping at `0x981776` then jump to the poll at `0x981684`; a save can observe the partial links. |
| Finalization | Tail Empty write at `0x98162d`; loop poll at `0x98163e`. |

Index/hash calls and bucket-loop polls may expose the same table states. The
faithful runtime and retained non-dispatching write-barrier contract cover the
stores. A SIGINT save cannot return normally to its interrupted operation: it
exits or raises, unwinding that rehash. An outer receiving catch may nevertheless
start a new operation on the abandoned partial table.

If the selected receiving route permits **only subsequent saves** after this
publication/interruption, `save_theory` skips empty theories and performs one
`th_proved` query on the sole nonempty theory per reached save
(`session_itp.ml:2150–2172`). Even charging the entire remaining upper bound
`r<=3` again conservatively, there are at most three additions. Fresh-head
insertion preserves acyclicity and adds one visit, so size is at most `N+3`
and visits at most `2*N+3`. For the first three captures this gives size
**51 / 51 / 46** and visits **99 / 99 / 89**. All sizes are below 64, excluding
the next resize under that explicit control premise. This supplies a bounded
save-only suffix, not a proof that every receiving route has that suffix.

More generally, after one abandoned first resize, fresh-head insertion and
replacement preserve finite chains until a second rehash begins. At size at
most 64 the visits are bounded by `2*N+(64-N)=N+64`; the insertion that reaches
65 gives at most `N+65` visits before its second rehash. This does not justify
relinking those potentially shared input chains.

## Receiving control and precise residual

`th_proved` catches `Not_found` from its **find expression**; its fallback add
is outside that catch. `update_theory_node` commits its theory replacement
before parent/file propagation, and `update_goal_node`/`update_trans_node`
likewise commit their own status before propagating. The `Not_found` catch
around theory-to-file propagation is not print-and-continue: `Loc.errorm`
calls `error`, which raises `Message` or `Located` (`loc.ml:302–306,338–341`).
These facts remove several false replay paths, but do not alone prove that
all later callbacks are blocked from visiting the file's empty theories.

The sibling counter/control packet at commit
`8cc4934b9017a8bb5a289772bd1a6bfa3bb2a09d` supplies the bounded callback
classification. The retained excerpts here make the relevant residual
self-contained:

| Region | Selected behavior relevant to this cache |
| --- | --- |
| Controller `build_prover_call`, 409–440 | A `Sys_error` in its protected build region invokes `spa_callback (InternalFailure e)`. |
| Controller `idle_handler`, 517–536 | Its broad catch protects `build_prover_call` and `update_observer`; an escape from the first failure callback can cause another `InternalFailure` callback. The second callback is outside that broad catch. |
| Controller callback wrapper, 592–617 | Every `InternalFailure` runs `update_goal_node` before the external callback. |
| GNAT `interpret_result`, 94–120 | `InternalFailure` only adds a formatted warning; it does not schedule constructors. `Done` has the scheduling route. |

No constructor in the protected failure region is useful for the sibling's
counter theorem, but **does not exclude cache updates**. After an idle failure
response, queued work and later callbacks may survive. If the first rehash is
interrupted in this protected callback, the proof must establish that the
committed leaf/transformation/root/theory statuses and remaining signal budget
exclude another `update_file_node` traversal, or establish a different bound
that handles its repairs and every later resize. The repeated identical failure
normally encounters an already-committed leaf status; that local observation
is not a proved invariant for all later callbacks, status reads and caught
signal-save exceptions.

The precise unclosed lane is therefore:

```
first published in-place theory-cache resize
  -> SIGINT save escapes and abandons partial links
  -> protected InternalFailure receiving path survives
  -> later status propagation may query missing empty-theory entries
  -> insertion growth and a second in-place resize need a sound bound
```

The global two-escape budget, `Th` key cardinality, and no-constructor result do
not independently close this lane. No new assumption excluding it is adopted.

## Actual-hash obstruction to a generic resize extension

The offline model first inserts the nonempty theory key, then the captured
ordered empty-theory keys until scalar size 33. It enumerates the new-array
publication, all 33 post-insert states, and all 32 tail-finalization states:
66 states per case, including the completed state. Empty-bucket polls duplicate
an unchanged state. This is an illustrative operation sequence, not an exhaustive
selected execution enumeration. The universal first-resize argument above does
not depend on that insertion order or the model counts.

| Capture | Model maximum first-prefix visits | Prefixes sharing cells | First retained cycle witness |
| --- | ---: | ---: | --- |
| Put_Line | 44 | 62 | key 57152 revisited from old bucket 16 in the second resize |
| Put | 46 | 62 | key 57152 revisited from old bucket 16 in the second resize |
| First_Or_Default | 40 | 45 | key 56993 revisited from old bucket 17 in the second resize |

For each retained countermodel, the first resize is abandoned at its stated
`0x981684` poll. The model queries the sole nonempty theory as a nested save
would, then deliberately supplies a **hypothetical later ordered file-query
pass**. Missing-key additions bring size from 33 to 65. The second resize
follows the actual mutable saved-next algorithm, revisits a cell from a shared
tail, and exposes a cycle at another `0x981684` poll. For Put_Line and Put,
the cycle is `57152 -> 56640 -> 56256 -> 57152`. First_Or_Default has a
three-cell cyclic suffix `56993 -> 56609 -> 56289 -> 56993`.

The model retains all cell identities, links, query additions and both poll
events. It falsifies the proposed generic rule “one finite interrupted rehash
plus later same-domain queries remains covered by `Th+2` and disjoint rehash.”
It neither proves that selected status control reaches the hypothetical pass
nor proves that the actual save queries a cyclic bucket. The selected-route
capacity result remains explicitly false in the evidence interface. The next
research step is the missing status/remaining-event invariant at the protected
failure catch; replaying the old successful native or capture analyses would
not answer that question.
