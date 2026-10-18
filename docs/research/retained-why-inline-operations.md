# Operational demand of the retained inlining invocation

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119), based on
`28697404fa`. The [accepted semantic refinement](retained-why-inline-refinement.md)
now has a **transformation-local structural, event and registration transfer**.
The fresh-identifier increment is at most **1,145**, including declaration
opening and task validation outside the previous 235-identifier kernel bound.
Stored delayed substitutions, type instantiation, constructor requests and
the actual wrapper/cache groups have numerical bounds and callable interfaces.

This covers the **one retained first Input_Is_Valid/cvc5 `inline_trivial`
entry**, for every unknown `inline:no` exclusion set. It does not close the
whole transformation's capacity predicate: initial shared counters/backing,
old hashcons comparands and runtime allocation/collection composition remain
process inputs. Other entries, later transformations and consumers remain
separate required work. Neither #119 nor whole-language capacity is complete.

The [offline packet](../evidence/retained-why-inline-operations-20261018/README.md)
reuses the successful capture and reviewed refinement without another native
run. It retains complete relevant Why3 sources at
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml sources at
`8eb41f72ded84df884c3671734c947f612091f84`. The existing relevant-source/runtime,
well-formedness and noncolliding-identifier premises apply. The source argument
is inspected, not machine-checked OCaml semantics. Physical resource availability
stays at the existing external boundary; no aggregate RAM gate is introduced.

## Restricted structural facts checked from the complete graph

The input has 512 task nodes, including 244 logical declarations: 17 type,
16 data, 68 parameter, 81 singleton logic and 62 proposition declarations.
The accepted all-exclusion transfer supplies 143 roots with summed term count
1,613, bound slots 168, pattern nodes 12 and applications 594. Logic bodies
contribute 418 terms and four bound slots; their formal lists total 123 slots.
The maximum root mass remains 99, including the reconstructed definition
axioms. No exclusion set is inferred from the missing Meta payloads.

The new inventory establishes the following additional restrictions on these
actual inputs and the accepted optional-hit alternatives:

- All 45 eligible environment bodies are binder-free, with no patterns.
  Every formal coefficient at every possible hit is at most one. Inlining can
  drop an argument or move it under binder-free structure; it cannot duplicate
  its binders or introduce a new binder.
- The 157 captured binding records contain eight saved substitutions. Six
  values are variable leaves; two are six-node, binder-free terms. Every value
  has at most one free-variable occurrence. Neither of the two nonunit keys
  occurs free in **any** initial saved value, including the six variable values.
- All 12 patterns are nullary constructor patterns with empty variable sets.
  Pattern opening creates no variables. `Pattern.check_compile` receives a
  nonempty scrutinee list, and every constructor argument list it synthesizes
  is empty; its `id_fresh "_"` and `id_fresh "x"` allocation paths contribute
  zero registrations (`pattern.ml:141–161`).
- All 16 data declarations have ground, parameter-free constructors. Their
  argument-type dependency graph is acyclic. Positivity and foundedness can
  therefore be bounded directly, including indirect ground data dependencies.
- Complete term, variable, pattern and signature type traversal finds maximum
  type occurrence size three and at most two type variables in a signature.
  Stored `Tyapp` values are normalized, without alias nodes. All constants in
  possible environment bodies use builtin unbounded integer type `int`; the
  hit-body smart constant constructor performs no range/float numeric check.

These are fail-closed guards in `inventory.py`, not universal facts about
Why3 or about other registered tasks. The predecessor's nonrecursion argument
includes hidden saved values, so it also justifies the empty recursive-call
graphs used below.

## Delayed substitution and opening

`t_subst_unsafe` visits ordinary children until a binder. At that binder it
updates the saved substitution map and does not traverse the raw bound body;
it does recursively map the **old saved values** (`term.ml:739–778`). A variable
replacement is returned directly, without recursively substituting inside it.
This distinction is why semantic occurrence counts alone were insufficient.

For this capture, every map value remains binder-free and at most six nodes.
The initial nonunit keys cannot affect any initial saved value, by the checked
disjointness property above. Opening subsequently introduces only fresh
variable leaves. Fresh identities cannot collide with either original nonunit
key. Composing maps therefore only renames a saved value's single possible
free leaf; it cannot expand that value. `t_replace_all` does not rewrite hidden
saved values. A changed binder is closed with an empty map; an unchanged binder
retains the input binding. The type and final substitution passes operate on
binder-free hit bodies. Thus they introduce no new delayed argument maps.

For a complete traversal path, use the independent maxima
`P = 8 + 6 = 14` for body-bound slots plus definition formals. Charge all eight
initial map entries, since original keys can propagate from ancestor maps.
The mapping traversal can add at most `P`
renaming keys along its ancestry. One subsequent validator traversal can add
at most another `P`. Validators start from the immutable mapped declaration;
they do not feed their opened result into the next validator. Even
`check_match`'s additional branch opening is independent of its normal fold.
Consequently:

```text
saved-map keys             K <= 8 + 2*14 = 36
opening-map keys               <= K + 14 = 50
nodes in each saved value   V <= 6
stored term occurrences     R <= 99*(1 + K*V) = 21,483.
```

The raw skeleton cannot exceed its fully opened term count: substitutions
replace a variable leaf by a nonempty binder-free term. There are at most 99
binding records in a formula of mass at most 99, including case branches with
zero bound variables. Charging every binding `K` values of size `V` therefore
covers unused values, repeated edges and maps preserved by equality fast paths.
These are representation bounds, not assertions that native execution retains
21,483 nodes at a time.

The recursive opening walks are the original mapper, logic termination and
task `check_match`. Each body/trigger substitution start can be charged to an
edge of its opened tree. Add six outer-definition opening sites per logic
declaration and at most 12 extra branch openings for pattern checking:

```text
opening-substitution starts <= 2*1613 + 418 + 6*81 + 12 = 4,142
recursive substitution entries <= 4,142*21,483 = 88,982,586.
```

The same envelope bounds binder-substitution updates. It is deliberately
loose; it closes the omitted hidden work without an exponential size recurrence.
The kernel's final 156 substitution entries remain a separate addend.
The packet also exports a 52,907,301,372 upper bound on free-variable scan
entries, charging each hidden update up to 99 replacement keys, each with
six nodes, plus closing/free-variable validation scans. These event counts
are not native measurements or expected running costs.

Every semantic free-variable count and every intermediate positive sum/product
used by this path is at most 99. For a binder update, the count of the replaced
variable is multiplied by at most one free occurrence in the saved value.
Removing replaced keys before unioning their contributions keeps partial sums
within the resulting semantic count. Other closing/count folds compute positive
partial sums of a formula bounded by 99. Hidden unused values obey their own
six-node/unary bound. This includes the previously unaccounted arithmetic in
`add_nt_vars` and `vars_union` (`term.ml:599–622,759–773`).

## Declaration and type routes, including reused data declarations

`decl_map` reconstructs every mapped logic/proposition declaration. Its logic
path opens the old definition, maps the body, compares before closing, and may
call `make_ls_defn`; `create_logic_decl` always calls `check_termination`
(`decl.ml:41–75,273–281,526–535,621–634`). The mapped nonrecursive singleton
has an empty call graph. The two `Hid.create 5` tables per logic declaration
remain empty: there is no descent-vector array allocation or recursive
call-list closure. The singleton variable graph cannot branch because no
`Por` pattern is present.

The inlining guard independently calls `get_used_syms_decl`, and then may open
the definition again to test/save the body. `Task.add_decl` reaches
`known_add_decl`, whose complete definition invokes used-symbol checking,
positivity, foundedness and match checking (`task.ml:145–160`,
`decl.ml:699–709,741–748,780–826`). Counting only the earlier constructor
validation would miss this second route.

The six outer-formal opening sites are:

1. `decl_map` / `open_ls_defn_cb`;
2. `check_termination`;
3. used-symbol collection in the inlining guard;
4. the candidate body opened for eligibility/environment storage;
5. used-symbol collection in `known_add_decl`;
6. `decl_fold` for `check_match`.

Some sites are mutually exclusive for a chosen metadata set; counting all
six preserves an upper bound. Full termination adds at most four body-bound
slots; full match validation adds at most 168. Hence the complete local
registration increment is

```text
235 + 6*123 + 4 + 168 = 1,145.
```

No reached path creates a named type, logic or proposition symbol. A fresh
variable's cloned name/attributes/location are shared, rather than new name
strings. `id_clone` alone is a pre-identifier; `create_vsymbol` performs the
single real registration (`term.ml:36–39,799–831`, `ident.ml:187–213`).

The 17 type, 16 data and 68 parameter declarations are reused by `decl_map`.
They still undergo task validation when added. In particular there are at most
16 **data revalidation calls and zero data-declaration constructor calls**.
The ground data check requires at most 16 initial positivity argument checks,
22 `ts_extract_pos` calls, 38 foundedness type entries and 22 constructor
entries. This includes the ground dependencies that `ts_extract_pos` visits
even when its final type-argument list is empty. No inductive declarations
are present.

`t_gen_fold` traverses stored substitution values. Used-symbol and type-variable
validators are therefore charged against `R`, not just 99: the guarded logic
fold, the task's mapped-root fold, and the two `make_ls_defn` type folds give
`(3*81 + 143)*R = 8,292,438` stored-term entries. Additional fixed-declaration
type traversal and the type/binder/pattern subloops are exported separately.
The packet includes conservative type-matching and free-variable scan bounds;
it does not collapse them into the kernel subtotal.

At hits, type instantiation scans at most the saved body's term count plus
its free-variable keys: `(156+67)*3 = 669` recursive type entries and at most
669 `Ty.Hsty` requests. Instantiation substitutes a type-variable leaf once,
so intermediate type size is at most `3*3 = 9`, including a typed body node
later erased by final term substitution. No alias expansion is hidden in this
bound (`ty.ml:126–143,234–254`, `term.ml:1083–1173`).

## Concrete request groups and shared-state transfers

The exported groups count requests/increments, not deduplicated live objects:

| Shared group | Local upper bound |
| --- | ---: |
| `Ident.id_register` | 1,145 increments |
| `Decl.Hsdecl` | 143 increments / merge-or-unique requests |
| `Theory.Hstdecl` | 244 increments / merge requests |
| `Task.Hstask` | 512 increments / merge requests |
| `Ty.Hsty` | 669 increments / merge requests |
| `Task.Stdecl`'s Hcpt table | 17,152 increments / insertion requests |

The last row charges at most 64 Patricia nodes per insertion into one of the
192 meta or 76 use/clone histories. Keys have 63 OCaml integer bits; a Patricia
path cannot branch on one bit twice (`hcpt.ml:132–158,176–275`). The value is
`64*(192+42+34)`. These are task history operations, not recursive theory export:
this invocation uses `add_tdecl`, not `use_export`.

Output known-identifier maps have at most 277 keys, the environment 45, the
unknown `inline:no` set 192, meta maps 192, clone maps 76 and each history set
268. The captured term/identifier attribute universe has 80 entries and the
invocation creates no attributes. Variable occurrence maps have at most 99
keys. Extmap tree nodes have fixed width; heights and their `+2` comparisons
are bounded by these cardinalities. List, pattern and term shapes retain the
preceding occurrence bounds. No aggregate memory ceiling is inferred.

The goal-specific `Trans.store` branches bypass the two enclosing store caches.
The selected callback creates one metadata cache (`Wtds.create 17`) and one
fold cache (`Wtask.create 63`). The former gets one lookup/set; the latter gets
at most 512 lookups and 511 sets, since the final goal is not cached. Each hit
creates a type memo table (`Wty.create 17`): at most 85 instances, with at most
156 total lookups/sets and at most five per instance. The 162 termination
tables have no insertions (`trans.ml:49–58,76–108,234–242,294–304`).

OCaml's ephemeron tables round those fresh initial arrays to 32, 64 and 16 as
applicable. `ephemeron_transfer(array, stored_entries, additions)` retains dead
entries in its input size. If `N = stored_entries + additions`, every array
is bounded by `A = max(initial_array, 4*N)`: resizing cleans first and grows
only if the retained size is at least half the old array length. It also
exports `2*A` for the resize/threshold arithmetic and old-plus-new arrays
(`ephemeron.ml:141–211`). Thus the fresh fold's individual-array bound is 2,044;
metadata/type memo arrays stay at most 32. These bounds allow arbitrary weak
clearing and do not assume the registration prefix's no-collection interval
continues here.

`weak_transfer(array, max_bucket, allocated_slots, requests)` is the separate
callable for `Weak.Make`, used by the four hashcons groups. It includes cleared
slots in the initial backing. Put `N = allocated_slots + requests`. The
inherited table may resize once from its historical oversized buckets. Every
new table starts empty; its oversized-bucket count is at most `N`, so a resize
trigger implies its old array length is below `2*N`. Therefore:

```text
outer array <= max(L0, floor(3*L0/2)+3, 3*N+3)
each bucket <= max(B0, floor(3*N/2)+3).
```

A bucket only grows when full, so its old length cannot exceed the number of
live objects then. Clearing, shrinking, reinsertion and internal rehashing do
not create another logical object. The callable exposes the multiplications
before `min`, shrink arithmetic, rover/oversize bounds and the maximum number
of equality callbacks per external request (`weak.ml:123–140,185–285`). The
caller must check those natural-number values against actual integer/array/
ephemeron capacities. The source's saturation or `min` does not make an
overflowing multiplication safe.

For every meaningful counter, `counter_transfer(initial, increment)` requires
the whole interval to fit `2^62-1`. Hash mixing and Patricia bit operations keep
their source-defined modular meaning; they are not new capacity counters.
No initial counter, backing size, live count or old comparand is invented.

## Exact boundary and verification

The local call graph is now covered through `Task.add_decl`, including reused
declaration validation and wrapper/table paths. The numerical output is a
collection of composable demand interfaces. It is **not** a complete allocation
trace or a completed process capacity predicate. The exact remaining inputs
for that predicate are:

- Initial counters and weak/ephemeron backing for the six shared groups,
  including every other caller in their process lifetime. The fresh-group
  backing is instantiated here; shared backing is a callable conditional
  transfer.
- The preexisting declaration comparands reached by `Decl.Hsdecl` collisions.
  The new candidate's semantic bound limits matched structure, but a complete
  bound on old stored frames, attribute-map enumeration and corresponding
  immutable-map work needs the shared-table projection. Local constructor
  hashing and closing comparisons have separate numerical bounds in the packet.
- Composition of these term/list/map/record requests and table rehash work
  with runtime allocation/collector representation counters. Cardinality
  bounds and term traversal events are not a byte-allocation or GC-lifetime
  theorem. The source widths, request groups and residual comparator input
  are explicit; successful source replay does not discharge this obligation.
- Other task/driver entry projections, later transformations, printers and
  serialization, and all remaining assurance-essential consumer capacities.

The full offline replay checks the frozen result and inventory, independently
recomputes the registration/opening arithmetic, tests counter fit boundaries,
exercises inherited weak backing and enumerates small ephemeron clearing
choices. A deliberate delayed-value corruption must fail at the disjointness
guard. This supplements the accepted semantic/exclusion tests without rerunning
their already-successful suite. Source/capture identities are checked; the
successful capture is reused. No tool pin, Oracle, admission rule, production
configuration or executable source changes.

Selected worker setting: GPT-6 Astra / Extra High, as assigned by the parent.
Runtime confirmation and token/cost data are unavailable. The packet records
the measured interval and focused checks. The parent owns independent review,
integration, publication, issue status and durable memory.
