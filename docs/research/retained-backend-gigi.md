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
uses one shared saved overflow call for REALPART/IMAGPART. `emit_check`'s
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

## Unresolved terms for whole-backend composition

These interfaces remove the per-call/per-type arity ambiguity; they do not yet
supply one complete, usable constructor coefficient. The remaining joins are:

1. Bound actual uncached entity conversions and their synthetic GCC type and
   declaration constructors. Variable Main ordinary/initializer visits,
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
