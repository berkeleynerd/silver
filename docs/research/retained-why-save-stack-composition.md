# Retained Why3 save-stack composition

This Round 36 packet closes the selected binder **structural-growth** question
and derives a numerical projection of the native stack added by save. It does
not yet give a complete save-stack requirement. The largest five-case projection
is **33,755,808 bytes across all three saves**, plus the explicitly unbounded
here omitted tool frames, pending dispatch and trusted service demand. Suspended
preparation/scheduler stack is a separate summand. No physical stack-headroom or
whole-save-capacity result follows from this projection.

The [packet](../evidence/retained-why-save-stack-composition-20261020/README.md)
uses retained sources, the accepted five logical task forests and their fresh
entry correspondence, and 65 selected native bodies (18,664 bytes checked
against the installed Linux x86-64 ELF). It performs no target execution,
capture, new disassembly, solver run or predecessor-checker replay. Exact
source/native correspondence remains the existing premise; the new byte check
does not purport to prove compiler refinement.

## The binder input that makes a finite useful bound possible

The opened-term counts in the
[shape transfer](retained-why-session-shape-transfer.md) do not, alone, bound
`bv_vars` and `bv_subst`: native substitution visits administrative maps even
when their entries do not contribute to the fully opened formula. This packet
reads those maps directly from the retained raw blocks, starting with the
accepted typed term-pointer closure. It validates the layouts, list/map
acyclicity, unique map keys and administrative term DAG. Every saved substitution
value belongs to that already accepted term closure.

| Case | Logical / fresh PID | Stored terms | Binder records | Saved substitution values | D | F0 | S0 | L |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 3085 / 17310 | 22,477 | 5,931 | 387 | 197 | 14 | 8 | 7 |
| Put | 3323 / 17514 | 17,790 | 4,715 | 310 | 197 | 12 | 8 | 7 |
| First_Or_Default | 3470 / 17631 | 7,744 | 1,731 | 44 | 89 | 7 | 1 | 7 |
| Is_Message | 3568 / 17704 | 1,337 | 143 | 0 | 37 | 7 | 0 | 7 |
| Input_Is_Valid | 97103 / 17869 | 1,545 | 156 | 4 | 39 | 7 | 1 | 7 |

**Every saved substitution value is `Tvar`, of term mass/depth one.** D is the
largest initial term depth including children and stored substitution-value
edges. F0 and S0 are the largest initial `bv_vars` and `bv_subst` cardinalities;
L bounds each initial argument, binder, trigger and trigger-element list.
Patterns and `Tcase` are absent. These are initial represented inputs, not an
assertion that the task graph contains only D distinct objects. The full
compressed certificate retains each binder record and each substitution-value
constructor; the summary is not a replacement for that input.

The source transfer is an induction over `term.ml:739–831`:

1. Opening adds only `t_var` of a fresh variable. A substitution of a `Tvar`
   returns an existing variable image or the original variable; `t_attr_copy`
   changes attributes/location or returns a similar variable, never its
   constructor. Thus all environment and deferred-map values remain variables.
2. Other constructors retain their constructor and child-list shape. Substitution
   does not recursively substitute inside an image returned at a variable leaf.
   `bv_subst_unsafe` maps variable leaves, so it cannot introduce a nested binder
   traversal through an image. Consequently term depth remains at most D and
   child/binder/trigger list lengths remain at most L. No exponential term
   expansion or arbitrary-expression replacement envelope is needed.
3. In `bv_subst_unsafe`, `set_inter` restricts the incoming environment to the
   current free-variable keys. `set_diff` removes those keys. For each removed
   key, `add_nt_vars` sees a variable image and inserts at most one replacement
   variable key. Collisions merge entries. Therefore `bv_vars` cardinality never
   exceeds its initial F0. Multiplicity values and their integer arithmetic are
   separate obligations; this argument bounds keys and frames, not those values.
4. Mapping the old deferred map preserves its keys; its subsequent union adds
   at most F0 keys. A particular immutable binder-record copy is transformed
   only along its enclosing binder ancestry. Its body is not written back into
   the fixed session task. There are at most D enclosing opening steps before
   reaching that record. Sibling traversals, later propositions, explanation
   traversal, repeated saves and nested saves start from the preserved task
   input; they do not continue mutating this copy. Hence

   ```text
   deferred-map keys <= S0 + F0*D
   opening-environment keys <= N = S0 + F0*D + L.
   ```

This yields N = **2773, 2379, 631, 266, 281**. It uses immutable term/binder
records, the selected variable-only inputs, and the existing map/source and
fixed-task preservation premises. It does not cover a future task with a
non-variable substitution value. Attribute union draws only from the initial
term-attribute union (fresh variable terms begin empty); its cardinality A is
**192, 168, 190, 39, 41**. Raw type graphs and task clone/theory-local symbol
containers are not extracted here.

## Native recursion, loops and callers

All sizes below include the eight-byte incoming return slot. A tail transfer
reuses that slot. Adding both sides of such a transfer in a projection is a
conservative overcharge, not a claim that both frames coexist.

| Selected body/family | Own bytes | Stack behavior |
| --- | ---: | --- |
| `Gnat_checks.save_session` | no additional reservation | tail jump to Session_itp |
| `Session_itp.save_session`, `save` | 32, 64 | former restores before tail-jumping to latter |
| `Shape.t_shape` | 64 | at most D active term levels |
| `List.iter`, `List.fold_left` | 32 each | backedges after prologue; no per-sibling accumulation |
| `t_bound_shape_task`, `do_d` | 80, 16+16 trap | do_d catches `ShapeTooLong` around one term traversal |
| `t_subst_unsafe`, `t_map_unsafe` | 80, 64 | structural recursion bounded by D |
| `b_subst`, `bv_subst_unsafe` | 48 each | variable images prevent recursive binder descent in map callbacks |
| `t_open_bound`, `t_open_quant`, `tr_map` | 32, 48, 16 | opening/trigger wrappers; `tr_map` coefficient imported by source/native inspection |
| `List.map` | 32 | at most L+1 frames per active list mapping |
| `Task.filter` | 48+16 trap | recursive call is inside its exception handler |
| `Task.skip`, `Task.task_fold` | 16, 32 | tail/backedge iteration |
| `Ident.advance`, `Ident.retreat` | 32 each | backedges after prologue; suffix index is not stack depth |
| `Extmap.find` | 32 | backedge after prologue; no per-node stack |
| `Extmap.add`, `iter`/`fold` | 80, 32 | recursive paths bounded by represented node counts |
| `Ephemeron.find_rec` | 48 | constant frame across the entire saved bucket chain |

`tr_map`'s 16-byte frame is included in the binder wrapper allowance; its body
and byte identity are retained alongside the other new frame witnesses.

The subtle `Task.filter` call at `0x598ba5` is a real recursive call under a
two-word trap. Its recursion consumes a strict suffix of the initial task
declaration list, including after a caught missing lookup. The saved task-chain
maxima C are **1044, 1044, 536, 368, 434**. This gives the filter/skip/task-fold
own-frame allowance `64*(C+1)+16+32+16`. Choose/find/comparator callees and task
selection maps remain separate; the bound is valid without claiming all calls
are tail-recursive merely because they scan a list.

For binder-related map recursion, the retained frame sum over the exact
`map_projection.symbols` list in `result.json` is **960 bytes**. These are
specified frames, not an invented maximum frame size. `union`, `inter`, `diff`
and `disjoint` descend strict subtrees or reduce the combined input-node
measure; split/join/add/remove helpers also descend finite represented trees.
Two operands each bounded by n have at most 2n nodes. Counting up to `2n+1`
active frames of **each** listed family is deliberately loose and covers
interleaved helper recursion:

```text
M(n) = 960*(2n+1).
```

The map component is `M(N)+M(A)`: the attribute union can occur inside a
variable-substitution callback while the administrative map operation is
suspended. Key comparators, apply/closure wrappers and other callbacks are not
included in M. The family listing and the byte checks make that boundary
explicit. This is not a claim that all those alternative map operations run
simultaneously, nor a bound on every map reached by save.

The term/binder recursion projection is

```text
80*(D+1) + 64*D + 32*(L+1)*(D+2) + 32+48+48+48+16.
```

The first two terms cover substitution and its structural mapper. The third
covers argument-list mapper chains plus the two trigger-list levels at opening;
the final terms are the named opening/binder/trigger wrappers. A variable image
adds only the terminal substitution level. Fresh-variable construction,
attribute-copy wrappers and their callees remain in the omitted-frame residual.

## Composition for the actual five forests

Let F, H, G and T be the accepted file, theory, goal and transformation counts.
Each selected forest has F=1 and T=1; H is 46/46/41/12/21 and G is 65/54/33/4/5.
Using whole-forest counts to bound active ancestry is intentionally looser than
an unproven exact tree-depth claim. The structural fold projection is

```text
32F + 32H + 64G + 48T + 32(F+H+G+T).
```

The serializer projection adds

```text
96F + 80H + 112G + 112T + 112 + 32(F+H+G+T+1).
```

Attempts are iterated sequentially; the extra 112-byte proof-attempt frame is
one active attempt, not the lifetime attempt count. Sorting, table operations,
proof-state predicates, printer callbacks and apply wrappers remain in the
omitted-frame residual. The shape-descent allowance is
`80+32+64D+32*(2D+1)+16+32`, covering t_bound_shape_task, do_d and its trap,
term frames, the two possible direct trigger iterator levels per term, the
outer declaration iterator, and alpha-renaming wrappers.

The selected identifier-search bodies contribute 288 bytes independently of
the possibly large suffix index: ident_v5 including trap, decoded, id_unique
including trap, find_unique including trap, one advance/retreat loop, testname
and specname. Their string/table/conversion descendants are separate.

For the two shape-dictionary maps only, reuse the accepted all-save binding
bounds K = **47841, 39745, 7657, 665, 951**. Their selected add/iteration/find
frames are bounded by `80*(K+1)+32*(K+1)+32`; K is not multiplied by r again.
The caller allowance is `32+64+16+32+32`. The accepted XML `output_acc` allowance
is 2,176 per save; the path `find_rec` projection is 48. Formatter work during
shape-constant conversion is not silently included in that XML allowance.

The sum P of these named projections is:

| Case | P per save (bytes) | r=3 projection (bytes) |
| --- | ---: | ---: |
| Put_Line | 11,251,936 | 33,755,808 |
| Put | 9,539,984 | 28,619,952 |
| First_Or_Default | 2,536,752 | 7,610,256 |
| Is_Message | 712,656 | 2,137,968 |
| Input_Is_Valid | 784,432 | 2,353,296 |

These are upper bounds on the **covered frame projection**; they are not lower
bounds, observed high-water measurements, or total stack upper bounds. Sums
overcharge sequential phases and restored tail-call frames. That is harmless
for this scoped composition and avoids claiming a tighter scheduling theorem.

## Exact remaining boundary

Define U as the maximum simultaneous tool-owned stack contribution **not charged
by the scoped instances above**, summed across the at most r saves. It includes
the listed symbols when reached in a different uncharged context. This prevents
a generic `Extmap` or `List` body used by an omitted helper from disappearing
merely because its name appears in a covered family. The outstanding joins are:

* Task selection: `used_theories` / `used_symbols` and their clone-map,
  hash-consed declaration-set, theory-local map and callback routes. C bounds
  `local_decls.filter`; it does not bound these other containers.
* Explanation traversal and remaining shape callees: `goal_expl_task` /
  `collect_expls` / `concat_expls`; identifier-printer initialization and private
  hash tables; variable creation, attribute-copy/comparison and scalar/constant
  formatting; application/closure wrappers connecting the bounded recursive
  families. The variable-only invariant removes expression-growth uncertainty,
  but it is not a complete native callee-stack proof.
* Serializer/helper routes: statistics/prover construction, hash-table
  operations, sorting, proof-state predicates, printer callbacks, filename and
  backup operations, remaining formatter core/scalar/channel wrappers, and
  path lookup wrappers/getter bridges outside the constant find_rec frame.

These are tool-owned callers and callees, not an invitation to prove collector,
libc or kernel internals. Let R be the simultaneous demand inside the existing
trusted runtime/platform services for valid requests. Let Q be the per-entry
pending-action/signal-dispatch bridge allowance, and A_pre the stack already
suspended in preparation/scheduling at the outer save entry. The interface is

```text
save-added stack <= r*P + U + e*Q + R,   r <= 3, e <= 2 globally;
process stack    <= A_pre + r*P + U + e*Q + R.
```

U, Q, R and A_pre remain unset by this packet, so
`complete_save_added_stack_upper` is **null**. The global r/e budgets include
save-origin pending nested calls and never reset at an inner save. Each
suspended outer save keeps at most its own P projection; repeated path getter
polls do not each create an additional simultaneous save or loop frame.

The large `32*(W+8)` clean/copy frame quantities in the accepted
[publication composition](retained-why-publication-composition.md) concern a
possibly suspended **preparation writer**, hence A_pre. They are not save-owned
lookup recursion. The accepted Round 35 publication/memo-loss result and #155
remain intact. This packet does not amend the Oracle, production, source pins,
admission, existing service contracts or the unstarted #88–#94 work.

## Validation and review handoff

Run `python3 docs/evidence/retained-why-save-stack-composition-20261020/check.py`
from the repository. It checks exact retained identities, body bytes/prologues,
trap pushes and named loop edges; performs the focused initial administrative
projection; and recomputes the displayed arithmetic. It does not mechanically
prove the source induction, whole call-graph closure or the external premises.
The review target is especially the variable-only invariant, the no-writeback
ancestry argument for N, and the scoped map-family stack composition.

Selected author setting: GPT-6 Astra / Extra High; live runtime setting not
independently confirmed. First observed start: 2026-10-20 13:26:17 UTC. Exact
elapsed/check evidence is in the packet's round record; token/cost telemetry is
unavailable. The allocation subthread read `term.ml:739–831` and found the key
cardinality recurrence consistent, while flagging multiplicity arithmetic as a
separate obligation. That bounded feedback is not independent acceptance of
this complete packet. No CLI memory was updated by this subthread.
