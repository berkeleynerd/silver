# Literal original-gigi residual: imported String frontier

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119), with claim/interface
correction tracked by [#131](https://github.com/berkeleynerd/silver/issues/131).
**R remains
unresolved.** This follow-up to the accepted
[warning-map transfer](retained-literal-warning-map.md) identifies an imported
type-layout route that its residual must cover. It also identifies stronger
whole-unit claims whose missing premise must be restored. It establishes
neither that a size function is actually created nor that none is created.
No compiler, prover or debugger was run.

The [source and offline evidence](../evidence/retained-literal-gigi-warning-residual-20261018/README.md)
pin GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and the exact reviewed
Silver base `6803ee54ca8d0a20bde4d2ce14562b84a9e46fd4`. References to the
aggregate below describe that base; subsequent repairs must not be mistaken
for the reviewed historical text. The relevant installed behavior/source
premise remains unchanged.

## Scope and retained results

The selected family has exactly one `with Silver_IO;`, the Main/SPARK shell,
C >= 1 qualified literal Put/Put_Line calls and N >= 0 nulls, no declarations
or use clauses, and individual literal lengths <= INT_MAX. Reuse the
accepted Main-local `W <= 9C+3N+1`, selected helper subtotal 8C, and local
declaration suppression ceiling 2C+N. This packet changes none of them.

R bounds **every other actual warning-map put**, including replacements,
after the prefix stop and before entry to Main's `gimplify_body`. The
conditional map formula remains I=2C+N+R, J=2C+1. R is not a bound on
distinct locations, Ada entities, GCC declarations or source visits. A
synthetic function created by type layout is inside this interval if its
body is gimplified first, even though it is not a Main-local declaration.

## Imported array layout reaches the unresolved decision

`cstand.adb:895–939,1040–1053` constructs Standard.String as a one-dimensional
unconstrained array of eight-bit Character, indexed by Positive, with byte
alignment. The selected host's storage unit is eight bits. The source's
unconstrained definition is separate from each actual literal's constant
extent. An ordinary external procedure's String profile reaches
`gnat_to_gnu_profile_type` and `gnat_to_gnu_entity`; the ordinary entity cache
at `decl.cc:400–445` can avoid repeated conversion, but does not count
synthetic layout work inside the first conversion.

The relevant source chain is:

| Step | Retained source and effect |
| --- | --- |
| Import String | `decl.cc:2209–2575` constructs the fat pointer, bounds template, XUA array and template-plus-array object record. It calls `build_template_type` at 2433 and `build_nonshared_array_type` at 2460. |
| Construct bounds | `decl.cc:7265–7402` takes lower/upper fields from the template through a PLACEHOLDER. Except for the guarded fixed-lower-bound alternative, the high bound is `COND_EXPR(upper >= lower, converted_upper, converted_lower - 1)`. The Positive setup in `cstand.adb` does not set the fixed-lower-bound-index flag. |
| Lay out XUA | `tree.cc:7575–7642` calls `layout_type` before any shared-type lookup; its canonical-type branch can perform another array construction. `stor-layout.cc:2660–2767` computes length as `1+(ub-lb)` and bit/byte sizes from that length. |
| Finalize sizes | `stor-layout.cc:1962–2020,2803–2808` rounds sizes, then calls `variable_size` separately for nonconstant bit and byte sizes. |
| Decide whether to factor | `stor-layout.cc:67–87` tests placeholder content **before** the global-binding early return. `self_referential_size:155–178` returns immediately for a simple arithmetic chain ending at a CALL or self-referential COMPONENT_REF; it can also abandon copying on a SAVE_EXPR. |
| Create a body if neither exclusion applies | `stor-layout.cc:181–265` makes parameters, FUNCTION_DECL, RESULT_DECL, BLOCK, MODIFY_EXPR and RETURN_EXPR, appends the function to `size_functions`, and returns a call. These declarations use generic builders rather than `gnat_pushdecl`. |
| Lay out the object record | `utils.cc:4562–4583` creates BOUNDS and ARRAY fields and calls `finish_record_type(..., 0, true)`. Its size is not established constant by the eight-byte bounds-template/sixteen-byte fat-pointer argument. |
| Gimplify before Main | `cgraphunit.cc:2562–2594` calls `finalize_size_functions` before `analyze_functions`. `stor-layout.cc:275–292` gimplifies and finalizes each retained size function. Ordinary body analysis invokes `gimplify_function_tree` at `cgraphunit.cc:691`. |

The smallest unresolved decision is the **actual folded bit/byte size shape**
at the first imported XUA `variable_size` calls, followed by the object-record
layout and any canonical/repeated layout. `skip_simple_constant_arithmetic`
(`tree.cc:4220–4243`) follows unary operators and the nonconstant side of
constant-sided binary operators. It does not traverse an arbitrary
conditional or a binary expression with two nonconstant operands. The
unfolded bounds therefore do not themselves prove its early-return condition.
This round did not establish the selected fold result or count the resulting
helper bodies. Calling the graph fixed does not supply that count.

The earlier general
[size-function interface](retained-backend-capacity.md#compiler-generated-size-functions-have-a-separate-finite-interface)
already distinguishes the constant bounds/fat-pointer records from the
template-plus-array object record. Its V bound is in actual layout/helper
invocations; it cannot be instantiated with the number of source types.

## Why R cannot yet be filled in

The following direct declaration sites were isolated as useful future
accounting inputs. Their counts are **restricted site counts**, not an
exhaustive original-gigi subtotal:

| Direct route | Restricted demand |
| --- | --- |
| Main and empty elaboration FUNCTION_DECLs | One each at their respective constructors. |
| Hard-register dummy | Zero `gnat_pushdecl` calls: `utils.cc:6459–6488` constructs and registers it directly. |
| One-with namespace | At most one namespace declaration for the single Silver_IO component, under the creation guard (`trans.cc:6427–6440,8333–8339`). |
| Imported Put/Put_Line declarations | At most two ordinary external procedure declarations; their IN String parameters use `create_param_decl`, which does not push declarations. |
| One ordinary String conversion | Fat-pointer TYPE_DECL, template-index TYPE_DECL, XUA TYPE_DECL, object-record TYPE_DECL and common final TYPE_DECL (`decl.cc:2397,2527,5019,7377`; `utils.cc:2861–2871,4580`). |
| Optional parallel debug record | One additional XVE push for the object record under `gnat_encodings == ALL` (`utils.cc:2497–2685`, push at 2548). Ordinary no-debug selection alone is insufficient to erase this source branch because the object-record finisher receives `true`. |

Character/Integer/Positive conversion, common type finishing, cache behavior,
profile helpers and generic helper warning mutations still need an exhaustive
composition. No sum of this table is exported as R. In particular, frontend
node/entity or gigi-visit counts do not count synthetic declarations one for
one.

Generated nonvoid size-function returns can reach the temporary-result
suppression at `gimplify.cc:1948`, the return copy at 1962 and conditional
lowering at 5728. `create_tmp_var_raw` uses `input_location`
(`gimple-expr.cc:442–449`). These are candidate API calls, **not established
puts**: reserved locations and absent dispositions may eliminate puts.
`gnat_to_gnu_entity` maps Standard locations to BUILTINS_LOCATION
(`decl.cc:500–505`; `trans.cc:11006–11018`), and `gimplify_body` initializes
its location from its function declaration (`gimplify.cc:21778`). This
suggests a narrower reserved-location argument, but this round does not claim
its transitive invariant. In particular, `gimple_set_location`
(`gimple.h:1959–1964`) copies dispositions independently of the no-warning
bit, and ad-hoc block locations are distinct values. Final DECL locations
alone do not prove that all intervening map operations are harmless.

## Exact dependency impact at the reviewed Silver base

The [machine-readable impact record](../evidence/retained-literal-gigi-warning-residual-20261018/dependency-impact.json)
lists the affected fields. A failed absence proof is not an observed compiler
failure or evidence that every listed numerical bound is actually exceeded.

| Base claim or output | Missing justification and appropriate scope |
| --- | --- |
| `retained-literal-pipeline.md:137,146–147,300` | “No uncharged post-prefix dependency body”, “no self-referential size-function body”, and “Main remains the only defined function body” do not follow from constant literal extents. Imported String layout needs its own argument. |
| `compose.py:167–257`, `native_pool_lifetime` | `symbols.registered_nodes_upper=C+4`, `next_uid_upper=C+5`, `order_upper=C+4`, assembler-name population C+3, `additional_GGC_request_events_upper=5C+5`, and `named_consumer_closed` require exclusion/accounting of extra helper symbols and associated activity. The Main bounds-pool roots remain available; this does not establish the complete incoming shared-pool state. |
| `compose.py:260–354`, `native_graph_lifetime` | `function_summary_ID_high_water_upper=1`, `additional_registered_symbols=0`, the C-dependent graph/summary populations, `additional_GGC_request_events_upper=8C+33`, and `conditional_graph_and_summary_lifetime_closed` need the missing whole-unit body premise or extra-function transfers. |
| `compose.py:869–870,892–894,928–929` | Conditions `native_varpool_and_shared_tree_pool` and `native_graph_and_summary_lifetime`, exposed pool/graph subtotals, and `evaluated_predicates_pass` must not present the preceding conditional quantities as source-closed. |
| `retained-literal-assembler.md:20–55`; `retained-literal-assembler-storage.md:18`; linker inheritance | The complete emitted stream/object uses Main's final chain, one bounded frame, and no additional function route. Creation of an internal helper does **not** prove it survives to emission. Conversely Main preservation does **not** prove no extra helper is emitted. Keep the assembler/GAS/link arithmetic conditional on that emission premise pending a discard proof or extra emitted-body transfer. Aggregate consumers are `Main_assembler_object_interface`, `Main_GAS_BFD_storage` and `literal_output_linker_representation`. |

The accepted `retained-native-ingress-bound.md:7–9,40–41,153–162,202`
explicitly covers Main-local input and leaves original global construction
separate. Its W/8C results, corrected Main bindings, and Main's selected
warning-copy ceiling remain usable. Per-function CF/CFG/SSA/RTL interfaces
likewise remain per-function interfaces under their existing Main-preservation
premises; they are not totals for generated helper bodies. R remains None,
and `whole_literal_pipeline_capacity_established` remains false.

## Next bounded question and existing evidence

The next source question is the folded XUA bit/byte-size shape and the
object-record continuation. If helpers exist, count their layout creation,
warning activity and cgraph lifetime, then determine whether they are
discarded before emission. Stop at those named interfaces; no toolchain
attestation, unrelated imported behavior or aggregate RAM gate is required.

Recommendation: begin with one bounded **cold Standard.String conversion**
trace, recording the input and output tree shape of each extent fold and
each `variable_size` call. The precise hypothesis is that the first XUA
extent retains a two-bound conditional/arithmetic shape, so the simple-chain
early return does not apply; later size formulas may reduce to arithmetic
around its replacement call. This is a hypothesis, not a conclusion. The
trace must include canonical-type recursion and XUT field/record layout,
then use the ordinary complete-entity cache to justify independence from
repeated Put/Put_Line references. That is a more direct first question than
a broad fixed-frontier capture. Keep Astra / Extra High as the starting
setting; use Max only if a named folded-shape or repeated-layout ambiguity
remains the reasoning bottleneck. A focused native shape observation could
guide that source trace if needed, but would not replace it or establish R
from a sample. This recommendation authorizes no additional run.

The retained prefix capture stops before `Compilation_Unit_to_gnu`; it cannot
observe this route. `retained-native-fixed-capture-20261018` records Ada
Table.Last growth for a richer fixed witness, not GCC size-function counts,
warning events or body identities. Its README explicitly separates backend
costs and source-based constant promotion. The literal-output JSON is an
offline formula result, not a native observation of helper absence. No
reviewed existing capture was found that supplies a fixed imported GCC
frontier independent of C/N. Reuse those successful records for their
existing claims; do not turn them into an R measurement.

Selected agent settings: GPT-6 Astra / Extra High, assigned by the parent.
Runtime confirmation, token and cost measurements are unavailable. This
bounded round sought an original-gigi R; it instead isolated the unclosed
size-function decision and its whole-unit dependencies. Parent requested a
freeze at this frontier before further research. Timing and the offline check
result are retained in the evidence README and result. No frozen predecessor,
aggregate, admission, Oracle, GitHub or CLI-memory record was edited here.
