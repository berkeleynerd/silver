# Retained inlining comparand capacity

2026-10-18, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119), based on
`0e07ab375aba4064bc323a2bd601d043e3e83195`.

The complete retained declaration table closes the **source-operation and
representation transfer for unsuccessful `Hsdecl` comparands** at the first
Input_Is_Valid/cvc5 `inline_trivial` entry. The same composition covers successful
comparisons, definition-close strict equality, shallow term similarity and
candidate strict hashing. It joins the
[accepted representative state](retained-why-inline-representative-state.md)
and its attached local arithmetic; the earlier packets remain frozen.

The bounds include **145 possible strict table comparisons / 2,032 term-pair
entries**, another **81 definition-close comparisons / 418 entries**, and
**1,911 strict-hash term entries**. All stored constants reachable by these
comparators have immediate integer values. No undecoded custom payload is
needed to instantiate this comparator input.

These are source events and data-structure dimensions, not native elapsed time,
instruction counts, aggregate allocation or physical RAM. Existing relevant
source/runtime, well-formedness, valid-cache and noncolliding-freshness premises
remain. Runtime primitive lowering, allocation/collector composition, other
shared states and downstream consumers remain open; complete transformation and
whole-pipeline flags stay false. Physical resource availability remains external.

The [offline packet](../evidence/retained-why-inline-comparand-capacity-20261018/README.md)
contains the complete classification, raw profiles, pure transfer functions and
callable joined result. No native target, capture, debugger, compiler, build,
proof or solver was run in this round. No production source, Oracle, admission
rule, tool pin or configuration changed.

## Which old values can enter formula comparison

This starts from all **6,704** distinct retained nonempty objects in all 5,003
buckets. The earlier complete-state/graph checks are replayed. Weak clearing
can remove objects, and cannot add a missing comparand. The accepted local
insertion and no-foreign-insertion arguments remain applicable.

`Hsdecl.equal` first distinguishes declaration constructors. This invocation
reconstructs singleton `Dlogic` and `Dprop` declarations only; goals use `unique`
and do not query the weak table. Proposition formulas are reached only after
kind and physical proposition-symbol equality. For logic lists, however,
`Lists.equal` calls `List.for_all2`: **a matching first symbol can enter its
formula comparison before a later length mismatch**. Merely comparing entire
symbol-list keys would be insufficient for cost coverage
(`decl.ml:350–366,411–419,621–634`; `lists.ml:38–46`).

The new classification uses that first-symbol precondition and checks every
initial logic list. All **1,203** initial `Dlogic` objects are singleton lists.
Consequently exactly **145** old objects can reach strict term comparison:
the 142 non-goal input objects and the three old propositions previously
excluded from *successful returns*. Those three remain included in this cost
transfer. The other **6,559** objects are rejected before their formulas or
other declaration payloads are traversed. Types/data/parameters/inductives have
a different constructor; other logic/proposition declarations fail the first
symbol/kind test. Their custom constants are therefore not comparator inputs.

Each mapped key occurs once. A locally inserted candidate keeps its key and
cannot pass a later request's symbol test. An initial object can therefore
enter strict comparison at most once over this invocation. `find_or` advances
its slot cursor after every failed comparison, and also after a successful
comparison whose subsequent weak `get` loses the object (`weak.ml:272–293`).
There is no retry of the same slot. Shallow `get_copy` preserves the original
declaration's node pointer and introduces no new formula representation.

The accepted wrapper argument still applies: theory declaration equality is
physical, and normal task predecessors cannot be goals. Other wrapper tables
do not inject a recursive goal-formula comparison into this fold. This does
not instantiate those tables' backing/counter states.

## Stored inputs and generated candidates

The raw profile reads complete formulas and **unused** saved values, independently
of the opened-coordinate walk. It checks finite term/list/map traversals, map
ordering, stored heights/balance, variable-tag identity, nullary patterns,
type-tag access, attribute sets, location payloads and constants. Repeated
stored edges are counted. A separate frame walker implements `descend`'s
remaining-frame rule and includes all trigger terms/groups and branch bodies.

Across the 145 possible old formula comparands:

| Dimension | Maximum |
| --- | ---: |
| Opened term occurrences | 91 |
| Opened bound slots | 8 |
| Opened patterns | 2 |
| Trigger groups | 3 |
| Active delayed frames | 4 |
| Saved-map entries in one map / stored height | 6 / 4 |
| Attributes at one raw term | 1 |

The goal is additionally profiled as an input for candidate generation; it has
up to five frames and six raw term attributes. No trigger group is empty in
the inspected formulas, although the transfer functions separately charge
group cursors and permit empty groups when their counts are supplied.

The union of all 143 input formulas and the possible old comparands contains
2,034 stored term objects and 38 constant objects. Every constant has the
`ConstInt` constructor, an immediate literal-kind discriminator, and an
immediate integer between **−2,147,483,648 and 2,147,483,647**. The full reachable
formula subgraph contains 13,082 blocks and has only strings as opaque blocks.
The full table graph does contain custom blocks; they were not discarded by
assuming the entire process has only small integers.

Generated terms preserve constants: relocation and substitution copy the
constant payload, and hit type mapping reconstructs `t_const c ...` with that
same `c` (`inlining.ml:21–40`; `term.ml:738–778,1107–1174`). The accepted body
contract confines this route to builtin integer constants and excludes
range/float conversion. Thus no real, string or custom-number comparison is
introduced by a fresh candidate. This is specific to this retained invocation.

`Constant.compare_const ~structural:true` compares the literal kind and then
calls `BigInt.compare` on two immediate integers. Its real normalization and
exponentiation path is unreachable (`constant.ml:22–32`; `number.ml:48–64`;
`bigInt.ml:12–16`). The exported vector counts those runtime primitive calls
and their operand representations; it does not claim a new proof of the
Zarith/native primitive implementation.

Types are compared by `ty_tag`, variables/symbols by identity or identifier tag;
no type/signature/alias traversal occurs in strict comparison
(`ty.ml:75–82,300–303`; `term.ml:34–36,63–65`; `wstdlib.ml:61–99`). Locations
are compared as three immediate integers, without resolving file tags to
filenames (`loc.ml:67–71,110`). The checker follows only field zero of a present
option, as the source option match does. Some retained option-shaped blocks
have extra payload words; their allocation shape is not inferred to be exactly
one word, and those words are not location-comparison inputs.

The accepted candidate envelope supplies at most 36 saved-map keys and 80
attributes. For a logic declaration, the comparator/hash sees the **complete
definition axiom**, while the accepted semantic row describes its body.
`make_ls_defn` adds a head application, one variable per formal, equality/iff,
and at most one quantifier. The new per-row bound therefore takes the maximum
of the complete original axiom and `body_nodes + arity + 3`; it adds the
formals to the bound-slot ceiling (`decl.ml:41–75`). Proposition rows already
describe the whole formula. The resulting complete-formula maximum is 91.

Inserted bodies are binder-free/pattern-free with formal coefficients at most
one. Substitution consequently does not duplicate existing binders, patterns
or trigger groups, nor introduce another trigger-bearing body. An unchanged
definition may keep its original outer quantifier/triggers; a rebuilt one has
an empty outer trigger list. The corresponding original full-formula trigger
count therefore bounds the candidate, including all optional metadata misses.

## Strict comparison and hashing transfer

For each side let `N,B,P,G,D,K,A` bound opened term occurrences, bound slots,
nullary patterns, trigger groups, active frames, saved-map keys and attributes.
`strict_transfer` returns the following conservative vector, with
`Q=min(N_left,N_right)`:

```text
term-pair entries             <= Q
frame probes                 <= Q*(D_left+D_right)
map lookups                  <= 2*frame_probes
map tree entries             <= 2*Q*sum(D_side*(max(B_side,K_side)+1))
bound-map additions          <= B_left+B_right
bound-map node constructors  <= 4*(max(B_left,B_right)+1)*(B_left+B_right)
attribute enumeration nodes  <= Q*(A_left+A_right)
attribute helper entries     <= 3*Q*(A_left+A_right+2)
list cursor tests            <= 8*(Q+B_left+B_right+P_left+P_right+G_left+G_right+1)
```

Constructor recursion compares matching prefixes; mismatch, attribute/location
rejection and the physical shortcut can only stop earlier. A substituted
variable stands for its opened replacement, so visiting that replacement's
root is already paid by an opened occurrence. `descend` consumes a frame before
following its saved value; it never reuses that frame to substitute the
replacement again (`term.ml:266–281,325–401`). This bounds probes even when a
map contains unused values. Each probe checks the bound map and, if needed,
the saved map. Ordered lookup descends one tree path (`extmap.ml:502–507`).

Binder creation adds at most the opened bound slots. Nullary patterns add no
bound variables. `Extmap.add` visits one path; each balancing return constructs
at most three nodes, covered by the displayed four-times allowance
(`extmap.ml:105–161`). The largest bound map has eight keys, the largest saved
map has 36, and the largest bound index plus one is nine. Their natural
height/index arithmetic fits the 63-bit signed OCaml integer representation.

`Sattr.compare` uses tag-keyed map enumeration; each operand's map node is
enumerated at most once, without comparing attribute strings
(`extset.ml:71–72`; `extmap.ml:359–378,492`; `ident.ml:20–26`). The list allowance
includes application arguments, binder lists, branch lists, nullary pattern
lists and both trigger-list levels, including their terminal tests. Pattern
and trigger counts are explicit rather than inferred only from term count.

`hash_transfer` uses the same one-sided frame/map/binder argument for
`t_hash_strict` (`term.ml:420–505,536–539`). It separately charges attribute
folds, immediate discriminant hashes, constant hashes and modular hash mixing.
The constant hash input has two ordinary blocks and two immediate fields,
four value nodes in total. There is no custom hash callback. OCaml hash mixing
retains its source modular semantics; it is not treated as natural-number
arithmetic that must avoid wrapping. Rehashing uses cached hashes and does not
call the old declaration's hash function (`weak.ml:215–227`).

The joined vector gives:

| Work | Strict table equality | Definition closing | Candidate strict hash |
| --- | ---: | ---: | ---: |
| Invocations | 145 | 81 | 142 |
| Term entries/pairs | 2,032 | 418 | 1,911 |
| Map lookups | 130,454 | 24,272 | 108,454 |
| Map-tree entries | 4,641,324 | 898,064 | 4,012,798 |
| Bound-map node constructors | 11,196 | 3,952 | 5,080 |

The two strict comparison groups sum to 2,450 term-pair entries. They register
no identifiers and issue no hashcons requests. The accepted **1,145** local
identifier increment remains unchanged.

Shallow `t_similar`, called by `t_attr_copy`, is also distinct from recursive
strict equality. It compares type identity, constructor/symbol identity and
at most seven application children or two case-branch pointers; its constant
case has the same immediate-integer profile (`term.ml:404–418,654–659`). The
accepted hidden-substitution and kernel entry counts give at most
**88,985,261** `t_attr_copy`/`t_similar` calls: hidden substitution entries plus
replace, unfold, relocate, type-map and post-type-substitution entries. Each
source route performs at most one such copy per charged entry. This large
upper bound is inherited conservative arithmetic, not observed work. The
packet exports its shallow pointer/list/constant comparison vector separately.

## Joined weak-table dimensions and remaining boundary

The goal takes `unique`; exactly 142 of the 143 mapped-root requests can call
`merge`. Initially `oversize=0`, `limit=7`, maximum bucket length is seven and
outer length is 5,003. An insertion increases `oversize` at most once; shrinking
only decreases it. Before any first resize it is therefore at most 142, while
the resize trigger requires more than `5003/2=2501`. This excludes that first
resize inductively (`weak.ml:117–121,185–263`).

With no resize, an individual bucket contains at most its seven initial slots'
objects plus all 142 new candidates: 149 live objects. A growth occurs only
when every old slot is occupied. Its length is at most
`floor(3*149/2)+3=226`; shrinking does not increase length. A comparison scan
reads one fixed bucket, and shrinking/insertion occurs only after that scan
returns. The initial projection has no duplicate objects, and shrinking keeps
that invariant in the installed replacement bucket. Thus total equality
callbacks, including shallow rejections, are at most
`142*7 + 142*141/2 = 11005`.

The callable exports the 5,003 outer length, 226 bucket length, at most 32,092
weak-copy attempts and 11,005 shallow three-word declaration copies, plus
growth/shrink integer conditions. The inherited runtime array/ephemeron
representation conditions remain explicit; this is not a physical allocation
guarantee. The already captured declaration counter still ends at most
`6836+143=6979`.

`compose()` verifies the frozen input identities and complete table, performs
the prefix-sensitive raw classification, joins its groups to the reviewed
representative projection, and instantiates the transfers for every candidate
row. It exports the prior attached demand vector alongside these new bounds.
Numeric arguments to a pure transfer are never accepted as proof that an
arbitrary table has this retained profile.

No additional initial comparator input is needed for this exact entry. The
remaining boundary includes other shared tables/counters and their lifetime
callers, native primitive lowering, closure/stack/allocation/collector
composition, other fixed entries and downstream transformation/printing paths.
This source argument is inspected and checked by evidence scripts, not a
machine-checked operational semantics theorem. It closes this comparand gap
without closing #119 or the complete inlining/pipeline capacity conjunction.

## Validation and round record

The focused checker replays the joined result and every per-comparand profile.
It rejects a new matching logic prefix hidden behind a later list-length
mismatch, an omitted initial object, and a custom integer hidden in an unused
saved value. It checks remaining-frame substitution and bound precedence,
larger-map/attribute propagation, rejection of Boolean numeric substitutes,
and the exact no-first-resize threshold. The synthetic decoder/frame fixtures
are not native program observations.

The [round record](../evidence/retained-why-inline-comparand-capacity-20261018/round.json)
records direct elapsed time, final focused-check timing and review inputs.
Selected worker: **GPT-6 Astra / Extra High**, assigned by the parent. Runtime
confirmation, token use and monetary cost are unavailable. Parent owns
independent review, integration, publication, issue status and durable memory.
No GitHub, CLI-memory or harness write occurred in this subthread.
