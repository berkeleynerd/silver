# Retained native gigi constructor and cleanup interfaces

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

Main's own compilation/body scaffold has `U=1`, `F<=2`, `R<=2`: Main and,
when secondary-stack cleanup is required, its `_finalizer`. Other compilation units and imported fixed
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

### Diagnostic preparation has a selected scalar bound

The extra diagnostic traversal does not recursively multiply all normalized
expression trees. Its guard tests the **whole** raise condition for `N_Op_Not`,
then its immediate right child for `N_In`, `N_Op_Ge` or `N_Op_Le`; it does not
search inside a short-circuit condition (`trans.cc:6178–6207`). The selected
native families therefore separate as follows:

| Native check family | Diagnostic preparation |
| --- | --- |
| Integer declaration/assignment range check | May enter. `Generate_Range_Check` forces a non-name, non-single-attribute value with `Mode => Strict` before inserting same-base `Not_In` under `Suppress => All_Checks` (`checks.adb:7688–7730`). Source Integer values have no attribute/call alternative, so the value is a literal/name or a captured constant name; target object endpoints are static Integer values. |
| String subtype and final-slice range check | The generated whole condition is `high >= low and then (...)`; it fails the top-level `N_Op_Not` test. Its scalar conditional bound expressions do not change that outer condition. |
| String declaration/assignment length check | Its length inequality fails the same top-level test. |
| Ordinary for-range check | The range-check builder's temporary tree is not inserted by the ordinary `N_Range` declaration path; it is not an additional executable raise. |
| Original Integer unary/binary arithmetic | Selected strict overflow checking is delegated to the backend, so there is no frontend conditional-raise subtree to replay here. |
| Image result slice and unconstrained String actuals | The Image slice checks are suppressed; the unconstrained formals add no range check. |

The latter five rows use the corresponding closed native constructor families
in [the native expansion analysis](retained-native-expansion.md), especially
“Enabled range-check composition”, “Ordinary native for-loop skeleton”,
“Ordinary Integer declarations and assignments” and “Initial native Integer
Image construction”. The claim is specific to these families, not to arbitrary
GNAT conditional raises or all scalar expressions.

Let `H_store = D_i + J_i`, the native upper bound on Integer declaration and
assignment range checks. Each surviving diagnostic preparation translates at
most its scalar value and two static range endpoints. Each is one current
name/literal occurrence. If membership simplified to a single comparison,
there is only one explicit bound. Consequently:

```text
extra diagnostic scalar syntax visits <= 3 H_store
extra diagnostic String visits = 0
extra diagnostic conditional-raise visits = 0.
```

Type lookup, constant lowering, conversions and raise-call construction still
use their ordinary helper transfers. This closes the duplicate **source
traversal** edge; it does not claim three total GCC allocations per check.

### Main value calls have no body for size-helper inlining

`maybe_inline_call_in_expr` enters its body-copying path only if the resolved
callee has both `TREE_READONLY` and `DECL_SAVED_TREE`
(`tree-inline.cc:6667–6720`). A failed gate creates no declaration map and
copies no body. Selecting O0 alone would not establish this condition.

The Main call frontier consists of separately compiled Silver operations,
the selected runtime signatures and backend builtins. The two Silver API
specifications and the selected concat, Image and secondary-stack runtime
specifications contain no `Inline_Always`. `Compilation_Unit_to_gnu` skips
external inline-body processing at O0 unless that pragma is present
(`trans.cc:6031–6065`). Imported function declaration construction sets up the
declaration/profile without attaching a saved body (`utils.cc:3700–3755`).
The saved-body writers are the translated procedure body and compilation-unit
elaboration paths (`utils.cc:3851–3869`, `trans.cc:6076–6082`). The variable
Main frontier's own bodies are Main and its void `_finalizer`; neither is a
value-producing callee in an array size or bound. Fixed runtime implementations
are separate compilation inputs, not additional bodies attached per Main call.

Thus ordinary Main value calls meet the no-body-inlining premise of the
[size extrema helper transfer](retained-backend-capacity.md#size-extrema-helpers-recursion-and-call-reconstruction).
Compiler-generated size-wrapper functions remain a separate layout obligation:
this call-frontier argument must not be applied to them merely because their
eventual runtime operands came from Main. The evidence checks the exact
selected API/spec identities and the O0/body gates; it does not infer the
premise from a sample call graph.

### Final native type-bound roots have bounded syntax

Use the **completed native normalized tree**, after captures and type analysis,
not raw pre-analysis copies. Every variable Main signed-subtype endpoint in
that tree has at most sixteen ordinary syntax nodes:

* Explicit Integer object endpoints are Ada-static and folded; ordinary for
  endpoints are captured whole expressions or stable name/literal leaves.
* Concat's largest normalized low/high shapes have twelve/sixteen nodes;
  input-derived bounds use attributes/names and Image bounds use leaves.
* A standalone literal's dynamic target low has at most twelve nodes, and
  its constructed `low + (length - 1)` high has at most fourteen.
* Decorated copies may own further associated index types. Those are separate
  type identities with the same endpoint shapes, not extra descendants to
  omit from the type count.

These are the normalized endpoint bounds in
[native expansion](retained-native-expansion.md#uniform-normalized-view-and-bound-copy-shapes),
including its standalone-literal and for-loop extensions. Names are terminal
for this ordinary syntax count. The native range-query recurrence that follows
internal-constant initializers and the earlier 144-node raw-copy allowance
measure different graphs and cannot be substituted for sixteen here.

Let `T_s` count variable Main signed Integer/index subtype identities and `T_l`
its String-literal subtype identities. `elaborate_entity` and the final signed
subtype conversion use the same low/high root IDs
(`decl.cc:1967–1977,7200–7225`). `elaborate_expression` tests their saved
association before traversal and records it afterward when there is no
placeholder (`:7532–7566`). Normalized Main bounds have no discriminant or
record placeholder. Deferred type elaboration therefore does not multiply
those root traversals. Constrained String subtype conversion obtains bounds
from the converted index type rather than translating their Ada syntax again
(`:2614–2632`). A String-literal subtype independently translates at most its
one low-bound root (`:3142–3193`). Consequently:

```text
distinct signed-subtype bound roots translated <= 2 T_s
ordinary syntax visits from these roots       <= 32 T_s
String-literal low-bound syntax visits        <= 16 T_l
combined extra type-bound syntax visits       <= 32 T_s + 16 T_l
                                             <= 32 E_Main.
```

`E_Main` is the native constructor vector's variable Main entity count;
`T_s` and `T_l` are disjoint subsets. Count the fixed Standard/runtime type
frontier separately. The inequality sums each semantic root's weight and
needs no disjointness assumption about descendants shared by different roots.
It closes this source-traversal interface even if several semantic ranges
refer to overlapping syntax.

This is not a sixteen-node bound on the resulting GCC expression. Entity
references, descriptor construction, protected operands, shared initializers
and the helper transfers can produce or reference larger GCC graphs. Their
occurrence/shape accounting, type construction and cached-entity metadata
remain necessary. In particular this result supplies the source roots for
gigi; it does not bound `max_value` by the number of Ada syntax nodes alone.

### Variable Main object initializers are not lazily replayed

`gnat_to_gnu_external` is a real extra source-traversal edge for an unassociated
constant or object renaming. Its two object callers are the reference-only
branches at `decl.cc:697–718,754–766`; the existing-association return precedes
both (`400–445`). A general GNAT program therefore cannot use source node
identity alone to bound initializer visits. The selected normalized Main has
a stronger **object dependency order**:

| Constructor family | Order before a dependent object reference |
| --- | --- |
| Original Integer/String declarations | The recognizer permits only earlier visible objects in an initializer. Ordinary declaration lowering converts the initializer, then defines its object. |
| Concat | Operand actions, length and aggregate captures, and the selected-low capture precede the dependent constrained subtype, access type, result object and final copies. |
| Integer Image | Buffer and position declarations precede the runtime call and returned slice. |
| Initial input | The reference/access capture precedes the source `D` renaming and its dependent bound uses. |
| Forced scalar bound or value | `Force_Evaluation` inserts the capture declaration at the current action point before replacing the expression by that capture's name. Its initializer may contain a nested expression with actions. |
| Conditional actions | Actions precede their own EWA expression; Boolean forcing appends its flag declaration after the existing actions. Nested captured initializers preserve this same order recursively. |
| For index | Outer endpoint captures precede the loop; gigi defines the index before converting its body. |
| Main finalizer | The declaration pass defines Main's objects before the second pass converts the fixed finalizer body that refers to the mark object. |

The native placement and constructor sources are recorded in
[native expansion](retained-native-expansion.md), especially “First raw-bound
analysis and capture”, “Ordinary initial action placement”, “Boolean
expression-with-actions wrapper”, “Initial native Integer Image construction”
and “Fixed input and Main secondary-stack scaffold”. These establish the
dependency directions, including actions retained **inside** a captured
initializer. This is not an assumption that every initializer is action-free.

Gigi preserves this order. Ordinary declaration lowering translates its
initializer before `gnat_to_gnu_entity(..., true)`
(`trans.cc:6826–6880`); a deferred declaration stores the translated initializer
for its freeze rather than retranslating it (`9846–9856`). Object renamings
likewise translate their renamed expression before definition (`6883–6917`).
`process_decls` converts ordinary objects only on the first, ordered pass;
the second pass is for bodies and the stated package/freeze/subprogram-renaming
cases (`9889–10025`). EWA lowering explicitly converts actions before its
expression and result type (`8603–8622`). Slices convert their prefix before
the slice type (`7086–7097`), and the for index is defined before its body
(`3240–3245,3301–3306`). Calls resolve an actual's type before translating its
value, but the only EWA actuals in this frontier have Integer/Boolean result
types with no object-dependent endpoints; String value actions are already
outside the call or in the surrounding Boolean EWA. The String actual's
captured-bound dependencies are therefore already defined.

Lazy **type** conversion is still permitted: a subtype may be elaborated at a
reference or its freeze. Its completed endpoints contain only literals,
already defined object names and their ordinary attributes, as established
above. It cannot force a later variable Main object initializer. An identifier
uses its Actual_Subtype only when that subtype already has an association
(`trans.cc:1233–1256`). The ordinary Main objects have no address clause,
deferred private full view or representation-reset route that removes their
saved association; source constants with an address clause would be a
different replay edge (`1265–1302`, `decl.cc:1278–1291`).

Thus induction over these constructor dependencies gives:

```text
variable Main constant/renaming gnat_to_gnu_external calls = 0
variable Main initializer source translations             <= 1 per declaration
variable Main EWA action-list source translations          <= 1 per ordinary occurrence.
```

The last line counts a list when its enclosing initializer is reached, not
again merely because a later name references that initializer. The other
`gnat_to_gnu_external` caller processes compile-time diagnostic pragmas;
variable Main supplies none. Imported declarations and their initializer
dependencies belong to the fixed runtime frontier. A constant name can still
return its **already lowered GCC initializer**; the GCC graph/copy transfers
must charge that sharing separately.

### Source visits compose without an entity-times-syntax product

Let `O_Main` count current ordinary syntax occurrences reached in the final
normalized variable Main declaration/statement/operand forest, excluding
semantic type-bound root edges. This is a forest of occurrences, not of GCC
nodes. The native cumulative ordinary-node allocation bound `A_Main` safely
dominates it, although the per-kind current counts are usually much tighter.
The selected ordinary cases visit their children once: scalar unary/binary
and conditional expressions, explicit membership bounds, assignment sides,
String view prefixes, call names/actuals, and ordered statement/action lists.
The call's later adaptation/copy-out work uses the saved GCC operands. Ordinary
First/Last/Length attributes convert their prefix once; the unrelated Size
attribute's alternate dereference traversal is outside this frontier
(`trans.cc:1741–1750,2141–2319,4912–4952,6118–6144,7086–7097,7291–7660`).

Combining this with the preceding two root transfers gives:

```text
variable Main source-syntax visits <= O_Main + 32 E_Main + 3 (D_i + J_i)
                                  <= A_Main + 32 E_Main + 3 (D_i + J_i).
```

Use separate fixed-input terms for Main's fixed scaffold and imported
Standard/runtime declarations. No multiplication by the number of object
references, type references or later loop iterations is required for this
source-traversal bound. It does not yet bound a helper's GCC traversal:
ordinary name lowering, type descriptors and folders can follow an already
constructed GCC graph. The remaining composition must consume that graph's
ordinary occurrence weights and protected identities.

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
handler or user subprogram; its at most two procedures have no parameters/results;
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

The word “simple” in the implementation does not mean a linear arithmetic
spine. `skip_simple_arithmetic` can skip **either** invariant operand of a
binary arithmetic operation, and `tree_invariant_p` recursively recognizes
readonly declarations, constants and SAVE/TARGET boundaries
(`tree.cc:4080–4106,4173–4223`). An arbitrarily branching pure arithmetic tree
over such leaves can therefore be returned unchanged by both protection and
`save_expr`. The single-spine bound above is for newly reconstructed
conversion/reference wrappers, not for the unchanged arithmetic input.

Two properties keep this frontier concrete without claiming a global folder
bound. Dynamic readonly captures are not initializer macros:
`create_var_decl` sets `TREE_CONSTANT` only when its initializer is constant,
whereas `TREE_READONLY` alone does not satisfy
`constant_decl_with_initializer_p`
(`utils.cc:3018–3057,3088–3099`, `trans.cc:1047–1059,1330–1369`). Checked unary
and binary operations protect before reusing operands. Constant multiply uses
its dynamic operand in at most the result and two comparisons; constant
add/subtract uses at most the result and one comparison. The two-dynamic case
requests one shared overflow result for REALPART/IMAGPART through `save_expr`.
That helper can elide the SAVE for a readonly invariant call, so preserved
identity sharing cannot be assumed in every case; the call transfer below
uses actual occurrences for that alternative. `emit_check`'s
surviving conditional has a side-effecting raise arm, so it is not a pure
arithmetic region that protection can skip. If folding removes that check,
the removed branch is no longer a live duplicate. Pure unchecked regions,
shared already-lowered constant initializers and generic fold transformations
still need their own occurrence-weight transfer.

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

## Selected call adaptation

`Call_to_gnu` (`trans.cc:4705–5670`) separates source traversal from ABI
adaptation. Its first loop converts each actual once, sometimes selecting the
inner expression of a suppressed conversion. The later copy-in/copy-out loop
uses the saved GNU names and result fields; it does not convert the source
actual a second time. The subprogram name is converted once per call.

Use `C` calls, `P` actual positions, and `P_profile` formal positions visited
by `elaborate_profile`. Selected direct runtime calls have no variadic, stubbed,
atomic, storage-model or frontend Likely/Expect route. The native expansion
argument excludes additional source formals for these signatures; retaining
`P_profile` separately makes the profile elaboration edge explicit. The
following are cumulative **request** bounds, before helper internals:

| Requests | Bound | Source accounting |
| --- | --- | --- |
| Ordinary/unchecked input adaptation | `8 P` | nominal type 1, aliasing 1, input unpadding 1, restored actual conversion 1; by-reference arm at most 4, by-copy arm at most 2 (`5037–5066,5143–5270`) |
| Stabilize-reference helper | `P` | non-reference Out/In_Out actual (`4964–4973`) |
| Compound helper | `2 P + C` | stabilization initializer, initialized A temporary, final returned value (`4970–4973,5107–5109,5654–5665`) |
| A temporary | `P` | mutually exclusive uninitialized/initialized forms (`5100–5109`) |
| R/P result temporary | `C` | the already-proved shared `gnu_retval` guard |
| Assignment binary helper | `2 P + 2 C` | A initialization and by-reference copyback; CICO assignment is in the disjoint non-reference arm. Per call, result initialization and target assignment |
| Component-reference helper | `P + C` | CICO actual extraction and optional function-result extraction (`5454–5458,5550–5556`) |
| Unary helper | `P + 2 C` | one actual address, core function address, optional direct-reference result dereference |
| Extra CICO checked conversion | `P` | ordinary conversion actual (`5482–5487`) |
| Extra CICO ordinary/unchecked conversion | `P` | target or result adaptation (`5489–5509`) |
| `maybe_unconstrained_array` | `P` | CICO extraction; foreign component-pointer arm can replace, not coexist with, that arm |
| `maybe_padded_object` | `P` | same disjoint CICO/foreign alternatives |
| Saved-name TREE_LIST | `P` | one Out/In_Out name in by-copy or omitted-input arm |
| Core CALL_EXPR | `C`, at most `P + 3 C` operand slots | each actual contributes at most one call argument; no Likely/Expect extra arguments |

The assignment bound includes the INIT hidden in `create_init_temporary`
(`trans.cc:4603–4613`). It does not charge that INIT a second time as a
separate helper expansion. Per-actual assignment cases can be enumerated:
non-reference actual has at most one CICO assignment; reference actual has at
most an A initialization plus its copyback. At the call level, R initialization
and P initialization are alternatives, followed by at most one target write.

The direct append-to-list invocations in this routine are at most `3 P + 4 C`:
actual copyback, omitted Out actual address, CICO assignment, result
initialization, target/procedure statement, after-list merge and enclosing
`add_stmt`. This deliberately charges the three actual alternatives together;
helper-internal appends, BIND finalization and merged-list link traversal are
separate. The actual vector reserves at most `P` entries, apart from its fixed
16-entry inline storage per active call. Vector growth and capacity rounding
need the normal container transfer.

Type-resolution requests are separate from these expression helpers.
`elaborate_profile` makes `P_profile` formal and at most `C` result type
requests (`4680–4691`). The main actual loop makes at most `4 P` type requests:
formal, actual, real-object nominal type and unpadded actual type. Returning a
value without a target adds at most `C` unpadded result-type requests. They may
hit an existing entity association; counting every request as an event is safe,
but counting each as a fresh whole type graph without the caching argument is
not useful. Likewise the fixed runtime function profile remains distinct from
its per-call argument adaptation.

## Local declaration and type events

The variable native entity frontier consists of ordinary objects/captures,
loop/block scopes, signed Integer subtypes, constrained String array subtypes,
String literal subtypes and the generated access-to-constrained-String type for
secondary-stack concatenation. Base String, record types and the access-all
unconstrained String type belong to the fixed imported-root graph. There is no
source-dependent recursive record, base-array or subprogram type graph.

`create_var_decl` requests exactly one CONST_DECL or VAR_DECL
(`utils.cc:3018–3133`). Its declaration insertion calls `gnat_pushdecl`, which
links a local declaration directly into the current BLOCK rather than
allocating a TREE_LIST for that link (`894–990`). `add_decl_expr` requests one
DECL_EXPR before checking external/global placement, except for its early
non-declaration/unconstrained-type exclusions (`trans.cc:9104–9185`). It may
also request one `maybe_padded_object`, one INIT binary helper and its
statement insertion if the attached initializer cannot remain in DECL_INITIAL.
A temporary with no attached initializer cannot take that latter route.

For each actual uncached ordinary-object entity conversion, direct declaration
sites request at most four variable/constant declarations: optional ALIGN,
optional UNC, the main declaration and optional corresponding constant
variable (`decl.cc:1507–1693`). This is deliberately an upper bound over
mutually restricted branches. Materialized lvalue renaming is an alternative
ending in `break`, with at most one direct variable declaration
(`1177–1205`); its reference elaboration remains a separate helper.
The over-alignment, padding and allocator helpers can request further type,
expression or declaration work and are not included in four. Generated Main
objects have no Ada Out-parameter declaration, so the optional fake debugging
PARM_DECL at `1643–1664` belongs only to other fixed functions.

For each **uncached branch visit**, the principal selected type requests are:

| Type branch | Requests before common type finishing and callee internals |
| --- | --- |
| Ordinary signed Integer subtype (`decl.cc:1901–2003`) | one signed/unsigned integer-type helper, one base-type lookup, two bound `elaborate_expression` requests, one type-stub declaration |
| String literal subtype (`3142–3193`) | one full String type lookup, one component-type lookup, at most one source lower-bound traversal, four conversions, one `UI_To_gnu` length, at most two integer constants, one binary helper, one `int_const_binop`, one range-type helper, one index-type helper, one nonshared-array-type helper |
| One-dimensional constrained String subtype (`2577–3140`) | one parent, one index, one base-index and one component-type lookup; at most two `max_value`, one `update_n_elem`, five conversions, one overflow-probe `fold_build2`, one binary and one conditional helper, one integer-constant/size binary shift, one index-type helper, one nonshared-array-type helper, one final maximum-size multiply and one type-stub declaration |
| Local access-to-constrained-String (`3810–4056`) | one designated-type lookup, one pointer-type helper; at most one const-qualified-type helper if the access-constant flag is present |

The constrained-array subtype row includes the debug-encoding alternative:
at most one debug RECORD_TYPE, one field helper, one record-finalization helper,
one parent-type entity lookup and two `add_parallel_type` requests. The ordinary
row has one dimension, hence no inner-dimension stride variables. No packed,
Fortran, reverse-storage, aliased-component or volatile branch is silently
included. A `max_value` request can inspect and reconstruct an existing scalar
expression; its generic cost is not zero. All literal counts are independent of
the character count: payload bytes belong to STRING_CST events.

The access type's designated subtype is a complete local constrained array;
it is neither private/incomplete nor from a limited-with unit, and cannot point
to itself. Therefore this variable branch does not build a dummy fat-pointer
graph or enqueue an incomplete-type fixup. A constrained-array pointer is an
ordinary pointer, even though a later call may convert it to a fixed String
fat-pointer type.

Common finishing (`decl.cc:4530–5022`) adds at most one `validate_size`, one
`validate_alignment`, one `make_type_from_size`, one `maybe_pad_type`, one
`set_rm_size`, one extra
stripped type declaration and one final type declaration per local type visit.
The global size and record-field elaboration loops are excluded for these local
Main types. Size backannotation can request at most two `annotate_value` and
one `UI_From_Int`; that native Uint/metadata work must be included in the native
backannotation transfer. Alias registration, debug contexts and identifier/name
construction remain metadata rather than executable-tree operands.

The smaller helpers have explicit local transfers:

- `create_index_type` requests one nonshared range-type helper and one type
  declaration (`utils.cc:2861–2871`). `create_range_type` requests one nonshared
  range type and sets two language-specific RM bound slots (`2877–2894`).
- `create_type_stub_decl` requests one TYPE_DECL (`2918–2925`).
  `create_type_decl` requests at most one TYPE_DECL, reusing an unnamed stub
  when possible, then calls `gnat_pushdecl` (`2938–2988`). Named nonartificial
  pointer insertion may request one `build_variant_type_copy`
  (`1010–1035`); artificial generated access types avoid that branch.
- `elaborate_expression` traverses its source bound once on an association
  miss and saves the result unless it contains a placeholder
  (`decl.cc:7532–7566`). The variable scalar/constrained-String bounds have no
  record discriminant placeholder. Its `_1` helper requests at most one named
  variable and at most one `gnat_save_expr` (`7569–7658`); the O0 loop-bound
  subtype case deliberately uses a variable to prevent repeated evaluation.
  `_2` adds at most one `size_int` and two `size_binop`, invoking `_1` once.
- `update_n_elem` requests two conversions and three `size_binop`
  (`7169–7197`).
- Character component conversion (`5538–5691`) has one component-type lookup,
  one size validator, and at most one each of `make_type_from_size`,
  `maybe_pad_type` and extra type declaration. Its selected ordinary Character
  component has no record packing, zero-size aliased component or atomic work.
- `make_type_from_size` on ordinary scalar types requests at most one
  signed/unsigned type helper, one `bitsize_int` and sized-type canonicalization;
  it leaves ordinary array types unchanged (`utils.cc:1522–1613`).
  A pointer/fat-pointer alternative requests at most one pointer-type helper.
- `maybe_pad_type` (`1691–1935`) removes an existing padding layer before
  repadding. Its direct worst branch requests two RECORD_TYPEs, two field
  helpers, two record-finalization helpers, one reference-type helper, one
  `add_parallel_type`, one XVZ variable, one conversion and one `size_binop`.
  It can additionally request two `round_up`, one `max_size` and, for a small
  nonfat record, one `make_packable_type`. This is not a recursive stack of new
  padding layers. Layout and the fixed record frontier still price those
  helpers; canonical table growth is separate metadata.

In particular, a complete local-variable bound must add the named-bound,
padding-XVZ, object/capture and generic temporary events to `C+P`; the call
bound alone is not a bound on all BIND locals.

### Constructor-bearing Main entities are fully converted once

The local rows above can now consume **entity counts**, rather than an
unbounded number of reference visits. Let O count variable Main ordinary
objects, generated captures/renamings and for indices; let Ts, Ta, Tl and Tp
count respectively its signed scalar subtypes, constrained String subtypes,
String-literal subtypes and generated access-to-constrained-String types.
These are disjoint native entity families, so

```text
O + Ts + Ta + Tl + Tp <= E_Main.
```

Count a full conversion when `gnat_to_gnu_entity` reaches the relevant kind
branch, rather than counting its cached returns or itype dispatch wrapper.
On the selected Main frontier, each of these entities has at most one full
conversion. The argument has three parts.

First, the existing-association path returns before the kind switch
(`decl.cc:404–445`). Completed ordinary conversions save the resulting
declaration at `:5025–5026`; object renamings that save an expression instead
do so explicitly at `:1164–1166`. An unassociated itype reference can enter
`process_type`, but that wrapper delegates to its one defining conversion;
it does not itself enter the type-construction branch (`:352–400`).

Second, definition sites do not repeatedly bypass that cache. The ordered
declaration pass and EWA rules established above translate each object/type
declaration once. A for index is defined once before the loop body, independent
of the runtime trip count. An N_Itype_Reference checks for an association
before invoking `process_type` (`trans.cc:8635–8638`). A declaration deferred
to its freeze stores its initializer without defining the entity; its freeze
performs the full definition (`:6865–6878,6905–6915,9846–9856`). For a deferred
type, `process_type` creates at most a dummy association first; the freeze
replaces that dummy with the full type. The second declaration pass visits
only the freeze's body actions, not `process_freeze_entity` again
(`:9899–10001`). Neither `process_type` nor `process_freeze_entity` can replace
an already completed type on this frontier: their only relevant replacement
is a dummy (`:9757–9795,10708–10752`). Concurrent/private full-view cases in
those routines are absent from variable Main.

Third, the kind branches cannot reenter the same unfinished Main type before
it is cached. This needs more than the cache's existence: the general signed
subtype branch explicitly allows such reentrancy (`decl.cc:1990–1995`). The
native [endpoint-type dependency argument](retained-native-expansion.md#scalar-endpoint-types-precede-their-new-subtype)
shows that Main endpoint expression types are base or earlier types, not the
fresh subtype being declared. Already analyzed names can retain an earlier
object's subtype; they are not all retagged to a base type. Constrained String
types depend on their already constructed index subtype and fixed parent/
Character types; generated access types depend on their earlier complete
constrained String type. String-literal lower bounds and signed bounds refer
only to the earlier objects/types established by that argument and the
object-dependency induction above. The resulting dependency graph is acyclic.
Main has no recursive record, incomplete/private view, packed-array
implementation replacement, extended access or address-clause reset route.
Imported types and declarations have their own fixed graph, paid separately.

Consequently the principal variable-branch event bounds are

```text
ordinary-object full conversions      <= O
signed-subtype full conversions       <= Ts
constrained-String full conversions    <= Ta
String-literal full conversions       <= Tl
local constrained-access conversions  <= Tp.
```

For example, the earlier four direct ordinary-declaration sites contribute
at most `4O` declarations; they do not become `4O` times the number of object
references. Common type finishing and each per-kind helper-request row are
likewise multiplied by the corresponding type count once. These are request
coefficients, still subject to their layout/folding/metadata transfers.

Allow separately one deferred-type dummy construction per local type. The
dummy cache is keyed by its underlying equivalent type; a hit allocates
nothing. A miss requests one ENUMERAL_TYPE, one TYPE_DECL and at most one
debug LANG_TYPE on this nonrecord/nondiscriminated Main frontier
(`utils.cc:521–568`). Thus `T=Ts+Ta+Tl+Tp` supplies at most `2T` dummy/debug
type nodes and T dummy declarations, including dummies later replaced. Its
name/identifier metadata is separate. `elaborate_entity`'s deferred scalar
bound preparation uses the same cached endpoint roots already charged in
the `32E_Main` source-visit interface; no second syntax traversal is added.

This claim deliberately excludes scope-only E_Block/E_Loop entries:
`decl.cc:4480–4486` returns an error marker without caching them. Such entries
do not construct the object/type families above; their name/context work must
remain in the metadata visit count. Main/finalizer subprogram profiles and all
fixed imported entities are also separate. The bound is not a claim that
every `gnat_to_gnu_entity` invocation, or every possible GNAT kind, occurs once.

## One-dimensional descriptors and shared references

A String template has two scalar fields. `build_template`
(`utils.cc:4401–4460`) iterates once, requests two conversions, two placeholder
substitutions, appends two constructor elements and requests one
`gnat_build_constructor`. That helper requests one CONSTRUCTOR after inspecting
its existing element values (`utils2.cc:2166–2220`). It does not recursively
copy them. Its `initializer_constant_valid_p` and bitfield predicates remain
explicit generic predicate work; sorting a two-element record does not expand
an expression.

`convert_to_fat_pointer` has these alternatives (`utils.cc:4794–4905`):

| Input | Requests before callee internals |
| --- | --- |
| ordinary nonnull constrained-array pointer | one template helper, one ADDR unary helper, one pointer conversion, one two-element constructor |
| shifted thin pointer | one protect, one pointer-plus binary helper, one `fold_build1(NEGATE)`, one byte-position helper, one `fold_convert`, one final pointer conversion, one two-element constructor |
| unshifted thin pointer | one protect, three unary helpers, two component-reference helpers, one final pointer conversion, one two-element constructor |
| null pointer | at most one empty bounds CONSTRUCTOR and ADDR unary helper, one `fold_convert`, one two-element CONSTRUCTOR |

The null-bounds cache can reduce those requests but is not needed for the upper
bound. Converting constrained to unconstrained String adds an outer address
and dereference helper around this fat-pointer conversion
(`utils.cc:5591–5627`). A gigi unconstrained-array reference is a special
one-operand node, not a source-level copy of the String payload.

`maybe_padded_object` is at most one conversion (`gigi.h:1299–1307`).
`maybe_unconstrained_array` (`utils.cc:5764–5851`) on an unconstrained-array
reference requests at most two component references and two dereference
helpers, plus one plain COND_EXPR when the fat pointer is conditional. On a
template-containing record it instead requests at most one conversion, one
component reference and one `maybe_padded_object`. The NULL alternative
requests one unary NULL_EXPR. Storage-model LOAD recursion is excluded.

For a direct known descriptor/result field, `build_component_ref` requests
one ternary COMPONENT_REF and, unless disabled, one `fold`
(`utils2.cc:2225–2330`). A preexisting view-conversion spine can be searched
first: with `v` such wrappers, charge at most `v+1` direct field attempts and
at most `v` unpadding conversions. Internal-record-field search is unnecessary
for the selected direct descriptor fields. Fixed record offsets fit their
representation; an overflowing-offset error path would add a raise helper and
NULL_EXPR and cannot be assumed away for arbitrary user record types.

Protection and stabilization are different. `gnat_stabilize_reference`
(`utils2.cc:3181–3380`) first follows an lvalue-reference spine, rebuilding each
unary/ternary/quaternary wrapper once. Its scalar callback can then recurse
through **both** operands of a binary expression. Let `n1,n2,n3,n4` count the
visited wrapper/operator occurrences by arity and `s` count terminal save
requests across this traversal. Its direct constructor bound is
`n1+n2+n3+n4+s`, with `n1+2*n2+3*n3+4*n4+s` operand slots. These are traversal
occurrences, not distinct-node identities: shared binary DAGs must be charged
by their incoming paths unless a separate memoization/sharing argument applies.
Stable constants/declarations and existing SAVE expressions stop traversal.
It never makes a STRING_CST payload copy at this site.

## Aggregate assignment and String equality

String/descriptor INIT and MODIFY use the aggregate branch of `build_binary_op`
(`utils2.cc:1013–1197`), not its scalar row. Before the final plain binary node,
its selected broad envelope is three ordinary conversions, one unchecked
conversion, and one `find_common_type`; the two-conversion small-padded branch
and the one-conversion padded-view branch are alternatives. LHS conversion and
reference stripping walks the existing operand-zero spine without copying it.
`find_common_type` (`216–272`) selects an existing type; it does not construct
a new one. Conversion internals, including String payload-copy opportunities,
remain charged separately.

For one-dimensional String equality, `compare_arrays_for_equality`
(`utils2.cc:286–456`) requests at most:

```text
2 protect helpers; 4 size_binop; 10 ordinary conversions;
8 scalar binary helpers; 4 fold_build2;
6 placeholder substitutions; 2 plain COMPOUND_EXPR;
1 maybe_character_type; 1 find_common_type.
```

The dimension loop runs once. Ten conversions comprise three initial Booleans,
four stored bounds, one constant nullness Boolean and two data operands.
Eight scalar binary helpers comprise up to two bound differences, three
per-dimension Boolean joins, one data join and two final nullness joins.
The direct folder requests comprise at most three comparison tests and the
final **array** equality. The two nullness alternatives can reduce these
maxima. String inequality adds one `invert_truthvalue_loc` at the caller.
The generic folder and gimplifier must therefore price aggregate EQ/NE, not
only scalar comparisons. This local transfer does not enumerate characters or
copy the compared arrays; subsequent memcmp/block lowering remains separate.

## Conversion, address and allocation subroutes

Ordinary nonbiased scalar conversion has a small gigi dispatch interface
(`utils.cc:5414–5484`). An integer constant requests one `int_const_convert`;
other integer/enumeral values request one `convert_to_integer` and one `fold`.
Boolean and mere scalar variants request one `fold_convert`. Complex
conversion, if requested for the internal overflow pair, requests one
`convert_to_complex` and one `fold`. These are alternatives, and none is a
promise about the generic helper's transitive allocations.

Ordinary pointer conversion requests one `convert_to_pointer` and one `fold`.
A fat-pointer input adds one data-field component-reference helper
(`utils.cc:5486–5530`). Thin-pointer adjustments instead request at most two
`byte_position`, one `size_diffop`, two `fold_convert` and one pointer-plus
binary helper. Generated pointers to constrained String are ordinary pointers;
the fixed runtime's unconstrained String ABI can use fat pointers.

For two ordinary array types, `convert` has four principal alternatives:
reuse the expression, copy a STRING_CST as already counted, build one plain
VIEW_CONVERT_EXPR for a mere type variant, or request `unchecked_convert`.
For an existing indirect array reference it can instead request one pointer
type, one `fold_convert` and one indirect-reference helper
(`utils.cc:5547–5571`). A preexisting aggregate-view-conversion spine may be
removed recursively (`5327–5367`); each such step consumes one existing wrapper,
not another source expression traversal.

For a two-field descriptor CONSTRUCTOR, conversion between mere variants
copies one node and its two element entries (`utils.cc:5191–5206`). The
compatible-record alternative allocates a replacement element vector, converts
each supplied field value once and then copies the node (`5208–5273`); partial
failed attempts are charged too. The fields of a flat bounds template are
scalars, and the fields of a fat pointer are ordinary pointers, so these field
conversions terminate in the scalar/pointer rows. Fixed `Mark_Id` metadata has
two record levels, not an arbitrary source-defined record depth:
`Mark_Id=(Stack pointer, Top)` and `Top=(Byte, Chunk pointer)`
(`libgnat/s-secsta.ads:300–308,335–341`). Other fixed imported-record work stays
in the fixed-root type graph.

Padding and template-containing-record conversions have their own request
edges (`utils.cc:5009–5158`). An input-padding step requests at most one
component-reference helper, then converts the inner value. An output-padding
step converts the inner target and wraps it in a one-element CONSTRUCTOR or
view conversion. A template-containing target requests one template helper,
one `maybe_unconstrained_array`, at most one data-field conversion and one
two-element constructor. These reduce to the descriptor/array cases after
removing the relevant type wrapper. The natural-layout argument must bound
the number of actual padding layers; it must not replace that obligation with
an assumption that all conversions are scalar.

The native expansion frontier excludes a variable Main type with
`Is_Constr_Array_Subt_With_Bounds`: its setters require an aliased object or
controlled array component, neither of which is selected. Generated String
storage has no aliased flag and Character is noncontrolled. Thus the
template-containing object route is retained for the fixed imported-type
interface, not multiplied by each ordinary String declaration or concatenation.

For ordinary array-to-array `unchecked_convert`, excluding constructor
realignment, the selected transfer is one `maybe_unconstrained_array` and one
plain or folded VIEW_CONVERT_EXPR (`utils.cc:5911–6204`). Fixed-size padding
branches explicitly exclude both STRING_CST and aggregate-to-aggregate
conversion. This covers the generated literal-subtype-to-constrained-String
conversion; it does not copy one character node per byte.

An unchecked ordinary scalar/pointer conversion first requests one `convert`.
Do not infer that its final truncation branch is absent merely because the
source has no modular types: a subtype's RM size can differ from its allocated
size. The conservative integral tail (`utils.cc:6207–6240`) adds at most one
`gnat_type_for_size`, one `size_binop`, three ordinary conversions and two
scalar binary helpers, or one integer constant for a zero-bit value. Reverse
storage, scalar/aggregate reinterpretation and vector construction are outside
the selected conversion pairs. Constructor realignment/size growth remains
tied to actual record layout and must be counted if that pair is reachable.

### Address and dereference are not subtree copies

For ordinary ADDR_EXPR requests, `build_unary_op`
(`utils2.cc:1567–1728`) follows at most one existing operand-zero/operand-one
spine through eligible aggregate conversions, padded constructors and special
compound expressions. Let `h` count the visited spine positions, including the
terminal one. Its local envelope is at most `2h` pointer/reference-type
requests, `2h` conversions, `h-1` plain COMPOUND_EXPR nodes and one terminal
`build_fold_addr_expr`. The large allowance covers the terminal indirect
reference's pointer type and alias-all variant, the optional common-path
unpadding conversion, and each return conversion. Generic address folding is
separate. ATTR_ADDR_EXPR field-offset construction is a distinct route; it is
not silently charged as this ordinary address helper.

`gnat_mark_addressable` (`utils2.cc:3009–3051`) only follows existing wrappers,
sets flags and consults an existing corresponding constant variable. It neither
constructs a copy nor creates the corresponding variable lazily.

An INDIRECT_REF helper (`1729–1792`) requests at most one thin-pointer
`byte_position`, one thin-to-fat conversion and one final result conversion.
Its terminal choice is one unary UNCONSTRAINED_ARRAY_REF, reuse of an ADDR
operand, or one `build_fold_indirect_ref`. `gnat_save_expr`
(`3068–3095`) similarly follows just a unary/ternary descriptor spine and adds
at most one terminal SAVE_EXPR. Its wrapper slots are `h1+3*h3`, plus one
for that terminal save; it does not unfold the saved value's expression tree.

### The selected concatenation allocator

The frontend supplies `new ConstrT`, without an initializer, through a named
access type designating constrained String. The pool is the Integer
`SS_Pool` marker and the procedure is `SS_Allocate`
(`exp_ch4.adb:3367–3405,4639–4654`; `libgnat/s-secsta.ads:70–73,110–113`).
At `trans.cc:7656–7725`, this requires one allocated-type lookup and one result
type lookup, then `build_allocator`. It does not follow the qualified-expression
initializer route. The secondary-stack pool also explicitly bypasses the
template-containing thin-pointer result adjustment.

Consequently `build_allocator` (`utils2.cc:2608–2761`) uses the ordinary-pointer,
no-initializer path: one allocation-call helper and one result-pointer
conversion; it adds at most one `size_int(-1)` if the constant size is invalid.
Its size is from a constrained String subtype, so no record-discriminant
placeholder requires `max_size`. The caller's native bound/capture evaluation
was already charged. The initializer's recursive COND_EXPR split, protected
initialization, template-object construction and storage-model branches do not
apply to this frontend form.

`build_call_alloc_dealloc_proc` (`2354–2435`) on the secondary-stack marker
requests one existing procedure conversion, one allocation-size type lookup,
one alignment `size_int`, two ordinary conversions and a two-actual call
helper. The out Address formal is the GCC function result; the two actuals are
size and alignment. This is an ordinary runtime function, not the invisible
return-slot frontend builtin. The resulting call has five operand slots as
established earlier, plus its function-address and type helper requests.

There is also an independent size check for excluding implicit heap allocation
in ordinary declarations. `allocatable_size_p` permits a valid constant local
size, and permits a static size through `INT_MAX` inclusive
(`decl.cc:7116–7128`). Natural-layout Character String has one byte per element
and length at most `Integer'Last`, while the fixed pointer/scalar/Mark_Id
objects are smaller. GCC `valid_constant_size_p` accepts nonnegative,
nonoverflowed constants up to half of sizetype's maximum
(`tree.cc:6982–7023`). Once the type/layout transfer establishes these size
premises, the declaration's oversized-object `malloc` branch is excluded.
This does not establish a physical-memory guarantee or bound backend frame
allocation, and does not exempt either from the overall contract.

## Gimplification consumes scalar regions and additional metadata roots

The ordinary arithmetic regions that protection leaves unwrapped need not be
linear spines. Their incoming-edge occurrence weight still gives a useful
gimplification interface. Consider a region of ordinary scalar unary/binary
operations handled by the generic class dispatch, with integral constants,
SSA_NAMEs, nonvolatile scalar VAR_DECL/PARM_DECL leaves without a VALUE_EXPR,
and SAVE boundaries. Its types are completed integral register types. This
row excludes special conditional/short-circuit,
comparison boolification, call, memory-reference, aggregate and pointer
adaptation cases; their outputs may enter the region as GIMPLE-value leaves.
It includes arbitrary branching within the stated arithmetic region.

Let N count its ordinary unary/binary occurrences, S its distinct unresolved
value SAVE identities, and M extra requests to materialize a scalar value
from the surrounding caller. Count each SAVE child region once. Then:

```text
scalar temporary-materialization requests T <= N + S + M
plain INIT_EXPR requests                    <= T
ordinary unshare-copy nodes                 <= T
raw GIMPLE_ASSIGN requests                  <= T
raw GIMPLE assignment operand positions     <= 3 T
maybe_fold_stmt entries                     <= T
fresh SSA_NAME requests                     <= T
fresh VAR_DECL requests                     <= T.
```

The two identity rows are separate upper bounds, not a claim that each
request creates both. The assignment and copy rows count the materialization
helper's work; an enclosing source/descriptor store and a caller's separate
unshare request retain their own charges. This is a transfer for raw
construction before the
GIMPLE folder's replacement sequence; that sequence has its own cost and
output shape. The ordinary INIT/copy nodes have at most `4*T` operand slots
in total. Declaration/type/name metadata remains separate too.

The generic dispatch visits each unary/binary operand before asking whether
the result needs a temporary (`gimplify.cc:21295–21348,21502–21558`). If needed,
`internal_get_tmp_var` first gimplifies to a register RHS, constructs one INIT
around `unshare_expr(val)`, and gimplifies that initialization
(`:680–721`). The second traversal sees a **shallow** scalar operator whose
operands are already GIMPLE values. Its unshare copies at most that operator;
it does not recursively expand the original arithmetic tree. Both initial
and final assignment predicates select the register-RHS case for the fresh
scalar destination (`:6288–6307`). The ordinary assignment path constructs
one GIMPLE_ASSIGN and calls `maybe_fold_stmt` (`:7604–7615`). There is no
variable-size wrapper or pointer conversion in this scalar specialization.

`gimplify_save_expr` evaluates its operand only while
`SAVE_EXPR_RESOLVED_P` is false, then replaces that operand by the resulting
temporary and sets the flag (`:7758–7799`). Later references return it without
replaying the child. Void SAVEs, including the EWA action group, gimplify their
statements once and need no value temporary. `gimplify_compound_expr` likewise
consumes its left statements and final value without copying them
(`:7723–7746`).

Initial `gimplify_body` uses `push_gimplify_context(true)` even at O0
(`:21760`). Formal arithmetic temporaries therefore normally use SSA_NAMEs;
SAVE materialization explicitly passes `gimple_in_ssa_p(cfun)`, which is false
at initial lowering, and uses a VAR_DECL. The O0 branch in `lookup_tmp_var`
disables its expression cache only when that helper is selected
(`:639–654`). The conservative identity rows also allow the helper's
undefined-SSA fallback to request a VAR_DECL (`:718–719`); they do not assume
that this fallback is a successful lowering path. The initial-SSA component
must receive the already created SSA_NAME count as an input.

### Size-position roots include Ada's RM endpoints

The whole-body unsharing forest is not the entire later gimplification input.
`gimplify_type_sizes` marks a type's **main variant** before recursion, so each
such variant is processed at most once. It visits scalar MIN/MAX, record field
OFFSET/SIZE/SIZE_UNIT, and each type's SIZE/SIZE_UNIT. Arrays recurse into their
element/domain types; pointer and reference types do not recursively open
their designated type (`gimplify.cc:21600–21705`). A TYPE_DECL's original
type is an additional entry to the same cached traversal
(`:2145–2155`). Include it in the reached type inventory.

The Ada language hook has two additional roots: TYPE_RM_MIN_VALUE and
TYPE_RM_MAX_VALUE for a scalar declaration whose type sizes are not yet
gimplified (`trans.cc:9378–9406`). Those custom fields are not visited by the
generic tree walker used in whole-body unsharing. Dynamic local object
declarations independently supply DECL_SIZE and DECL_SIZE_UNIT to
`gimplify_vla_decl` (`gimplify.cc:1971–1978`).

Let T count reached main type variants, Ts their scalar variants, F their
record fields, Dv the VLA-declaration entries and Ds scalar DECL_EXPR visits
eligible for the Ada hook. Main and its finalizer return void; generated size
functions return scalars. No dynamically sized aggregate return adds another
pair in this frontier. A sufficient count is therefore

```text
gimplify_one_sizepos requests <= 2*T + 2*Ts + 3*F + 2*Dv + 2*Ds.
```

These are actual metadata/visit counts, not source type identities. Reusing
the same bound through two metadata fields may consume two incoming-root
weights. A one-size-position request returns immediately for null, GIMPLE
constant, VAR_DECL or placeholder-containing input. Otherwise it calls
`unshare_expr` once and then gimplifies the copied root
(`gimplify.cc:21712–21739`). The ordinary unshare transfer applies to that
root. Its non-SSA/constant-result normalization adds at most one extra scalar
materialization request; charge that in M above when the result belongs to the
scalar region. Preserved SAVE identities still share their one-time child
evaluation across these roots. This closes the root-count interface, while
the actual bound/size expressions and non-scalar gimplifier branches remain
required inputs.

## Scalar conditionals preserve branch bodies during gimplification

This component is a transfer on the **actual GENERIC occurrence forest**
after the preceding construction/unsharing transfers. Protected SAVE children
are charged once as above. It covers void conditionals and nonaddressable
integral value conditionals, including the scalar register destination case
of assignment distribution. Predicates are Boolean truth operators,
comparisons or Boolean-valued leaves; there is no `__builtin_expect` special
case, annotation wrapper, OpenMP or lvalue-valued conditional. Other producers
and folder replacements must supply their own resulting occurrences. This is
not a claim that a source `if` translates to a single GENERIC conditional.

Initial gimplification has `allow_rhs_cond_expr=false`: the default argument
is false (`gimplify.h:53–54`), `gimplify_body` passes only `true` for the SSA
argument, and the temporary enabling site is in the excluded OpenMP atomic
route (`gimplify.cc:19462–19467,21760`). A scalar value conditional consequently
requests at most one VAR_DECL and two INIT_EXPR arm wrappers, then gimplifies
the same conditional as void (`:5564–5641`). An assignment to a scalar register
destination can instead distribute its assignment into the two arms, reusing
that destination (`:7002–7048`). The result's optional unshares cut at the
declaration/SSA identity in this specialization, so they do not duplicate a
branch expression. Count the two wrappers even when one or both disappear
while lowering another conditional. Nested branch bodies are consumed once.

For a void conditional whose predicate is no longer ANDIF/ORIF, the direct
normal path requests at most:

```text
raw GIMPLE_COND                 1
raw GIMPLE_LABEL                3
raw GIMPLE_GOTO                 1
fresh LABEL_DECL               3
maybe_fold_stmt entry          1.
```

Each predicate and arm is gimplified once on this path
(`gimplify.cc:5673–5809`). Hijacking an existing jump can only remove the
corresponding arm traversal/construction. If both arms become empty, the last
predicate statement replay sees the already gimplified predicate; it does not
replay its original child tree. The rows price raw control tuples, not a
folder's replacement sequence. Ordinary child expression and assignment costs
remain in their own transfers.

### Short-circuit normalization has a linear constructor transfer

Let C count incoming COND_EXPR occurrences, A count incoming ANDIF/ORIF
occurrences, and V count the latter that first reach the generic value-context
dispatch. That dispatch creates one value conditional around the existing
short-circuit expression and two converted Boolean constants
(`gimplify.cc:20483–20500`), so `V<=A`. Set `C'=C+V`. Price those `2V`
constant conversion requests separately; they do not copy a predicate or arm.

`shortcut_cond_expr` first strips simple no-else ANDIF or no-then ORIF cases,
creating one conditional for each consumed operator. The general case invokes
`shortcut_cond_r` and forwards each original arm once; its additional join
code has at most one GOTO_EXPR, two LABEL_EXPRs and six statement-list append
requests (`gimplify.cc:5214–5385`). Let As and Ar count respectively shortcut
operators consumed by these simple and recursive routes; `As+Ar<=A`. Let R
count general recursive-route roots. Each such root consumes a still-present
shortcut operator, so `R<=Ar`.

In the recursive route (`:5036–5137`), a shortcut operator has two recursive
children and at most one local LABEL_EXPR. A nonvoid ternary predicate has
two recursive arm children, creates one void conditional around its original
predicate, and leaves that predicate for ordinary later gimplification. Let K
count these ternary visits. They consume original value-conditional
occurrences, so `K<=C'`. The remaining leaves each create one void conditional
and at most two GOTO_EXPRs through `build_and_jump`; each jump can create at
most one label (`:3221–3235`). The binary-forest identity gives

```text
recursive-route leaves L = Ar + K + R.
```

The created ternary wrapper replaces that original ternary. Each recursive
route root also replaces its incoming wrapper. Thus the count of conditionals
that eventually reach the normal control-tuple path is bounded by

```text
Q <= C' + As + (L+K) - R - K
  =  C' + As + Ar + K
  <= 2C' + A.
```

Here the subtractions account for consumed wrappers, not reclaimed memory.
For **lifetime constructor requests**, retain all newly created intermediates.
The simple route creates at most As conditional nodes; the recursive route
creates `L+K=Ar+2K+R`. Including the V value wrappers gives at most
`V+2A+2C'` new COND_EXPR requests. The recursive route and its joins also give

```text
new GENERIC GOTO_EXPR requests        <= 2L+R <= 5A+2C'
new GENERIC LABEL_EXPR requests       <= Ar+2R <= 3A
fresh shortcut LABEL_DECL requests    <= 2L+R <= 5A+2C'
direct statement-list append requests <= 3Ar+6R <= 9A.
```

Append requests remain an interface to the separate statement-list backing
transfer; an input list's element occurrences are not inferred from the
number of calls. Predicates, then bodies and else bodies are forwarded rather
than copied by these routes. `gimple_boolify` mutates truth/comparison types
and their children without allocation on the stated Boolean frontier
(`:5391–5470`). If a different producer introduces a non-Boolean leaf, account
for its `fold_convert_loc` request and result shape separately.

Combining normal conditional tuples with every generated jump/label, even
when label hijacking later removes them, gives the following sufficient raw
control interface:

```text
raw control GIMPLE tuples             <= 12C'+13A
fresh control LABEL_DECL requests     <= 8C'+8A
maybe_fold_stmt control entries       <= 2C'+A
value-conditional VAR_DECL requests   <= C'
value/distributed assignment wrappers <= 2C'
raw assignments from those wrappers   <= 2C'.
```

The final assignment row excludes child arithmetic materializations and
ordinary source stores. Its wrappers have four operand slots per conditional
at most, and its raw assignments at most six. All outputs of GIMPLE folding
remain a separate obligation.

Condition coverage is disabled on the retained invocation. Both condition
association helpers return before allocating a hash map
(`gimplify.cc:113–124,5537–5547`). `next_cond_uid` nevertheless increments its
unsigned counter, starting at one for each function. Normal tests and
shortcut-root entries together request at most `Q+A<=2C'+2A` identifiers.
Requiring that bound below UINT_MAX preserves a nonzero next value. Those
same entries bound this component's nested conditional-context pushes; add
any other producer's pushes before applying the signed-int peak check
(`:469–488`). These are representation/counter checks, not execution-time or
aggregate-memory limits.

## Checked-overflow calls preserve a conditional sharing boundary

Let B2 count actual checked Integer32 binary-helper entries with two
nonconstant operands. It is a subset of the checked-binary events already
charged above, including any actual source-visit replay. For each such entry,
`trans.cc:10134–10146` creates at most one two-actual ADD/SUB/MUL_OVERFLOW
internal call and requests `save_expr` around it, with the result shared by REALPART and
IMAGPART. This fixes the constructor contribution to the source-to-GENERIC
graph: one call identity and two incoming references to the save result.

The SAVE is **not unconditional**. These three IFNs have ECF_CONST
(`internal-fn.def:520–522`). `process_call_operands` can make the call readonly
and side-effect-free when its arguments are invariant; `save_expr` then
returns the call directly (`tree.cc:4080–4098,4132–4165,4257–4282`). Whole-body
unsharing can consequently produce separate calls for the two direct incoming
references. An ancestor's unsaved repeated references can contribute more
incoming occurrences too. The actual occurrence weights, not just B2, must
carry those edges through subsequent folding and unsharing. For this component
let I count the internal-call occurrences that reach value materialization,
counting each retained SAVE child once and each unprotected incoming occurrence.

There is an important difference from an ordinary call. When a value is
wanted, `gimplify_call_expr` returns immediately for these internal calls,
**before gimplifying their arguments** (`gimplify.cc:4653–4654`). Consequently
`internal_get_tmp_var`'s unshare is not necessarily a copy of a shallow call.
It can copy the ordinary operand forest beneath that call. A per-call constant
copy bound, or multiplying by a lowered argument count of two, is unsound.

The first unresolved retained SAVE enters `get_initialized_tmp_var` with
`allow_ssa=gimple_in_ssa_p(cfun)=false` at initial lowering
(`:7758–7799`). That helper makes one complex VAR_DECL, one INIT_EXPR and one
`unshare_expr` of the call. The assignment path then gimplifies each actual
once, pushes the two lowered actuals into an `auto_vec<tree>`, and creates one
GIMPLE_CALL (`:7547–7566`). An unprotected occurrence follows the ordinary
value-materialization route; it likewise requests one temporary/INIT, but can
use an SSA_NAME instead of a VAR_DECL. The internal-call constructor has `nargs+3=5`
operand positions (`gimple.cc:328–340`). The direct event interface is

```text
complex result materializations       <= I
INIT_EXPR requests                    <= I   (2*I operand slots)
raw internal GIMPLE_CALL requests      <= I   (5*I operand slots)
two-element temporary-vector requests  <= I
actual first-lowering requests         <= 2*I
maybe_fold_stmt entries                <= I.
```

In a combined inventory, count each retained SAVE identity once. Use this
call output instead of applying the ordinary-arithmetic assignment row to
that identity. Each temporary requests at most one SSA_NAME or VAR_DECL;
retain both conservative identity allowances when joining the materialization
helper. Actual-expression lowering, declaration/vector backing and the folder's replacement sequence
remain separate charges. Later complex lowering must also consume the
complex temporary and REALPART/IMAGPART occurrences.

For copy accounting, let Wj be the ordinary incoming-edge weight of the jth
materialized overflow call and its arguments, stopping at types, declarations,
constants and protected SAVE/TARGET/BIND identities. Ordinary `unshare_expr` passes no
protected-node visitation set, so it does not enter their children
(`gimplify.cc:944–973,1097–1101`). It copies at most Wj nodes and the matching
operand-position weight. Therefore

```text
additional overflow-materialization copy nodes <= U = sum_j Wj.
```

U is a computable weighted-tree transfer. Within each ordinary cut region,
sum the children's U values and add the current region's W value when its root
is an internal call that will materialize. Equivalently, each ordinary node
is charged once for each such call ancestor, including itself. Protected-node
children are separate roots and reset that ancestor count. The analogous
recurrence applies to operand positions. Only when all the materialized call
roots are distinct SAVE children are their regions disjoint and `U<=W` follows.
With elided SAVEs, use the recurrence rather than asserting linearity or
charging every call the size of an entire unrelated function. Repeated
references to one retained overflow SAVE do not add another Wj:
after resolution they return its temporary without reentering the child.
This copy allowance charges discarded original objects too; it does not
claim that both the original and copied actual expressions execute.

### Direct nonbuiltin scalar calls have only shallow replay

For comparison, take a direct nonbuiltin call whose function is its canonical
ADDR_EXPR, whose result is void or a nonaddressable register scalar, and whose
actuals lower to integral constants, nonvolatile scalar declarations without
VALUE_EXPR, or SSA_NAMEs. There is no static chain, aggregate actual,
lvalue-result request, variadic pack,
OpenMP variant or returns-twice flag in this specialization. These premises
are narrower than the complete Silver call frontier: String descriptors,
reference adaptation and builtin memcmp/memcpy/alloca still require their
own transfers.

The ordinary call path lowers each actual before returning a value call,
wrapping its function address in a NOP that remembers the original type
(`gimplify.cc:4886–5013`). `fold_call_expr` returns without a transformation
for a nonbuiltin callee (`builtins.cc:11051–11089`). A standalone call needs
one visit; a direct scalar assignment one; a SAVE materialization at most two;
and general value materialization at most three: the initial visit,
`internal_get_tmp_var`'s register-RHS visit, and its INIT's RHS visit. After the
first visit, later actual visits see the already lowered scalar leaves. The
canonical function-address NOP is stripped before another is inserted.

For X such occurrences and P total actual positions, a sufficient direct
interface is `3X` call-helper visits, `3P` actual visits, `3X` NOP requests,
X result-materialization requests, X INIT requests, X raw GIMPLE_CALLs with
`P+3X` operand positions, and X GIMPLE-folder entries. A discarded noreturn
SSA destination can additionally request one GIMPLE_NOP per call
(`:7585–7598`). The source call and its argument subtrees are consumed only
once; repeated helper visits are not repeated original argument traversals.

If a result temporary is needed, its one unshare sees at most the CALL_EXPR,
the type-preserving NOP and the direct ADDR_EXPR, for at most `3X` copied
ordinary nodes and `P+5X` copied operand positions. Scalar leaves, the
FUNCTION_DECL, its type and the call-length constant are cut points. The
GIMPLE constructor also requests one `build_fold_addr_expr` per direct call
(`gimple.cc:251–263,385–405`); its address/pointer-type transfer is still
charged separately. Count the temporary's SSA_NAME/VAR_DECL choice using
the earlier materialization interface, with SAVE requests selecting VAR_DECL.

## String and descriptor reference gimplification

Aggregate VIEW_CONVERT_EXPR, ARRAY_REF/ARRAY_RANGE_REF and COMPONENT_REF enter
`gimplify_compound_lval`; a VIEW_CONVERT between register types instead lowers
its operand as a scalar (`gimplify.cc:20411–20429`). The compound helper
(`:3523–3727`) walks the operand-zero reference spine into a stack, processes
metadata, lowers the innermost base once, then lowers each index and annotation.
It retains the reference nodes; it does not copy the String payload or rebuild
one reference per character. Generic folding of an encountered INDIRECT_REF,
declaration aliases, metadata substitution and later materialization are
separate edges in this transfer.

Let S be actual compound-helper entries, A the ARRAY_REF/ARRAY_RANGE_REF stack
entries, C the COMPONENT_REF entries, and V the other selected handled entries
(aggregate views and complex projections). Let R=A+C+V. Count entries after
any initial indirect folding or declaration-alias expansion, so generated
reference wrappers are included. With J actual declaration-alias expansions:

```text
reference-stack pushes                      = R
innermost base-lowering requests            <= S
index-lowering requests                    <= A
low-bound / element-size lowering requests  <= 2A
component-offset lowering requests         <= C
initial indirect-fold requests             <= R+S+J
optional addressability preparations        <= S
outer component canonicalizations          <= S.
```

There is one stack with ten inline entries per active helper. Its dynamic
backing follows the existing vector-capacity transfer, using its maximum
actual spine length; R is the cumulative push count, not a simultaneous
capacity. For the String/descriptor memory frontier, the base is a nonregister
lvalue, so the helper's alternate repeated scalar-register projection route
is absent. Complex projections over a register use the scalar transfer.

### Reference metadata is a real copy edge

For each absent array annotation the helper asks `array_ref_low_bound` or
`array_ref_element_size`; an absent field annotation asks
`component_ref_field_offset`. These readers substitute placeholders in the
existing type bound/element size/field offset
(`tree.cc:13147–13192,13390–13415`). Their explicit-annotation multiplication
branches are not entered here, since the caller has just tested the slot null.
The absent-domain fallback requests at most one integer constant per array.

The lower bound is unshared **before** the invariant test, even when it will
not be attached to the array reference. Noninvariant element sizes and field
offsets are also unshared, then divided by their alignment unit
(`gimplify.cc:3591–3640`). Accordingly the general metadata interface is

```text
placeholder-substitution requests          <= 2A+C
metadata unshare requests                  <= 2A+C
alignment integer requests                 <= A+C
EXACT_DIV size_binop requests               <= A+C
fresh ordinary metadata copy nodes         <= sum_j W(metadata_j).
```

W is the ordinary incoming-edge copy weight with type/declaration/constant and
SAVE/TARGET/BIND cut points. The last sum includes the unconditional lower-bound
requests, including discarded copies. Substitution outputs are weighted after
substitution. These are additional roots, not descendants that can be omitted
from the executable-expression count.

The selected natural-layout Character element has constant byte size one;
the fixed descriptor's field offsets are constants. Once those layout premises
are discharged, their noninvariant branches contribute zero metadata copies,
zero alignment divisions and zero alignment constants. Only the lower-bound
copy edge remains. For a local constrained String type whose declaration has
already passed `gimplify_type_sizes`, a placeholder-free lower bound is a
constant or VAR_DECL: declaration processing runs type-size lowering first,
arrays recursively lower their index type, and `gimplify_one_sizepos` preserves
or produces those leaves (`:2132–2154,21623–21652,21714–21741`). Such a bound's
unshare has zero ordinary copy weight. This conclusion is conditional on that
ordering and does not apply to a fixed unconstrained descriptor's placeholder
bound or an anonymously generated type with no preceding declaration. Those
roots retain their substitution and copy weights.

### Address and declaration-alias preparation

`gimplify_addr_expr` (`:7811–7918`) has a bounded local helper interface per
actual invocation: at most one operand-lowering request, one addressability
preparation, one `build_fold_addr_expr` request and one `fold_convert` request.
The original INDIRECT_REF or zero-offset MEM_REF alternative skips operand
lowering; the VIEW_CONVERT alternative consumes that view and takes the inner
address. The default route may rebuild a mismatched address or remove a newly
exposed indirection after lowering. These are alternatives, not cumulative
extra calls. A rewritten expression reenters the ordinary gimplifier and its
folder output remains part of the actual occurrence vector.

Pointer conversion has one additional reference producer:
`canonicalize_addr_expr` (`:3320–3364`) may replace a pointer-to-array cast with
one ARRAY_REF and one ADDR_EXPR, with five total operand slots. It first
requests one pointer type and may finish with one fold conversion. Its new
ARRAY_REF uses a constant lower bound and constant element size. The sibling
`canonicalize_component_ref` (`:3264–3305`) changes the retained reference's
type and may request one qualified type; despite its old introductory comment,
the current implementation constructs no NOP_EXPR. These producers feed R
above; they are not attributed to source-level indexing.

`prepare_gimple_addressable` (`:5835–5843`) walks existing reference wrappers
without copying them. If the terminal base is a register, it creates at most
one non-SSA temporary using `internal_get_tmp_var`. At this call the value is
already a scalar declaration or SSA leaf, so its unshare does not copy a deep
reference graph. Charge one VAR_DECL, one INIT wrapper and one scalar raw
assignment, plus the existing naming/UID/fold transfers. A base already in
memory adds none of these requests.

A declaration alias is different: `gimplify_var_or_parm_decl` unshares the
whole `DECL_VALUE_EXPR` (`:3409–3442`). Charge one copy request and its actual
ordinary graph weight per alias expansion, including the restart into the
compound reference loop. Main's ordinary VLA lowering installs an INDIRECT_REF
of a fresh pointer variable (`:1971–1995`), so that particular replacement has
one ordinary node and one operand slot; it does not replay a String initializer.
The gigi debug-renaming replacement instead has an INDIRECT_REF and NOP_EXPR
over an integer constant (`decl.cc:772–787`). Its two-node graph has no nested
declaration alias. The other gigi writers are Out-parameter debug aliases and
named-return-value substitution (`decl.cc:1643–1657`, `trans.cc:3540–3585`),
outside Main's zero-formal void bodies; OpenMP alias installation is also
excluded. This accounts for the relevant variable Main aliases without
assuming every scalar declaration in every compiler phase is alias-free.

Finally, later scalar/address materialization can unshare a **whole normalized
reference spine**, not merely its outermost wrapper. Its metadata and index
operands have then been lowered, but the lvalue spine remains. Retain the
sum of those actual spine weights in the materialization interface.

### Plain String stores and aggregate equality

After surrounding statement/conditional/call wrappers have been handled,
consider a plain nonvolatile String store whose RHS is a STRING_CST or an
ordinary memory reference, possibly with aggregate view conversions. These
are the array-to-array stores; descriptor CONSTRUCTOR initialization and
aggregate-returning CALL_EXPR are separate families. Gigi represents the
literal payload by STRING_CST, not a per-character CONSTRUCTOR. A read-only
String declaration initialized by STRING_CST therefore does not enter the
constructor replay case at `gimplify.cc:6887–6919`.

Let M count actual plain-store occurrences reaching this phase, including any
stores introduced by prior conditional distribution. The statement's value is
unused. Once the RHS reference normalization has finished, the main path in
`gimplify_modify_expr` (`:7315–7510`) requests at most one LHS lowering and two
RHS lowerings: the second is only for a changed LHS predicate. Reference
normalization itself, including repeated indirect folding while the RHS shape
changes, remains charged by the reference/folder occurrence interface. It is
not a claim that arbitrary folder rewrites take only two steps.

Each variable-size store requests at most one WITH_SIZE_EXPR wrapper with two
operand slots. `maybe_with_size_expr` first unshares the existing TYPE_SIZE_UNIT,
then substitutes placeholders, then builds the wrapper (`:3830–3851`):

```text
WITH_SIZE_EXPR requests and size-unshare requests  <= M each
size placeholder-substitution requests            <= M
ordinary size-copy nodes                          <= sum_j W(size_j).
```

Here W is measured **before** substitution, unlike the lower-bound copy above.
Already wrapped expressions and constant sizes return without these requests.
The WITH_SIZE_EXPR route lowers its value and size once per visit
(`:20933–20943`); its size root is additional scalar work. Pre-lowered local
type sizes are leaves, while unconstrained descriptor-size roots retain their
own weighted substitution. An empty type can instead evaluate the operands for
side effects and discard the store.

A nonempty fixed-size memory store ends in one raw two-operand GIMPLE_ASSIGN
and one `maybe_fold_stmt` request (`:7593–7614`). A variable-size store between
addressable lvalues instead enters `gimplify_modify_expr_to_memcpy`
(`:5847–5891,7495–7507`). Its local interface is one addressability preparation,
two address-fold requests, two argument-lowering requests, and one raw
three-actual GIMPLE_CALL with six operand slots. Because the statement result
is unused, there is no returned-pointer temporary or result MEM_REF. The two
terminal choices are disjoint:

```text
raw plain-store GIMPLE_ASSIGN + raw memcpy GIMPLE_CALL <= M
raw plain-store statement operand slots               <= 6M
store-triggered address-fold/argument requests          <= 2M each
store-triggered addressability preparations             <= M
raw-assignment maybe_fold_stmt requests                 <= M.
```

These raw statement counts exclude instructions generated while lowering
addresses, indices and size expressions. They do not price later builtin
expansion or machine block moves. The memset and element-by-element
CONSTRUCTOR routes are not silently used for a String literal.

Array equality has a second split that depends on the actual GCC mode, not on
whether the source length was static (`:21253–21288`). For each aggregate
EQ_EXPR/NE_EXPR, `gimplify_scalar_mode_aggregate_compare` requests two folded
VIEW_CONVERT_EXPRs and one folded scalar comparison (`:7661–7710`). EQ/NE skip
the ordering-only byte-swap block completely. The scalar type lookup, folder
results and view/reference operands have their ordinary transfers.

For a non-scalar-mode array,
`gimplify_variable_sized_compare` (`:7630–7651`) instead requests:

```text
one size-root unshare, then one placeholder substitution;
two build_fold_addr_expr helpers;
one three-actual memcmp CALL_EXPR (six operand slots);
one plain scalar EQ/NE node (two operand slots).
```

This helper does not scan the array bytes. Its memcmp call enters builtin-call
folding and gimplification, so the earlier **nonbuiltin** scalar-call bound
cannot be substituted. Size copies, scalar-mode view folding, constructor
initialization and eventual memcpy/memcmp expansion remain distinct joins.

## Concrete null Main body: source to initial GIMPLE

The [native specialization](retained-native-expansion.md#null-and-one-literal-put-have-no-secondary-stack-scaffold)
establishes that the exact 64-byte null fixture in the
[producer specialization](retained-producer-zero-check-sources.md#null-source)
has one Main body, no local objects/types, no transient block, no secondary-stack
mark/release/finalizer and one implicit bare return. Thus its actual scaffold
has F=1, not the general upper bound two. This subsection composes the **executed
Main body**, with the compilation-unit elaboration scaffold, fixed imported
type/declaration conversion and compiler initialization retained separately.

At the selected O0, source `null` is not erased by gigi.
`trans.cc:7736–7753` builds a fresh LABEL_DECL, GOTO_EXPR and LABEL_EXPR. The
label helper inserts the declaration through `gnat_pushdecl`
(`utils.cc:3660–3671,894–990`), which requests a DECL_EXPR
(`trans.cc:9117`) and links the label into the current body's BLOCK_VARS.
All four unary statement kinds have side effects by construction, so their
statement-list appends are retained (`tree.cc:5194–5230`). The implicit bare
return requests one RETURN_EXPR (`trans.cc:3848–3906,8119–8146`).

The label is a local declaration even though it is not a local variable. Its
presence prevents the body block from taking the empty-block merge route in
`gnat_poplevel`; `end_stmt_group` therefore requests a BIND_EXPR around the
four statements (`utils.cc:744–767`, `trans.cc:9255–9276`). The local graph is

```text
BIND_EXPR(vars = label, block = body block)
  STATEMENT_LIST
    DECL_EXPR(label)
    GOTO_EXPR(label)
    LABEL_EXPR(label)
    RETURN_EXPR(null)
```

The source-null group has two members; appending it into the handled-statement
group splices its links instead of retaining a nested STATEMENT_LIST
(`tree-iterator.cc:63–86,188–233`). The body adopts that handled list. The
SPARK_Mode pragma can request one empty list, which contributes no executable
statement. Consequently the local cumulative constructor interface is

```text
direct executable expression nodes = 5
direct executable operand slots   = 7
LABEL_DECL requests               = 1
statement-list header requests   <= 3
statement-list link requests      = 4
binding-level/BLOCK requests       = 3 including the unit elaboration level.
```

The three bindings are the compilation-unit level plus Main's framework and
body levels. Only the body BIND is included in the five executable nodes above;
the unit's elaboration BIND and Main's FUNCTION_DECL/RESULT_DECL construction
remain outside this executed-body row. No user literal payload, variable
bound, arithmetic operator, overflow check, array/reference conversion,
ordinary call or cleanup is hidden in the row.

For whole-body unsharing, the ordinary copy weight is W=4: the four unary
statements. The BIND is a protected cut root, and STATEMENT_LIST headers and
links are preserved by this pass. Types and the repeatedly referenced label
declaration are also cut points. The
[general whole-body transfer](retained-backend-capacity.md#expression-unsharing-preserves-payload-and-save-boundaries)
therefore permits at most 12 further ordinary expression nodes and 12 operand
slots, with no new labels, types, constants, list headers or links. This is a
conservative lifetime allowance, not a claim that the initially unshared null
body actually needs all twelve copies. The executed-body subtotal is at most
17 expression nodes, 19 operand slots, three list headers and four list links.
That graph has no symbolic folder entry; fixed imported type/layout work may
still have such entries and has not been paid by this subtotal.

Initial gimplification drops the label's DECL_EXPR without constructing a
statement (`gimplify.cc:2124–2225`). The direct GOTO and LABEL each request one
tuple (`:20695–20718,3165–3185`), and the bare return requests one GIMPLE_RETURN
(`:1872–1891`). The label has no hot/cold attribute and the return is outside
a conditional context, so neither path adds a prediction tuple. There is no
VAR_DECL to clobber or dynamic storage to restore. One GIMPLE_BIND contains
the resulting sequence; `gimplify_body` reuses it rather than adding a second
outer bind (`:21789–21836`). Thus

```text
initial raw GIMPLE = 1 GOTO + 1 LABEL + 1 RETURN + 1 BIND = 4 tuples
raw tuple bytes   = 64 + 64 + 80 + 72 = 280 bytes on selected LP64.
```

The RETURN uses the memory-operands structure, not the smaller register-operands
structure (`gimple.def:51–57,135–145`); the
[tuple-size transfer](retained-backend-capacity.md#raw-gimple-tuples-use-individual-operand-arrays)
supplies those bytes. These are individual raw requests before GC rounding,
not aggregate RAM or emitted-code bounds. Generic lowering/CFG, O0 mandatory
passes, fixed compiler graphs, target expansion and linker work remain needed
for whole native closure. Together with the producer's zero Main Why3 tasks,
the fixture now has concrete zeros and small counts at two backend interfaces;
neither interface substitutes for the intervening or fixed work.

### The same null body through CF, EH, CFG and initial SSA

The initial four-tuple graph above gives a concrete input to the existing
[CF/EH transfer](retained-backend-capacity.md#o0-cleanup-lowering-no-recursive-body-duplication)
and [CFG/SSA transfer](retained-backend-cfg.md). This specialization counts
the executed Main function. Fixed setup, imported declarations, other functions,
pass objects and later passes still have their own costs.

`lower_gimple_bind` splices its existing body into the outer sequence and
removes the BIND. Its `record_vars` ignores the sole LABEL_DECL, so it adds no
entry to `local_decls` (`gimple-low.cc:908–982,1438–1468`). The initial goto
sets `cannot_fallthru`, but the following label clears it. Thus the implicit
return is retained and lowered normally (`:695–810`). There is one new return
label, one new goto and one new GIMPLE_LABEL; the original GIMPLE_RETURN is
reused after the new label. The return-record vector is created with capacity
eight and receives one record (`:122–214,1178–1223`). The exact flat output is

```text
goto L_null
L_null:
goto L_return
L_return:
return
```

CF therefore allocates two additional raw tuples and one LABEL_DECL. Its
cumulative raw-tuple subtotal, including the now detached BIND, is six tuples
and `280+64+64=408` bytes on the selected LP64 layout. It makes no arithmetic
expression or symbolic-fold request for these statements.

EH refactoring encounters no TRY node. EH lowering still does **fixed
analysis work**: it creates the finally hash table with requested size 31,
inserts the two labels as `finally_tree_node` records, and allocates one
`eh_region_may_contain_throw_map` bitmap header
(`tree-eh.cc:200–259,2241–2285,3351–3401`). The entries' parent is null.
Both gotos and the return immediately leave `maybe_record_in_goto_queue`
because `state->tf` is null (`:702–715`). The label default case does nothing.
No EH region, landing pad, cleanup copy, queued goto or replacement statement
is created. The flat five-statement graph is unchanged.

Initial CFG construction puts these statements into exactly three ordinary
blocks: the first goto, the first label and second goto, and the final label
and return (`tree-cfg.cc:488–555`). It allocates four edges, including entry
and exit; simple-goto edges replace the two goto statements
(`:810–840,1370–1388`). Together with the fixed entry/exit blocks, this gives
five block-index slots. The block and label maps retain their existing
20-entry initial requests, and at most two label UIDs are assigned. The two
dead-label scans allocate arrays of five `label_record` entries. They may
remove labels after the gotos have gone; they create no statements
(`:145–215,1507–1547,1664–1700`). General discriminator accounting specializes
to at most `S+E=5+4=9` requests and counter increment ceiling
`S+2B+E=5+6+4=15`.

Do not assume O0 merges this path into one block. The CF pass may mark the
return label nonartificial to preserve its location, and the CFG merger
preserves nonartificial labels and certain goto locations at O0
(`gimple-low.cc:1213–1221`, `tree-cfg.cc:1880–1929`). The sufficient retained
ceilings are three ordinary blocks, four edges and three statements: at most
two labels and the one return. The path has one predecessor and one successor
per ordinary block. Forwarder removal returns before redirection on this
shape (`tree-cfgcleanup.cc:476–519`); block merging can only shorten the path.
There is no switch, PHI, forced label or abnormal edge. The merger's possible
new debug binding for a nonartificial label is excluded by its O0 merge guard.
Consequently the initial cleanup creates **zero** labels, statements, blocks
or edges; its general `B*E` fresh-label allowance specializes to zero. Loop
discovery finds no real loop, while retaining its ordinary root-loop and
analysis containers. The [CFG component](retained-backend-cfg.md) prices those
containers with `B=3`, `E=4`, `N=5`.

The first CFG fixup adds nothing on this graph. There is no call/LHS/store,
EH association or abnormal edge, and every ordinary block has a successor,
including the return's exit edge. Its unreachable-call insertion guard is
therefore false. Its dead-code worklist stays empty and its returned TODO
flags are zero (`tree-cfg.cc:10017–10138`). Profile-field maintenance and the
empty worklist header remain fixed pass work.

Initial SSA is **not zero work**, even for a bare return. It creates the
artificial `.MEM` VAR_DECL. Operand scanning explicitly appends a virtual use
to `GIMPLE_RETURN` before scanning its null value operand
(`tree-ssa-operands.cc:228–278,951–995`). The labels contribute no use or
definition. The resulting one use creates one `var_info` and its three
block-bitmaps; there is no ordinary or virtual definition. The CFG remains a
straight path, so its dominance frontiers are empty
(`cfganal.cc:1639–1668`). No PHI is inserted. Renaming the one use requests one
default memory SSA_NAME and its detached GIMPLE_NOP
(`tree-into-ssa.cc:648–704,1203–1228,1337–1411`, `tree-dfa.cc:353–365`). The
returned value is still null; the memory name is analysis metadata.

```text
SSA-entry ordinary blocks / edges / live statements <= 3 / 4 / 3
new .MEM declaration / default SSA_NAME / detached NOP = 1 / 1 / 1
new PHIs / nondefault SSA_NAMEs / executable statements = 0 / 0 / 0
SSA operand use entries = 1
SSA-name vector logical length = 2, including reserved slot zero
```

The return's use entry consumes the first 1,024-byte operand slab, even though
only one 40-byte entry is live (`tree-ssa-operands.cc:424–485` and the
[operand-cache transfer](retained-backend-cfg.md#operand-caches-worklists-and-arithmetic)).
The existing 50-slot SSA-name initial backing does not grow. Other SSA
containers use `n<=5`, `v=1`, `d=0`, `P=0`, `u=1`; the local-declaration hash
constructor receives zero because labels are not variables. Its minimum
hash backing, dominator walkers, bitmap headers, root-loop data and allocator
rounding are still charged through their existing transfers. SSA's source
code supplies no symbolic arithmetic folding for this graph. The O0
unused-local TODO returns without change as established in the CFG component.

This closes the null body's **shape join through initial SSA**, including
the otherwise easy-to-miss memory use. It does not close the intervening
whole-unit IPA bookkeeping or subsequent warning/mandatory-lowering passes,
out-of-SSA, RTL, object emission or linking. The offline checker pins the
stated source branches and arithmetic; it does not run these passes or infer
compiler success from this fixture.

### Null Main through the remaining O0 GIMPLE stages

Continue with three ordinary blocks, four edges, at most two labels and a
bare return, one default `.MEM` SSA name, and no local variables. This is a
**conditional per-function join**: whole-unit IPA must preserve this incoming
body, the selected native options must remain O0 without instrumentation, and
the selected target must use `default_instruction_selection`. In particular,
this does not assume that the compilation unit has no global variables: gigi's
dummy hard-register varpool symbol belongs to the separate whole-unit account.

The three optimization superpasses require `optimize>=1` and are skipped
(`passes.cc:519–610`). The pass registrations nevertheless include active
warnings, local summaries and mandatory lowering (`passes.def:54–122,195–208,
432–461`). The following branch audit preserves the input shape:

- Early inlining finds no callees, including no always-inline callee. Ordinary
  early inlining is disabled at O0 (`ipa-inline.cc:3009–3059,3215–3360`). The
  two local function summaries still allocate/update their summaries and scan
  the body; their O0 path omits stack-size estimation and optimizing analyses,
  not the entire pass (`ipa-fnsummary.cc:2856–2920,3386–3540`). Summary storage
  belongs to the whole-unit account. SSA-name release only compacts the
  existing vector (`tree-ssanames.cc:983–1013`).
- Alignment has no local declarations to visit. EH dispatch has no dispatch
  or RESX statements, and RESX lowering likewise finds none. However
  `assign_filter_values` unconditionally requests a 16-entry type vector,
  a 64-entry exception-specification vector and two hashes of requested size
  31, even with no regions (`except.cc:852–866`). The later EH cleanup gate
  requires a region tree (`tree-eh.cc:5015–5018`).
- Varargs lowering finds no IFN_VA_ARG; vector lowering finds no assignment or
  vector-conversion call; complex lowering's initial scan returns with no
  complex operation; bitint lowering finds no bitint name or statement and
  returns before its transformation. O0 switch lowering collects no switch,
  while still requesting its initial one-entry statement vector. The
  unconditional SSA/CFG TODOs do not invent a definition or branch on this
  unchanged straight path. These are the concrete no-transform cases in
  `tree-stdarg.cc:995–1104`, `tree-vect-generic.cc:2461–2490`,
  `tree-complex.cc:215–331,1994–2002`,
  `gimple-lower-bitint.cc:6943–6997` and
  `tree-switch-conversion.cc:3045–3092`.
- Assumption-function, SIMD-ID and musttail gates are false on this body.
  NRV requires optimization. The selected configuration has no OpenMP,
  OpenACC, TM, sanitizer, vtable-verification or hardening instrumentation.
  GIMPLE instruction selection first calls the target hook; its selected
  default returns false. Both generic vector helpers reject these statements,
  and the subsequent noncall/nonassignment branch continues without change
  (`gimple-isel.cc:63–73,174–183,1350–1393`,
  `targhooks.cc:2787–2790`). The target-hook premise is deliberately explicit;
  the generic pass alone does not establish it for arbitrary targets.
- Nonnull comparison has no formal parameters. The selected warning options
  leave uninitialized, format-overflow/truncation and recursion warnings
  disabled. In particular, do not treat O0 uninitialized warning as an empty
  scan if later enabled: it can invoke value numbering. The final noreturn
  warning sees the existing exit predecessor. Final CFG cleanup has no
  unreachable call or abnormal/critical edge and preserves the path bounds
  (`tree-cfgcleanup.cc:1413–1485`).

The bound entering out-of-SSA remains `b<=3`, `e<=4`, `t<=3`, `num_ssa_names=2`,
`local_decls=0`. This is a shape result, not zero pass cost or a byte bound on
all mandatory setup. The source checker pins the cited branches; configuration
and whole-unit preservation are separate join premises.

#### Warning and expansion range-cache setup remains payable

The alloca warning enables a ranger before looking for alloca calls
(`gimple-ssa-warn-alloca.cc:258–273`). Its normal limit gate admits the default
limit after adjustment to PTRDIFF_MAX (`:81–88,149–161`). Both early and late
access warnings also enable a ranger; `warn_free_nonheap_object` enables them
in the selected configuration. Their statement checks return for labels and
a bare return. The early instance still runs dangling-use/store scans,
including a bitmap, an empty store hash and an inline-eight worklist requested
with `n_basic_blocks+1<=6` (`gimple-ssa-warn-access.cc:2270–2275,4480–4537,
4733–4760,4857–4904`). Its visited set includes the entry block, so path depth
is at most four. Each access invocation computes both dominator directions
and DFS backedges. Those graph-sized costs do not disappear with empty
pointer-check work.

Expansion creates another ranger unconditionally. There are therefore at most
four ranger instances in this selected continuation: alloca, two access
warnings, and expansion. At the warning sites the block-index bound is five;
at expansion the initialization block has already been added, so use **six**.
No instance requests a scalar range from the null body. Its mandatory setup
still has the following typed request bounds, per instance, with `n<=6` and
`s=num_ssa_names=2`:

| Setup object | Requested logical extent |
| --- | ---: |
| Ranger temporary-statement vector | `s=2`, then truncated |
| Block-range pointer vector; temporal timestamp vector | `s=2` each |
| GORI definition-chain vector | `s=2` |
| GORI incoming/outgoing vectors | `n<=6` each |
| GORI incoming/outgoing bitmap headers | `2*n<=12` |
| GORI maybe-variant bitmap | 1 header |
| Infer exit vector; cached nonzero vector | `n+1<=7`; `s+1=3` |
| Infer seen bitmap | at most 1 header |
| Propagation update vector and bitmap | `n+64<=70`; 1 header |
| Optional dominator-oracle equivalence/relation vectors | `n+1<=7` each |
| Optional dominator-oracle self/partial vectors | `s+1=3` each |
| Optional dominator-oracle bitmaps | 5 headers |

`ranger_cache` contains a global SSA cache and block-range cache; each creates
one range allocator, and the infer manager creates a third. Each allocator
selects an obstack allocator by default. The infer list always initializes
another obstack; the optional equivalence oracle initializes its chain
obstack. These object and chunk allocations, bitmap backing, vector growth
rounding and the two Boolean ranges in `gori_compute` still need their typed
allocator sizes. The global SSA-cache vector remains empty. The outgoing
switch-range helper starts with null table and allocator pointers.

The relevant constructors are `gimple-range.cc:40–66`,
`gimple-range-cache.cc:366–373,540–545,828–835,940–948,998–1022`,
`gimple-range-gori.cc:96–103,359–366,479–523,582–599`,
`gimple-range-infer.cc:331–351`, `value-query.cc:194–255`,
`value-relation.cc:312–330,1064–1073`, and
`value-range-storage.cc:47–56,82–88`. Every existing block has one successor
except the exit, whose terminal statement is absent. `calculate_gori`
therefore stops after its two bitmap headers, without a definition chain,
range demand or switch-table allocation. No `sbr_vector` is created merely
by constructing `block_range_cache`.

#### Out-of-SSA selects no real partition

The default `.MEM` name is virtual and its variable is ignored. There is no
formal parameter, static chain, nonvoid result, PHI, assignment, call, asm or
clobber. `rewrite_out_of_ssa` and its parameter/default-definition loop add
none (`tree-outof-ssa.cc:919–944,1057–1088,1382–1405`). `init_var_map` requests
a partition of two and at most three block pointers. The coalesce constructor
still allocates its record, a requested-size-40 hash and an obstack, and
same-variable population constructs a requested-size-10 hash. No coalesce
pair is added. Partition-view selection excludes the virtual name, yielding
zero real partitions (`tree-ssa-live.cc:84–117,198–230`).

The optimized-base helper still constructs its zero-element tentative
partition and zero-length mapping requests. `coalesce_ssa_name` then returns
before liveness analysis, conflict-graph construction, pair sorting or
coalescing (`tree-ssa-coalesce.cc:1601–1742,1843–1871`). Normal partition view
again selects none. Parameter/default and undefined-value bitmaps are empty.
No fresh GIMPLE statement, name, label, edge or RTL copy is generated.
Temporary-expression replacement is disabled at selected O0; this condition
is part of the selected-option premise, not inferred just from the body.

`expand_phi_nodes` nevertheless constructs its elimination graph. The vector
constructor requests are 30, 20, 10, 30, 20, 20 and 10, and its visited bitmap
has zero partition bits (`tree-outof-ssa.cc:433–438,1012–1049`). No PHI means
no copy, edge insertion or splitting. `partition_to_pseudo` has requested
length zero; allocator minimums remain distinct from logical emptiness.

#### Executed body expansion adds labels and notes only

Before expanding the final GIMPLE block, `expand_gimple_basic_block` removes
the bare return when its next block is EXIT, turning the edge into fallthrough
(`cfgexpand.cc:6167–6206`). This condition holds for the last block of the
straight path. Consequently this body makes **zero** `expand_null_return`
calls. The actual function-return machinery is a separate entry/exit phase.

At most two remaining GIMPLE labels each allocate one CODE_LABEL through
`label_rtx`; neither label is forced or nonlocal (`stmt.cc:96–109,157–179`,
`emit-rtl.cc:2873–2878`). Every ordinary block receives one BASIC_BLOCK note.
All successors are the next block, so the implicit-goto footer emits no jump.
The last emitted item is a note or label, so its dummy-move guard is also
false (`cfgexpand.cc:6495–6566`). With no call or dynamic allocation there is
no pending stack adjustment from this body. Thus its direct contribution is
at most **two RTL labels and three block notes**, no value-expression
expansion, arithmetic, load, store, call, barrier or jump.

This excludes the separately payable function framework. In particular,
`expand_used_vars` can allocate the selected target's PIC pseudo despite no
real SSA partitions or locals (`cfgexpand.cc:2466–2500`). Function start
allocates a return label and establishes parameter/target state. The
initialization block adds one block and one split edge (`:6574–6615`). Function
end emits its return label and may emit a blockage for non-call exceptions;
void result suppresses scalar result transfers, not all target work
(`function.cc:5104–5220,5400–5646`). Constructing the exit block adds at most
one block and edge (`cfgexpand.cc:6633–6701`). This gives a pre-subdivision
shape ceiling of five ordinary blocks and six edges, under the separately
verified fixed entry/exit routes. Later RTL block subdivision, target stack
alignment, unsharing, epilogue generation, emission and linking are not closed
by the two-label/three-note body count.

#### Selected x86 function framework and the end of `pass_expand`

For the recorded Linux x86_64 native configuration, strengthen the preceding
body-only result with the ordinary SysV ABI, default code model and stack
boundaries, no forced realignment or target attributes, no stack checking,
stack protection, instrumentation or debug emission, and the default
`expand_to_rtl_hook`. These remain effective-configuration/source-correspondence
premises. In particular this is not an assertion about arbitrary command-line
flags or arbitrary implementations of GCC's target hooks.

The default x86_64 code model is CM_SMALL or CM_SMALL_PIC according to PIC
selection (`i386-options.cc:2273–2286`). `ix86_use_pseudo_pic_reg` is false in
both cases (`i386.cc:1795–1803`). Thus the earlier generic PIC-pseudo allowance
specializes to zero. `init_vars_expansion` still initializes its bitmap obstack
and constructs the declaration-to-stack-partition hash; the absence of local
variables does not skip that setup (`cfgexpand.cc:2371–2398`). Label declarations
in lexical scopes do not allocate object storage. No real SSA partition,
local object, dynamic allocation or protected declaration contributes a stack
slot, stack-conflict graph or variable initialization sequence.

The void result makes `aggregate_value_p` return before target return-layout
queries (`function.cc:2055–2095`). `expand_function_start` allocates one return
CODE_LABEL and gives the result null RTL. Its parameter setup has an empty
argument vector, no hidden struct-result parameter, no varargs save area and
no parameter conversions (`:2307–2330,2383–2429,3641–3880`). The selected
`ix86_internal_arg_pointer` returns the existing virtual incoming-arguments
register; cumulative-argument initialization only updates scalar bookkeeping
for this void/no-parameter signature, and the 64-bit return-pop hook returns
zero (`i386.cc:1464–1471,1874–2026,8108–8111`). The argument offset is cached
zero. There is no static chain, nonlocal goto area or profiling/stack-probe
instruction. Function start emits one FUNCTION_BEG note
(`function.cc:5214–5303`). The selected ELF initialization-section definition
makes `expand_main_function` empty even if its name test succeeds
(`cfgexpand.cc:6925–6935`, `config/elfos.h:217`).

Checked Ada enables non-call exceptions; the function captures that flag
(`gcc-interface/misc.cc:402–435`, `function.cc:4904–4907`). Function end emits
the existing return label and, for non-SJLJ unwinding, one blockage. It has no
EH-return label, stack protection, return-register transfer, naked-return label or alloca restoration.
`expand_eh_return` returns immediately without its private EH-return label
(`except.cc:2287–2293`). The x86 blockage is exactly
`UNSPEC_VOLATILE [CONST_INT 0]` with encoded machine length zero
(`i386.md:20923–20928`). The generated constructor/runtime expander creates
one UNSPEC_VOLATILE node and one one-element rtvec, reusing cached const0;
`emit_insn` adds one INSN (`genemit.cc:447–465`,
`emit-rtl.cc:4146–4158,6940–7058`). It does not create a call, symbol, jump or
hardware return at this stage. Machine prologue/epilogue return generation
belongs to later RTL passes.

The initialization and exit block constructors each add one BASIC_BLOCK note
(`cfgrtl.cc:295–390`). Add the initial DELETED note emitted by `pass_expand`,
the FUNCTION_BEG note and the body counts already established:

```text
ordinary RTL blocks <= 3 + 1 + 1 = 5
edges including entry/exit <= 4 + 1 + 1 = 6
block-index slots before compaction <= 5 + 1 + 1 = 7
CODE_LABEL allocations <= 2 + 1 = 3
NOTE allocations <= 3 + 1 + 1 + 1 + 1 = 7
INSN allocations before CFG cleanup <= 1 blockage
new dynamic pseudos / stack slots / calls / jumps = 0 / 0 / 0 / 0
```

No instruction has an internal EH landing-pad note. RTL block-boundary
scanning therefore creates no subdivision: every label is a block head, and
the blockage is neither a jump, trap nor internally throwing instruction
(`cfgbuild.cc:73–119,438–652`; `except.cc:1818–1896`). Its successor-count vector
and input bitmap still have at most seven logical entries/bits. Edge rebuilding
requests only already-existing fallthrough edges; no forced label, jump table,
call, EH target or nonlocal target is present (`cfgbuild.cc:200–380,738–807`).

Default preferred and incoming stack boundaries are both 128 bits; Main's
special minimum is also 128. The void signature and absent variables add no
larger alignment requirement. Non-call exceptions lift the initially word-size
preferred requirement to 128, which still does not require realignment.
There is no alloca, nonlocal transfer, stack-clobbering asm or outgoing argument
area to require DRAP. The x86 DRAP hook consequently returns null without
creating a pseudo or move (`i386.h:778–801`,
`i386-options.cc:2654–2685`, `i386.cc:7990–8111`,
`cfgexpand.cc:6856–6920`).

**O0 CFG cleanup can add nops.** On this path every merge is of adjacent
fallthrough blocks; there is no jump-threading or crossjump mode. The direct
fallthrough branch of `merge_blocks_move` cannot move or add blocks
(`cfgcleanup.cc:725–762`). Its RTL merger may call
`emit_nop_for_unique_locus_between` to retain a source location, independently
of debug output (`cfgrtl.cc:783–851,857–965`). Each successful merge removes
one ordinary block, so at most four nops can be requested. The target nop
pattern is cached CONST_INT zero and costs one INSN per request
(`i386.md:21055–21062`). The remaining branch-to-branch path cannot force an
edge here: threading is disabled, `onlyjump_p` is false, and ordinary branch
redirection rejects fallthrough (`cfgcleanup.cc:402–600`,
`cfgrtl.cc:1053–1093,1317–1332,1444–1471`). Cleanup can remove labels and notes,
but introduces no new labels, edges, blocks, pseudos or calls. Its dominance,
loop-repair, dataflow and manager bookkeeping still require their own storage.

The lifetime instruction-chain allocation ceiling through this cleanup is
therefore **15 nodes**: three CODE_LABELs, seven NOTEs and five INSNs (one
blockage plus at most four nops). This is cumulative allocation, not a claim
that all fifteen survive. Initial-value materialization finds no saved
hard-register/pseudo pair and returns. Final RTL unsharing visits only the
blockage and cached nop constants; registers, constants and labels are shareable.
Conservatively allow at most one additional copy of the blockage node and its
one-element rtvec if its used flag is already marked. Thus the entire
non-chain pattern allowance is at most **two UNSPEC_VOLATILE nodes and two
one-element rtvec allocations**, including construction and unsharing
(`function.cc:1348–1363`, `emit-rtl.cc:2928–2991,3189–3355`). There is no operand
DAG expansion or stack-slot/parameter unsharing on this signature.

This closes a small **RTL shape output of `pass_expand`** under the stated
entry/configuration premises. It does not price all work performed along the
way. For example, per-function preparation still requests a temporary-address
hash of size 32 and an RTL constant-pool record/hash of size 31, both empty
for this body (`function.cc:1239–1252,4941–4957`, `varasm.cc:4149–4168`).
`init_emit` requests a 198-byte alignment array and a 198-entry RTL-pointer
array, because x86 has 92 hard-register identifiers and six virtual-register
identifiers, followed by 100 spare slots. On LP64 those two raw requests total
`198 + 198*8 = 1,782` bytes before allocator rounding. They reference existing
hard/virtual REG nodes; `init_virtual_regs` does not allocate another six
(`i386.md:511`, `i386.h:990`, `rtl.h:4091–4146`,
`emit-rtl.cc:5782–5791,5979–6040`). The logical first dynamic pseudo number is
98 and does not advance in this expansion.

Other retained requests include the empty label-to-RTL hash, at most six
head/end pairs before exit-block construction, a seven-bit subdivision bitmap
and seven-entry successor vector. The general one-time `initialize_rtl`, target
state, pass-manager/GC/dataflow setup, lexical-block/location stores, allocator
rounding and subsequent RTL passes remain separate fixed obligations. The
1,782-byte subtotal and 15-node count cannot be substituted for those costs
or for an assembled-object/linker bound.

## Unresolved terms for whole-backend composition

These interfaces remove the per-call/per-type arity ambiguity; they do not yet
supply one complete, usable constructor coefficient. The remaining joins are:

1. Join the now-bounded constructor-bearing Main entity conversions with
   their synthetic GCC type and declaration helper transfers. Variable Main ordinary/initializer visits,
   diagnostic replay and normalized type-bound roots now compose into the
   source-derived linear term above. Preserve its per-kind native syntax
   counts where useful; neither that term nor the entity cache prices the
   resulting GCC helper work or the fixed imported-type frontier.
2. Join the selected conversion/address/allocator subroutes above with the
   actual wrapper/padding and constructor-field occurrence vector. Their
   source recurrence has no secondary-stack initializer recursion, but its
   input shape counts and natural-layout premises are still necessary; a
   flat cost for every possible conversion pair is not supplied here.
3. Price generic folding, `convert_to_integer`/pointer/complex, placeholder
   substitution, `max_value`/`max_size`, type/range/array layout and copy/unshare
   work on the actual incoming edge/shape vector. SAVE_EXPR protection and
   constant reuse must be retained where the source guarantees them.
4. Join declaration insertion, type language slots, identifiers/debug contexts,
   canonical tables, statement lists, constructor/actual vectors and native
   backannotation metadata. Executable operand slots do not bound these stores.
5. Apply gimplification, nested-function lowering, cleanup/CFG and target
   lowering/emission transfers. The earlier cleanup interface fixes its control
   frontier but is not an x86 machine-code or assembler bound.

No local source path found here forces a larger source-language construct or a
patched compiler. Whether the composed predicate admits a useful larger domain
still depends on closing these transfer terms without an arbitrary multiplier.
