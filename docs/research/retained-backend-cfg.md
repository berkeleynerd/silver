# Retained backend: initial CFG, loops and SSA

Date: 2026-10-18. Research for #119, continuing the retained-tool capacity
work in #108. This is a source-derived component analysis, not an implemented
capacity rule or a claim that the whole compiler pipeline is bounded.

The source pin is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The
[offline evidence package](../evidence/retained-backend-cfg-20261018/README.md)
retains full-file identities, numbered excerpts and arithmetic checks. It does
not invoke GCC, GNATprove, Lean or the Silver suite. The selected host is Linux
x86-64, LP64, with 32-bit `int` and 64-bit pointers/`size_t`.

## Input and scope

Consume the initial-CFG transfer in
[the backend analysis](retained-backend-capacity.md): S flat GIMPLE statements
after EH lowering, B = max(1,S) ordinary blocks, K total switch-label operands,
and E = min(1+2B+K, 1+3B) CFG edges. Entry and exit add two fixed blocks; write
N = B+2. Each generated cleanup switch has at most three labels including its
default. These are ceilings, not assertions that every statement becomes its
own block or that all maxima occur together.

The current source frontier has no PHIs, `current_loops == NULL`, source labels,
nonlocal/computed gotos, setjmp/returns-twice dispatch, OMP, transactions or asm.
The initial label map and initial CFG allocations are already charged upstream.
This report starts at `execute_build_cfg`'s `cleanup_tree_cfg()`, covers initial
loop discovery, and then extends the transfer through the O0 fixup bridge and
initial SSA construction. Later SSA updates, ordinary optimizing passes and
RTL expansion are outside it.

The default SSA-update argument is zero (`tree-cfgcleanup.h:25`). There is no
call to `update_ssa` on this invocation. This does **not** imply that every helper
is forbidden to construct an SSA_NAME: switch range conversion is discussed
below. The no-PHI premise, which is what excludes PHI propagation and edge
splitting here, is the useful invariant.

## Blocks and edges do not grow

`cleanup_tree_cfg_noloop` (`tree-cfgcleanup.cc:1118–1267`) first performs a
reachable-block traversal with dominance temporarily unavailable. That traversal
can prune edges; afterward it deletes unvisited blocks. The setjmp and abnormal
helper vectors receive no elements under the frontier above. It then computes
dominators, records switch-edge cases, visits blocks for merging, drains a
bitmap worklist, regroups touched switches and compacts block indices.

The paths which could create loop preheaders are guarded by `current_loops`.
They cannot run here. The ordinary forwarder remover's split path requires both
`can_split` and PHIs; the default caller supplies false and there are no PHIs
(`tree-cfgcleanup.cc:476–780,871–896`). Its other successful path redirects
predecessor edges and deletes the forwarder. `ssa_redirect_edge` copies no PHI
arguments in this invocation; `redirect_edge_succ_nodup` either redirects the
existing edge or combines it with another and deletes it
(`tree-ssa.cc:140–168`, `cfghooks.cc:502–520`).

Block merging moves the successor edge vector, concatenates existing statements
and deletes the second block (`cfghooks.cc:842–937`, `tree-cfg.cc:2017–2160`).
Its PHI-to-assignment path is excluded. The source has no user labels to trigger
the new-debug-bind path. EH labels may be removed or moved; they do not require
a fresh block. The noreturn arm of `cleanup_control_flow_bb` removes trailing
debug statements and a fallthrough edge. It does not call the separate
`fixup_noreturn_call` routine that can split a block.

Consequently, throughout this interval:

```text
ordinary blocks <= B; total blocks <= N; last block index <= N;
CFG edge identities ever allocated in the interval = 0;
live CFG edges <= E; successful block deletions <= B.
```

Edge predecessor/successor **vectors** can still reallocate when an existing
edge changes destination. Counts of graph objects do not eliminate those
backing allocations. There are at most B successful forwarder removals and
at most E incoming edges per removal, hence at most B*E such redirections.
The existing heap/GC-vector transfer must consume those append requests and
per-vector length ceilings; it must not charge zero because no edge object is
new. Block merge transfers an existing successor vector rather than growing it.

## Labels, switch cases and generated statements

A switch-edge redirection asks `gimple_block_label(dest)` for a destination
label (`tree-cfg.cc:6057–6081,6128–6278`). It reuses an ordinary leading label
when one is available; otherwise it creates one LABEL_DECL and one GIMPLE_LABEL.
Charging every possible forwarder-edge redirection gives the conservative
lifetime bound

```text
fresh LABEL_DECL <= B*E; fresh GIMPLE_LABEL <= B*E.
```

Labels later removed by merging still count in that lifetime charge. The label
UID counter and its map must therefore consume the upstream label count plus
B*E, not merely the final number of live labels. UID assignment also supplies a
useful distinction: some artificially created labels may never be numbered,
but treating all of them as numbered is a sufficient overestimate. Declaration
UIDs, allocation sizes and global counters consume the same fresh-label term.

`start_recording_case_labels` creates one edge-to-case hash map and one bitmap
(`tree-cfg.cc:1230–1323`). Each lookup chains **existing** CASE_LABEL_EXPR nodes;
it does not create a TREE_LIST or copy a case. No new CFG edge identity exists,
so at most E different edge keys can be inserted. Removed-edge keys can remain
until the map is discarded and must still be included. The touched-switch
bitmap is indexed below N. Case grouping edits/shrinks existing operands and
may remove an edge and dominated blocks; it never increases K
(`tree-cfg.cc:1710–1852`). The auxiliary removed-label set is only for forced
or nonlocal labels, excluded by the current frontier.

Do not assume these cleanup cases remain singletons. Grouping runs in
`build_gimple_cfg` before cleanup, and may set CASE_HIGH by merging adjacent
cases. `convert_single_case_switch` replaces a two-label switch with one
GIMPLE_COND (`tree-cfgcleanup.cc:85–127`):

* A singleton uses one constant `fold_convert`, then an equality condition.
* A range calls `generate_range_test`, then creates an unsigned less-or-equal
  condition. The range helper makes two constant conversions, one constant
  subtraction, at most one `gimple_convert` request and one binary
  `gimple_build(MINUS_EXPR)` request (`tree-cfg.cc:9636–9653`).

At most S original switches can be converted, once each. Their replacement
conditions contribute at most S freshly allocated GIMPLE statements, but do
not themselves increase the live statement count. Boolean-condition
canonicalization makes one zero-constant request per eligible condition and
changes it to `!= 0`, which is no longer eligible (`:132–160`). There are at
most S such condition instances: original conditions plus converted switches
are disjoint subsets of the original statement identities.

The fallback arms of the two `gimple_build` requests each construct one SSA_NAME
and one assignment (`gimple-fold.cc:11005–11058,11287–11296`). Successful
simplification may instead produce a sequence; it is **not** established here
that the result contains at most two or three assignments. The matcher can
follow the SSA definition created in the same temporary sequence. The final
condition simplifier supplies NULL for its sequence and `no_follow_ssa_edges`
for valueization (`tree-cfgcleanup.cc:188–202`), a different interface.

Let A be the total number of statements emitted by the range-helper sequences,
including fallbacks, and let T_range include their tree/type/name allocations.
Then the structural transfer is:

```text
fresh GIMPLE statements <= B*E + S + A;
live output statements <= S + B*E + A;
extra label trees <= B*E; additional range trees/names = T_range;
range-helper gimple_build/convert entry requests <= 2*S;
constant conversion/subtraction/zero entry requests <= 4*S.
```

The constant request row counts entry calls (up to three for a range plus one
canonicalization); it consumes the backend's constant-fold/type transfer.
Range-type construction and generated symbolic matcher work remain explicit
inputs. A is not set to a measured value from a sample program.

## Cleanup worklist visits

Repeated condition simplification can allocate transient trees even when it
makes no change. Counting only final statements therefore misses a lifetime
cost. The pre-order pass visits each ordinary block once. Later worklist visits
need their own multiplier W for the NULL-sequence condition matcher.

A conservative structural envelope can be obtained by partitioning the
worklist run whenever it changes the CFG or a relevant terminal statement.
There are at most B block deletions, E edge deletions, and at most S instances
each of switch replacement, Boolean canonicalization, terminal-control removal
and call-control-flag cleanup. Forwarder redirection occurs in an iteration
which deletes its block. Thus M = B+E+4S is a sufficient number of such events.

Between events, an unproductive worklist visit either stops or queues a
mergeable single predecessor (`cleanup_tree_cfg_bb:871–896`). Following those
predecessors cannot cycle in the reachable CFG: every node in such a cycle
would have its only predecessor within the cycle, leaving no entry path.
Entry itself is not a merge candidate. There are at most B pending bitmap
entries at the start of an interval and each follows a chain of at most B
ordinary blocks. Bit deduplication only reduces visits. An intentionally loose
bound, including the pre-order pass and event iterations, is therefore:

```text
W = B + (M+1)*(B+1)^2 + M, where M=B+E+4S.
```

This prices **entry requests**, not the recursive work or allocations inside a
matcher. It relies on the current no-PHI frontier: propagation of arbitrary
SSA expressions would require revisiting the terminal-change argument.
`end_recording_case_labels` may remove additional blocks after the worklist;
those removals use the global B/E ceilings and do not start a new worklist.
The formula is an analysis envelope, not a proposed source-language limit.

## Dominator storage and counter arithmetic

With N total blocks, one `dom_info` instance creates nine 32-bit arrays of N
elements, one basic-block-pointer array of N elements, and one 32-bit DFS-order
array of at most N+1 elements (`dominance.cc:148–219`). Its nonrecursive DFS
allocates an edge-iterator array of N+1 entries (`:302–391`). On LP64 the
iterator has a 32-bit index plus an aligned pointer and occupies 16 bytes
(`basic-block.h:361–364`). The array payload sum is therefore bounded by

```text
9*4N + 8N + 4(N+1) + 16(N+1) = 64N + 20 bytes.
```

Allocator metadata, the `dom_info` object and other concurrently live containers
are additional. No postdominator fake-exit bitmap is allocated on this route.
Checking may create further instances for verification; reuse is not a claim
that those checks allocate nothing.

The initial CFG cleanup computes a dominance forest without fast-query numbers.
Loop discovery requests fast queries and reuses the maintained forest.
`assign_dfs_numbers` increments a signed int twice per forest node
(`dominance.cc:637–686`). The local sufficient counter condition is
`2N <= INT_MAX`, or B <= 1,073,741,821. This also covers the DFS stack's signed
index and the unsigned additions/doublings of set cardinalities in `link_roots`
(`:516–545`). It is not the full CFG arithmetic predicate.

Each forest node has one et_node and a rightmost et_occ. Each parent link adds
one et_occ. `set_immediate_dominator` splits/releases the old parent occurrence
before linking the replacement (`dominance.cc:873–892`,
`et-forest.cc:463–620`). At most N et_node and 2N et_occ objects are live.
The LP64 layouts are 64 and 48 bytes respectively; checking pools add an aligned
8-byte allocation ID. The pool block size is fixed at 65,536 bytes, with an
8-byte block-list header (`alloc-pool.h:160–198,261–307,351–430`,
`memory-block.h:25–84`). Therefore the conservative checking-enabled pool
backing ceilings, while these are the only clients of those two pools, are:

```text
et_nodes:       65,536 * ceil(N / 910);
et_occurrences: 65,536 * ceil(2N / 1170).
```

Without checking, capacities are 1023 and 1365 slots per block. Released slots
are reused; the backing count follows peak live demand, not the number of
reparent operations. Shared block caching and earlier/later clients must be
composed at translation-unit lifetime. The lazy-depth arithmetic has a separate local condition, derived below.

### Lazy Euler-depth arithmetic

The forest records an Euler traversal of actual tree depths in `[0,N-1]`.
A splay node's `depth` is the difference between its traversal depth and its
splay parent's traversal depth; at a splay root it is relative to the component's
coordinate origin. Its `min` is the minimum traversal depth in its splay subtree,
relative to the same parent's coordinate. These are the definitions in
`et-forest.cc:48–53`, implemented by `set_depth`, `set_depth_add` and
`et_recomp_min` (`:63–133`).

Detaching a splay subtree without adjusting its root weight does not accumulate
an arbitrary offset. It changes that component's origin to the removed parent's
traversal depth. After splaying, detaching again selects another occurrence's
traversal depth as the origin. Both are in the same depth interval. Reattaching
in `et_nca` and `et_below` restores that origin relationship. `et_split` finally
splays the detached tree's root occurrence and sets its root depth/minimum to
zero; all descendant depths then become relative to the detached tree root.
`et_set_father` joins disjoint trees and increases the attached root's relative
depth by one; the resulting real tree still contains at most N nodes
(`:517–774`). Thus, at stable operation/rotation boundaries, the magnitudes of
stored relative depths and subtree minima are at most N. This bound depends on
forest height, not the number of previous splay/reparent operations.

Transient expressions also need a bound; their operands are not all final
stored differences. The five rotation cases in `et_splay:300–437` use old
`occ_depth`, `f_depth`, `gf_depth`, each of magnitude at most N. A two-term
shift or target depth has magnitude at most 2N. `set_depth` evaluates
`d-old_depth` (at most 3N), then adds the old `min` (at most N), giving the
conservative **4N** transient ceiling. `set_depth_add` adds a shift of at most
2N to a field of magnitude at most N, giving 3N. A stale minimum produced by
`set_depth` is overwritten by `et_recomp_min` before it can become a child's
minimum in another rotation: the code recomputes the old grandparent first,
then the old parent. The other shifted children already have correct relative
minima; their operations change the coordinate origin uniformly. At each
rotation boundary the original N field invariant is restored.

`et_recomp_min` sums two bounded differences. Linking uses a single increment
and a two-term sum. `et_nca`'s longest expression is
`ret->min + o1->depth + o2->depth`, bounded by 3N; `et_below` uses two terms.
Splitting uses no larger arithmetic. These cover the signed depth/minimum
operations in the selected source; the separately undefined `DEBUG_ET` routines
are not enabled by `CHECKING_P` (`et-forest.cc:33–34`). Therefore

```text
4N <= INT_MAX, equivalently B <= 536,870,909,
```

is a sufficient local condition for the lazy-depth intermediates, and also
implies the earlier two-number-per-node DFS condition. It does not replace
pool/array/backing-allocation limits or later pass counters.

### Incremental repair is a distinct graph algorithm

When dominance is available, removing an edge may delete its dominated blocks
and repair other immediate dominators (`tree-cfg.cc:8983–9123`). Each invocation
has two sparse bitmaps indexed below N, a removed-block vector and a fixup vector,
each with at most B ordinary-block pointers. The fixup list is duplicate-free:
each selected immediate dominator contributes its distinct direct children.
There are at most E invocations which actually remove an original CFG edge.

`iterate_fix_dominators` can construct an auxiliary graph with at most B+1
vertices and at most E edges (`dominance.cc:1392–1558`). It has one hash map
with at most B+1 keys, one bitmap per vertex while deduplicating edges, and
three int arrays of B+1 entries. The graph uses obstacks; LP64 vertex and edge
payloads are both 32 bytes (`graphds.h:22–49`, `graphds.cc:47–111`). Contracting
vertices moves existing graph edges and allocates none.

`graphds_domtree` adds an int marks array, an int postorder vector and a DFS
edge-pointer stack, each with at most B+1 elements. A strongly-connected-
component calculation adds one int queue, one int postorder vector, and two
successive DFS stacks of that size (`graphds.cc:198–330,407–478`). The SCC-group
vector array has at most the current graph's vertex count of entries; the
sum of requested element counts across those vectors is separately at most
that vertex count. At most B+1 parent groups are examined per repair; corresponding
child sets are disjoint. These counts are inputs to the existing vector,
bitmap, ordinary allocation and obstack transfers, not substitutes for them.

### Convergence and the signed repair marker

`graphds_domtree` uses `int mark = 1` and increments it for every considered
predecessor during every convergence sweep (`graphds.cc:412,456`). It never
resets this marker. Let V be the auxiliary graph's vertex count and F its edge
count, with V <= B+1 and F <= E. The counter therefore needs a sweep bound,
in addition to the storage bounds above.

The relevant source invariant is the descending candidate-dominator set
representation described and implemented at `graphds.cc:407–464`:

* The entry represents `{entry}`. Before a non-entry vertex receives a parent,
  its candidate set is the universe; skipping such a predecessor is intersection
  with that universe, not treating it as an empty set.
* For a defined vertex v, its candidate set is v plus the chain of `parent`
  pointers. `tree_nca` returns the intersection of two defined chains by finding
  their lowest common ancestor (`:357–400`); its first `x == -1` arm initializes
  the intersection accumulator from the first defined predecessor.
* Processing a vertex intersects the predecessor candidates and includes v.
  Candidates descend from the universe. Updating an ancestor's parent makes
  descendant chains lose the same discarded prefix; it does not introduce a
  new candidate. Reverse postorder keeps the defined-parent chains rooted at
  entry. In the first sweep, every non-entry vertex has an earlier DFS-tree
  predecessor, so a defined operand exists and every vertex acquires a parent.

These are the usual descending-set invariants of the algorithm actually used
here, rather than an assumption that the graph is reducible. The program's
`changed` flag is set only by a parent change. Once the candidate chains stop
changing, the next sweep clears it and terminates. It cannot perform an
additional uncounted allocation/convergence loop after that sweep.

For completeness, the path-length argument bounds the number of sweeps without
using a measured convergence count. Start with entry's singleton and universal
sets elsewhere. After k complete sweeps, each candidate set is contained in the
intersection of the vertex sets on all entry-to-v paths of at most k edges:
apply the predecessor intersection to each such path's final edge, using the
previous sweep for its prefix. In-place updates and descending ancestor chains
can only remove candidates sooner. Actual dominators remain in every candidate
set. If x fails to dominate v, an entry-to-v path avoiding x exists; removing
cycles gives one of at most V-1 edges. After V-1 sweeps no false candidate can
remain. Allowing a first-definition sweep and a final unchanged sweep gives the
conservative total **P <= V+1**. The allowance is deliberately loose; no
reducibility or single-sweep shortcut is required.

There are at most F considered predecessor edges per sweep, including calls
whose `tree_nca` returns immediately. Counting the final postincrement gives

```text
mark <= 1 + F*(V+1) <= 1 + E*(B+2);
1 + E*(B+2) <= INT_MAX
```

as the sufficient local rule. The multiplication is mathematical admission-
analysis arithmetic; GCC does not evaluate that product. Its implementation
executes individual `mark++` operations, each protected by the resulting
ceiling. No marking value repeats and none collides with the initial zero
marks array. For the worst input edge ceiling E=1+3B, B <= 26,753 suffices;
smaller actual E can allow a larger B. This is a sufficient per-invocation
repair bound, not the selected whole-language capacity limit. Each repair
starts a fresh marker; the E invocation bound affects lifetime allocations but
does not multiply this marker ceiling again.

The offline package includes a transcription of the DFS/LCA/parent iteration,
checks its descending candidates and compares its final result with a direct
set solver on small reachable graphs. Those checks support the transcription;
the source invariant and path argument supply the general bound.

## Initial loop discovery

`AVOID_CFG_MODIFICATIONS` is exactly `LOOPS_MAY_HAVE_MULTIPLE_LATCHES`
(`cfgloop.h:313–321`). `apply_loop_flags` therefore skips latch disambiguation,
preheaders, simple-latch creation, irreducible-region analysis and recorded exits
(`loop-init.cc:42–79`). This invocation starts from scratch and cannot take the
existing-loop repair path (`:86–134`).

`flow_loops_find` allocates one loops container and one root loop, then at most
one loop per ordinary block which is a natural-loop header
(`cfgloop.cc:338–379,416–529`). Each loop allocation includes one loop_exit
sentinel. There are no recorded per-edge exits under these flags. The root has
no superloops vector; each real loop stores its ancestors.

Reverse completion order puts outer loops before inner loops. Each newly
allocated loop has no children when inserted; `establish_preds` therefore
allocates its ancestor vector only once, not recursively for a previously
built subtree (`cfgloop.cc:273–313`). With L <= B real loops, depth <= L and
sum of depths <= L(L+1)/2. The triangular ceiling follows by charging each real
loop its root ancestor and at most one strict-ancestor relation for each pair
of distinct real loops. Thus:

```text
loops structures = 1;
loop and loop_exit objects <= B+1 each;
permanent loop-pointer array length <= B+1;
temporary loop-pointer array length <= B;
ancestor-vector requests <= B;
ancestor-vector requested slots summed <= B(B+1)/2;
maximum per-vector ancestor count <= B.
```

`vec_alloc`/growth can reserve more than the requested number; use the vector
capacity transfer for backing bytes rather than multiplying requested slots
by eight and calling that the allocation. The quadratic aggregate is not
itself evaluated as a product by GCC; the proof/admission arithmetic that
computes it must use a sufficiently wide or checked representation.

The reverse-order int array has N entries. Its DFS uses an edge-iterator vector
with requested capacity N+1 and a temporary block flag, not another per-block
bitmap (`cfganal.cc:979–1088`). Loop-node discovery has a heap vector containing
at most B basic-block pointers per loop: each node is marked with that loop
before being pushed, so each node is pushed at most once in that loop's walk
(`cfgloop.cc:225–267`). There are at most B walks; loop `num_nodes` is a signed
int during construction and is bounded by B. This is compiler traversal over
CFG nodes, unrelated to runtime loop trip counts.

If `flag_checking` is enabled, `verify_loop_structure` recomputes dominator
information for comparison, creates a visited bitmap and N-element block
array, and repeatedly materializes `loops_list` vectors of at most B+1 ints
(`cfgloop.h:639–656,685–843`, `cfgloop.cc:1392–1747,2129–2186`). The recorded-
exit and irreducibility verifier branches remain disabled by the flags. These
checks need their own transient/lifetime allocations; this report does not
silently assume a release build. The final annotation scan has no reachable
ANNOTATE calls at O0 under the gigi frontier and creates no replacement GIMPLE.

## O0 initial SSA construction

The SSA pass is active at O0: `pass_build_ssa` tests only the absence of
`PROP_ssa`; its enclosing pass tests errors/LTO, not optimization level
(`tree-into-ssa.cc:2460–2501`, `passes.cc:405–424`, `passes.def:57–70`).
Only the preliminary address-taken transformation is guarded by `optimize`.
The final `TODO_remove_unused_locals` returns immediately at O0
(`tree-ssa-live.cc:783–795`); its optimizing liveness machinery is not part of
this invocation. Normal compilation has no variable-tracking assignments;
the no-debug setting clears that flag (`opts.cc:1472–1511`), and
`target_for_debug_bind` then returns NULL (`tree-ssa.cc:243–270`). The bounds
below are for this selected setting, not an override adding debug bindings.

### Bridge through the preceding fixup pass

`pass_fixup_cfg` occurs before SSA and must not be erased from the composition.
It can discover a noreturn call, remove a write-only store, prune an EH edge,
or append a builtin-unreachable call (`tree-cfg.cc:9972–10144`). Even without
assuming that all such opportunities were already handled, a structural bridge
is available. Let T0 bound the non-PHI statements at initial CFG-pass exit,
including its cleanup-generated labels and range sequences. The fixup visits
each original call once; each noreturn fixup can split its block once. Splitting
moves existing statements/edges and adds one block and one fallthrough edge
(`tree-cfgcleanup.cc:788–850`, `tree-cfg.cc:6307–6349`,
`cfghooks.cc:562–602`). It can add at most B+T0 unreachable calls, one per
visited block. Removing an SSA-valued call LHS may additionally request one
temporary declaration and one detached NOP per call; count these at most T0
requests (`tree-cfgcleanup.cc:820–839`). They do not create new calls to split.
The fixup's simple dead-code worklist only removes defining statements and
clears call LHS operands; without debug binds it creates no replacement
statements (`tree-ssa-dce.cc:2152–2257`). Its signed removal counter is safe
under `T0 <= INT_MAX`. Releasing an existing SSA name saves its unsigned version
in an int (`tree-ssanames.cc:692`), so also retain `Z0 <= INT_MAX` for the
incoming name-vector length.

Fixup can return `TODO_update_ssa` with its cleanup flag, but this does not
silently insert PHIs before the construction analyzed below. The incoming
renaming-needed flags are zero (`tree-ssanames.cc:164–165`), the update mapping
table is uninitialized for this function, and `update_stmt_operands` returns
while operand caches are inactive (`tree-ssa-operands.cc:1140–1154`). No virtual
operands have been built yet. The fixup paths create no SSA replacement mapping;
their name release/default-definition operations do not set the update flag.
Thus `need_ssa_update_p` stays false and the scheduled `update_ssa` returns
immediately (`tree-into-ssa.cc:3146–3151,3369–3385`).

If fixup schedules CFG cleanup, the existing loop flags still allow multiple
latches and have no LCSSA, preheader, irreducibility or recorded-exit requirement.
The cleanup's preliminary forwarder construction adds at most one block/edge
per old real loop, hence at most B. Its forced GIMPLE edge redirection returns
NULL for a new jump block (`tree-cfg.cc:6293–6300`). Remaining cleanup removes
blocks/edges. Loop repair rediscovery with these flags creates no further CFG
blocks (`loop-init.cc:200–339`). Thus sufficient SSA-entry ceilings are

```text
b = 2B + T0 ordinary blocks;
n = b+2 total blocks and block-index slots;
e = E+B+T0 CFG edges.
```

These are conservative even if the selected fixup changes nothing. The two
splitting stages need at most T0+B new basic blocks/edges and their dominance
nodes. Existing CFG/ET/vector transfers apply with b/e/n. Preheader redirection
plus subsequent forwarder removal makes at most (B+b)*e switch-label requests.
The cleanup's no-PHI restriction still excludes PHI-driven splitting. No new
switch is introduced, so across both cleanups there are at most S conversions
of the original switch identities; charge their range-sequence total as A_all.
An explicit statement ceiling at SSA entry is then

```text
t <= S + B*E + (B+b)*e + A_all + B+T0.
```

Detached NOPs from call-LHS repair are a separate lifetime term. Repairing old
loop ancestry is not the from-scratch triangular allocation row: allow at most
B^2 ancestor-vector reconstructions while removing old ancestors, plus b
reconstructions during rediscovery, each of length at most b. New loop/exit
objects during rediscovery are at most b, and the loop vector retains at most
B+b+1 index slots, including deleted-loop holes. A surviving loop's ancestor
list can be rebuilt once for each removed old ancestor; this gives the B^2
charge. During rediscovery all surviving loops are detached before being
inserted outermost first, so their child lists are empty at insertion.

This bridge prices shape changes rather than assuming earlier functions or
IPA can never refine a call's attributes. The source/gigi composition must also
carry the ordinary declaration/type/constant requests of those helpers and the
new unreachable call-graph edges; the graph counts above do not price a
call-graph object's backing allocation.

### Variables, PHIs and new names

Use SSA-entry quantities b/e/n/t from the bridge. Let X be the total expanded
operand-tree occurrences across these t statements, counting repeated uses of
a shared tree separately. Let v be the number of distinct declaration symbols
visited by the renamer, including the one artificial `.MEM` symbol; `v <= X+1`
is sufficient. Let d count real and virtual non-PHI definition operands;
`d <= 2t` under the admitted assignment/call frontier. Existing SSA_NAME
operands are preserved rather than renamed again.

`init_ssa_operands` creates exactly one `.MEM` VAR_DECL. The identifier is a
fixed interned name, not a generated source-length string
(`tree-ssa-operands.cc:232–277`). The definition scan creates one `var_info`
record per visited declaration and at most three block-indexed bitmaps per
record (`tree-into-ssa.cc:354–375,450–466,629–701`). A `var_info` is 48 bytes on
LP64: its variable pointer, a 16-byte flags/current-definition header including
padding, and three bitmap pointers (`:56–69,152–174`). The hash table's initial
request is the length of `local_decls`, which may exceed v; retain that input
separately rather than substituting the number of useful variables.

The dominance-frontier relation has at most b^2 set bits. Its construction
climbs a dominator chain per predecessor and stops on the first repeated bit
(`cfganal.cc:1639–1671`). `compute_idf` uses its insertion-point bitmap as a
visited set, so each block is pushed at most once per variable
(`:1679–1731`). Pruning only removes insertion points. The builder then creates
one PHI per retained variable/block pair, not one per definition/use occurrence
(`tree-into-ssa.cc:962–1133`). Therefore:

```text
PHI nodes P <= v*b;
PHI argument positions H <= v*e;
fresh SSA_NAME requests <= d+P+v <= 2t+v*b+v;
fresh default-definition NOPs <= v;
fresh clobber-replacement NOPs <= t.
```

The H bound sums each block's incoming degree for at most v PHIs there; the
looser P*e product is unnecessary. Initial PHI creation requests one result
SSA_NAME. Each ordinary definition requests one name. `get_reaching_def` obtains
at most one cached default name per declaration, with one detached NOP
(`tree-into-ssa.cc:1208–1230,1337–1455`, `tree-dfa.cc:356–366`). A scalar clobber
can replace its statement by one NOP and reuse that default name. PHI arguments
point to reaching names; they do not copy their defining expressions.

No name-remapping SSA update runs inside this `REWRITE_ALL` invocation. The
abnormal-use repair path in `insert_phi_nodes` requires setjmp or nonlocal
labels and is excluded. There is no data-dependent symbolic folder in these
renaming paths. The pass inserts no block or edge, and its live output statement
count is at most t+P; replacing a clobber does not increase that count.

`make_ssa_name_fn` initializes pointer/range information to NULL; it does not
allocate range objects for each name (`tree-ssanames.cc:351–420`). Source field
layout gives 72 bytes per SSA_NAME on LP64, or 88 with
`ENABLE_GIMPLE_CHECKING` (`tree-core.h:1704–1739`). Apply the tree allocator's
rounding separately. If Z0 is the SSA-name vector length on entry, the outgoing
length is at most `Z0+d+P+v`; default initialization reserves 50 pointer slots
and puts NULL in slot zero (`tree-ssanames.cc:143–164`). The existing GC-vector
ceiling applies to this total. The unsigned creation/reuse counters also need
the all-function, all-phase request sum; they are not reset by this pass.

### PHI allocation's signed shift

A PHI carries its argument-use links inline. LP64 source fields give
`sizeof(phi_arg_d)=48`, `sizeof(gimple)=40` and `sizeof(gphi)=104`
(`tree-core.h:1704–1747`, `gimple.h:220–288,472–486`). The GIMPLE header's old
word-number comments include padding that the actual fields do not require;
the field layout, rather than those comments, gives these sizes. For incoming
degree r the PHI allocator computes

```text
q = max(2,r);
requested = 56 + 48*q;
rounded = 2^ceil(log2(requested));
capacity = floor((rounded-56)/48).
```

`ideal_phi_node_len` evaluates `new_size = 1 << log2` with a signed int left
operand (`tree-phinodes.cc:139–161`). Therefore requiring
`56+48*max(2,r) <= 2^30` keeps the shift count at most 30 and the value positive.
It is equivalent to `r <= 22,369,620`; substituting e is sufficient without
computing each indegree. The size_t subtraction/multiplication and the returned
signed capacity are then representable as well.

Every insertion-point block is a join (at least two predecessors), since that
is where the original dominance frontiers place bits. For a freshly allocated
PHI, `capacity <= 2r+1`, and its requested payload is less than twice
`56+48r`. Summing gives the convenient conservative lifetime ceiling

```text
new PHI argument capacity slots <= 2*v*e + v*b;
new PHI requested payload bytes <= 112*v*b + 96*v*e.
```

Allocator rounding remains separate. Free PHI buckets may supply an older,
larger node; that storage was charged when originally allocated. Reuse does
not increase fresh allocations. Initial SSA adds no edges after PHI creation,
so its `reserve_phi_args_for_new_edge` resizing path does not run. Later CFG
passes must price that path separately.

### Operand caches, worklists and arithmetic

Operand scanning walks expression operands, not the contents of String byte
payloads. The expanded-occurrence input X covers repeated traversal of shared
reference trees. Every real scalar-use leaf contributes at most one use entry,
and each statement contributes at most one virtual use: `u <= X+t`
(`tree-ssa-operands.cc:764–999`). Definition operands use the statement's
existing slots. Each statement's temporary `auto_vec<tree*,16>` consumes the
vector transfer for its use count; summing use insertions over the scan gives u.

A persistent use entry is 40 bytes on LP64. Its slab allocator initially requests
1024 bytes, next 4096, and thereafter 16,384, including the eight-byte slab link.
The comparison is `index+40 >= payload`, so these hold 25, 102 and 409 entries
respectively, not the rounded-up quotients (`tree-ssa-operands.cc:256–364`,
`tree-ssa-operands.h:37–64`). Old entries are returned to the free list before a
statement's replacement list is built. The initial scan therefore needs at
most u entry slots; the non-debug renaming paths only change pointers or remove
entries. For u>0 a sufficient exact slab-request envelope is

```text
1024
+ (4096 if u>25 else 0)
+ 16384*ceil(max(0,u-127)/409).
```

The allocator's unsigned index never exceeds 16,376; each addition of 40 is
bounded independently of the number of slabs. Its linked list has no slab-count
index that could wrap. An all-phase allocation composition still includes
subsequent operand rebuilds and their peak live demand.

Other principal initial-SSA containers are bounded directly:

* One dense interesting-block bitmap and an array of n bitmap headers for
  dominance frontiers; frontier bit indices are below n.
* At most 3v variable-associated block bitmaps. The separate per-block kills
  bitmap uses DECL_UID indices, so it consumes the previously established
  translation-unit declaration-UID ceiling, not merely v.
* One v-element variable-info pointer vector, and per variable an IDF bitmap
  and work vector of at most n entries.
* PHI pruning uses two temporary block bitmaps, at most `2b+1` two-unsigned
  `dom_dfsnum` entries (eight bytes each), and an int work vector of at most n
  entries. The live-use bitmap prevents duplicate work pushes
  (`tree-into-ssa.cc:721–921`).
* Each of the two dominator walks allocates two n-element int arrays and one
  2n-element pointer stack, plus the previously priced reverse-order traversal
  (`domwalk.cc:273–364`). Its stack is explicit, not recursion per CFG block.
* The reaching-definition stack starts with capacity ten and receives at most
  `n+2(d+P)` pointer pushes over the whole walk: one block marker and at most two
  saved-definition entries per ordinary/PHI definition
  (`tree-into-ssa.cc:1139–1176,1463–1544,2285–2295`).

`4n <= INT_MAX` protects dominator walk's `2n` expression, DFS values and the
signed subtraction in the sort comparators. Pruning's `2b+1`, unsigned interval
midpoint `f+t`, and DFS-out increment are also covered; the relevant DFS numbers
are nonnegative, so subtracting two of them has magnitude at most their maximum,
not twice the maximum. Generic vector limits still apply to v, u, names and the
reaching-definition stack, which can be larger than n. Default-definition and
variable-info hashes consume the existing hash-table transfer with at most v
live entries each. These are source-derived container inputs and local integer
conditions; they do not by themselves bound all translation-unit heap bytes.

The result reaches the initial SSA pass and its O0 no-op unused-local cleanup.
It does not cover the following warning passes, nothrow inference, cgraph
rebuild, later SSA updates or SSA destruction. Those are later backend stages,
not hidden within the counts for this invocation.

## O0 path after initial SSA and the out-of-SSA component

O0 does not mean that the rest of GIMPLE is skipped. The three optimization
superpasses require `optimize >= 1` (`passes.cc:519–610`), and `pass_nothrow`
itself requires `optimize` (`ipa-pure-const.cc:2329–2341`). However, the local
pass group still runs, there are additional fixup/cgraph passes, and warning,
EH and mandatory lowering passes precede `pass_expand`
(`passes.def:72–122,195–207,432–461`). In particular the access warning pass
runs when `warn_free_nonheap_object` is enabled, whose common default is one.
It constructs a ranger and both dominator directions, even at O0
(`common.opt:648–650`, `gimple-ssa-warn-access.cc:2270–2275,4857–4904`). These
allocations must be supplied by the intermediate-pass composition.

The complex lowering entry is also not dismissed merely because the source
language has no complex numbers: checked Integer arithmetic uses an internal
complex result. Its scanner does not mark a complex-result call alone as work,
and a REALPART/IMAGPART extraction from a defined SSA name does not mark work
either. Complex assignments or extraction from an undefined name can activate
the pass (`tree-complex.cc:213–333`). This is a useful shape test for the bridge,
not a claim that every intermediate invocation is a no-op.

The following transfer starts at `rewrite_out_of_ssa`, called at the start of
`pass_expand` (`cfgexpand.cc:7023–7036`). Its b/e/n/t/z/p/h are **new local
inputs at that point**: ordinary blocks, edges, block-index slots, non-PHI
statements, SSA-name vector length, real PHIs and their argument positions.
They must not be substituted directly with the initial-SSA counts before the
intermediate passes are composed. No asm, bitint, debug binds, source register
variables or optional compiler switches are selected. O0 leaves
`flag_tree_ter` and `flag_tree_coalesce_vars` false; their enable entries start
at O1 (`opts.cc:600–618`). The ordinary coalescer still runs. Temporary-expression
replacement does not (`tree-outof-ssa.cc:1057–1091`).

### Backedge preparation and names

`insert_backedge_copies` visits each existing real PHI argument once. It can
insert one scalar copy/name for that position, or make one `gimple_build`
request to adjust an adjacent comparison (`tree-outof-ssa.cc:1153–1332`).
Those are alternative branches; counting both is conservative. Let A and Z_A
bound statements and names emitted by these at most h builder requests.
This exposes the same generated-matcher interface as the earlier switch
transfer, rather than treating a builder entry as one statement. Then

```text
ordinary statements after preparation t1 <= t+h+A;
SSA-name vector length z1 <= z+h+Z_A+a;
new ordinary copy assignments <= h;
new detached default-definition NOPs <= a.
```

Here a counts formal parameters, a nonvoid result and an optional static-chain
declaration; `for_all_parms` asks for one cached default definition for each
(`tree-outof-ssa.cc:919–944,1057–1065`). For a parameterless void Main, a is zero.
`copy_ssa_name` allocates one name with the existing variable/type; unlike
`duplicate_ssa_name`, it does not copy pointer/range information
(`tree-ssanames.cc:817–830`). The h copy requests therefore do not conceal
per-name range copies.

This preparation adds no CFG edge/block or PHI. Subsequent useless-PHI removal
only deletes PHIs and arguments. Each recursive removal is charged to a PHI
whose last use was just removed; it clears that use before recursing, so a
cycle that still has uses cannot trigger repeated recursion. Maximum recursive
depth is p (`tree-outof-ssa.cc:794–868`). The backedge conflict probe can hold
pointers to all current uses of one name; its temporary vector is bounded by
the total expanded operand occurrences plus h after the builder sequences.
That input needs the generic vector's signed-index limit because one selected
position is saved in an int. Statement UID renumbering also requires the final
per-block statement count to fit unsigned32 (`:1095–1113`).

### Coalescing requests and the signed cost accumulator

For this subsection use z1 and t1 after preparation, with h still a ceiling
because PHIs were only removed. `create_coalesce_list_for_region` considers
one pair per PHI argument and at most one pair per non-PHI statement.
`populate_coalesce_list_for_outofssa` adds at most three requests per name:
a default-def cost-one pair, a result-declaration pair, and a same-variable
pair (`tree-ssa-coalesce.cc:1023–1333`). Thus

```text
all pair-record requests <= h+t1+3z1;
hashed pair records <= h+t1+2z1;
cost-one list records <= h+z1.
```

A hashed record is 20 bytes (five ints); a cost-one record is 16 bytes (two
ints and a pointer). They live in one obstack. The hash additionally has at
most `min(z1*(z1-1)/2, h+t1+2z1)` distinct unordered pairs, and the sorted
pointer array has that many elements. Repeated proposals for the same hashed
pair update its record, while cost-one proposals can allocate duplicate list
entries. Do not use the distinct-pair count for both paths.

The initial hash request is `max(40,3*z1)`, with multiplication in unsigned32
(`:262–276`). Require `3*z1 <= UINT_MAX` before applying the generic hash
transfer. Name/partition IDs, the distinct-pair count and the sorted count are
also used as ints; retain `z1 <= INT_MAX` and `h+t1+2*z1 <= INT_MAX`.
The pair hash's unsigned multiplication may wrap by design; that does not
invalidate equality checking and is not a signed-capacity obligation.

The cost update needs a separate condition. `add_coalesce` only tests the
**old** cost against `INT_MAX-1`, then can execute signed `cost += value`
without a sum check (`:358–376`). Ordinary profile frequencies are in
0..10,000 (`profile-count.cc:296–308`, `basic-block.h:158`), zero becomes one,
and the largest edge multiplier is five (`tree-ssa-coalesce.cc:149–210`).
There are at most h+t1+z1 ordinary additions; the later mandatory same-variable
values `INT_MAX-1`/`INT_MAX` are assigned directly and suppress further additions.
A convenient sufficient condition is therefore

```text
50,000 * (h+t1+z1) <= INT_MAX-1.
```

This deliberately charges all ordinary proposals to one pair. It is a local
sufficient condition, not a necessary source limit. Once it holds, cost and
pair-index differences in the sort comparator are representable because both
operands are nonnegative and at most INT_MAX. Optional conflict-count sorting
is not enabled at O0; even if accounted conservatively, each count is at most
z1. The record counts and cost condition are separate from heap composition.

### Partition maps, liveness convergence and conflict storage

`init_var_map` requests one partition of z1 names and a vector of b block
pointers. `compute_optimized_partition_bases` requests one further temporary
partition with at most z1 elements. `partition_new` uses a 16-byte element and
an eight-byte header on LP64, giving `8+16m` bytes for m elements; the m=0
expression uses defined size_t wrap and evaluates to the eight-byte header
(`include/partition.h:48–68`, `libiberty/partition.c:44–116`). Union updates
class membership in place and allocates no node. Class counts stay at most z1.

Each of the two partition views requests at most two z1-element int arrays.
The base map adds one z1-int array and a z1-unsigned temporary vector.
Temporary selected/used/copy bitmaps index below z1. The same-variable hash
starts at request ten and has at most z1 entries. The retained map later owns
two more partition bitmaps, each with at most z1 bits; `pass_expand` requests
at most z1 RTL pointers for `partition_to_pseudo`
(`tree-ssa-live.cc:84–130,195–308`, `tree-ssa-coalesce.cc:1298–1333,1601–1742`,
`tree-outof-ssa.cc:970–1007`, `cfgexpand.cc:7035`). Apply vector/hash/bitmap
backing and rounding separately to these requested counts.

Liveness has two arrays of n bitmap headers, one n-int work stack and one
(n+1)-bit visited bitmap (`tree-ssa-live.cc:1025–1141`). Each live-in set only
grows during propagation. There are b*z1 possible block/partition bits, so at
most b*z1 successful growth events can schedule revisits. An already scheduled
block has its visited bit cleared and cannot be pushed again until popped.
The stack therefore needs at most b entries, and total block visits are at
most `b+b*z1`. This is a termination/counting argument, not a fixed iteration
assumption. Live-out first stores definitions and is then cleared and rebuilt;
each finished live-in/live-out family contains at most b*z1 set bits.
The enabled live-on-entry verifier allocates no auxiliary container on its
successful path (`:1564–1681`).

The interference graph has at most z1 bitmap rows and z1*(z1-1) set bits,
with symmetric storage (`tree-ssa-coalesce.cc:534–650`). Its live tracker has
at most z1 base-indexed bitmap headers; partition membership across those
bitmaps contains at most z1 current bits, plus at most z1 base-live bits.
These sets are cleared and reused per block. Counting lifetime work rather
than only peak contents, tracker insertion events are at most `b*z1+u`, where
u is the real use-operand count after preparation. Conflict construction makes
at most `2*z1*(t1+p+z1)` directed bit-insertion attempts. Each successful
coalescence removes one partition, so there are at most z1-1 conflict merges;
allow another `2*z1*z1` directed insert/copy events for all merges
(`:726–1000,1339–1470`). These event counts let the bitmap allocator transfer
charge repeated clearing and rebuilding without assuming peak bits equal
lifetime bytes. No coalescing step creates new GIMPLE, SSA names or CFG edges.

### PHI elimination supplies bounded RTL requests

`expand_phi_nodes` later traverses each incoming PHI edge using one reusable
elimination graph (`tree-outof-ssa.cc:1012–1049`). For k real PHIs in that edge's
destination, it requests at most 2k distinct graph nodes, 2k int edge endpoints,
k edge locations, k constant destinations, k constant values and k constant
locations. The DFS stack has at most 2k entries and the visited bitmap is sized
to the partition count. Initial vector requests are fixed at 30/20/10 elements
as recorded in the constructor (`:433–438`). Their retained capacity follows
the largest incoming-edge demand, not the sum of all argument counts; lifetime
vector growth still consumes the generic vector transfer.

`elim_forward` marks before recursion and pushes each graph node once.
`elim_backward` also marks before recursion. Every ordinary copy emitted
inside it, at a new predecessor in `elim_create`, or in the acyclic case can
be charged to a newly marked graph node. There are at most 2k such copies.
At most one cycle-saving temporary/copy is requested per outer stack pop,
hence at most another 2k. Constant copies use a separate group of c PHIs, so
with r nonconstant edges and c constant positions, at most `4r+c <= 4k` copy
requests suffice (`:632–784`). Both recursive traversals have depth at most
2k; this is an explicit stack obligation, not an assertion of constant stack.
Summing k over the original incoming edges gives h, therefore

```text
partition/value/temporary copy requests <= 4h;
cycle-temporary requests <= 2h;
copy_rtx requests <= 8h;
value expand_expr/store_expr requests <= h.
```

The copy_rtx bound allows two per copy; the value requests occur only for
queued constant/unpartitioned arguments. These are entries to the selected
RTL move/conversion/expression transfers, not a claim of one machine
instruction per request (`:252–430`). Their modes, operand trees and stack
adjustment work must be priced there. No replacement PHI is constructed.
Requiring `2p <= INT_MAX` is a sufficient guard for the signed graph-size and
vector iteration indices, besides the existing vector limits.

If an EH edge with queued RTL reaches a block with multiple predecessors,
`expand_phi_nodes` splits that edge. Each original incoming edge is split at
most once here: the replacement edge entering the destination is the new
fallthrough edge, not a new EH edge needing the same split. Thus this local
step adds at most e blocks and e edges. Landing-pad/label/tree allocations of
`split_edge`, final edge insertion and ordinary RTL expansion remain their
own transfers; the h copy bound alone does not bound them.

## Composition status

The useful outputs are the unchanged B/E CFG ceilings, B*E fresh-label ceiling,
explicit switch-range matcher inputs, the dominance/loop container cardinalities,
the b/e/n/t transfer through fixup, initial SSA's PHI/name/operand-cache ceilings,
the separate out-of-SSA/coalescing/PHI-copy transfer, and sufficient inequalities
for the additional signed counters. None requires
replacing GCC or adding an externally maintained backend. None yet justifies
accepting an arbitrarily large source program on the retained toolchain.

Still needed for a closed capacity predicate: reachable matcher sequence/tree
bounds; all generic vector/hash/bitmap/obstack allocator composition; exact loop
object layout and any enabled verifier helper allocation not priced above; and
the intermediate O0 warning, IPA, mandatory-lowering and SSA-update input join;
PHI-copy RTL helpers, EH splitting, remaining RTL, machine code, link and
overall translation-unit lifetime composition.
The report does not claim source correspondence or compiler correctness from
its finite arithmetic checks. No compiler, solver, Lean, full suite, clean build,
macOS or CI evidence was produced for this documentation increment.
