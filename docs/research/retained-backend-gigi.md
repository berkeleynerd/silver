# Retained native gigi traversal and cleanup interface

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This is a source-derived component of the unfinished
[retained-tool capacity contract](retained-tool-capacity.md). It follows the
[normalized Main frontier](retained-native-expansion.md#normalized-main-frontier-for-backend-composition)
at GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and the selected O0 application
options. The installed-tool/source relation remains an explicit premise.
It introduces no compiler change, membership predicate or whole-backend bound.

The [offline evidence](../evidence/retained-backend-gigi-20261018/) checks full
source-file identities, the retained excerpts, constructor-site inventories and
the arithmetic below. It does not execute a compiler or prove reachability.
The source argument supplies the latter. No successful frontend capture was
repeated; the existing native fixed-root capture remains separate evidence.

## Count events and edges, not just source identities

Keep separate counts for ordinary executable traversal, entity/type conversion,
and helper construction. A frontend node identity need not correspond to one
GCC node. Conversely, a reference to an already-associated entity need not
construct a declaration. A helper request is not one primitive GCC allocation:
`build_binary_op`, `convert`, folding and type construction have their own
transfers.

For an actual expanded-Main conversion, let the following count **visits**, not
lexical source constructs:

| Symbol | Conversion event |
| --- | --- |
| `U` | `Compilation_Unit_to_gnu` |
| `F` | zero-formal procedure body, with no copy-in/copy-out result |
| `B` | reachable `N_Block_Statement` |
| `L` | integer `N_Loop_Statement` |
| `C` | `Call_to_gnu` |
| `P` | actual-parameter positions visited by those calls |
| `X` | `gnat_to_gnu_external` |
| `H` | handled statement sequence |
| `I` | if statement and elsif-part conditions |
| `A` | `N_Expression_With_Actions` |
| `R` | implicit bare procedure return |

Main's own compilation/body scaffold has `U=1`, `F=2`, `R<=2`: Main and its
one secondary-stack `_finalizer`. Other compilation units and imported fixed
declarations must be added separately. Actual expanded copies belong to the
native-expansion count; runtime loop iterations do not multiply any of these
compiler visits. Reachability can reduce counts, but is not needed for the
upper bounds.

The ordinary-list traversal is once per member (`trans.cc:5688–5691,9298–9305`),
and a for body is converted once (`3301–3306`). The two-pass declaration driver
does not revisit ordinary object declarations in the second pass
(`9889–10025`). Lazy entity-initializer translation and type-bound elaboration
are separate incoming edges; entity references reuse associations
(`decl.cc:400–445,697–718,754–766`). This is the distinction already used for
the [ordinary String payload transfer](retained-backend-capacity.md#ordinary-main-literal-lowering-events).

There is an additional scalar edge that must **not** be hidden behind that
String-literal argument. `Raise_Error_to_gnu` recognizes an artificial
`not (x in range)` or `not (x >=/<= bound)` check, translates its index and
bounds for diagnostic preparation (`trans.cc:6178–6222`), and later translates
the complete condition (`6296–6310`). The first translations occur even when
`with_extra_info` is false. Thus charge both the preparation roots and the
ordinary condition root. The normalized conditions are scalar; they do not
replay a Character String payload. O0 disables the loop-invariant-check
collection at `6253–6281`, so these checks do not fill `loop_info.checks` or
cause the later loop invariant-construction pass at `3317–3380`.

## Binding requests and retained BIND nodes

All `gnat_pushlevel` sites in the four gigi implementation files are inventoried
in the evidence. Their selected paths give:

```text
binding-level requests <= U + 2 F + B + 2 L + C + X
fresh BLOCK requests   <= U + 2 F + B + 2 L + C + X
retained BIND_EXPR     <= U + F + B + 2 L + C.
```

Each push requests at most one `gnat_binding_level` and one `BLOCK`; reuse
only reduces fresh requests (`utils.cc:682–728`). These are cumulative request
bounds, not a peak-live or byte bound.

The coefficient two for procedures has two distinct source sites. The
function framework pushes once in `begin_subprog_body` (`utils.cc:3830–3846`)
and the body pushes once in `Subprogram_Body_to_gnu`
(`trans.cc:4109–4126`). The framework block becomes function metadata in
`end_subprog_body`, rather than a second body `BIND_EXPR`
(`utils.cc:3851–3875`). Each compilation-unit elaboration framework supplies
one further binding (`trans.cc:5999–6001,6078–6091`).

Each integer loop supplies an index binding (`3222–3227`) and a body binding
(`3301–3306`). The latter is deliberately present so dynamic storage can be
released per iteration. Each generated block supplies one (`7987–8001`). An if
branch explicitly passes `binding_p=false` to `build_stmt_group`
(`7944–7976`), and an expression-with-actions explicitly creates no binding
(`8603–8622`).

A call supplies at most one binding. The initial push at `4900–4906` and the
late push at `5087–5094` are guarded by the same `pushed_binding_level` flag.
An external-expression conversion pushes a disposable scope, then uses
`gnat_zaplevel`; it emits no corresponding BIND (`8968–8996`,
`utils.cc:772–783`). Empty nonfunction blocks are merged into their parent
by `gnat_poplevel`; otherwise `end_stmt_group` creates at most one BIND
(`utils.cc:744–767`, `trans.cc:9255–9276`).

The remaining push sites are for case alternatives, exception handlers,
copy-in/copy-out procedure bodies and named-return-value optimization. They are
absent from this variable Main frontier: source/expanded Main has no case,
handler or user subprogram; its two procedures have no parameters/results;
and O0 excludes the optimizing NRV path. Fixed imported-unit conversions must
still use their own inventory. This exclusion is not a claim about arbitrary
Ada input.

## Which cleanup regions see a return

Source grammar has no explicit return, goto or exit. Native source expansion
also creates no variable case/goto/exit/finally-statement family. This does
**not** mean Main has no return. `Expand_N_Subprogram_Body.Add_Return`
appends a bare return to the handled sequence if its final statement is not
already a transfer (`exp_ch6.adb:6233–6276,6734–6745`). There are no source
transfers or handlers here, so Main and the fixed finalizer each receive one.

Main's secondary-stack finalizer is attached to the subprogram body itself
(`exp_ch7.adb:4804–4817`). Gigi converts the handled sequence, then adds the
body's cleanup (`trans.cc:4109–4126`). `end_stmt_group` makes the cleanup
TRY_FINALLY first and the body BIND outside it (`9255–9276`). Thus Main's
implicit return is **inside** that TRY_FINALLY. Its lack of copy-in/copy-out
parameters makes the return-label stack entry null (`4106–4107`);
the bare-return branch emits `RETURN_EXPR`
(`8120–8144`, `3848–3910`). The finalizer's return belongs to its separate
function, not to Main's cleanup body.

The relevant EH input is later than this GENERIC shape. `pass_lower_cf`
precedes `pass_lower_eh` (`gcc/passes.def:36–39`).
`lower_gimple_return` replaces a return by a goto to a shared return label
(`gcc/gimple-low.cc:1180–1217`); the label and representative return are
emitted at function end, outside the lowered regions (`122–214`). Therefore
the EH-lowering interface is:

| Region | Outgoing goto queue / distinct label destinations | `may_return` at EH lowering |
| --- | --- | --- |
| Main At_End TRY_FINALLY | at most `Q=1`, `D=1`, to its function's shared return label | `0` |
| Any Main function-level BIND cleanup enclosing that return | at most `Q=1`, `D=1`, initially; propagate the same destination through inner cleanup lowering | `0` |
| Finalizer function-level BIND cleanup, if present | same separate-function bound | `0` |
| Inner generated block, call, loop-index or loop-body BIND cleanup | `Q=D=0` | `0` |

The inner-region row follows placement, rather than merely absence of source
gotos. The implicit return is appended to the top-level handled sequence,
after those scopes. Loop lowering places the condition, update, backedge and
end-label definition outside `LOOP_STMT_BODY`
(`trans.cc:9492–9581`). All remain inside the loop-index scope. A loop nested
inside another scope keeps its labels in that containing scope. Conditional
branching is internal to the statement/region containing it. There is no
source exit, handler escape, nonlocal goto or inlined procedure return to cross
an inner scope. Check failures call the runtime raise path and can propagate
exceptions; exception propagation is the EH `may_throw` path, not a fabricated
zero count of all possible exits. Silver Reject returns normally.

These are entry facts for the separate tree-EH transfer, not a claim that
EH-generated redirects, labels and cleanup copies cost nothing. That transfer
must include the shared return destination when lowering each enclosing
cleanup. In particular, applying a `Q=D=0` specialization to Main's outer
cleanup is invalid. Cleanup nesting is not bounded by two: for-body BINDs and
generated block/call bindings can nest with source nesting.

### No abnormal non-EH call edges in these bodies

The separate initial-CFG transfer can set `has_nonlocal_label=false` and
`calls_setjmp=false` for Main and its finalizer. This does not exclude ordinary
EH edges. The direct call frontier is the five Silver operations, Image,
Concat_2 through Concat_9, the secondary-stack routines, and the compiler's
check, memory and stack helpers. None is returns-twice or a setjmp family
builtin. Source Main cannot declare a function, apply a Machine_Attribute,
take a label address or call an arbitrary function pointer. An external
function's implementation is not inlined into Main by this O0 invocation.
The selected Linux ZCX unwinder does not add SJLJ setjmp code.

`notice_special_calls` sets `calls_setjmp` only from `ECF_RETURNS_TWICE`
(`gcc/tree-cfg.cc:2185–2196`). The relevant name-based recognition is
setjmp/sigsetjmp, savectx, vfork and getcontext (including the specified
underscore variants), none of which occurs in the frontier
(`gcc/calls.cc:590–630`). The declaration-attribute path likewise requires
`DECL_IS_RETURNS_TWICE` (`815–822`), which these declarations do not carry.
Presence of a static chain for the nested finalizer does not create a nonlocal
label. The nested-function pass creates one only for a goto whose destination
belongs to an outer function (`gcc/tree-nested.cc:2661–2713`); all loop,
cleanup and lowered-return destinations here belong to the current function.
That is the sole caller of `get_nl_goto_field`, and setting the function flag
requires the resulting field (`3674–3679`). Consequently
`call_can_make_abnormal_goto` returns false at its first guard
(`gcc/tree-cfg.cc:2633–2644`). Fixed separately compiled support bodies are
outside this Main/finalizer reduction.

## BIND-local variables and clobber interface

Let `V_b` count the local `VAR_DECL` entries in retained BIND `b`, and let
`K_b` be its subset satisfying the selected ordinary clobber guards. Then

```text
K_b <= V_b
sum_b K_b <= sum_b V_b <= all local VAR_DECL construction events
cleanup statements in BIND b <= K_b + 1
nonempty BIND cleanup regions <= retained BIND count.
```

The last `+1` is the possible stack restore for variable-size objects. It is
per BIND, not per array. The source appends at most one ordinary storage-end
clobber per eligible local (`gcc/gimplify.cc:1710–1748`) and one stack restore
(`1790–1804`), then creates one TRY_FINALLY for their combined cleanup
(`1817–1829`). The separate stack-save statement and its temporary still need
the gimplifier's charge. OpenMP/OpenACC/sanitizer routes are not enabled.
Counting every local variable is conservative; source scalar-register status
or eventual optimization need not be predicted to use the inequality.

Gigi contributes two useful local-variable subtransfers:

* Each `create_var_decl` requests exactly one CONST_DECL or VAR_DECL
  (`utils.cc:3018–3057`) and links that declaration into a binding. The helper
  does not mean one total tree allocation: initializers, types, attributes and
  the declaration-expression wrapper are additional.
* `Call_to_gnu` constructs at most one result/P temporary per call and one A
  temporary per actual: **`V_call <= C + P`**. The first R temporary and the
  late R temporary use `!gnu_retval` to prevent duplication
  (`trans.cc:4864–4895,5079–5083`); P is created only with `!gnu_retval`
  (`5417–5426`). Each actual creates at most one A temporary through mutually
  exclusive initialized/uninitialized branches (`5097–5109`). These branches
  overcount the aligned String/Integer call profiles safely.

Source object count alone is **not** the complete clobber bound. The inventoried
other paths include a constant's corresponding variable
(`decl.cc:1669–1693`), materialized renamings (`1177–1205`), bound/size/debug
variables from `elaborate_expression_1` (`7532–7658`), padding-size variables
(`utils.cc:1832–1859`), and the gimplifier's own temporaries. Optional
over-aligned/with-bounds objects have their own constructors
(`decl.cc:1507–1592`). A composed variable bound must price the selected
type/entity paths or justify excluding each one. This record does not silently
replace those costs by `C+P`.

## Weighted structural constructors

The following are direct source requests, excluding the conversion of their
child expressions and helper internals. Each `buildN` event accounts for one
node request and N operand slots; a null operand still occupies its slot.
The count is cumulative, including nodes later folded or replaced.

| Event | Direct constructors / helper requests |
| --- | --- |
| One bare return | `1 RETURN_EXPR` (1 operand slot) |
| One if/elsif condition | `1 COND_EXPR` (3 slots), one condition conversion and one then-list conversion; final else-list once per if statement |
| One expression with actions | `1 SAVE_EXPR` (1 slot), one compound-expression helper; actions and value converted once |
| One retained BIND | `1 BIND_EXPR` (3 slots); its BLOCK was charged at push |
| Main At_End cleanup | one zero-actual call helper and one TRY_FINALLY (2 slots); existing finalizer entity reference |
| One integer for loop at O0 | `1 LOOP_STMT` (4 slots), one end-label declaration, one loop-info object, one integer-constant request, at most 2 bound-shift binary helpers, 2 bound conversions, 1 loop-variable conversion, 1 test binary helper, 1 update binary helper and 1 assignment binary helper; fallback adds 1 COND_EXPR (3 slots), 1 range-comparison helper and 1 empty-list request |
| Lower one LOOP_STMT | one start-label declaration, 2 LABEL_EXPR (2 slots total), at most 2 GOTO_EXPR (2 slots), at most 1 COND_EXPR (3 slots); reuse its existing body/test/update/end label |

The loop row follows `trans.cc:3026–3306`. At O0 there is no special induction
variable, invariant hoisting or vectorization annotation; the shifted and
fallback branches are mutually exclusive but can both be charged for an upper
bound. `gnat_to_gnu_entity` of the index remains its own entity/type charge.
Loop lowering's additional direct executable-tree requests are at most five
nodes with seven operand slots, plus its start-label declaration. It does not
copy the body. The generated start/end labels and gotos are internal in the
sense described above, despite being additional constructor events.

Statement lists are not free containers. Each `start_stmt_group` requests at
most one group structure (free-list reuse can reduce this), and a group with
no statements requests one empty STATEMENT_LIST at `end_stmt_group`.
`append_to_statement_list` may also create a list and link nodes; its transfer
must consume actual append events. It is incorrect to charge one list per
frontend node without establishing those events. The bound/condition helpers
in the table can also allocate after folding: their request counts are not
their transitive allocation counts.

## Scalar helper request interface

These rows count the named gigi requests **before** their callees' transfers.
The generic GCC folder may build several trees, even for one `fold_buildN`;
it must not be priced as one allocation by assumption. Children are existing
GCC operands, unless a row explicitly names another frontend traversal.
The scalar cases use nonbiased, nonmodular Integer/Boolean types; the separate
pointer/size and descriptor cases retain their own type frontier.

| Selected helper event | Local requests, excluding child conversion and the named subhelpers' internals |
| --- | --- |
| Ordinary non-NULL scalar `build_binary_op` | at most 3 `convert`, 1 `fold_build2`; INIT/MODIFY uses plain `build2` instead |
| Ordinary signed negate/absolute `build_unary_op` | at most 2 `convert`, 1 `fold_build1` |
| Boolean not | 1 `invert_truthvalue_loc`, then at O0 1 `fold`; at most 1 final conversion |
| Scalar `build_cond_expr` | 2 conversions, 1 `fold_build3`, at most 1 plain COMPOUND_EXPR |
| Scalar `build_compound_expr` | 1 `fold_build2` |
| Unary checked negate/absolute | 1 protect, 1 unary helper, 1 comparison binary helper, 1 `emit_check` |
| Binary checked add/subtract with a constant operand | 2 protect, at most 3 binary helpers including the initial result, 1 `emit_check` |
| Binary checked multiply with a constant operand | 2 protect, at most 6 binary helpers including the initial result, 1 `emit_check` |
| Binary checked Integer32 operation with two nonconstant operands | 2 protect, 1 initial binary helper, 2 conversions, 1 complex-type helper, 1 internal two-actual call, 1 `save_expr`, 2 plain unary nodes (REALPART and IMAGPART), 1 `fold_build2` comparison, 1 integer-constant request, 1 `emit_check` |
| `emit_check` with integral result | 1 raise-call helper, 1 integer-constant request, 1 plain COMPOUND_EXPR (2 slots), 1 `fold_build3` conditional |

The plain binary transfer follows `utils2.cc:984–1520`: comparison and
Boolean/arithmetic branches convert the two inputs; the result can receive
one final conversion. Integral assignments convert the RHS once and cannot
need the LHS aggregate-view conversions. NULL_EXPR propagation has its own
early branch (one NULL_EXPR, or a comparison plus NULL_EXPR) and must not be
mistaken for the ordinary row. Array, fat-pointer, modular and aggregate
branches are outside that scalar specialization.

The checked transfers follow `trans.cc:10014–10258`. The initial ordinary
operation is constructed **before** choosing a check strategy and counts even
when its result is later replaced. Constant multiply computes two quotient
bounds, two comparisons and their OR in addition to that initial operation.
The generic case constructs an internal overflow operation with a shared
complex-integer result. Therefore the backend's actual type frontier includes
**complex Integer32 pairs**, despite the source language having no complex
type. The 64-bit-on-32-bit and 128-bit-on-64-bit multiply library branches are
not selected by an Integer32 source operation on x86_64. Scalar return/check
conversions and backend address/size operations remain separately typed.

`emit_check` is at `10270–10280`. A checked conversion with ordinary integral
input and output (`10286–10494`) supplies at most one protect, three binary
helpers (two bounds and their OR), two inversions, one `emit_check`, and seven
ordinary conversions: initial input-base, at most two signedness-normalized
bound constants, two comparison-bound conversions, and final base/result
conversions. Input-mode normalization can request one `gnat_type_for_mode`;
bound normalization can request two signed/unsigned type helpers. The absent
floating-point and biased/modular branches must not be folded into this row.
With no overflow check it returns through a single ordinary conversion.

### Protection preserves shared checked operands

`gnat_protect_expr` is not a recursive copy of a scalar expression tree
(`utils2.cc:3104–3179`). Constants, NULL_EXPR and SAVE_EXPR return unchanged.
For an eligible no-side-effect simple expression it likewise returns the
original tree. Otherwise it follows a **single** conversion/reference spine:
each conversion/dereference wrapper requests one unary node; a selected
component-reference wrapper requests one ternary node; only operand zero is
recursed into. A scalar/fat-pointer leaf uses `save_expr`.
The excluded atomic-load branch is a different helper path.

For spine lengths `h1` (unary) and `h3` (ternary), its local new wrappers are
at most `h1+h3`, with `h1+3*h3` operand slots, and at most one terminal
`save_expr` request. No source child is converted again. GCC `save_expr`
itself returns an invariant/placeholder expression or constructs exactly one
SAVE_EXPR with one operand (`gcc/tree.cc:4132–4164`). The invariant tests do
not construct an expression. This justifies shared operands in the checked
operation rows; later generic unsharing must respect or separately price this
SAVE_EXPR behavior. It does not justify assigning zero cost to those later
passes.

## Raise-call filenames and direct call operands

With no local exception handler, the raise helpers use a runtime call,
not `build_goto_raise` (`utils2.cc:2060–2130`). Each invocation calls
`expand_sloc` (`2018–2051`), which constructs a new filename STRING_CST even
when another check already uses that filename. Let `f` be the actual selected
debug-source-name length, or fallback basename length. One invocation requests:

```text
1 STRING_CST with f payload bytes (f+21 requested bytes on selected LP64 ABI)
1 size_int(f), 1 index-type helper, 1 array-type helper
1 line integer constant, and 1 column integer constant if requested
1 filename ADDR_EXPR and 1 character-pointer-type helper
1 call helper with 2, 3 or 6 actuals.
```

The six-actual range helper adds three conversions to `integer_type_node`.
The selected String and constant-pool transfers must include these filename
payloads as well as author String values. Their magnitude comes from retained
source-name/path inputs; they are not source literal lengths. Suppression
options can replace the name by the empty string but do not eliminate the
constructor. Physical/logical line and column representability is the separate
source-position transfer. The filename's index type has range `0..f`, hence
`f+1` elements, while its stored payload length is `f` plus the private NUL.
The later emission transfer must include that terminator; the ordinary author
String rule that emits exactly the logical length is not interchangeable here.

`build_call_n_expr(n)` constructs one function ADDR_EXPR and requests its
pointer type, then calls `build_call_valist` (`utils2.cc:1972–1983`). The latter
requests one CALL_EXPR with **`n+3` operand slots** and one integer-constant
request for that length (`gcc/tree.cc:11020–11077`). An internal call uses
the same `n+3` layout with a null function operand (`11194–11224`); its
varargs wrapper additionally reserves `n` temporary tree-pointer entries.
The call operand slots include the length, function and static-chain slots.
This is the direct constructor interface; type internals and generic operand
processing remain their own transfer. In particular, the two-actual overflow
intrinsic has five slots, not two.

## String conversion copies are additional payload events

The ordinary literal-lowering transfer remains `2*N_lit`, but it does not
cover payload copying by conversions. `convert` makes a `copy_node` of a
STRING_CST when changing its constrained array type, except for the stated
constant-size-to-dynamic-size condition (`utils.cc:5170–5178`). Fetching a
constant's already-translated `DECL_INITIAL` can therefore lead to a new copy
through the common final conversion; no new frontend literal visit is needed.
Count these actual conversion-copy events separately as `C_string`, with
lengths `l_j`:

```text
additional String tree requests = C_string
additional payload bytes       = sum_j l_j
additional requested bytes     = sum_j(l_j+21).
```

This is a complete local transfer for that copy site: `copy_node` uses
`tree_size` and memcpy (`gcc/tree.cc:1468–1479`), and STRING_CST's size is
its stored length plus `offsetof(tree_string,str)+1` (`1224–1225`). The
copied payload has the same length. Generic folder/unsharing copies are
additional events, not automatically included in `C_string`.

The newly clarified native assignment frontier also includes a generated
unchecked conversion from a literal subtype to an ordinary constrained String
subtype when the assignment target's lower bound is dynamic
(`sem_res.adb:13249–13335`). It is an array-to-array conversion, not an
array-of-characters aggregate. `unchecked_convert` excludes STRING_CST and
aggregate-to-aggregate cases from its fixed-size padding branches
(`utils.cc:6064–6111`); this shape reaches the final view-conversion builder
(`6192–6204`). Its `fold_build1(VIEW_CONVERT_EXPR)` can require generic folding
work, which the separate folder transfer must consume. The ordinary gigi
STRING_CST copy rule above must not be substituted for that different site.

The structural/cleanup and scalar request interfaces are now explicit.
The complete bridge still needs weighted type/descriptor construction, call
argument/return adaptation, assignment/comparison helpers, common conversion
wrappers and statement-list links; the generic GCC folding/copy transfer must
then price the selected helper requests. These joins precede any total
GENERIC constructor/edge bound. No arbitrary per-node multiplier replaces them.
