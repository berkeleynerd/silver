# Three post-inline preparation stages

2026-10-20 UTC, Round 58, #119 / #153; Linux x86_64.
Under the accepted source-origin, valid-representation and guarded-mutation
premises, `eliminate_builtin`, `remove_unused` and the selected
`detect_polymorphism` calls have the following **additional** source bounds.
They compose with the accepted [R56 candidate/goal bounds](retained-why-fixed-inline-family.md)
and [R57 returned-context envelope](retained-why-returned-storage.md).
R57's 32 first-inline validator units are not reused to pay for these stages.

| Source category, all five processes | Builtin elimination | Unused removal | Polymorphism detection |
| --- | ---: | ---: | ---: |
| Direct Ident registrations | 368,499 | 365,652 | 19,176 |
| Term/opening entries | 254,039,427,771,800 | 129,527,372,113,304 | 25,434,145,117,968 |
| Free-variable scan entries | 33,251,603,935,713,224 | 20,924,910,425,522,120 | 8,713,768,023,499,336 |
| Type-node entries | 55,420,924,029,266,440 | 28,245,708,755,117,280 | 5,535,478,760,922,064 |

The combined direct Ident charge is **753,327**. Combined term/opening,
free-variable and type entries are 409,000,945,003,072;
62,890,282,384,734,680; and 89,202,111,545,305,784. Each is below 2^62.
These overlapping source categories are not native time, memory or allocation
measurements. They do not establish total later preparation/printing costs or
initial-counter-plus-demand headroom.

The [packet](../evidence/retained-why-postinline-preparation-20261020/README.md)
contains the new structural/driver inventory, per-root arithmetic, exact source
excerpts and focused checker. Accepted predecessor calculations are consumed as
frozen inputs; no predecessor checker, native target, solver, proof or capture
is replayed. The only archive-member projection added here counts the already
retained raw task chains; it does not recapture or replay the memory reader.

## Exact cut and family

The entry is the successful first `inline_trivial` return. Z3 then takes the
three named stages; CVC5 does likewise after its CE entry; Alt-Ergo takes the
first two and has **no** `detect_polymorphism` stage. The output cut is after
unused removal for Alt-Ergo and after detection for Z3/CVC5, before their next
selected transformation. There are no newly admitted transformations here.

| Process | Dtype | Ddata | Initial Dparam | Dlogic | Dind | Context Paxiom | Raw task nodes ≤ |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 26 | 21 | 124 | 158 | 1 | 243 | 1,044 |
| Put | 26 | 21 | 124 | 158 | 1 | 243 | 1,044 |
| First_Or_Default | 23 | 18 | 90 | 95 | 0 | 75 | 536 |
| Is_Message | 16 | 15 | 52 | 69 | 0 | 53 | 368 |
| Input_Is_Valid | 17 | 16 | 68 | 81 | 0 | 61 | 434 |

Each invocation adds its one goal. Every Dlogic and Dind has one head; each
Dind has one clause; each Ddata has one type head. These facts are newly checked
against the accepted declaration/typed inventories. CE can drop context
declarations; charging the raw counts covers both routes.

For each of the 561 logic definitions, the new projection peels the defining
equation's head and checks that its stored body contains no occurrence of its
own lsymbol, including saved values and triggers. The outer formal wrapper's
saved images are variable leaves. This is not the false claim that the whole
definition axiom lacks its head. Earlier definitions cannot mention a later
undeclared physical head; substituting their bodies therefore preserves absence
of recursion in this singleton family. R56's accepted optional-inline relation
also supplies this property for every returned opened body. Thus
`check_termination` opens and walks each body, but its call set has no entries:
`build_call_list`/`find_variant` do not expand a recursive call component.

All first-inline context formulas keep R57's M = 99, P = 8, V = 1 and
process-specific K, with type mass T ≤ 5/3 and arity A ≤ 7. For the unique goal,
the packet uses the particular frozen R56 root/route M, P, K and V; it never
assigns the context-only V = 1 premise to a goal. Every stage starts its
temporary validator walks from the same immutable formula fields. Such walks
are not new productive preparation episodes.

## Builtin elimination and actual returned values

`elim_abstract` in `eliminate_definition.ml:27–40` has these effects:

- A singleton Dlogic/Dind is dropped, replaced by `create_param_decl` for its
  existing head, or reconstructed by `create_logic_decl`/`create_ind_decl`
  with its **unchanged** definition/clause record. These alternatives produce
  at most one declaration per input. No defining axiom or fresh symbol is made.
- Ddata filters its type list and calls `create_data_decl` when nonempty.
  Here the list is singleton, so this retains or drops the same fixed type,
  constructors and projection signatures.
- Removed axioms/types disappear; other axioms, parameters, types and the
  unique goal are retained by physical reference.

Reconstruction is nevertheless real work. `create_logic_decl` runs termination
checking and hashes the definition. `create_ind_decl` checks free variables,
opens the clause prefix, checks positivity and head argument types, performs
the two type-free-variable folds and hashes the clause. R57's feature inventory
has no inductive let, case or epsilon; the clause-prefix branch which synthesizes
an equality for a let is unavailable. Constructor temporaries either use the
bounded input or its bounded opening; they cannot hide an uncharged new formula.

Successful Hsdecl lookup can return an older logical declaration. Its key is
still one of R57's original keys. The selected producer envelope bounds all
its hidden maps and key/image/signature types; strict equality with this
unchanged-field candidate then attaches the same M bound. This argument does
not infer hidden-storage bounds from equality. A returned Dparam has the exact
physical original lsymbol. Ddata equality compares its physical type,
constructor and projection lists, leaving no additional term field or binder
map. Unsuccessful collision comparands remain outside this interface.

`Trans.decl` sends each output through `Task.add_decl`. `known_add_decl` scans
its used symbols, including saved values, and checks the resulting known map.
Its final wrapper also performs type positivity, type foundness and match
checking. A Dlogic used-symbol scan opens its formals; its match walk separately
opens them and then all body binders. Axiom/goal match walks likewise open their
binders. The six fixed context cases have two nullary patterns and no pattern
variables. `Pattern.check_compile` therefore introduces no fresh variables:
the supplied scrutinee list is nonempty and each constructor argument list is
empty. Pattern dispatch is finite, with no nested pattern expansion.

The goal's original declaration was `Hsdecl.unique`. These stages pass its
existing declaration through; `Theory.create_decl` compares declaration pointers,
so tdecl/task reuse cannot substitute an older goal formula with different
stored fields. No new goal Hsdecl construction occurs in these stages.

## Unused removal, stored symbol folds and closure

`compute_used_ids` invokes `get_used_syms_decl` at most once per visited logical
declaration. The two Dprop dependency choices are alternatives; their common
source `Not_found` fallback is not an extra successful scan. For Dlogic,
`syms_logic_decl` opens the formal wrapper and folds the stored body. Dind and
Dprop use stored folds directly. `t_gen_fold` follows every saved **value**,
even if no opened occurrence uses it; its type callback also visits bound
quantifier types. Hidden keys are bounded by R57 even at sites that do not
visit their types. Retained Dtype aliases, Dparam signatures and Ddata
constructor argument types receive the separate type charge below.

The removal pass retains/drops whole tdecls and calls `Task.add_tdecl` on each
retained one. It creates no logical declaration and rewrites no term, but
repeats known-map/type/match validation. Its input may therefore be an old
builtin-returned context representation, covered by the previous section,
alongside the unchanged unique goal.

There is also a finite source bound for dependency propagation. Let C be the
raw context declaration count plus one goal, D the number of raw dependency
events and S the identifier-universe upper bound. The new inventories give
S = 1,090 / 1,090 / 449 / 303 / 359 and
D = 232 / 232 / 52 / 30 / 38. S counts all identifiers in R56's complete
typed inventory, overcharges two more identifiers per dependency and includes
the initial equality/integer seeds. Fresh bound-variable identifiers are never
inserted by `syms_term`; their types remain in this fixed type universe.
No selected driver directive adds a dependency meta.

The source records at most `C(S+D)` closure-map entries: a non-proposition
declares at most S identifiers, and a dependent proposition adds at most D
keys. Each recursive `add_used_ids` step with a nonempty `new_ids` removes at
least one existing closure entry. An earlier declaration may subsequently
reinsert the same key, so a once-per-key bound over the entire invocation would
be wrong. Charging **insertions**, not distinct keys, gives at most
`C + C(S+D)` entered propagation batches and
`S·[C + C(S+D)]` identifier-fold callback entries. Set unions do not enlarge the
universe. The combined family charges are 226,069,984 closure record writes
and 239,222,605,204 identifier-fold entries. Balanced-map/set work per callback
is a separate primitive-cost interface, not assigned unit native cost here.

## Detection, nonterm types and metadata

`detect_polymorphism` checks Dlogic/Dind/Dparam signatures, Dtype/Ddata heads,
and stored proposition types. It does not open definition bodies for the
polymorphism test. R57 supplies the chronological monomorphic result for Z3
and CVC5. The source then separates the goal, adds one empty-argument mono
meta and re-adds that same goal. The last operation repeats the goal's
used-symbol and match checks. No new context term is synthesized. Whether
the predicate short-circuits earlier can only reduce this full-scan bound.

The existing typed inventory includes all declared head signatures and Dtype
alias types. For each stage the arithmetic separately overcharges

```
16 · [C(A+1)T + F_type + F_constructor]
```

type entries. The accepted ground-data forest has zero type parameters and
only nullary ground type applications in constructor arguments. Its
`F_type/F_constructor` counts are 52/29, 52/29, 50/28, 36/21 and 38/22.
The trees enumerate every descendant and every constructor choice, so removal
or an early validation exception cannot increase them. They cover the
recursive type-symbol descents in task positivity/foundness, including repeated
descents along different constructor arguments. Constructor checks and ordinary
signature/alias folds fit the remaining `C(A+1)T` allowance. The factor 16
covers the constructor and repeated symbol/type-validation sites within one
stage; it is independent of the term-traversal allowances. All these types
remain fixed physical descriptors through the three-stage cut.

The new driver inventory uses R57's repaired comment/string lexer. Every
`remove allprops` rule in the selected closures has the **same theory and rule**
in the Z3 closure, including rules spelled in different top-level files.
Their generated tdecls therefore have the same source loader/environment and
clone-history connection as R54's exact Z3 event inventory. Other local rules
produce at most one meta tdecl. No `use` rule forces an additional theory.
Let B be the maximum byte length of recursively expanded active driver files;
one rule needs at least one byte. With H0 raw task nodes and Z R54 update
events, `H = H0(1+B)+Z+1` bounds the post-inline task-node count, including
one later mono meta. This deliberately loose driver-independent bound is
27,579,968 / 27,579,968 / 14,159,720 / 9,721,615 / 11,465,164.
It is a structural upper bound, not a claim that these nodes were observed.

All generic type-bearing driver metas come from exact common Z3 files;
syntax/literal/remove metas carry symbols or scalar arguments, not a new MAty.
`encoding:kept` and `algebraic:kept` are nonexclusive. R54's complete event
inventory has exactly two MAty arguments per process, both one-node ground
types, and no raw MAty argument. The same loader/clone-map argument bounds
these arguments for the other drivers. Unused removal therefore adds at most
two type-node visits for metadata per invocation. Each retained meta has at
most three arguments, and eight H argument visits cover tagged-set extraction,
dependency/keep initialization and removal tests. Generic task traversal and
add requests are separately reported in `result.json`; failed hashcons
comparands and map backing costs are not absorbed into these request counts.

The accepted [Debug control result](retained-why-debug-formatter-control.md)
excludes invocation of the supplied Pretty printers at these disabled debug
sites. Eager arguments still execute: the packet separately charges the
three cardinal calls per detection declaration (375,492 over the family).
Their native set cost remains a primitive interface. Stats wrappers and the
later meaningful solver-request printing keep their existing separate scope.

## Traversal units, direct registrations and composition

For a formula with the named M, P, K, V, T and A, define

```
K_open = K + 2P²
R_open = M(1 + K_open V)
U = M + (P+1)R_open
free_scan = MVU
type_scan = (A+2)T²U
```

The two scratch traversals conservatively cover nested opening and an
independent validator walk. R57 variable images compose only to variable
images. For the goal, R56's fixed nonleaf seed-value/free-key disjointness
preserves its own V under fresh renamings; the additional validators perform
no type substitution or nonleaf let elimination. Every scan restarts from its
immutable source rather than feeding temporary validator results into another
stage. The bound includes dead saved entries and uses M only after the
appropriate candidate or old-return attachment.

The separate context allowances are **16 / 8 / 2** traversal units for builtin,
unused and detection respectively; the goal receives **four per stage**.
`compose.py` lists the sites. Builtin's union includes termination open/walk,
inductive free/prefix/positivity/type checks, declaration hash, both operands
of a successful comparison and known-map/match opens and folds. Several sites
are mutually exclusive, leaving spare allowance. Unused removal has collection
and reinsertion symbol folds plus the match walk. Detection has its stored
proposition fold and the repeated goal insertion checks. These are fresh
charges for this cut, not the first-inline allowance.

For direct Ident counts, let A_f sum logic formal arities, B_l sum mapped
logic-body bound slots, B_i sum inductive slots, B_a sum axiom slots and B_g be
the particular goal's slots. From the actual opening sites:

```
I_builtin ≤ 3A_f + 2B_l + 3B_i + B_a + B_g
I_unused  ≤ 3A_f + B_l + B_i + B_a + B_g
I_detect  ≤ B_g
```

Stored folds, declaration hashing, metadata scans and ground-data checking
create no Ident. Nullary pattern compilation creates none. Generated Dparams
reuse original heads. This is a direct-registration bound, not an assertion
that tags or every other shared counter have the same demand.

Every process still has only its existing `E = 3N + e`, `e ≤ 2`. The
ordinary composition is raw + CE + CE for the first two stages and raw + CE
for detection. Each stage's envelope uses its maximum possible root/route
demand for the **same** e variable. Adding these envelopes is conservative
even when different maxima cannot occur in one failed prefix; it does not
grant two new interruptions at each stage. Memo hits retain covered immutable
results, and failed prefixes are dominated by full episodes. R56/R57 preceding
charges remain required and are not subtracted from this packet.

The numeric interface also reports 59,781 Hsdecl constructor requests,
186,092 tdecl constructor requests and 7,367 type-application requests. These
are requests, not successful counter increments or a bound on failed collision
chains. The output adds no new logical symbol, no new formula body and at most
one zero-argument metadata declaration per detection invocation. Thus the
returned K/R/type envelopes remain available to the next selected stage.

## Remaining scope

Unsuccessful collision comparands, primitive map/table/string/integer costs,
initial counters plus later demands, the next selected transformations and
solver-request printing remain separate obligations. Ordinary allocation,
collection and stack resources are unpriced here under the existing runtime
assumptions; this packet creates **no aggregate RAM gate or allocator-internals
proof requirement**. A finite source count alone neither proves nor disproves
operational feasibility. The prospective SIGINT-only mask and successful
guarded-mutation premises remain conditional; no launcher, Oracle, tooling,
admission or production file changes.

The next concrete interface is Z3's inductive elimination and CVC5/Alt-Ergo's
conditional definition/recursion passes. The established singleton/nonrecursive
shape should simplify the latter branches, but their scans and task rebuilding
still need charges. Inductive elimination can introduce fresh axiom heads and
new formula fields. Those validators and later printer/counter demands must be
charged separately.
The source arguments here are independently reviewable correspondence
arguments, not machine-checked OCaml semantics. Selected author model/effort:
GPT-6 Astra / Extra High; runtime confirmation and token/cost telemetry are
unavailable. The round and check records give the actual finite evidence.
