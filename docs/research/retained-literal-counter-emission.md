# Literal function and symbol counters at emission

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
The selected empty elaboration procedure contributes **zero symbol
registrations**. The complete selected function-structure sequence is
elaboration, Main, bit-size helper, byte-size helper: their definition
numbers are respectively **0, 1, 2, 3**, and the next number is 4. Only Main
is emitted. Its boundary labels remain **`.LFB1` and `.LFE1`** because their
consumer reads Main's saved number, not the global next number.

With B distinct registered bounds-pool declarations (B <= C) and D distinct
called output procedures (1 <= D <= min(2,C)), cumulative registrations are
exactly **B+D+4**, hence at most **C+6**. The next symbol UID is B+D+5 <= C+7;
the next symbol order is B+D+4 <= C+6. Removing the two size helpers never
rewinds these counters. These conclusions close the empty-elaboration and
synthetic-counter-to-emission questions left by the
[generated-body frontier](retained-literal-warning-residual-bound.md) and
[cold String layout](retained-literal-string-layout.md). They do not supply
the imported allocation subtotal or complete collector/counter lifetime.

The [evidence packet](../evidence/retained-literal-counter-emission-20261018/README.md)
exports a checked callable without changing the aggregate or assembler
files. Independent review is pending.

## Scope and inherited results

Retain exactly one `with Silver_IO;`, the Main/SPARK shell, C >= 1 qualified
literal Put/Put_Line calls, N >= 0 null statements, no declarations/use
clauses and each literal length <= INT_MAX. Retain the selected non-LTO,
O0 Linux x86-64 SysV descriptor, no debug, dumps, profiling,
instrumentation/sanitizers, offload, function-specific attributes, thunks,
function sections or hot/cold partitioning. The existing optional selected
wide-split setting only affects Main's later RTL. These are the retained
descriptor premises, not newly installed compiler switches.

The source identity is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`;
source-to-installed-behavior correspondence remains the existing external
dependency premise. The accepted frontier supplies precisely Main, one
empty elaboration, two cold String helpers and at most two external
procedure declarations without bodies. It excludes other generated
bodies, dynamic size execution, imported variable references, aliases,
nested functions, user asm and runtime-check/personality functions. The
accepted cold argument supplies no helper ordinary lowering, IPA body
execution, RTL or emission; it includes their initial gimplification and
later removal. This note uses those results, rather than reproving the
String folding argument or pricing helper allocations.

The retained fixed-prefix argument has no registered symbol and no
nonnull function allocation before `Compilation_Unit_to_gnu`. The
synthetic target-cost function has a null declaration, which does not
consume `funcdef_no`. Prefix builtins are declarations, not cgraph nodes.
The three ignored OTHERS external variables and Boolean constants do not
enter varpool. The
[real-function/default-hook argument](retained-native-expansion.md#real-function-construction-and-rtl-startup)
and [symbol ingress](retained-native-expansion.md#null-mains-incoming-ipa-symbol-graph)
transfer their prefix/default-configuration portions, not their old null
whole-lifetime totals.

## Why empty elaboration never registers

`Compilation_Unit_to_gnu` constructs one potential elaboration procedure
with `create_subprog_decl`, before translating the context and Main
(`trans.cc:5967–6097`). The constructor's `definition` argument is false:
the later `funcdef_no` allocation is not evidence that a cgraph definition
has been finalized. Its route has the following exhaustive boundaries.

1. `create_subprog_decl` builds the FUNCTION_DECL, finishes its result and
   attributes, pushes it, and calls `rest_of_decl_compilation`
   (`utils.cc:3703–3774`). No alias, address/register, linkonce or
   function-specific attribute is present. `finish_subprog_decl` creates
   the RESULT_DECL and sets fields/names; it does not register a function
   (`:3781–3818`).
2. `gnat_pushdecl` puts the elaboration in global scope because there is
   no current function. Its `add_decl_expr` builds/marks a global
   DECL_EXPR without adding it to an executable statement group
   (`utils.cc:889–997`; `trans.cc:9103–9136`). It does not make the function
   a nested child of Main or a call/reference target.
3. `rest_of_decl_compilation` has no matching alias/register path and
   explicitly excludes FUNCTION_DECL from `varpool_node::finalize_decl`
   (`passes.cc:176–250`). Its only remaining target action is the no-op
   function-relayout hook examined below. A FUNCTION_DECL with a saved
   tree is not automatically a registered cgraph node.
4. The explicit `allocate_struct_function` at `trans.cc:5994` allocates
   function/EH/machine state and consumes one definition number. Neither
   that routine nor its selected hooks registers a symbol. The empty
   BIND guard later sets `Has_No_Elaboration_Code`, skipping
   `begin_subprog_body`, `end_subprog_body` and
   `rest_of_subprog_body_compilation` (`trans.cc:698–723`). The latter is
   the gigi routine that calls `finalize_function`/`get_create`
   (`utils.cc:3874–3892`), so neither call happens for elaboration.
5. Global finishing considers variable declarations, type/constant debug
   entries, and specifically external imported functions; it does not
   finalize nonexternal elaboration FUNCTION_DECLs
   (`utils.cc:6490–6545`). The selected debug hooks cannot introduce
   another body or registration. There is no executable address/call to
   the empty elaboration, so later Main graph construction cannot discover
   it through a reference.

The zero is a symbol-registration projection. The elaboration FUNCTION_DECL,
RESULT_DECL, function structure and saved BIND still exist and retain all
their allocation and declaration/identifier/location counter costs.

## Allocation hooks and exact function numbers

`function.cc:4848–4915` calls EH initialization, the machine-state
initializer, ABI override, current-function hook, declaration relayout,
the target relayout hook and scalar initialization. The following source
cases close the potential hidden-function/registration continuation.

| Selected hook | Counter/constructor consequence |
| --- | --- |
| `init_eh_for_function` (`except.cc:351–358`) | Allocates EH state and two sentinel vectors; no personality lookup, function or symbol. |
| `ix86_init_machine_status` (`i386-options.cc:1991–2001`) | Allocates/initializes machine state; no function or symbol. |
| `OVERRIDE_ABI_FORMAT` → `ix86_call_abi_override` (`i386.h:1101`; `i386.cc:1661–1690,1787–1790`) | Stores SysV ABI; no `ms_abi` attribute, no registration. |
| `invoke_set_current_function_hook` (`function.cc:4674–4706`) | Uses the unchanged default optimization node. No function-specific optab initialization. O0/no alignment override gives null alignment strings, so each alignment parser returns before its cache (`opts.cc:684–687`; `toplev.cc:1215–1220,1276–1281`). |
| `ix86_set_current_function` (`i386-options.cc:3452–3580`) | Default/current target nodes and FP flags agree. Normal function and default call-saved policy apply to all four functions; SysV SI is already call-used. Both `reinit_regs` branches fail, as do interrupt/no-caller-saved branches. Switching to null uses the same default node. No recursive target setup or generated function. |
| Result/parameter `relayout_decl` (`stor-layout.cc:661–844,852–861`) | Void results for Main/elaboration, constant scalar parameters/results for helpers; no placeholder size, fresh size function or symbol. |
| `target_option.relayout_function` (`target.def:7061–7067`) | Default `hook_void_tree`. No override in the selected x86 implementation or thirteen selected target headers. |

The full x86 branch matters: `allocate_struct_function` calls the hook
directly after installing `cfun`; it must not be treated as a skipped
ordinary `set_cfun` call. All four declarations have the same selected
default target/optimization properties. The helper's u128 return is a
constant scalar type; it does not request an aggregate-return wrapper.
This table establishes no extra function/symbol constructors. Other
storage belongs to its own packet and is not assigned zero here.

`funcdef_no` is a zero-initialized static int; its increment is
`get_next_funcdef_no()` (`function.cc:115,4812–4815`). Empty elaboration
allocates first. Main allocates in its source-body translation at
`trans.cc:4024`, before `finalize_compilation_unit`. Only later does
`finalize_size_functions` allocate both helpers in their creation order
(`cgraphunit.cc:2562–2594`; `stor-layout.cc:275–292`). Main's later
`gimplify_function_tree` reuses `DECL_STRUCT_FUNCTION` and does not allocate
again (`gimplify.cc:21965–21977`); the same guard reuses each just-created
helper structure. The accepted body/pass frontier admits no clone or
later function constructor. Therefore:

| Function | Stored `funcdef_no` | Finalized/initially gimplified | Ordinary lowering / emitted |
| --- | ---: | --- | --- |
| Empty elaboration | 0 | no / no | no / no |
| Main | 1 | yes / yes | yes / yes |
| String bit-size helper | 2 | yes / yes | no / no |
| String byte-size helper | 3 | yes / yes | no / no |

There are four nonnull function allocations and three finalized cgraph
definitions, of which one survives to body emission. The next definition
number is 4; the non-Main increment is 3. No counter rewind is inferred
from freeing either helper.

## Complete selected registrations

The accepted imported type frontier has type/stub/field declarations,
parameters/results and the two helper declarations. Standard scalar sizes
are constant; the final unconstrained String has no TYPE_SIZE, so the
global size-variable branch is absent. The XUT/XVE layouts make no extra
function, and Main does not execute their placeholder calls. None adds a
varpool declaration outside the already accepted constant-bounds path.
The source-family restriction and erased Static ghost contracts exclude
the library's variables and unrelated package declarations.

| Registered nodes | Count | Constructor route |
| --- | ---: | --- |
| Main function | 1 | Gigi body finalization → `cgraph_node::finalize_function`. |
| Cold size helper functions | 2 | `finalize_size_functions` → same finalization. |
| Called Put/Put_Line externals | D | Actual Main calls → `get_create`, once per declaration. |
| Forced hard-register dummy | 1 | `gnat_write_global_declarations`, `utils.cc:6459–6488`. |
| Distinct bounds constant-pool declarations | B <= C | Main gimplification's `tree_output_constant_def` finalization, as in the accepted pool join. |
| Empty elaboration / other imported declarations | 0 / 0 | Exclusions above; type/namespace declarations are not symbols. |

`get_create` returns existing cgraph/varpool nodes before allocation
(`cgraph.cc:658–712`; `varpool.cc:136–166`). The bounds count B counts
registered descriptor declarations, not occurrences or raw string constants;
raw literal strings retain the accepted direct constant-emission route.
Nested registration would recursively create the parent, but all selected
function contexts are global or null, so `maybe_record_nested_function`
does not take that branch (`tree-nested.cc:129–146`).

Symbol insertion can ask the assembler-name hook for a name
(`symtab.cc:161–195,412–423`). GNAT uses
`lhd_set_decl_assembler_name` (`langhooks-def.h:131`; no override in
`misc.cc`), whose naming branch constructs an identifier, not a symbol.
The x86 name hook uses `cgraph_node::get`, not `get_create`; no selected
function is versioned, a dispatcher or a resolver
(`langhooks.cc:140–182`; `i386-features.cc:5511–5534`). No selected target
header defines a PE subtarget mangler. Thus registration/name lookup
introduces no hidden recursive node.

`symbol_table` starts at UID 1, order 0. Each new node consumes one of
each (`cgraph.h:2558–2575,3138–3149`). There is no top-level asm, which is
the separate order increment route. Unregister/release unlinks/frees nodes
without decrementing either monotone counter (`:3169–3196`). Consequently:

```text
cumulative registrations = B+D+4 <= C+6
next symbol UID           = B+D+5 <= C+7
next symbol order         = B+D+4 <= C+6
live nodes after removal of both helpers <= B+D+2 <= C+4
```

The last bound is not an initial-lowering bound: Main's initial analysis
can see both helpers. Use the cumulative bounds for dense arrays indexed
by order or maximum UID; do not compact away the two holes without an
actual compaction argument. A sufficient existing signed-counter check is
`C+7 <= INT_MAX`, which protects the next value as well as assigned values.
This is an implementation representation condition, not a new admission
limit or an inherent limit of output operations.

## Counter-to-name and stream interface

The function-boundary consumers use `current_function_funcdef_no`, a macro
for `cfun->funcdef_no` (`function.h:547`). `dwarf2out_alloc_current_fde`
stores the same number; begin/end output use it with LFB/LFE
(`dwarf2out.cc:1044–1053,1094–1097,1268–1270`). Returning to Main restores
its function structure. The global next value 4 is never substituted for
its saved 1. Thus both emitted boundary names have five bytes excluding
NUL; both still occupy the same two lines. EH/LSDA, ASAN, profiling,
patchable-entry, hard-CFR, debug and hot/cold alternatives are excluded by
the unchanged selected descriptor and body shape. No additional label
family is enabled by an increased definition number.

| Counter/name family | Effect of these three non-Main functions at selected emission |
| --- | --- |
| Function definition number | Elaboration shifts Main from hypothetical 0 to actual 1; later helpers do not change it. Exactly `.LFB1` / `.LFE1`. |
| Symbol UID and symbol order | Two helper increments persist for graph/order consumers. They are not operands of the selected name writers. No name suffix or extra output line arises. |
| Private size-name `fnno` | Two SZ names are constructed; neither helper body/name is emitted or referenced by Main. Do not identify this sequence with function numbers or constant labels. |
| Helper DECL_UID, temporary-name and condition counters | Helper-local declarations/tuples are discarded before RTL. Their persistent global increments remain in their own lifetime accounting. Main's selected no-debug register/descriptor lowering does not serialize their numbers. |
| Ordinary RTL labels `.L<k>` | Separate `label_num`, incremented by `gen_label_rtx` (`emit-rtl.cc:96,2877`). Empty elaboration/helpers do not expand RTL and add zero increments. Retain the existing incoming/global signed-label condition. |
| Constant labels `.LC<k>` | Separate `const_labelno` (`varasm.cc:84,3733–3734,4251–4252`). No static data is emitted by the three functions. Retain the pool-label endpoint condition `39257+2C <= INT_MAX` from the existing conservative prefix/pool join. |
| CFI `.LCFI<k>` | Separate `dwarf2out_cfi_label_num`; helper initial gimplification never enters the CFI pass. Only Main's at most five already counted CFI labels can consume it (`dwarf2cfi.cc:208,475–480,2495–2520`). |
| Public/ordinary assembler names | `_ada_main`, `silver_io__put`, `silver_io__put_line` remain fixed. Bounds declarations use their assigned LC names. The forced hard-register dummy, despite its ULONG_MAX private suffix, is skipped by `varpool_node::assemble_decl` (`varpool.cc:585–586`). |

The selected label macros append decimal integers with a dot/class prefix
(`elfos.h:121–130`; `i386/att.h:76–91`). A nonnegative signed 32-bit
ordinary/constant number has at most ten digits; an unsigned 64-bit
counter has at most twenty. The existing conservative 25-character local
label ceiling covers dot + LCFI + twenty digits; the actual Main boundary
names are much shorter. The established signed-label/counter guards are
still required: a printed-width ceiling alone never proves safe increments.
No affected spelling introduces `@`; the existing fixed call `@PLT`
operand suffix is syntax handled by the assembler interface.

Under the remaining original final-RTL/data/descriptor premises, these
counter corrections therefore preserve the assembler's existing 25-byte
local-name / 26-byte NUL-inclusive envelope, 64-byte instruction line and
512-byte complete-line envelope. They add **zero emitted bodies, labels,
lines, bytes, sections, symbols or relocations** beyond the selected Main
stream already counted. In particular the accepted formulas remain
`114 + (7C+7N+45) + W + 8C` lines and
`7410 + 65(7C+7N+45) + 13W + 512C` bytes. This is a proof of preservation
under this previously missing counter join; it does not rederive or
unconditionally validate the whole stream.

## Integration and remaining work

`derive.evaluate(C,N)` exports the bounds and exact function interface.
It deliberately leaves original imported allocation events/bytes, complete
gimplifier lifetime and global DECL_UID/temporary/RTL-label/collector
composition unresolved. The helper allocation packet owns the three
non-Main function allocations and two initial helper gimplifications;
this note adds no duplicate storage charge. Existing two helper symbol
registrations must be retained, not added twice. Empty elaboration adds
zero to that existing symbol formula and one to the non-Main definition
counter already reported by the warning-residual packet.

The parent may discharge the empty-elaboration registration and persistent
function/symbol-counter-to-name sub-obligations using this interface while
preserving all remaining invocation/materialization, imported capacity,
identifier, global-counter and collector obligations. Full pipeline capacity
remains false. Oracle, tool options, language admission and the external
physical-resource trust boundary are unchanged.

Selected settings: GPT-6 Astra / Extra High, assigned by parent; runtime
confirmation and token/cost evidence unavailable. Round start
2026-10-18 20:43:46 UTC; completion and measured wall elapsed time are in
the evidence check result, separately from checker runtime. Native runs:
zero. Only this note and its evidence directory are owned by this subthread.
