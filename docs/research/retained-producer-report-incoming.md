# Incoming producer report state

2026-10-24, research [#119](https://github.com/berkeleynerd/silver/issues/119)
and [#193](https://github.com/berkeleynerd/silver/issues/193). This supplies the
state already present when a selected producer receives its Why response. It
does not set that state to zero, accept a caller's flow-graph certificate, or
complete the collector/Silver-reader successor. The response/report author owns
the response messages, final schema, claim serialization and report write.

The source model is SPARK `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, from the
already retained frontend source archive. GCC source has revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Source-to-installed-tool correspondence
and physical storage remain the existing premises. This is a source and integer
arithmetic investigation; no compiler, prover or provider was rerun.

## Scope and incoming variables

Use the full current Main grammar, including unused declarations and unreachable
arms, and the selected `silver_io`, `silver_arguments`, `silver_output_libc` and
`silver_runtime` sources. Imported runtime *bodies* are not additional analyzed
bodies: `Build_Graphs_For_Entity` requires analysis requested and the appropriate
body/spec in SPARK (`flow.adb:1538–1593`). `FA_Graphs` is keyed by entity and its
analysis loop visits each entry once (`:1724`). A graph for a fixed library body
must use that body's frontend counts; Main counts do not stand in for it.

For each such graph let `A,E,L` be the established frontend upper bounds on
ordinary typed node identities, entity identities and syntax-list headers in
the relevant unit's source closure. They include generated loop-bound captures,
subtypes, expression-function bodies and extended-return objects. Use the
[Main semantic transfer](retained-main-semantics.md) and its fixed-unit binding,
not a measured graph size. Where a whole-process bound is used for a graph it
overcharges the graph; it must still cover all referenced fixed source entities.
The process-level outside-graph checks use process-level frontend bounds.

Two kinds of variable domain must remain distinct. The finite normal-use
*object* domain used by initialization/data-flow sets is denoted `F`. A general
`Flow_Id` can also name a statement or subprogram and has seven variants and
five facets (`flow_types.ads:97–184`). The latter is not a reason to multiply
every data-flow set by all seven variants.

## Source-derived graph and variable domain

The selected global-effect set is contained in these six source identities:

* `Ada.Text_IO.File_System`;
* `Silver_IO.Written_Bytes`, `Written_Count`, `Flushed`, `Succeeded`;
* `Silver_Runtime.Exit_State`.

Main's calls use at most the first five. `Put`/`Put_Line` explicitly list those
five; `Reject`, `Put_Byte`, `Flush` and the output-library setter use
`File_System`; the argument queries are `Global => null`; the runtime setter
uses `Exit_State`. The selected bodies introduce no extra global effect. Read
sets for proof can additionally retain source constants, which must be charged
to `E` even when absent from the effect set. Do not infer that `Global => null`
makes all proof-reference sets empty.

Global generation therefore operates on subsets of a finite source-name set.
The selected call graph is finite and contains no recursive application call:
Main calls the five API roots; their bodies call the fixed queries and imported
bindings. Global propagation takes unions of existing name sets and projects
existing state/constituent names (`flow_generated_globals-phase_2.adb:
2402–2513,2536–2633,4134–4301,4535–4537`). It creates no new application variable
or fresh name on each iteration. A monotone presentation of the selected
closure has at most `3 * (E+6) * C` strict membership additions for `C` selected
callables (Input, Output and Proof_In sets), including source constants. This
bounds the domain of the
actual worklist/closure; it is not a claim that its implementation executes
exactly that many loop iterations. Source constants are kept separately in the
proof-reference domain. Refinement/encapsulation of the two external abstract
states stops at their visible identity; their runtime bodies are not traversed.
The call-vertex bound still uses the six effect globals: phase-2
`Strip_Constants` filters constants without variable input from proper/refined
Proof_In and Input sets (`flow_generated_globals-phase_2.adb:2974–3015`), and
`Process_Subprogram_Globals` explicitly removes such constants from both sets
before constructing call vertices (`flow-control_flow_graph.adb:6863–6892`).
The larger proof-reference closure domain is not an extra per-call effect set.

`Get_Components` returns a singleton for abstract state and for the selected
scalar/array/private-nondiscriminated types. An unconstrained top-level array
adds only `The_Bounds` (`flow_utility.adb:1028–1030,1083–1106,1233–1247`).
`Flatten_Variable` immediately returns this set because it contains its root
(`:1280–1301`). There is no per-character expansion. `System.Address` has a
nondiscriminated private view and modular full view; `Interfaces.C.int` and
`Ada.Command_Line.Exit_Status` are scalar. Thus there are no `Record_Field`
component vectors, record grouping vertices, ownership reclaim actions or
controlled-object finalization in these analyzed bodies.

With `E` covering the source closure just specified, the following uniform
object bound deliberately allows both facets of each entity and each external
global, plus synthetic null:

```text
G = 6
F = 2 * (E + G) + 1
```

For an emitter argument that can be a statement, a separate complete finite
identity universe is `7 * (5 * (A + E) + G + 2)`; this is not used in the
initialization multiplier. Canonical conversion between a visible global's
entity and its generated-global name preserves the six-object domain.

Each `Add_Vertex` wrapper adds exactly one vertex (`flow-control_flow_graph.adb:
1257–1290`). The following constructor accounting concerns phase 2:

| Constructor family | Bound and source reason |
| --- | --- |
| Start/helper/exceptional/end, null initial/final, initializer placeholder, empty pre/post/exception joins | `10` (`:8441–8460,8742–8843`) |
| Initial/final object, formal and function-result vertices | `4E`; at most two flattened leaves, two vertices each; repeated entity setup returns after the map insertion fails (`:1506–1635`) |
| Initial/final globals | `4G`; proof/input/output modes partition the finite global identities (`:8490–8530`) |
| Ordinary assignment | One vertex and at most two queued expressions, each contributing at most two fold-check vertices (`:2009–2039,7339–7385`) |
| Object declaration | At most two initialization vertices, one declaration marker and two fold-check vertices; a side-effect initializer instead uses the call row below plus its marker (`:4883–5198`) |
| If/elsif | One condition vertex and two possible fold checks per condition; each arm list visited once (`:2711–2980`) |
| For loop | One loop vertex, at most one whole-array initialization summary, and four bound-expression fold checks, in addition to the loop entity's initial/final pair already charged; body visited once (`:3397–3454,4215,4312`) |
| Call | At most five call/control vertices, at most two actual/result positions each costing two in/out and two fold-check vertices, and at most `2G` global vertices (`:6102–6335,6863–6948,6954–7087`) |
| Type, pragma, null, block, simple or extended return | At most four local vertices excluding recursively visited declarations/statements (`:2440–2532,4381–4408,5566–5769,6442–6625,6688–6735`) |
| Contract expression | One vertex per expression; `2A` covers abstract/refined retrieval (`:6393–6433,8753–8940`) |
| Empty statement-list join | At most one per visited list, hence `L` (`:1357–1395,7186–7215`) |

All selected explicit call profiles have at most one actual; the second
position above is the result of a side-effect function. A conservative common
node coefficient is `14+2G`: object marker plus the call row. This overcharges
a side-effect object initializer, which actually returns after the call at
`:4895`, before the ordinary declaration marker. Other rows are smaller.
Initial/final entity vertices and contract retrieval are separately
charged, even where this duplicates the ordinary-node allowance. Therefore

```text
V <= 10 + 4E + 4G + (16 + 2G)A + L
  = 34 + 4E + 28A + L.
```

This recurrence is structural. Branches and nested loops sum their children;
runtime iteration counts do not multiply them. Selected sources and the
established light-expansion closure have no handlers, `finally`, record/access
cleanup or loop-entry attributes. Thus `Unwind` does not replay statement
subtrees. The two folded-expression checks are the `Proof_Ins .. Null_Deps`
enum range (`flow_types.ads:859`), not an unexplained coefficient. Graph
pruning/simplification and DDG/CDG/PDG copies retain the constructor vertex
domain, as in the earlier [null graph accounting](retained-producer-null-storage.md).
The driver's `Global_Gen_Mode` phase-1 branch and phase-2 response branch are
mutually exclusive (`gnat2why-driver.adb:795–829`). Phase-1 extra unresolved-call
vertices (`flow-control_flow_graph.adb:9238–9255`) therefore do not belong to
this response-producing process. This is a process distinction, not permission
to reset counters inside a process; phase-1's own earlier reports are separate
upstream process obligations.

The generic envelope is intentionally weaker than a specialized one. The
already accepted null family has `A<=39`, `E=1` and `L<=39`, so this gives
`V<=1169`, while its earlier constructor refinement gives `V<=89`. Reuse the
specialized result for that family; do not rerun it to obtain a larger number.

## Initialization and trace attempts before deduplication

The initialization routine is not bounded by arbitrary program paths.
`Scan_Children` stores `(Start,V_Use)` keys, with `Start=FA.Start_Vertex`
unless its starting vertex is a parameter havoc
(`flow-analysis.adb:3114–3127`). The call constructor creates a parameter-havoc
vertex only when its local-handler list is nonempty
(`flow-control_flow_graph.adb:6048–6052,6238–6244,6321–6335`). There are no such
handlers in the selected source/light-expansion domain. Recursing through a
partial array write does not change this fact: the recursive child is not a
havoc vertex either. Each of the Err and Unknown maps consequently has at most
`V` keys, rather than `V²`.

For a fixed key, `To_Entire_Variables` groups the leaves by root;
`Compress_Checks` can retain the root or its bounds facet, and cannot create a
record-component tree (`flow-analysis.adb:2630–2737`). These root groups are
disjoint. Charging all `F` object identities per key gives

```text
initialization check calls <= 2VF
initialization info calls  <= 2F.
```

This does not assume the checker recognizes every semantically initialized
Silver object. In particular it remains valid for fixed-library partial-array
writes and conservative flow outcomes.

`Find_Ineffective_Statements` visits each PDG vertex once and emits at most one
trace-bearing alternative per vertex (`:1843–2058`). The only other trace
callers are the initialization routine and the explicit Depends/Initializes
checks. Those checks return when the corresponding source contract is absent
(`:4130–4136,4967–4972`); none is present in the selected sources. Hence

```text
trace attempts per graph <= V + 2VF.
trace lines per attempt  <= V.
```

The trace set is a vertex set, so a vertex cannot appear twice in one file.
The FA overload computes `Tracefile` by writing it **before** calling the
deduplicating entity overload (`flow_error_messages.adb:539–577`). Thus neither
deduplication nor disabled warning display removes the file-counter obligation.
Its counter is process-wide. If `T` sums these attempts and `t0` is its actual
earlier value, require `t0+T <= Natural'Last`; filenames are
`Unit_Name & "__flow__" & decimal(counter) & ".trace"` (`:1013–1018`).

## Earlier flow emitter calls

The retained count is bounded by **attempts**, not by the number of entities
or static call sites. The entity overload deduplicates
`Msg3 & Source_Ptr'Image(Slc) & Integer'Image(Severity'Pos)`, after computing
the expanded message, span, key and `JSON_Result_Type`
(`flow_error_messages.adb:330–387`). Two messages for the same entity/location
can survive because their substituted text differs. Conversely, duplicate
attempts still pay their eager strings and any trace write.

The following table charges each reached emitting loop. `A,E,F,V` are the
source-derived quantities above. Fixed argument profiles have one explicit
formal and side-effect assignments have a scalar LHS (`Status`), so the
aliasing row has no unbounded parameter or LHS-expression cross product.

| Per-graph caller | Attempt bound | Pinned source |
| --- | ---: | --- |
| Exceptional-path graph diagnostic | `1` | `flow-control_flow_graph.adb:7849–7874` |
| Sanity: function global outputs | `F` | `flow-analysis-sanity.adb:58–105` |
| Sanity: variable inputs in subtype constraints | `2AF` | `:130–216,760–886,1067–1367,1390–1493`; at most two bound-expression roots per scalar/one-dimensional array declaration, each scanning a set of at most F variables |
| Sanity: generated/declared globals | `6F` | `:1998–2085`; six missing/unused sets |
| Sanity: illegal writes and unknown variables | `2VF` | `:1630–1823`; one defined-set scan and one used/defined-union scan per vertex |
| Unwritten exports | `V` | `flow-analysis.adb:795–1036` |
| Unused objects / ineffective imports | `2F` | `:1277–1445` |
| Ineffective statements, including whole-subprogram no-effect case | `V+1` | `:1831–2058` |
| Dead statements | `V` | `:2068–2100` |
| Initialization errors and info | `2VF+2F` | previous section |
| Inputs only used in assertions | `F` | `:3520–3636` |
| Illegal reads of Proof_In | `2VF` | `:3642–3725`; flattening at most two leaves |
| Impossible-to-initialize abstract state | `E` | `:3731–3839` |
| Aliasing, including result/global comparison | `13A` | `flow-analysis-antialiasing.adb:933–1197`; one explicit actual: at most G parameter/global pairs, one result/actual pair, G result/global pairs; G<=6 |
| Function volatility | `VF+1` | `flow-analysis.adb:5764–5923` |
| Always_Terminates | `V(1+A)+1` | `:6442–6725`; one loop diagnostic plus at most one per direct call pair at each vertex, then one success message |
| Final dependency-status messages | `2` | `flow.adb:1869–1908` |

All selected `Subprogram_Call` pairs have a unique direct callee for their
typed call node; there are no dispatching/indirect equality families. Thus a
vertex's call set has at most `A` elements. Runtime calls are not expanded into
their bodies. Summing the rows gives the deliberately conservative bound

```text
B_flow_graph = 2AF + 7VF + 12F + V(4+A) + 13A + E + 6.
```

The other flow callers have specific zero domains: no while/exit/continue
stable-condition checks; no explicit Depends/Initializes/Refined_State;
no protected/task/concurrent calls; no class-wide types; no `Old` references;
no Constant_After_Elaboration; no ghost subprograms or side-effect calls in
ghost expressions. The four Static ghost observations are objects, not ghost
subprograms. Hidden-state checks see visible objects in top-level packages,
whose enclosing package is Standard; the selected packages have no private
children or hidden body state (`flow-analysis.adb:4572–4840`). These exclusions
concern the source and its typed closure, not merely absence of pragma text.

Outside the graph loop, specification contract checking visits the source
scope tree once (`flow.adb:1662–1695`). Charge `E(2F+1)` for its constant-global
and required-contract calls. `Flow_Sanity.Check_Incomplete_Globals` loops over
the translation entities and their pre/post/expression-function roots
(`flow_sanity.adb:175–277`); `(4A+2E)F` allows twice the distinct frontend roots,
including the separate package/entity-list insertion routes. Here use the
**process** `A,E,F`, covering referenced fixed specifications. Consequently

```text
B_flow = sum_over_graphs(B_flow_graph)
       + E_process(2F_process+1)
       + (4A_process+2E_process)F_process.

incoming Flow_Msgs records <= B_flow.
incoming Flow_Msgs_Set keys <= B_flow.
```

The source classifier is a reviewable argument, not a claim that a lexical
search proves reachability. The evidence inventories every native caller so a
new call site cannot be silently lost from the table.

## Warning/error records before the response

`Warning_Msg_N` always appends a `Warnings_Errors` JSON record, even when its
display is suppressed (`errout_wrapper.adb:874–918`). In particular every
reached Image translation emits `Warn_Imprecise_Image`
(`gnat2why-expr.adb:20258–20296`). Count translation invocations, not Image
tokens: each invocation first creates fresh Why call/constant nodes, so the
existing producer Why-allocation bound `B_N` injectively pays for the warnings
in a completed prefix. A prefix interrupted before the funding allocation
cannot have emitted this warning. Use the appropriate per-process/fixed-unit
`B_N`, not Main's value for a different process.

The other reached warning families are conservatively covered by:

* array-initialization recognition: at most `A²` per graph, from one
  source-subtree scan per for loop and at most one `Potentially_Defined`
  warning per visited assignment/one-formal call
  (`flow-control_flow_graph.adb:3609–3666,4007–4118`);
* array aliasing: at most `13A` per graph, using the alias-pair charge above.
  The selected arrays are one-dimensional and cannot yield a nested
  record/array path or multiple index comparisons
  (`flow-analysis-antialiasing.adb:666–744`).

Thus the proposed selected-source bound is

```text
B_warn = B_N + sum_over_graphs(A² + 13A).
```

The warning frontier additionally requires the following source exclusions.
There are no overlays, address clauses, relaxed initialization, potentially
invalid types, DICs, record representation attributes, unchecked conversions,
recursive contracts, subprogram variants, or loop-local constants before
invariants. Main arithmetic is parenthesized; the selected fixed arithmetic
does not create the unparenthesized repeated-operator warning shape.
Integer Image does not take the enumeration-image marking warning.
Every selected imported binding has an explicit Global contract and either an
explicit termination aspect or a pure-function implicit termination condition
(`spark_util-subprograms.adb:786–861`), so the two assumption warnings in
`spark_definition.adb:6543–6582` are absent. With clauses mark initial-condition
expressions, not all declarations/bodies of withed runtime units
(`:4289–4308`); the selected withed specifications have no Initial_Condition.
The selected input has no Annotate/unknown configuration pragma and its root
has SPARK_Mode On. Error-entry routes for unsupported/illegal SPARK constructs,
borrowing and record untangling are absent from this successful typed/producer
prefix. The source inventory retains those sites as excluded obligations.
The no-possible-termination warning additionally requires `No_Return`
(`spark_definition.adb:8607–8618`), which no selected subprogram has.
The unreferenced function/procedure warnings require
`Is_Local_Subprogram_Always_Inlined` (`:14008–14020`). The package-spec APIs
and the sole body-local expression function fail that predicate's underlying
inline eligibility checks (`GCC inline.adb:1950–2030`); merely counting local
declarations would not establish this exclusion.
The Overflow_Mode warning requires a non-compilation-unit pragma
(`spark_definition.adb:13244–13259`); the selected source has none. The false
precondition warning requires a predicate folded to `Standard_False`
(`:5674`); the sole selected Pre, `Number <= Argument_Count`, is dynamic.
The imported APIs are outside the hardcoded imprecise-call warning family.

Each of these three warning recipes has fixed text, at most one native name
slot and no continuation. `Create_N` resolves the Image template's `&` before
constructing its Message (`errout_wrapper.adb:346–395`). Its 168-character
template replaces one character by the seven-character quoted `"Image"`, and
can add an 18-character documentation suffix, giving **192** raw characters.
The two array warnings are shorter (`vc_kinds.ads:770–784,810–814`). The wrapper
inserts a default name even though the resulting text has no placeholder.
Thus `To_JSON` does not actually emit their argument arrays
(`errout_wrapper.adb:651–669`).
Using one argument as a conservative schema bound is also sound. Flow messages
are created after substitution with an empty `Names` list (`:374` in
`flow_error_messages.adb`). Native continuation lists remain separate from the
serialized main message.

## Raw strings, names and continuation owners

Let `N_name` bound one `Chars` spelling, `N_magic` bound a canonical
generated-global entity-name spelling, `P` bound a source/reference/runtime-name
spelling, and `h` bound instantiation edges. These are the existing frontend
name/source/configuration quantities, not lengths observed in a report. With
debug node-number rendering disabled, `Flow_Id_To_String` contributes

```text
L_flow_name = max(2N_name+14, N_magic, 6).
```

Its direct form has at most one immediate scope prefix and one root spelling;
the longest facet suffix has 13 characters. Its magic form copies the stored
name; the empty identity prints `<void>` (`flow_types.adb:959–1088`). There is
no record-component loop in the selected domain. This is also the name bound
exported for the response author's `Get_Fix` transfer.

`Substitute` additionally permits constant/private/constituent prose and
quotes. `R_name=max(4N_name+64,N_magic+2)` covers these without assuming that
all objects are ordinary variables (`flow_error_messages.adb:4489–4634`). A
`#` adds source-location text; `@` emits location text **without** disabling
further substitution, unlike `&`, `%` and `#` (`:4640–4688`). Therefore a
one-marker-per-call rule would be wrong for `@`.

The pinned frontend caps the actual location buffer at 66,558 characters
(`erroutc.ads:125–132`, `types.ads:181`, `erroutc.adb:1359–1367`). Its
source-location routine appends one filename/runtime name and at most one
ten-digit line image per instantiation level, with fixed punctuation
(`:1450–1551,1760–1770`). A useful source-sensitive bound is

```text
R_loc = min(66558, (h+1)(P+64)).
```

The literal census gives a useful bound without summing unrelated message
catalogues. Each flow message recipe originates in one of the seven flow caller
modules. The largest whole-module decoded literal sum is 5,265 bytes, from
`flow-analysis.adb`; the largest whole-module `@` count is two. Add the
12 literal bytes in the flow wrapper and at most 11 CWE bytes (four digits plus
seven punctuation characters), giving **`C=5,288`, `Q_at=2`**. On the selected
scalar/array caller paths each static message recipe concatenates a subset of
its caller module's literal occurrences once; loops
around message construction emit separate messages, rather than accumulating
one unbounded message. The excluded concurrent-object recipe is the sole
caller that builds a continuation list from an unbounded object collection.

Current source basenames (`main.adb` and the fixed source closure), generated
identifiers and canonical global names introduce none of `&`, `%`, `#`, `@`.
This follows the retained frontend naming domain and configured source names;
it must be checked again for a different source-name configuration. It prevents
an inserted location/name from creating a fresh placeholder for the next
substitution. Three substitutions can then add at most three name renderings,
three `#` locations and all `Q_at` original `@` locations. `Compute_Message`
adds at most `h` explicit instantiation contexts, each at most `P+38`:

```text
M_in = C + 3R_name + (Q_at+3)R_loc + h(P+38).
```

This bounds the incoming raw main-message string, each Details/Explanation/Fix
string and each original continuation string. It includes the CWE/SRM literal
suffixes. A source configuration allowing inserted placeholder characters
requires the unconditional fallback
`C * max(1,R_name+R_loc)^3 + h(P+38)` instead; the faster additive expression
must not silently be applied to that configuration. All arithmetic guards are
checked before selecting either bound.

The native `Message.Names` list has length zero for flow messages and at most
one for the three warning families. Original flow continuations have at most
one element: the unknown-global, variable-input and initialization callers
each construct a singleton or empty list. The concurrent-object accumulating
caller is excluded. `Print_Regular_Msg` copies that list, then appends at most
six optional elements (`flow_error_messages.adb:3960–4116`), so each native
continuation list has length at most **7**. Every added element contains fixed
prefixes and one already bounded field; the oneline and IDE forms fit

```text
native diagnostic temporary string <= 7M_in + 178 + 16.
flow dedup key string               <= M_in + 13.
```

The 178 is the complete literal sum in `Print_Regular_Msg`, excluding the
already counted dynamic fields; the additional 16 covers the message-ID image
and delimiters. Under the selected `--output=brief` with the existing
`--report=all`
configuration, only the original message and its at-most-one original
continuation are printed. The bound on each printed raw message is then
`M_in+16`; the larger construction bound still applies to eager locals.
This formatting specialization does not eliminate earlier warning records,
trace attempts, message expansion or pool calls. The report/output owner
establishes the output option's noninterference separately. Retaining `all`
preserves the existing info-message path: changing to `fail` would change
`FA.Errors_Or_Warnings` and therefore claim generation, so that proposal was
withdrawn. `M_in+16` depends on the brief formatting branch, not the report
filter (`flow_error_messages.adb:3960–3996`).

The latter 13 is the signed 32-bit source-pointer image (at most 11) and the
six-valued severity-position image (at most 2). The eager `Vertex_Img` local
is separately at most ten decimal digits, and its conversion still requires
the vertex index to fit Natural even with debug output disabled. No
continuation list is serialized into a second report array: `Add_Json_Msg`
serializes the main `Message`; native diagnostic owners are distinct from
the retained JSON owners.

For process trace-attempt sum `T`, actual incoming trace counter `t0` and
unit-name bound `P_unit`:

```text
trace filename <= P_unit + 14 + digits(t0+T)
trace line including LF <= P + 12
trace file lines <= V.
```

The filename constants are eight characters for `__flow__` and six for
`.trace`. `Vertex_Sloc_Location` writes filename, separator and line image
(`flow_error_messages.adb:5013–5029`). These are per-object/index bounds;
`T*V*(P+12)` can describe total trace bytes without turning it into an
aggregate-disk admission gate.

Each Unbounded_String accumulator must apply the retained runtime backing
transfer to its own maximum requested length: `M + floor(M/2) + 2*alignment`
plus header, with all additions/indexes representable. The source bounds above
are not byte-capacity claims about allocator headers. JSON string/map/array
owners, SARIF text transformation and XString growth compose through the
response/report packet. The author's native Errout transfer additionally
accounts for earlier frontend diagnostics; these emitter counts do not erase
that incoming state.

## Message IDs and assumption-pool carries

`Next_Message_Id` increments a single process counter initialized to zero;
its sole selected caller is `Print_Regular_Msg`
(`errout_wrapper.adb:17,599–604`; `flow_error_messages.adb:3962`). An inserted
flow key causes at most one print. The justified-check branch prints then sets
`Suppressed`, preventing the later regular print (`:386–499`). Native
continuations pass `Error_Entry => False`; warning/error wrappers do not call
`Next_Message_Id`. Therefore the incoming message-ID increment is at most
`B_flow`, while the actual current value must be carried into response emission.
For incoming value `i0` and later response print bound `R`, check
`i0+B_flow+R <= Integer'Last`, since the counter increments after returning its
old value. Do not reserve the last representable ID without its increment.

The complete `Entity_To_Subp_Assumption` caller inventory has nine source
locations outside its implementation. Before the response, VC timing contributes
at most `2E_process` calls and appended flow records contribute at most
`B_flow`. The warning/error result default leaves `E` empty and therefore makes
no such call (`errout_wrapper.adb:136–139,430–436,483–489,901–914`). Main and the
selected fixed sources have no Assume or skip annotations. Thus

```text
N_subp_incoming <= 2E_process + B_flow.
```

The two final `Get_SPARK_JSON` branches are mutually exclusive per entity-list
entry and add at most `2E_process` **later**, during `Create_JSON_File`; they
are not also incoming calls. Ordinary entity marking is deduplicated
(`spark_definition.adb:11848–11850`), with one list append for a marked entity
(`:12218,12246`); package declarations have a separate append (`:12890`). The
factor two safely retains both routes. Response timings, proof records and
`Claim_To_Token` remain with the response/report author.

Incoming `Proof_Msgs` is zero for a source-specific reason, not initialization
of the container: the accepted [registration caller partition](retained-producer-tail.md)
excludes all 23 direct static-result calls and both floating-point forwarders
for these five process shapes. `Emit_Proof_Result` is the sole external caller
of `Error_Msg_Proof`; before the response it can be reached only by those static
results. Ordinary fixed-body loop invariants use the procedure translation
overload and do not take the static-result branch. Reuse that accepted
partition rather than re-executing native evidence.

If `h` counts instantiation **edges**, one call builds at most `h+1` base
locations and one subprogram (`spark_util.adb:1917–1951`), hence at most `h+2`
pool `Find` attempts. If the integration instead names the number of locations
`location_depth`, the multiplier is `location_depth+1`. Distinct entity counts
do not pay for repeated `Find` calls. Preserve the predecessor's process-wide
`e<=2` rounding allowance once over the combined pool; do not restart it at
this cut.

## Integration status

These source bounds passed the scoped independent review; whole-packet
integration remains separate. They close the former
opaque graph inputs and specify the exact earlier counters to carry. No task
completion or complete #119 predicate is asserted merely because the sums are
finite. Every sum, product, container extent, counter increment and string
backing operation retains its own representability guard.

The focused independent graph review inspected the actual constructors,
flattening, import/build gates, extended returns, initialization maps and all
trace callers. It found no vertex/trace undercount. It corrected the global
closure wording to include proof constants (`E+6`) and identified the
side-effect object marker as a safe overcharge because that branch returns
early. Phase-1 emitters remain distinct process obligations, as stated above.

The subsequent scoped review inspected emitter-loop counts, the three warning
families and excluded warning gates, literal/message construction (including
initialization's accumulating locals), the additive substitution bound,
continuation ownership, trace strings and message-ID carry. It found no
concrete undercount or blocker. It requested the explicit No_Return,
inline-eligibility, Overflow_Mode and false-precondition gates now recorded
above. This does not review the response, final report or whole #193 join.

Reviewer setting: selected GPT-6 Astra / Extra High, runtime confirmation
unavailable; source-only review, no checker or native execution. Reviewed
snapshot hashes were note
`543fd21de5c1aff1099284a07d4d9f2da12ee468a4bb8b73cefd37fead5b6caa`,
result `7268ad387424ab88069d3fbd3e4b3554fb29d0c0df166d44622391058570ae1c`,
and checker `744ae568c07e59bd37a1cc9d55114c5ae47858eab8b127ef49f67234ec807f82`,
against the stated SPARK/GCC revisions. The post-review edits add those exact
gates and review metadata; they do not alter a coefficient. Review elapsed
time and token/cost measurements were not available.

## Work record

Selected setting: GPT-6 Astra / Extra High, inherited for this subthread;
runtime model confirmation unavailable. Initial recorded clock:
2026-10-24 00:28:52 UTC. This round's outcome is source-based incoming state
composition; token/cost measurements were unavailable. No native/proof run was
started, and no saved proof evidence was invalidated.
