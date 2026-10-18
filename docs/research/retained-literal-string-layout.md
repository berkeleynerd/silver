# Cold Standard.String size functions and discard boundary

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119) and
[#131](https://github.com/berkeleynerd/silver/issues/131).
The first ordinary, complete conversion of Standard.String creates **two
size functions**, one for bits and one for bytes. The XUT object record and
optional XVE encoding create no additional size functions. Both functions
are gimplified before Main, remain registered during Main's initial
lowering, and are removed at the end of initial call-graph analysis. They
receive no ordinary lowering, IPA, RTL expansion or assembly emission.
Their removal does not undo the function-definition, symbol UID or
symbol-order increments.

This closes the concrete layout decision isolated by the
[previous frontier](retained-literal-gigi-warning-residual.md), under the
same retained source/behavior and selected invocation premises. It does
not close the full imported frontier, R, helper allocation costs or the
aggregate capacity conditions. The [evidence packet](../evidence/retained-literal-string-layout-20261018/README.md)
pins GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and the historical
Silver inputs. Its offline checks support the source argument; no native
observation or machine-checked C++ semantics is claimed.

## Inputs and the cold conversion

Retain exactly one `with Silver_IO;`, Main/SPARK shell, C >= 1 qualified
literal Put/Put_Line calls, N >= 0 nulls, no declarations/use clauses and
each literal length <= INT_MAX. The ordinary complete-entity cache
(`decl.cc:400–445`) returns the existing String conversion on subsequent
profile/type references. String is neither incomplete/private nor a cloned
record subtype, so neither cache exception applies. Thus this is one cold
conversion, independent of C, N, which of the two procedures is first,
and repeated calls. It is not a claim that every other imported constructor
has now been counted.

Standard.String is one-dimensional, unconstrained, Positive-indexed and
has eight-bit Character components and byte alignment
(`cstand.adb:895–939,1040–1053`). Standard entities are fresh, zeroed entities
(`cstand.adb:1819–1861`; `atree.adb:1157–1176,1887–1912`), and neither their
common constructor nor Positive's setup sets the fixed-lower-bound flag.
Its declared `Flag` field defaults to zero
(`gen_il-gen-gen_entities.adb:508`). Positive's Esize equals the signed
Integer base Esize, so its GCC representation stays signed 32-bit despite its
positive RM lower bound (`decl.cc:1901–1984`).

Let l and u denote the readonly LB0/UB0 component references through
P_BOUNDS and the fat-pointer PLACEHOLDER; let L=(u64)l, U=(u64)u and
Q=(u >= l), comparing signed 32-bit values. The readonly, nonvolatile
reference chain has no side effect or SAVE_EXPR
(`decl.cc:2399–2435,7320–7377`). The index has low L and high
H=`Q ? U : L-1`; the latter uses `build3`, not a folding ternary builder.

The following is the relevant folded shape, allowing ordinary arithmetic
reassociation and swapping/inverting the conditional arms:

```text
byte extent: Q ? ((U-L)+1) : 0
bit extent:  Q ? (u128((U-L)+1) * 8) : 0
```

`stor-layout.cc:2660–2716` computes `1+(H-L)`, then both extents before
either is passed to `variable_size`. `size_binop` delegates nonconstant
operations to the folder (`fold-const.cc:2092–2136`). Subtracting L
distributes over H: L has no side effects and neither arm of H is constant;
the false arm `(L-1)-L` contracts to -1. The next +1 yields zero on that
arm. These are exactly the guards at `fold-const.cc:7019–7103,11000–11140`
and contraction rules at `match.pd:4362–4383`; this distribution does not
insert a SAVE_EXPR. Multiplication by one disappears.

Neither widening conversion can narrow the two-bound subtraction:
`match.pd:4534–4547` requires result precision <= operand precision, which
fails for 64 versus 32, and `9687` onwards concerns narrowing an arithmetic
result. The conversion to bitsizetype distributes over the conditional
(`fold-const.cc:9258–9322`); the false branch becomes a constant, so the
guard that pulls two conversion branches back out is false. Constant
multiplication by eight distributes again. `initialize_sizetypes`
(`stor-layout.cc:2908–2980`) selects 64/128-bit size/bit-size types on this
target. `round_up` leaves the byte extent alone (alignment 1) and the bit
extent alone (both conditional arms are multiples of 8).

The GENERIC conditional matcher candidates cannot replace this by a
single-bound leaf: the condition is a comparison of two distinct bound
references; the nonzero arm is their widened difference plus one (and,
for bits, its widening and multiplication), not a comparison operand,
truth-valued arm, repeated arm, nested conditional, or a sign/absolute
value pattern. The general-looking rules at `match.pd:7091,8428,8678–8684`
are GIMPLE-only. The remaining `fold_ternary_loc` cases
(`fold-const.cc:12893–13240`) either have the same excluded shapes or
invert/swap arms. No selected integer fold introduces a call or SAVE_EXPR.
This is a source case argument; the checker does not simulate GCC folding.

## Exactly two helpers, no canonical or record multiplier

`finalize_type_size` calls `variable_size` independently for bits and bytes
(`stor-layout.cc:2011–2016`). Both extents contain placeholders and a
two-bound conditional. `skip_simple_constant_arithmetic`
(`tree.cc:4220–4243`) stops there; it cannot reach a CALL_EXPR or a single
self-referential COMPONENT_REF. There is no SAVE_EXPR to abort copying.
Consequently each call takes the constructor in
`self_referential_size` (`stor-layout.cc:155–265`).

`find_placeholder_in_expr` (`tree.cc:4490–4556`) retains the outer LB0 and
UB0 references, coalesces repeated occurrences, and does not separately
retain the nested P_BOUNDS field. Each function therefore has two signed 32-bit
parameters, a result of u128 or u64 respectively, and one
`RETURN_EXPR(MODIFY_EXPR(RESULT_DECL, extent))`. Substitution leaves a
call-free scalar expression with one two-arm conditional. The byte extent
was computed before the bit-size replacement, so the second helper does
not call the first. Each layout result becomes its own two-argument call.

There is exactly one XUA array layout. Fresh GCC types are self-canonical
(`tree.cc:1365–1373`). Character's special constructor makes a fresh 8-bit
integer type; its unsigned debug copy does not replace its canonical type
(`decl.cc:1731–1753`; `utils.cc:2114–2151`). Component sizing 8/alignment 8
does not change it (`decl.cc:5540–5688`; `utils.cc:1522–1590,1698–1750`).
`create_index_type` uses a **nonshared** range, which returns before the
shared/canonicalization branch (`utils.cc:2861–2871`;
`tree.cc:7460–7520`). Both actual inputs to `build_array_type_1` are thus
self-canonical. Its recursive canonical-array condition is false
(`tree.cc:7575–7642`). Later layout calls see an already-sized array and
return (`stor-layout.cc:2449`).

For XUT, `build_unc_object_type` creates BOUNDS followed by ARRAY and
calls `finish_record_type(...,0,true)` (`utils.cc:4562–4583`). BOUNDS is
eight bytes; ARRAY starts at byte 8. `layout_decl` copies the existing bit
and byte calls into ARRAY and each `variable_size` immediately reaches
the CALL cutpoint (`stor-layout.cc:661–813`). `place_field` advances the
variable field using its **byte** size, leaving bitpos zero
(`stor-layout.cc:1668–1744`). If B denotes the byte-size call, XUT's raw
byte size is `8+B`, and raw bit size is `8*u128(8+B)`; alignment 32 produces
only additions, casts, multiplication, and constant masks around that
single B. These operations remain constant-sided chains under folding.
The record's final `variable_size` calls therefore also reach B and
return without construction. There is no sum of independent bit and byte
calls and no remaining conditional outside the call.

The extra `variable_size` calls in `finish_record_type` are guarded by
rep_level==1; this call uses 0 (`utils.cc:2411–2426`). Its subsequent
Ada-size arithmetic is not installed for TYPE_CONTAINS_TEMPLATE. If the
XVE debug branch executes, it assigns constant record sizes directly,
does not invoke the record finisher, and copies each old field size with
an explicit gap position (`utils.cc:2497–2685`). The variable field uses
the old bit-size call as the supplied size argument, but its replacement
type is a pointer. `create_field_decl` installs that argument in DECL_SIZE
only inside its INTEGER_CST bit-field guard (`utils.cc:3224–3345`), which
the nonconstant call fails. `layout_decl` therefore takes the pointer's
constant 64-bit/8-byte sizes. Thus XVE adds zero size functions even if
encodings ALL is selected. The final UNCONSTRAINED_ARRAY_TYPE has no TYPE_SIZE, so the
common variable-size/global-size-variable branches are not entered
(`decl.cc:4660–4788`).

## Gimplified, registered, then discarded

`finalize_compilation_unit` invokes `finalize_size_functions` **before**
`analyze_functions` (`cgraphunit.cc:2562–2594`). The former allocates each
function structure, gimplifies the body, and calls `finalize_function`
(`stor-layout.cc:275–292`). These are two real post-prefix function
allocations and gimplifications, even though their code is never emitted.

The constructors make both functions private, static, artificial,
debug-ignored and declared-inline, without user attributes, constructors,
destructors, aliases, nesting or asm references. The selected invocation
does not enable keep-inline-functions, profiling/instrumentation,
sanitizers, OpenMP/offload or debug emission. `common.opt:2302–2304`
declares keep-inline without a nonzero initializer; the retained selected
frontend argv contains no enabling option. With that setting,
`finalize_function` cannot force them out: the O0/static/no-reorder
force-output arm explicitly excludes DECL_DECLARED_INLINE_P
(`cgraphunit.cc:452–519`). `needed_p` has no TREE_USED exception and is
false (`cgraphunit.cc:240–277`). They are not queued through
`cgraph_new_nodes`: this path uses `finalize_function`, not `add_new_function`.

The accepted Main ingress has only literal descriptors and calls to the
selected external output procedures; it has no dynamic size calculation,
address of either helper or initializer containing one. Bound-pool
initializers contain constants. Type size metadata does not itself make
a graph reference: initializer reference walking stops at types and
declarations (`cgraphbuild.cc:44–111,408–418`), while the body graph pass
records actual GIMPLE calls/addresses/loads/stores and EH references
(`cgraphbuild.cc:214–395`). The helper bodies contain no calls or addresses
of functions. Thus neither helper gains a caller/referrer during Main's
analysis. This uses the accepted Main shape, not the old unproved claim
that no synthetic functions are constructed.

Initial analysis queues only needed/referred symbols and their closure.
Neither helper reaches `cgraph_node::analyze`, so neither executes
`all_lowering_passes` (`cgraphunit.cc:675–707,1180–1355`). At the removal
loop, each has null aux, no referrer and no asm reference, so `remove()`
is called (`cgraphunit.cc:1376–1417`). Removal unregisters the symbol and
releases its body and node (`cgraph.cc:2262–2370`). The first analysis
finishes before the later analysis/early-debug/`compile()` pipeline.
Accordingly the cold helpers contribute:

| Phase/counter | Exact cold contribution |
| --- | ---: |
| Created size-function declarations / initial gimplifications | 2 / 2 |
| Additional registered live function nodes during initial Main lowering | 2 |
| Helper executions of ordinary lowering / IPA / RTL / assembly | 0 / 0 / 0 / 0 |
| Live helper nodes after initial unused-symbol removal | 0 |
| Persistent symbol next-UID / order increments | +2 / +2 |
| Persistent function-definition-number increments | +2 |
| Private size-function name sequence increments (`fnno`) | +2 |

Symbol registration increments cgraph_max_uid/order; unregister/release
only unlink/decrement live count (`cgraph.h:3138–3196`). Function allocation
calls `get_next_funcdef_no`, which increments the separate counter
(`function.cc:4812–4815,4838–4867`). Neither removal path rewinds them.
`self_referential_size` consumes `fnno++` while constructing each private
SZ name. These names are created, even though no corresponding label or
body is emitted. This packet does not identify that private sequence with
the function-definition counter or claim a new aggregate declaration-UID,
temporary-name, summary-ID or label-number bound.

## Exact remaining joins

The concrete result repairs the missing **extra emitted helper-body**
premise for this String route; it does not by itself restore every complete
emission formula. The parent must integrate the two allocations/initial
gimplifications/registrations into the incoming shared-pool state, account
for the extra registered nodes during Main's initial lowering, and carry
the persistent UID/order/function-definition increments through the graph
and assembler-name/CFI-label consumers. Later passes that enumerate live
functions receive zero such helpers; earlier maxima and monotone counters
must not be reset to their old values. Any summary machinery touched
before removal needs its own constructor/hook check.

No helper warning-map subtotal is exported here. The candidate suppression
and copies in the nonvoid return/conditional lowering remain subject to
the reserved-location/ad-hoc-location argument identified in the prior
packet. Full **R remains None**. Helper/tree/function allocation events,
bytes, transient backing and collection effects also remain uninstantiated.
The ordinary imported declarations outside this cold layout still need
their exhaustive subtotal. Preserve I=2C+N+R, J=2C+1, Main-local
W<=9C+3N+1 and helper subtotal 8C in their accepted scopes; no aggregate
capacity condition is changed by this packet.

Selected agent settings: GPT-6 Astra / Extra High, assigned by parent;
runtime confirmation and token/cost evidence unavailable. Round start
20:01:46 UTC; completion/elapsed time is recorded in the check result.
Native executions: zero. This round resolved the two-function layout and
discard boundary, with persistent counter corrections; independent review
is pending. Only this research note and its evidence directory were edited.
