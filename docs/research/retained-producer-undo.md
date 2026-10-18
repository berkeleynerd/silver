# Retained producer scoped undo peak

Research for #119, 2026-10-18. For the current scalar/String Main fragment and
its reviewed fixed dependency frontier, a conservative source bound is:

```text
X           = 36 E_total + 7 U_Common + 1
boundaries  <= 204 (A_total + 1)
insertions  <= B_N + 15 X
undo_peak   <= 204 (A_total + 1) + 2 B_N + 30 X
```

`A_total` covers all simultaneously referenceable frontend node identities,
`E_total <= A_total` their entity subset, `U_Common` the Common pool's distinct
nonempty names, and `B_N` all allocated Why nodes for this process. The bound is
on outstanding undo actions. Repeated completed translations do not accumulate
in it. The capacity condition is that this per-list bound fits the retained
Ada container `Count_Type`; its linked-node allocation arithmetic remains the
separate [storage argument](retained-producer-storage.md). This introduces no
aggregate memory limit and no numerical threshold chosen from sample sizes.

The reduction assumes the current no-inlining/no-loop-unrolling translation
path and the [fixed dependency closure](retained-producer-fixed.md). It is not a
bound for arbitrary Ada/SPARK programs, recursive access-type completion,
user-provided predicates/invariants, dispatching or proof-inline annotations.
The retained source/tool behavior premise remains explicit.

## Why the distinct-key count is insufficient

`Gnat2Why.Util.Ada_Ent_To_Why` is the only scoped map here. The complete map
instance is `Symbol_Table` (`gnat2why-util.ads:187`). Its private undo list is an
`Indefinite_Doubly_Linked_Lists` instance (`:141–156`). At
`gnat2why-util.adb:159–219`, an insertion under a scope appends one inverse action
for a new key, or two for replacement: restore the old item and remove the new
one. `Push_Scope` appends one boundary (`:281–284`). `Pop_Scope` replays through
the preceding boundary and deletes the actions; replay calls the underlying
maps directly and appends no new undo actions (`:224–274`). Therefore:

```text
undo_length <= outstanding_boundaries + 2 outstanding_insertions.
```

Repeated writes to the same key must be counted separately. Conversely, an
insertion before any scope exists appends nothing. `Translate_CUnit` registers
symbols before translating entities/completions and generating VCs
(`gnat2why-driver.adb:1415–1446`); the ordinary registration calls at
`:1386,1405` do not contribute undo actions.

## Outstanding boundaries

The [source inventory](../evidence/retained-producer-undo-20261018/inventory.json)
finds 48 qualified `Push_Scope` call sites. One is in generic
`Generate_Expr_With_Actions`; that generic has four instances, at
`gnat2why-expr.adb:25740,25804,25970,26126`. Thus there are at most 51 distinct
scope call-site instances. `EW_Domain` has four members (`why-sinfo.ads:809–817`).
Counting all these sites, including ones excluded below, gives
`51 * 4 = 204` possible site/domain tags per frontend source identity. One
additional identity covers the process/declaration root when no expression
identity is needed.

The relevant injection is from **active scopes**, not all calls over time, to
`(site instance, frontend identity or root, domain)`. In the current frontier:

- Statement/expression recursion proceeds into a strict syntactic descendant.
  A loop body, nested expression, conditional branch or array component uses its
  own frontend node identity. Sibling traversals and separate predicate/check
  passes finish their scopes before another pass starts. The loop-unrolling and
  proof-inlining paths are disabled.
- A same-expression translation into another Why domain is charged to that
  domain. The quantified-expression term-to-predicate redirection occurs before
  its scope is pushed (`gnat2why-expr.adb:10424–10431,10594–10628`). It cannot
  create an unlimited chain of equal site/node/domain tuples.
- The ordinary expression-with-actions instance brackets its recursive
  callback and then pops (`:9961–9993`). The other three instances are the
  premise/result/runtime cut-operation traversals. Their callbacks descend into
  source children (`:25752–26180`); they do not turn sequential repeated visits
  into simultaneous equal tuples. Current fixed contracts contain no cut
  operations, but counting these instances is harmless.
- Declaration/module generators run from the driver's entity passes. They do
  not recursively start the same generator for the same entity. The recursive
  incomplete-access-type dynamic-invariant path is excluded by the frontier;
  its explicit recursive calls at `gnat2why-types.adb:473–488` are not silently
  treated as ordinary scalar translation.

Scopes with no allocations still count. In particular,
`Generate_Expr_With_Actions` can wrap a leaf that reuses an existing Why
identifier. Charging every boundary to a fresh Why node would be invalid;
the source-identity bound covers this case. These facts give
`boundaries <= 204 (A_total + 1)`. The coefficient comes from the full source
inventory and the actual domain enumeration, not an empirical maximum depth.

## Outstanding insertions

There are three relevant insertion families beyond initial registration.

### Fresh identifiers

Each reachable loop-index insertion creates a fresh `Mk_Item_Of_Entity`
identifier (`gnat2why-expr-loops.adb:738–748`). Each action-object insertion does
the same with `Local => True` (`gnat2why-expr.adb:15542–15553`). Each quantified
variable insertion uses the fresh `New_Identifier` at `:10473–10474`, installed
once at `:10594–10595`. The scalar/ordinary array item constructors eventually
call `To_Why_Id`, whose relevant branches return `New_Identifier`
(`why-gen-binders.adb:1111–1145`; `why-inter.adb:1447–1537`). Different such
insertions therefore have distinct allocated identifiers, even when they
replace the same entity key. Their combined count, including outstanding ones,
is at most `B_N`.

Main's ordinary counted-loop path has one boundary and one insertion while its
body is translated. The iterator alternative and filtered-loop replacement
path (`gnat2why-expr-loops.adb:755–765,1679–1681`) are not generated by admitted
Main loops. The fixed bodies use ordinary range loops; their quantified
contracts use the fresh quantified-variable path above.

### Binder batches that may reuse identifiers

The inventory finds 13 calls of `Push_Binders_To_Symbol_Table`. Include two
additional batch loops: `Generate_Subprogram_Program_Fun`
(`gnat2why-subprograms.adb:7643–7656`) and `Process_Info_Hiding_For_VCs`
(`why-inter.adb:1316–1341`). This gives 15 batch sites, including unreachable
ones. Each item is inserted at most once per batch. The helper itself makes one
of its two insertions per item (`why-gen-binders.adb:1430–1451`).

A raw-formal array has at most `E_total` interesting entries. Effect/variable
arrays traverse a set of direct entity mappings or opaque Common names. A
`Flow_Id` has seven variants; a direct mapping additionally has five facets
(`flow_types.ads:116–180`). Thus its full representation domain has at most
`35 E_total + 7 U_Common` relevant elements. This deliberately counts all
variant/facet combinations instead of assuming that proof callers normalized
them. `Compute_Binders_For_Effects`
unions read/write sets before constructing items
(`gnat2why-subprograms.adb:2067–2092`), and `Get_Binders_From_Variables` emits at
most one item per set member (`why-gen-binders.adb:284–365`). Concatenating raw
formals and effects can therefore use `X = 36 E_total + 7 U_Common + 1` as a bound.
The coefficient 36 adds the raw-formal entity domain to the 35-fold direct
mapping domain. The spare one also covers the synthetic unit parameter,
although that parameter has no entity/name and is skipped by the insertion helper. Splitting a String
into content/bounds does not multiply insertions: it is still one `Item_Type`.
The information-hiding map has only entity keys and is covered by `X` as well.

**The factor 15 requires a separate non-reentrancy argument.** It does not follow
from the boundary tuple count. For the retained frontier, a particular batch
site cannot have two outstanding activations:

- `Generate_Type_Completion` is called from `Driver.Complete_Declaration`
  (`gnat2why-driver.adb:302`). Transforming a Main loop bound or an expression
  does not call that declaration generator. Scalar-bound, default-init and
  ordinary dynamic-invariant completion callbacks may translate expressions,
  but they do not recursively call `Generate_Type_Completion`. The sole
  recursive local `Create_Dynamic_Invariant` path creates predicates for
  incomplete access types; such types are outside the current frontier.
- Program-function and post-axiom generators are called by the sequential
  subprogram declaration/completion pipeline. An ordinary call in a contract
  creates a Why call; it does not recursively generate the called subprogram's
  declaration or inline its body. Within expression-function completion, the
  program-function and post-axiom calls finish before the expression-body scope
  starts (`gnat2why-subprograms.adb:8788–8796,8866–8987`). Pointer-specialization,
  dispatch and inline-annotation batch sites require excluded constructs.
- The aggregate-function batch at `gnat2why-expr.adb:16088–16111` handles the
  current rank-one Character arrays. Its defining proposition handles scalar
  Character components, so it cannot recursively enter that same batch for a
  nested array component. Current fixed aggregates contain scalar
  `Character'Val` values; Main admits no user-written iterated or nested array
  aggregates. Variable-bound expressions do not change the component type.
- Information hiding brackets a top-level VC-generation pass and has no
  recursive VC-generation callback. There are no owner-provided hide/unhide
  annotations in Main or the fixed library source.

Thus at most one batch at each of the 15 counted sites contributes outstanding
insertions, giving `15 X`. Counting all 13 helper sites deliberately overcounts
excluded pointer, dispatch and lemma paths, but does not assume those paths are
nonrecursive for arbitrary Ada programs.

### Excluded temporary-rebinding families

The complete inventory additionally records 26 `Insert_Tmp_Item_For_Entity`
call sites and the direct inserts. Apart from the quantified-variable site
already charged, the remaining temporary bindings require a loop filter,
record discriminants/record aggregates, user type predicates/invariants or
DICs, access/borrowing operations, or iterated component associations. These
constructs are absent from the admitted Main/fixed translated type frontier.
The call-invariant wrapper may still push an empty scope, already charged by
the boundary argument; its insertion branch requires
`Invariant_Check_Needed` (`gnat2why-expr.adb:14576–14586`). Direct inherited and
dispatch parameter remapping requires tagged dispatch. Initial registration and
all wrapper/helper direct insert sites are accounted for above.

Consequently `insertions <= B_N + 15 X`, including replacements of existing
keys. Combining with the exact one-boundary/two-inverse-action rule gives the
stated per-list peak bound.

## Reproduction and limits

```sh
python3 docs/evidence/retained-producer-undo-20261018/check.py \
  --source-root /path/to/spark-source \
  --source-archive docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz
```

The checker verifies all 279 complete Ada source files against the retained
archive, checks the complete lexical call inventory, the four generic
instances, four domains and seven primitive undo-appending sites, and
recalculates the coefficients. It does not claim that lexical counting proves
reachability or non-reentrancy: those are the source arguments above. No new
compiler, debugger, solver or proof process was run for this bound.

Changing the admitted type/construct frontier, enabling inlining/unrolling, or
adding recursive declaration/aggregate generators requires reviewing these
injections. The bound remains conditional on the retained source/tool behavior
premise; no historical binary attestation is introduced.
