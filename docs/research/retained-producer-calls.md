# Retained producer: selected library call wrappers

Source-derived [#119](https://github.com/berkeleynerd/silver/issues/119) component,
2026-10-18, Linux x86_64. This supplies per-call costs to the
[producer aggregate](retained-producer-capacity.md) for the currently selected
Silver library specifications and inspected SPARK revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. The existing source-to-installed-tool
premise remains; these are not installed-binary measurements. Changes to library
contracts, types or effects require rechecking these transfers.

Costs are `(nodes, lists, appended elements, emitted occurrences)`. They exclude
fixed library theories and symbol/module setup, the supplied String argument's
translation and expected-type conversion, surrounding source-location labels,
and the enclosing expression's result conversion. A per-call cost is not a
bound on the selected library's complete translation or later VC transformations.

## Reachable branches

The two query functions have `Global => null`; First_Or_Default takes one
immutable unconstrained String and returns String, while Input_Is_Valid has no
parameters and returns Boolean. Put and Put_Line each take one immutable String.
Their four output globals are an ordinary static String, a constrained Natural,
and two Booleans; File_System is In_Out. Reject has no parameters and only that
In_Out state. See [Silver_IO](../../src/silver_io.ads),
[Silver_Arguments](../../src/silver_arguments.ads) and
[Silver_Runtime](../../src/silver_runtime.ads). No selected public operation has
a precondition, exceptional/exit contract, controlling parameter/result,
volatile or side-effect function, variant, or parameter type invariant. Main
has no dynamic termination condition. The explicit termination aspects and the
default/computed cases are static (`spark_util-subprograms.adb:786–859`).

Consequently the Main calls take the ordinary registered-symbol route, without
dispatch, specialization, tag, recursive-variant, dynamic-termination or
exception-wrapper construction. The precise exceptional-contract guard reads
only the exceptional/exit contracts (`spark_util.adb:2450–2540,3092–3153`);
an implementation's possible exception is not by itself that guard. Type
invariant checks depend on actual type invariants, not the ordinary dynamic
range/length properties (`spark_util-subprograms.adb:2044–2107`,
`spark_util-types.adb:1521–1552`). The selected scalar/String types have none.

`Compute_Raw_Binders` constructs an ordinary regular binder for each in String
formal (`gnat2why-subprograms.adb:2098–2154`). The formal is immutable, with
no init/valid/move flag, so its [setup bound](retained-producer-objects.md)
is five nodes, no lists/elements. `Localize_Binders` does not create another
identifier for this already local binder. `Get_Why_Type_From_Item` reads its
existing type. `Compute_Call_Args` translates the actual once using that
expected type and returns it unchanged through `Get_Item_From_Expr`'s regular
immutable branch (`gnat2why-expr.adb:4334–4919,10757–10788`,
`why-gen-binders.adb:448–455,613–739`). There is no copy-back or reference
context. Zero-parameter calls receive the existing `Void` expression as their
single Why argument. Global parameters are absent in these program calls and
the two Global-null logic calls.

Both call translators eagerly create **two Void sequences**, even when the
exception/post-call stores stay unused. Each costs one node, one list and one
element. `Transform_Identifier` returns the registered subprogram identifier
without allocating another (`gnat2why-expr.adb:26847–26909`).

In the program domain, `Insert_Ref_Context` also eagerly allocates one Effects
node and its three empty lists. The four direct output objects have no relaxed
initialization, and File_System is an input as well as an output, so no havoc is
inserted. A procedure call is prepended to its existing Store list. For a
function that store is still Void, so its expression is returned directly.
The reference context is empty (`gnat2why-expr.adb:12090–12217`). The Effects
allocation and unused exception sequence still count. These guards concern
Main's calls; library-body calls have their own fixed translation costs.

## Procedure wrappers

Put/Put_Line use `Transform_Call_With_Side_Effects`
(`gnat2why-expr.adb:21035–21399`). Their symbols have an absent result type, so
each call emits four occurrences beyond the argument (call, identifier, name,
module). The returned Store adds its sequence node and the existing four-node
Void expression. `Compute_Tag_Check` returns Void, and prepending it adds
nothing (`:8654–8741`, `why-gen-progs.adb:275–323,329–341`).

| Component | Nodes | Lists | Elements | Occurrences beyond argument |
| --- | ---: | ---: | ---: | ---: |
| Formal setup allowance | 5 | 0 | 0 | 0 |
| Two eager Void sequences | 2 | 2 | 2 | 5 retained in Store |
| Call | 1 | 1 | 1 | 4 |
| Eager Effects | 1 | 3 | 0 | 0 |
| Prepend call into Store | 0 | 0 | 1 | 0 |
| **Put or Put_Line wrapper** | **9** | **6** | **4** | **9** |

The actual's full String conversion is a separate existing row
`(47,22,31,459)` and includes the argument once. Reject has no formal setup;
its Why argument is Void. Its wrapper is therefore `(4,6,4,13)` with no source
argument. These counts precede any enclosing statement-location wrapper.

## Function wrappers, including guarded logic calls

`Transform_Function_Call` uses `New_Function_Call`
(`gnat2why-expr.adb:26365–26689`, `why-gen-expr.adb:5017–5178`). Program calls
have no precondition wrapper here. Logic calls may use a guard according to
`Use_Guard_For_Function` (`gnat2why-util.adb:1843–1872`). In particular, the
postcondition of First_Or_Default makes assuming the unguarded branch unsafe
without also establishing the selected guard option. The bound below covers
both settings and both term/program-term guard constructions.

There is exactly one Why argument, either the supplied expression or Void.
The larger guarded term construction creates a result identifier/name, at most
one argument temporary identifier/name, guard call, ordinary call, equality,
conjunction, epsilon and at most one argument binding: **ten nodes**.
There are at most four lists and seven elements, including an allowance of
two elements for the conjunction's optional list. The actual conjunction
stores its two operands directly and leaves that list empty, so this allowance
is conservative. The program-term construction is smaller in each component.

A result type has at most three occurrences, its local identifier five,
the function identifier six, the cached guard identifier five, and the
equality identifier four. The guard identifier's type is builtin unit
(`why-atree-modules.adb:3117–3125`), also two occurrences. For one fresh
argument temporary, the guarded term has at most **64 occurrences plus the
argument once**: ordinary call 15, guard call 18, equality 27, conjunction 46,
epsilon 55, then the outer binding adds nine. If no temporary is needed,
`New_Temp_For_Expr` retained an identifier or dereference, of at most ten
occurrences here. Charging ten more occurrences covers both retained uses
instead of two five-occurrence temporary references. Thus the uniform
body allowance is `(10,4,7,74)`, plus the argument once. The program-term
construction has at most 58 occurrences plus the argument before that same
cheap-reference allowance. Source:
`why-gen-expr.adb:311–347,3485–3504,4289–4331,4962–5011`; schema
`xgen/xtree_sinfo.adb:243–273,301–324,330–349,528–534`.

Adding formal setup, both eager sequences and the optional Effects allocation
gives a common **First_Or_Default wrapper `(18,9,9,74)`**, plus its argument
translation/conversion once. The function appears only in the original input
initializer; its program and possible constant-value term translations must
both be charged. **Input_Is_Valid is bounded by `(18,9,9,78)`** including Void
and conservatively retaining the unused formal/guard allowance. This is an
upper bound, not a claim that Boolean calls actually execute every guard path.
Outer result conversion and Boolean-to-predicate conversion remain separate.

Each guarded function body introduces at most two temporary names, and at most
one argument entry into `Temp_Names_Map`, removed by the binding helper. There
are no new per-call theories or direct modules in these wrappers; registered
function/guard symbols are fixed-library setup. The [evidence](../evidence/retained-producer-calls-20261018/README.md)
checks source identities and this local arithmetic without compiler/proof runs.
Complete helper invocation, fixed-library translation and auxiliary-container
capacity remain aggregate obligations.
