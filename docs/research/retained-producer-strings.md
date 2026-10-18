# Retained producer string lengths

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-18, Linux x86_64. This supplies the string-length component of the
[producer capacity derivation](retained-producer-capacity.md). It neither
changes admission nor chooses the final capacity predicate. In particular,
charging the largest shape label to every serialized node is unnecessarily
coarse; retain the separate field families below when composing byte costs.

The source premise is the same archived SPARK revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0` and GCC Ada revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` used by the parent derivation.
External source/package correspondence remains its stated assumption.
No compiler, debugger, backend, solver or Lean process ran for this result.

## Inputs and result

Use these already source/configuration-derived quantities:

- `I`: maximum Main identifier-token length, with comments and literals
  excluded. Counting reserved words and context names too is conservative.
- `F`: Main source-loop count.
- `A`: the parent derivation's bound on Main frontend nodes; it bounds each
  acyclic parent path. A sharper proven parent-depth bound can replace it
  **only in the shape-label term**.
- `P`: the maximum byte length of any configured source filename or reference
  name used by this invocation, including Main, the fixed dependencies and
  their actual directory prefixes. Use the generated program location, not
  merely the caller's input basename. The selected configuration has no
  `Source_Reference` override; relocation requires recomputing this input.

All frontend, Why, VC and temporary-name counters must separately satisfy
their representation bounds. Ten decimal digits then cover their nonnegative
32-bit values; an Ada image's optional sign/leading blank is accounted for
below. These length formulas do not prove the counter bounds themselves.

Set

```text
H = max(I + 5, 18)
Q = H + 26F + 30
```

The parent source argument establishes `H` for Main `Chars` and `Q` for Main
`Full_Name`. The following bounds cover each actual field and its constructor
intermediates, including fixed imported work:

| Family | Main-generated contribution | Fixed contribution | Serializer fields |
| --- | --- | --- | --- |
| Names and name metadata | `H + Q + 41` | `1702` | Ordinary `Symbol` fields, including module/name/namespace, axiom names and projection metadata |
| Comments | `2 max(Q,760) + 2P + 248` | `1690 + 2P` | `W_Comment.Comment`, `W_Theory_Declaration.Comment` |
| Labels and markers | `max(9 + A(2H+8), P+78, H+5, 44)` | `1690 + 2P` | `Symbol_Set` members and `W_Loc_Label.Marker` |
| Identifier string attributes | `33` | `33` | `W_Identifier.Labels : String_Sets.Set` |
| Serialized source filenames | `P` | `P` | Filename component of each `Source_Ptr` field |

Take the maximum of the two contributions for each row. If a caller needs
one uniform parameter, their maximum supplies **`u`** to the serializer.
The ordinary Common-pool name bound is **`max(Q,760)`**. No unresolved fixed
name length, location-chain depth or localization depth remains in these
formulas for the current Main translation frontier. Separate fixed library
processes are addressed below.

The table partitions string *fields*, not nodes: a function declaration may
carry both labels and a location. Its children have their own fields. The
existing `h=3` bound still applies independently to each set's cardinality.

## Exhaustive constructor frontier

The offline [inventory and checker](../evidence/retained-producer-strings-20261018/check.py)
verify all 279 archived Ada files. They recover **671 `NID` calls**: 491 direct
string literals, whose maximum length is 40, and 180 nonliteral actuals.
The retained inventory identifies every nonliteral actual by source, line and
lexical body. It also inventories **1043 calls** to the ten relevant String
forwarders; node-typed overloads are deliberate overcount. The 62 literal
arms of `Why_Name_Enum.To_String` have maximum length 23. This source inventory
does not establish a call bound or pretend to be a complete Ada parser.

The manual partition of that complete frontier is:

| Origin/constructor family | Closure in the current frontier |
| --- | --- |
| Direct literals, `To_String(WNE_...)`, initialization markers and fixed enum suffixes | Finite source constants; included in the 40-character allowance or the relevant concatenation below. The largest literal within the inventoried forwarder calls is 32 characters. |
| `To_Why_Id`, `To_Why_Type`, entity `E_Module`, `Insert_*_Symbols`, loop exception names | `Short_Name`/`Full_Name` plus fixed suffixes. Main has ordinary scalar/String types and objects; record fields, pointers, dispatch and hidden/refined selections add no Main branch. |
| `New_Temp_Identifier`, including `New_Generated_Identifier` forwarding | Literal or canonical `Short_Name` base plus at most 18 characters. The node-typed overload does not stringify an AST. Old/Loop_Entry helpers pass the fixed bases `old` and `loop_entry`. |
| `Append_Num`, `Attr_Append`, content/ref/havoc and unit parameters | One canonical base plus a fixed suffix and, where applicable, at most eleven characters for `_` plus digits. Main array dimension is one, so its first/last suffix has no dimension-number tail. |
| `Localize_Binders.Local_Name` | The parent Main lineage proof permits one effective extension, bounded by `H+Q+41`; fixed callee items belong to the fixed reduction below. `To_Local` preserves the symbol. |
| Reference-type record projections and `Emit_Projection_Metas` | Main type name `H+2`, `__ref` (+5), content field `H+2+9`, separating/serial/projection text (+25), and metadata `function ` (+9): at most `2H+52`. Projection names are consumed by a declaration and two metadata fields, not fed back into another projection-name builder. |
| `New_Defining_Axiom`, `New_Defining_Bool_Axiom`, subprogram post-axiom names | Canonical symbol or Short_Name plus fixed axiom text. The Boolean helper's String `Fun_Name` actuals are fixed enum names or an already canonical type-invariant symbol. Main supplies no user predicate or expression function. |
| `Transform_String_Literal` theory/function/axiom names | `New_Temp_Identifier("String_Literal")`, followed at most by `__def` and `__well_formed`; 52 characters suffice. The literal's bytes are numeric predicate nodes, never copied into a name. Lowercasing the module name does not grow it. |
| Array representation/comparison/conversion names | Main uses the fixed rank-one, signed-Integer-index, Standard.Character key. The component name in `Get_Array_Theory_Name` is that fixed type's Full_Name, not a Main object/subtype name. Standard has populated this representation before Main. Conversion keys concatenate two fixed representation names. |
| Comment constructors and forwarding through `Open_Theory` | The previously checked 107 Comment actuals give `2Q' + 2L_build + 226`, with `Q'=max(Q,760)` and `L_build<=P+11`. This is the comment row above. |
| Trace/check/shape/pretty/branch/loop labels | The parent label derivation gives the shape and `P+78` terms. `name:` plus decoded ASCII source name costs `H+5`; trace ID plus fixed attribute/result suffix costs at most 44. Pretty/branch/loop markers cost at most 24/20/15. |
| Other specialized families | Higher-order/profile specialization, unchecked conversion, deep/container/delta aggregates, record extraction, access/move/validity trees, dispatch/LSP/lemma/pledge names and non-Standard fixed-point names are outside Main's admitted shapes. Any selected fixed work is covered by the fixed template reduction; admitting such a Main shape would require revisiting this partition. |

The String overloads of `New_Identifier`, `New_Module`, `New_Named_Type` and
`New_Type_Decl` only intern/forward their argument; module capitalization does
not grow it (`why-gen-names.adb:714–834`, `why-inter.adb:1241–1244`,
`why-gen-decl.adb:275–280`). Positional constructor calls select those same
overloads or copy an existing name/node. `Unit_Param` adds `__void_param` to a
canonical formal name; its parameterized caller is a fixed callee, while Main
literal definitions use its empty default. Array index-substitution prefixes
are fixed dimension/representation names. Thus these wrappers do not introduce
an unbounded String parameter or an additional concatenation recurrence.

For Main, `Q>=H+30`. Consequently `H+Q+41` dominates the projection/metainfo
bound `2H+52`, module bound `Q+24`, temporary bound `H+20`, and the finite
52/40-character cases. Name appenders do not repeatedly wrap their own result:
they construct distinct fields from canonical types/items. The one potentially
repeated item operation, binder localization, has its separate flag/lineage
proof in the parent record.

String-set attributes bypass `NID`, so pool observations alone would miss
them. Their complete nonempty origins are `mlw:proxy_symbol`, `introduced`,
and the Old/Loop_Entry model-trace attributes
(`why-gen-names.adb:850–880`; `gnat2why-util.adb:1379–1417,1478–1505`). The
longest is `model_trace:` + ten digits + `'Loop_Entry`, exactly 33 characters.
Copies preserve the attribute. The source-pointer serializer also bypasses
`NID` for its filename and is therefore charged separately by `P`.

## Why the fixed observations can be inflated soundly

The earlier [intern-pool measurements](retained-producer-capacity.md#name-construction-and-the-remaining-lookup-connection)
retained exact inputs and all final pool entries' length summaries. Across
the five isolated API-root runs, the largest Why string is 169 bytes and the
largest Common entity-name string is 76. These maxima **alone** are not a
universal claim. The following source reduction supplies the missing transfer.

Use the parent's additive isolated-root/cache argument: every non-import
fixed construction in a combined Main invocation has a corresponding fixed
construction in an isolated root, with the same fixed source entity, signature,
contract and constructor structure. Standard precedes Main; fixed entities
receive their own registration/translation/completion passes; a Main local
cannot rebind a fixed callee formal or become its global. Cache hits can omit
a construction, not specialize its value to Main's actual String. Closing
imports reuses names/module nodes and does not construct a new name lineage.

For **string values**, the remaining differences in corresponding constructions
are precisely:

1. Frontend internal/related-name serials and Why temporary, source-node and
   VC decimal IDs. Each occurrence has positive width in the isolated run;
   it occupies at most ten digits under the independent counter conditions.
   Signed/special marker images or an Ada image's leading blank do not break
   the factor: their original width is at least two when the sign/blank is
   retained, and their new width is at most eleven. Copying a leaf several
   times counts every occurrence in the original string length.
2. Configured source/reference paths. The fixed Why translation frontier
   contains Standard, the selected ordinary signatures/contracts and their
   scalar/String/opaque-state dependencies, including the fixed priority
   helper. It contains no instantiated generic contract or inlined body.
   Main likewise admits neither. A comment contains at most two locations;
   a check label one. Each location is therefore a single file/reference
   name plus its bounded decimal fields. The wider runtime frontend load
   closure does not imply that all its generic declarations are translated
   into this Why frontier.
3. A projection's conditional `__N` suffix. The map key omits the module
   qualification, so a preceding Main reference type can collide with a
   fixed projection key. The isolated count can be one (no suffix) and the
   combined count larger. Allow **twelve additional characters**, even if
   no suffix occurred in the isolated run
   (`why-gen-decl.adb:138–236`). The projection procedure exports the string
   only to its function declaration and the two `function ` metadata
   actuals; no resulting string contains a chain of these optional suffixes.

Other conditional suffixes do not have this interaction: array dimensions
remain fixed, and Main introduces no declarations into a fixed entity's scope
that could change its homonym suffix. `Unique_Name` scope/child prefixes,
related-name prefix/suffix choices, fixed contract localization and old/result
suffix choices are determined by those fixed source entities. The dependency
tree cannot refer back to Main. `New_Internal_Name` always writes its serial;
`New_External_Name`'s zero/positive/unique-serial branch is determined by its
fixed caller, not by the current counter value (`gcc/ada/tbuild.adb:632–726`).
The constructor partition above accounts for the String-forwarding cases too.

To see why a separate count of decimal leaves is unnecessary, write an
observed string length as `L=C+sum(l_i)+sum(p_j)`, for fixed text, decimal
leaf widths and old path widths. Each new decimal width is at most `10l_i`;
there are at most two paths of at most `P` bytes each. Including the optional
projection suffix gives

```text
L_new <= C + 10 sum(l_i) + 2P + 12 <= 10L + 2P + 12.
```

This is a pointwise template bound, not a maximum extrapolated across sample
Main programs. Every nonempty intern request remains represented by a pool
entry until the final free; duplicate requests have the same length as the
retained entry. Source-side intermediates are constituent concatenation
prefixes or unchanged case/copies, so have no greater length. In particular:

```text
fixed ordinary name       <= 10*169 + 12 = 1702  (no path leaves)
fixed comment/label        <= 10*169 + 2P = 1690 + 2P
fixed Common entity name  <= 10*76 = 760          (no paths or projections)
```

The Common transfer additionally uses the fixed ALI/name-domain argument in
the parent record. Its varying Main entity names are charged by `Q`; fixed
metadata tokens and fixed-scope entities cannot acquire a Main scope prefix.
Prefix extraction can only shorten those names. This also covers the opaque
entity-name input of the comment constructor without leaving `Q_fixed` free.

## Separate fixed processes and use of the result

The four library producer processes have fixed sources/options and no Main
input. Applying the same conservative decimal/path allowance to their own
retained maxima gives ordinary name bounds 2122 (Silver_IO), 2262
(Silver_Arguments), 2302 (Silver_Output_Libc) and 2222 (Silver_Runtime).
For their comment/label rows use respectively `2110+2P`, `2250+2P`,
`2290+2P` and `2210+2P`; their filename and string-attribute rows remain
`P` and 33. Common names are bounded by 760. These allowances deliberately
retain serial inflation even though each fixed process has less variability.
Changes to the library sources/contracts/configuration require refreshing
the fixed evidence and its source reduction, as #93 already requires.

The checker verifies source/archive identity, the constructor inventories,
raw retained-input/summary equality, current library bytes and the arithmetic.
The template and lineage arguments above remain explicit source-review
premises, rather than being misrepresented as automated semantic checks:

```sh
python3 docs/evidence/retained-producer-strings-20261018/check.py \
  --source-root /path/to/archived/spark-source \
  --source-archive docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz
```

The checker exports `bounds(I,F,A,P)` for composition and returns both the
field-family bounds and uniform `u`. Use each bound with the actual kind/field
occurrence accounting before deciding the final rule. This record does not
assert that a coarse `O*(94+8u)` charge admits every current program, nor does
it claim aggregate physical-memory availability or complete tool capacity.
