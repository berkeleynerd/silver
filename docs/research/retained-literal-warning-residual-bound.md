# Literal original-gigi warning residual bound

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
For the retained literal-output family, **R <= 5**. This supplies the
previously missing source input to the accepted
[warning-map transfer](retained-literal-warning-map.md):

```text
I = 2C + N + 5
J = 2C + 1
incoming live/occupied <= 4098 + 2C + N
outgoing live/occupied <= 4099 + 4C + N
post-prefix warning-map GGC requests <= 4C + N + 7.
```

Five is a conservative ceiling on actual `nowarn_map->put` executions,
including replacement puts; it is not a measured population or an exact
insertion count. It remains valid when the map already contains dispositions.
The [callable and evidence](../evidence/retained-literal-warning-residual-bound-20261018/README.md)
substitute the derived bound into the frozen transfer without editing it.
This closes this warning residual, not original-gigi allocation, the complete
gimplifier, collector, imported capacity frontier or whole-pipeline capacity.
Independent review of this packet is pending.

## Scope and counted interval

Use the accepted selected recognizer and current library semantics:
exactly one `with Silver_IO;`, the Main/SPARK shell, C >= 1 qualified direct
literal Put/Put_Line calls, N >= 0 null statements, no declarations/use
clauses and each literal length <= INT_MAX. Retain the selected non-LTO,
O0, no-debug, no-instrumentation/sanitizer/offload configuration and existing
source/installed-behavior premise. The source identity is GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

R covers every other put after the prefix stop immediately before
`Compilation_Unit_to_gnu` and before **entry** to Main's `gimplify_body`.
The only excluded original-gigi sites are the already charged at most
2C+N local index/array TYPE_DECL and null LABEL_DECL suppression calls.
Main's own initial gimplification retains its separate J=2C+1 transfer.
The two generated size helpers are inside R's interval because their
initial gimplifications precede Main.

## Complete selected constructor frontier

The frontend/source-to-Main result and
[local metadata exhaustion](retained-native-ingress-bound.md#main-local-declaration-and-metadata-exhaustion)
exclude source objects, nested bodies, checks, handlers, contracts at native
execution, copy-in/copy-out, dynamic allocation and cleanup. In particular,
the fixed library's Static ghost state and Static postconditions do not
make native Main reference those variables or their expression dependencies.
The visible library procedures have one IN String parameter and void return;
they are ordinary Ada procedures, not aliases, intrinsics, foreign procedures,
methods, subprogram-type declarations or procedures with address clauses.

`Compilation_Unit_to_gnu` constructs the one potential elaboration procedure,
processes the context, then Main (`trans.cc:5967–6097`). Main acts as its own
spec, so there is no separate spec compilation-unit traversal. The explicit
with uses `get_namespace`; it does not translate the Silver_IO package body
or recursively construct its Ada.Text_IO declarations
(`trans.cc:8333–8339`). Implicit withs return an empty list at that case.
The selected auxiliary/action/inline/unchecked-conversion paths introduce
no additional executable bodies or referenced declarations; this is the
accepted source-family expansion, not an inference from namespace count.

Each imported procedure's first reference reaches the ordinary function
constructor (`decl.cc:4170–4340`). Its profile gets String, not the package's
other declarations (`decl.cc:6058–6122,6198–6201,6320–6405`). Void return
excludes return padding, and the IN parameter excludes CICO return records.
`create_param_decl` constructs a parameter without pushing it
(`utils.cc:3377–3383`); the result declaration likewise has no push
(`utils.cc:3781–3797`). There are at most two distinct procedure entities.
Their cache hits return before constructors (`decl.cc:400–445`), so repeated
calls add no procedure pushes.

The first String profile reaches the Standard graph: String, Character,
Positive and its Integer base, with already initialized scalar/builtin
dependencies reused. The cold layout's fat pointer, bounds template, index,
XUA array, XUT object and optional XVE record are covered by the
[frozen two-helper result](retained-literal-string-layout.md). Completed
String has TYPE_POINTER_TO and TYPE_REFERENCE_TO set to its fat pointer
(`decl.cc:2553–2559`), so subsequent profile conversions cannot take the
`build_dummy_unc_pointer_types` branch. Ordinary complete entity cache hits
also cannot take the incomplete/private or cloned-record cache exceptions.
No repeated call reopens a cold String graph at a new source location.

`gnat_pushdecl` is the only direct original-gigi suppression site in all
seven retained Ada gcc-interface C++ files. The only other direct site is
the scalar NULL_EXPR gimplifier hook, absent from these selected expressions
(`utils.cc:954–965`; `trans.cc:9405–9424`). Every selected source/helper
declaration route is accounted as follows:

| Route | R put ceiling | Reason |
| --- | ---: | --- |
| Main FUNCTION_DECL | 1 | One `create_subprog_decl`, hence at most one push/suppression. |
| Potential empty elaboration FUNCTION_DECL | 1 | One compilation-unit constructor, one push. Its empty body is never gimplified. |
| Put and Put_Line FUNCTION_DECLs | 2 | At most one ordinary constructor per distinct cached procedure. |
| Silver_IO namespace | 1 | One encoded name component and one creation behind the namespace-map hit guard. Encodings ALL can omit it. |
| Every Standard-derived type/stub/bound/debug declaration | 0 | The reserved-location invariant below covers suppression before final GNAT-location assignment. |
| Parameters, results, size-function declarations, record fields and translation-unit declaration | 0 | These builders do not use `gnat_pushdecl`; their layout/folding continuation is covered below. |
| C literal index/array declarations and N possible null labels | Excluded here | At most 2C+N pushes already owned by I's local term. |
| Literal data/bounds constructors and pool objects | 0 | Constant extents and accepted pointer/address projection; no extra pushed declaration or warning-bearing fold. |
| Forced hard-register dummy | 0 | Direct `build_decl(BUILTINS_LOCATION,...)` and varpool registration, no push (`utils.cc:6459–6488`). |
| Two size-helper initial gimplifications | 0 | Call-free scalar bodies and plain reserved locations, proved below. |

The five charged pushes can each suppress at most once. The suppression
API performs at most one put; an existing disposition is modified in place
(`gcc-diagnostic-spec.cc:150–181`). Their suppression guards need not be
proved true, and their initial locations need not be distinct. Summing all
rows gives **R <= 1+1+2+1 = 5**, independently of C, N and spelling/line-map
offsets. This is a warning-operation projection; it is not a declaration,
entity, node or allocation count for the imported graph.

### Generated-body and empty-elaboration interface

The complete selected constructor frontier has Main, one empty elaboration
FUNCTION_DECL, at most two external procedure declarations with no imported
bodies, and the exact two String size helpers. It has no other generated
FUNCTION_DECL body. This conclusion uses the selected expansion exclusions
above as well as the cold-layout result; namespace counting alone would not
establish it. Apart from Main, only the two size helpers are gimplified.
The frozen helper-discard result gives zero additional functions reaching
ordinary lowering, IPA body execution, RTL expansion or emission.

The empty elaboration is nevertheless material: the compilation-unit
constructor calls `allocate_struct_function(..., false)` once
(`trans.cc:5994`). Its nonnull declaration consumes one persistent function
definition number (`function.cc:4812–4815,4848–4867`). Its saved empty BIND
passes the empty-statement guard, which sets `Has_No_Elaboration_Code` and
skips `begin_subprog_body`, `end_subprog_body` and
`rest_of_subprog_body_compilation` (`trans.cc:698–723`). It is never finalized
or gimplified and contributes zero ordinary lowering, IPA, RTL or emitted
body executions. The empty body is not a zero-allocation assertion.

The exported non-Main function-definition contribution is therefore **+3**:
one empty elaboration plus two size helpers. The two helpers retain their
separate +2 symbol UID/order increments from the frozen packet. This note
does not export an empty-elaboration symbol-registration count, overall
symbol-table maximum, allocator total or assembler-label-width bound;
those are separate integration joins. No non-Main emitted body is added
by this constructor frontier once the frozen helper-discard premise holds.

## Reserved locations through Standard construction

Standard entities and their constructed scalar bounds have Standard
locations (`cstand.adb:895–939,1040–1053,1819–1861`). On entry to an uncached
entity conversion, `gnat_to_gnu_entity` sets `input_location` from that
entity before constructing declarations (`decl.cc:500–505`).
`Sloc_to_locus` maps Standard locations to the plain numeric
BUILTINS_LOCATION (`trans.cc:11006–11018`). A No_Location child leaves the
already reserved input unchanged. Cached children return without changing
it. The String graph recursively visits only these Standard scalar/type
dependencies; conversion of its index bounds likewise stays in Standard.
There is no callback to a Main call-site or library statement inside this
graph. The parameter helper's saved-location restoration is outside the
cold type traversal and cannot change a type declaration retroactively.

Consequently all its newly constructed declarations, including retained
TYPE_STUB_DECLs reused by `create_type_decl`, are born at BUILTINS_LOCATION.
The suppression in `gnat_pushdecl` occurs **before** the final location
setter, but it still sees that reserved initial location. Its context
processing only chooses existing/global lexical contexts; it neither
attaches an ad-hoc location nor enters another source unit
(`utils.cc:815–965`). Global context creation uses `build_translation_unit_decl`
without a push. The optional XVE path inherits the same location, including
its direct stub push. This proves zero puts without needing to turn a count
of all Standard declarations into a warning bound.

The original expressions are constants, readonly bound references,
integer conversions/arithmetic/comparisons/conditional, and later arithmetic
around the two ordinary size calls. Generic builders initialize expression
locations to UNKNOWN; explicitly supplied field/declaration locations here
are BUILTINS. `set_expr_location_from_node` does nothing when
`Sloc_to_locus` returns false for Standard (`trans.cc:11065–11085`).
`set_block_for_group` records a BIND's lexical block; it does not assign
ad-hoc locations to these layout expressions.

The only direct warning mutations in the retained generic fold dispatcher
are comparison-inversion copying and conversion of a MODIFY_EXPR with
constant RHS (`fold-const.cc:4650,9368–9380`). The second shape is absent
from all selected original scalar/type/literal expressions: the generated
helper's return MODIFY_EXPR wraps a dynamic conditional, and its constructor
does not fold-convert that assignment. The first may
occur when conditional arms are inverted, but its target has UNKNOWN or
BUILTINS location, so it performs zero puts. Copying trees for the two size
functions uses `copy_tree_r`, not the inline remapper; fresh bound-parameter
substitution does not integrate a call. The completed XUT/XVE sizes only
wrap the already built calls; no selected executable Main expression
instantiates their placeholder size trees. Ordinary literal bounds supplied
to `build_template` are constants (`utils.cc:4401–4463`). Therefore no
size-function inline remapping or builtin-call folding warning path opens.

## The two nonvoid conditional-return helpers

The frozen cold result supplies exactly two bodies, each with two signed
32-bit bound parameters, one scalar return and a two-arm conditional over
integer arithmetic, with no CALL_EXPR, SAVE_EXPR, NULL_EXPR, cleanup,
exception filter, aggregate/complex assignment or volatile access.
The functions, result and parameters are constructed while input_location
is BUILTINS; all body operators use plain UNKNOWN locations
(`stor-layout.cc:181–265`). Unsharing before the gimplifier sets its input
location uses `copy_node`/`copy_tree_r` and performs no warning-map operation
(`gimplify.cc:944–973`; `tree-inline.cc:5735–5795`).

`gimplify_body` then sets input_location from the function's reserved
declaration location (`gimplify.cc:21778`). Fixed-size scalar parameters
have constant type/decl sizes; `gimplify_parameters` and `gimplify_type_sizes`
produce no variable-size or callee-copy allocation expression for them
(`function.cc:3886–3984`; `gimplify.cc:21600–21739`). The same holds for
the u64/u128 scalar results. Recursive expression lowering only changes
input_location for a tree with a known expression locus
(`gimplify.cc:20360–20364`). New conditional assignments use unlocated
`build2(INIT_EXPR,...)`; labels use UNKNOWN; temporaries use the current
BUILTINS input location (`gimplify.cc:5557–5729`;
`gimple-expr.cc:439–466`). This closes the reserved tree/declaration
location invariant through both bodies.

The direct nonvoid-result suppression at `gimplify.cc:1948` therefore sees
BUILTINS and does not put. Return copies at 1962, conditional copies at 5728
and any comparison-to-assignment copy at 7601 target a fresh tuple at plain
UNKNOWN or a reserved location explicitly copied from the expression.
The other direct gimplifier warning sites require the excluded forms.
Generic scalar assignment/conditional folding has only these scalar
operands; builtin string/memory-call warning handlers cannot execute.

Ad-hoc locations require separate treatment: RESERVED_LOCATION_P examines
the full value, and an ad-hoc value whose pure locus is UNKNOWN is **not**
plain UNKNOWN. `gimple_set_location` also copies dispositions whenever its
old stored value is nonzero, irrespective of a no-warning flag
(`gimple.h:1934–1964`). We therefore do not reason from the pure locus alone.
In these helper paths, newly allocated tuples are cleared, ordinary
assignment/label/return/conditional builders do not call `gimple_set_block`,
and GIMPLE_BIND keeps its lexical block in a separate bind field
(`gimple.cc:168–183,471–520,635–644`). There are no call or debug-marker
builders, which are the relevant initial-gimplifier block-location routes.
Hence every stored tuple location remains **plain** UNKNOWN or BUILTINS.
The call-replacement block setter in `gimple-fold.cc:650–666` likewise
requires a GIMPLE_CALL, absent here. Scalar folds preserve a tuple's
existing location or use the same ordinary cleared assignment builders.
Annotation sets only missing locations to the current reserved input
(`gimple.cc:1485–1525`); repeated annotation cannot escape that set.
Any setter's location-copy overload therefore has a reserved target and
performs zero puts even if an old stored value was BUILTINS.

This is stronger than assuming that the helper's no-warning flags start
clear or that the global warning map is empty. The two return suppressions
may set flags, but neither creates a mapping; subsequent copies cannot
turn them into a nonreserved mapping. The two helper gimplifications add
**zero actual puts** to R.

## Phase boundary and computable composition

After original gigi, `gnat_write_global_declarations` creates the reserved
dummy and emits/records selected global declarations; its type/constant/
imported-function debug callbacks are no-ops under the selected no-debug
configuration (`utils.cc:6459–6540`; `misc.cc:104–124`). The scalar globals
are absent, and literal pool initializers have only constants. These
routes do not run another source-unit conversion or warning mutation.
Size-function finalization then gimplifies the two helpers before graph
analysis. Their `finalize_function` calls do not mutate warning mappings.

Before Main's analysis reaches `gimplify_body`, alias and toplevel-asm
queues are empty; selected function/variable attributes add no alias,
instrumented or generated body. The helpers are not queued for ordinary
analysis, and the empty elaboration function was not finalized. The dummy
and constant varpool initializer analysis creates no warning-bearing
expressions. The direct `check_global_declaration` suppression sites at
`cgraphunit.cc:1116,1120` occur only after the reachable queue (including
Main) is processed, so they are beyond R's endpoint. Later CF/CFG/IPA/RTL
locations likewise belong to later transfers, not this interval.

The new callable supplies R_bound=5 to the retained `evaluate(C,N,R)` and
reports `original_gigi_source_count_closed=true` for this source argument.
The predecessor module and its historical unresolved flag are unchanged.
The predicate still checks the accepted prime/probe/byte conditions; its
sufficient occupancy region becomes `4099+4C+N <= 1,073,741,823`.
For C=1,N=0 it returns I=7,J=3, eleven possible post-prefix map requests,
and incoming/outgoing backbone capacities 16381. This is conservative
arithmetic, not a native observation. Up to one control/finalizer remains
in the transfer; collector vector/page/coexistence obligations stay open.

Selected setting: GPT-6 Astra / Extra High, assigned by parent. Runtime
confirmation and token/cost measurements unavailable. Round start
2026-10-18 20:20:35 UTC; elapsed/check completion is recorded in the evidence.
No compiler, prover, debugger or native capture was run. Only this note and
its evidence directory were edited; aggregate conditions remain untouched.
