# Retained producer composition and useful region

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This composes the ordinary Main producer transfer with fixed dependencies,
imports, JSON fields and auxiliary container domains. The inputs are source
syntax counts and configured path lengths. No prover result decides membership.
The unchanged-tool capacity design still has to combine this component with
the complete frontend, native expansion/backend and fixed library-process
arguments. This record changes no production admission rule.

The [offline checker](../evidence/retained-producer-composition-20261018/check.py)
and [result](../evidence/retained-producer-composition-20261018/result.json)
retain the formulas, four source fixtures, their syntax counts and sensitivity
calculations. It reads existing graphs and schema; it launches no compiler,
debugger, solver or proof process. The fixtures establish that the inequalities
have useful solutions. The source arguments establish the inequalities.

## Fixed imports can remain paid

The earlier [isolated-root reduction](retained-producer-capacity.md#additive-isolated-root-envelope)
already transfers each fixed non-import tree and cache fill to an isolated root
witness. Its general aggregate conservatively recharged every post-Standard
close against all modules. For the current Main grammar, that extra charge is
unnecessary for the **fixed imported** theories:

1. `Compute_Module_Set` traverses the supplied theory's own tree. It collects
   referenced module IDs, including fixed builtin modules for numeric constants;
   it does not consult the global dependency graph or other theory contents
   (`why-inter.adb:165–326`). Identifier traversal uses its name, and explicit
   imports use their module. These are among the immutable cached values covered
   by the existing isolated-root argument.
2. `Standalone_Theory` adds the two standard imports. `Definition_Theory` adds
   its own module set after excluding its defining module and current module.
   `Axiom_Theory` adds its own set and records a dependency. Recording edges does
   not traverse them. Only `VC_Generation_Theory` invokes transitive dependency
   closure (`why-inter.adb:560–752`).
3. Imported library entities do not receive VC generation in the Main process.
   `Is_In_Analyzed_Files` accepts only the current compilation unit's body/spec,
   using an itype's associated node when necessary
   (`spark_util.adb:3839–3854`). `Analysis_Requested` immediately rejects an
   entity outside those files (`spark_util-subprograms.adb:52–88`), and the
   driver's `Generate_VCs` calls `Do_Generate_VCs` only for `Analyzed`
   (`gnat2why-driver.adb:1341–1375`).
4. The complete `VC_Generation_Theory` call frontier consists of type VC
   generation and the five subprogram/package/protected/task/LSP VC paths in
   `gnat2why-types.adb:1408` and `gnat2why-subprograms.adb:3928,4195,4448,4482,6457`.
   No ordinary imported declaration/completion helper closes a VC theory.
   Standard is translated/completed before the compilation unit, without a
   Standard VC pass (`gnat2why-driver.adb:1644–1687`).

Consequently, adding Main entities or another fixed root cannot enlarge a fixed
theory's import set. It can suppress shared fixed work. Module-ID renumbering
and name serial changes do not change tree shape or set cardinality; their
string bytes are independently bounded. All fixed import nodes and occurrences
can therefore remain included in the existing measured additive envelope
`K_fixed=(15349,3310,4729,22621)`. The five witnesses' own Main/import work
remains deliberate overcount. The former allowance of 219 unpaid fixed closes
is still safe, but is no longer required by this sharper composition.

## Modules and Main output files

The same non-import/cache reduction transfers the number of fixed module nodes.
Each retained post-Standard graph has 238 modules. The five final graphs have
343, 260, 388, 394 and 308 respectively. Their additive envelope is

```text
M_fixed = 238 + (105+22+150+156+70) = 741.
```

The checker derives this count from node kinds, not from theory-root count.
Close-time includes allocate no module. Definition/axiom closes may ask for
the defining entity's regular module; these misses belong to the memoized
module budget. A VC close's `Get_Refinement_Mask` reads existing Expr_Fun and
Refined_Post slots, and its Fun_Post slot was created before either corresponding
refinement was registered (`why-atree-modules.adb:410–445`;
`gnat2why-subprograms.adb:7452–7511,8701–8759,8844–8862`).
`Mutually_Recursive_Modules` reads existing module-map entries and specialization
records (`why-atree-modules.adb:4634–4724`). Thus those close-time traversals add
no unbudgeted direct module family.

Let `V_Main` be the four-component ordinary Main sum plus its `(746,341,522,1039)`
enclosing wrapper and `(83 E_Main+4,0,0,0)` cache allowance. The latter is the
already established `56 E_Main+4` symbol bound plus `27 E_Main` module misses.
It does not add the bootstrap initializer, already paid by `K_fixed`.
Write `H_chars` for the corrected literal/concat/copy length sum, and `A_Main`
for the [source-derived frontend bound](retained-main-semantics.md#node-identity-aggregate-and-remaining-resource-obligations).
One useful conservative module bound is

```text
M = 741 + V_Main.nodes - 7 H_chars - (4 A_Main+2).
```

This removes only two separately priced families which allocate **no modules**:
the per-character predicate constructors and the list/Void/location wrappers.
All other Main allocations are conservatively treated as possible modules.
This is a bound on allocation categories, not subtraction of a lower bound
from an unrelated total. The one-per-literal module and per-use map module
remain charged. This deliberately loose bound is retained as an independent
cross-check.

A type-sensitive bound is sharper. Let `X_Integer` count only literal,
value-name and arithmetic syntax nodes in ordinary Integer expressions;
exclude Length attributes even though their result is Integer. Put
`V_Integer=2 X_Integer+2G`. These visits construct only scalar types and
memoized entity modules, with no fresh direct map module. All other expression
visits may conservatively use their entire 110-node allowance as modules.
Using the already priced local constructors gives another bound:

| Direct/cached module family | Upper count |
| --- | ---: |
| Fixed envelope; whole Main wrapper | `741+746` |
| All Main memoized module kinds | `27 E_Main` |
| String object registration plus mutable definition | `2D_s` |
| String non-itype completion | `3D_s` |
| String type-symbol cache's two abstract-type calls | `2(D_s+K_literal)` |
| Array representation attempts plus one miss | `D_s+K_literal+3` |
| Literal definition modules | `K` |
| Other expression visits | `110(V-V_Integer)` |
| Whole String declaration/assignment node allowances | `55D_s+148S_assign` |
| Whole output/Reject wrapper node allowances | `9P_output+4P_reject` |
| String frames, at most D_s local roots plus one output String | `5F(D_s+1)` |

Take the minimum of this sum and the earlier module bound. Scalar declarations,
assignments, type completion, loop core and if/warning skeletons have no direct
module construction; their entity-module lookups stay in `27 E_Main`.
The object, cache, array and five-module String frame counts are already derived
in the corresponding sections of the parent record. The static String itype
declaration uses existing array and scalar modules
(`why-gen-arrays.adb:1534–1620,2526–2645`); its non-itype suffix is the separate
three-module row. The deliberately entire-node rows above need no additional
module assumption. This refinement does not discard any Why allocation from
the node/list/element budget.

The Main process prints **at most one JSON file**. Besides Main itself, its
entity frontier contains objects, loop scopes and ordinary scalar/String
types; it has no nested subprogram/package/task or protected type. The driver's
type path has no check to perform: no private view, access-subprogram type,
iterable/aggregate annotation, ownership type or nonpredefined equality.
`Generate_VCs_For_Type` returns before constructing a theory or registering a
VC when these checks are absent (`gnat2why-types.adb:1108–1141`;
`spark_util-types.adb:835–871`). Main itself is visited once. Each
`Do_Generate_VCs` invocation prints at most once, only if it registered new VCs
(`gnat2why-driver.adb:507–610`). It can print zero files. This proof does not
apply to the separate library-body processes, whose observed counts are two
and three files.

## Composed source inequalities

Use the source counter definitions and complete local coefficients in the
[ordinary Main sum](retained-producer-capacity.md#assembled-ordinary-main-contribution).
For a simple syntactic bound, replace the declaration classification by
`D_lit=D_s`, `D_alias=0`: the literal row dominates the alias and nonstatic
rows componentwise. Use `D_copy=D_s` and `G=2F`. Let

```text
B = K_fixed + V_Main
C = 2D+8F + 4R+6D_s+2K_literal+3F + K+2 + 4
I_import = min(C (2+2M), 2C+V_Main.occurrences+M)
N = B.nodes + I_import
L = B.lists
J = B.elements + I_import
O = B.occurrences + 2 I_import.
```

`C` includes only Main-owned unpaid closes, including its four wrapper closes.
The fixed envelope already pays fixed closes. With at most one output file,
`O` also bounds the lifetime emitted-node counter. Required independent checks
are `N<=2^30-1`, `L<=2^30`, `J<=2^31-1`, `O<=2^31-1`; the backing-vector,
linked-list and copy arithmetic follows the [storage derivation](retained-producer-storage.md).
`B.nodes` bounds temporary-name increments and the projection serial's preceding
count. Each constructed/serialized String must satisfy its own length rule.

The second import bound follows the tree structure. Every invocation of
`Compute_Module_Set` inserts at most one module per visited Name, numeric
constant or Include occurrence. The `Int_Unary_Minus` special case can insert
one additional module at its Identifier occurrence; its normal name traversal
has its own separately counted occurrence. Thus the sum of the own-tree set
cardinalities across all Main-owned theory roots is at most
`V_Main.occurrences`. This is an **occurrence** bound, including repeated shared
children and all wrapper occurrences, not a unique-node count. Each close adds
two standard imports. Only the single enclosing Main VC close traverses the
global dependency graph and can add another `M` imports. All other Main
type/object/literal/wrapper closes are definition, axiom or standalone closes.
Keeping the minimum preserves the earlier unconditional bound as a cross-check;
neither allowance assumes that shared fixed work has disappeared.

For JSON bytes, retain the schema's actual field types and the
[separate string families](retained-producer-strings.md), with `d=40` and `h=3`.
`W_Module.File` is a builtin Why library symbol, not a source filename. The
complete 155-call inventory has 154 named actuals using only five fixed symbols
or No_Symbol, and one positional forwarder preserving File unchanged. The five
symbols are initialized from `int`, `real`, `ref`, `_gnatprove_standard` and
`ada__model`; the maximum is **19** characters
(`why-atree-modules.adb:514–519`; `why-gen-names.adb:825–831`). Module nodes are
immutable. The checker scans all 279 archived Ada files and verifies those
actuals and initializers. Use 19 for this field instead of the ordinary-name
maximum; `W_Module.Name` retains that ordinary-name bound.

There is at most **one shape label** in a label set: `New_VC_Labels` constructs
one shape, one check and one fixed annotation/model marker; all other sets have
at most three nonshape labels (`why-gen-expr.adb:5329–5372`). Writing
`H=max(I_max+5,18)` and actual configured filename bound `P_path`, their total
characters are bounded by

```text
S_Main = max(3 max(P_path+78,H+5,44),
             9+A_shape(2H+8)+P_path+78+44)
S_fixed = 3 (1690+2P_path).
```

Use `2+2 max(S_Main,S_fixed)+3h` for a Symbol_Set field's local serialized
cost. This avoids charging three copies of the largest shape label. Individual
labels still obey the separate quoted-string temporary-buffer condition.

Here `A_shape` counts potential shape-contributing syntax nodes, with

```text
A_shape = A_parse-A_scan +4B_loop+44F+4R+21D_s+7U+10H_len
          +V0+2O+2P_flat+4O_loop.
```

The parser's non-scanner nodes are all retained conservatively. Scanner
identifier/literal leaves contribute no shape text; source call conversions
are paid by the parser's call rows and the semantic `V0` row. Generated entities,
ordinary freeze nodes, call markers and variable-reference markers also match
the `others` branch of `Shape_Of_Node`. The structural semantic subtotal
`A_struct` covers every remaining generated ordinary node. Substituting the
existing `T_fold` bound into it gives the added terms above. This bounds even
the sum of all shape-producing nodes, hence any single parent path, without
requiring a semantic AST measurement. It can remain much larger than actual
parent depth, especially for sequential siblings. It changes only the shape
length argument; the full `A_Main` still controls node/map/undo domains.

Let `w_k` be the family-aware local byte weight of node kind `k`, excluding
children; the checker derives it from the existing 63-kind/177-field schema.
Let `F_k` be the additive fixed occurrence vector reconstructed from the raw
graphs. The character predicate contains only call, identifier, name, module,
type, Integer constant and connection nodes. Define `w_char` as their maximum
weight, `O_char=40 H_chars`, and `O_body=V_Main.occurrences-O_char`. Then

```text
T = 29 + sum(F_k (w_fixed,k+1))
       + O_body (max_k w_k+1) + O_char (w_char+1)
       + I_import (w_include+w_module+2)
T <= 2147483646.
```

The root/list separators are charged once per emitted occurrence, as in the
schema proof. This is conservative for ordinary body nodes, but does not charge
a large shape/comment to every fixed node, character predicate or import.

The [fixed light-frontend component](retained-main-semantics.md#fixed-light-capture-result)
supplies `A_fixed=12784`, including its
sentinels and complete small witness Main. Do not subtract that witness. For
Main auxiliary domains, use `A_total=12784+A_Main` and
`E_total=12784+E_Main`. Thus

```text
F_Why = 6097+13 B.nodes
F_Common = 71831+E_total+13 E_Main
X_scoped = 36 E_total+7 F_Common+1
undo_peak = 204(A_total+1)+2 B.nodes+30 X_scoped.
```

Compare both pool calls to `2^31-1`, their distinct-name upper bounds to
1,610,612,741, source-node and `160 E_total` symbol-map domains to that hashed
container endpoint, and the undo list to `2^31-1`. The checker conservatively
uses each call count itself for its distinct-name upper bound. The
[undo derivation](retained-producer-undo.md) and pool/string arguments cover
temporary copies and 64-bit allocation/byte-counter arithmetic. They do not
place a cap on available physical memory. Failed-proof explanatory diagnostics
after the successful producer prefix remain outside this prefix claim.

## Nonvacuity and sensitivity

For `P_path=256`, the source fixtures give:

| Structure | A_Main | Nodes after imports | Emitted occurrences | JSON character bound |
| --- | ---: | ---: | ---: | ---: |
| Null | 39 | 20,401 | 32,831 | 124,012,051 |
| Output of `"a" & "b"` | 68 | 29,617 | 54,930 | 243,835,266 |
| Ranged Integer declaration and assignment | 74 | 30,353 | 58,493 | 271,833,565 |
| Ranged Integer plus loop and assignment | 169 | 43,113 | 89,960 | 452,442,136 |

All listed producer inequalities hold, including auxiliary domains. These byte
numbers are upper bounds, not measured report sizes. The largest undo bound is
34,290,838, the largest Why-pool call bound 267,150, and the largest ordinary
Common-pool call bound 84,727 in these four cases.

A single output literal exposes the length sensitivity without increasing its
syntax-tree depth:

| Literal characters | Complete source bytes | JSON bound at P_path=256 | Producer inequalities |
| --- | ---: | ---: | --- |
| 1 | 94 | 164,958,504 | pass |
| 64 | 157 | 191,103,504 | pass |
| 1,024 | 1,117 | 535,170,472 | pass |
| 4,096 | 4,189 | 1,377,021,352 | pass |
| 8,192 | 8,285 | 2,499,489,192 | fail byte envelope |

At 4,096 literal characters, changing `P_path` from 64 to 1,024 changes the
bound from 1,362,166,696 to 1,436,439,976; both fit. These are explicit
source/configuration scenarios, not an assertion that every installation has
256-byte paths. Production must calculate its actual configured path bound.
The 4,189-byte fixture lies beyond today's source cap, so this component is
neither vacuous nor intrinsically confined to today's source bound. Failure of
the conservative 8,192-character inequality does not establish an actual tool
failure at that size. A sharper per-kind Main/module transfer could enlarge the
region without changing the external tool.

Sequential range-loop assignments expose a different conservative loss:

| Loops | Source bytes | JSON bound | Producer inequalities |
| --- | ---: | ---: | --- |
| 1 | 143 | 452,442,136 | pass |
| 2 | 182 | 675,436,441 | pass |
| 3 | 221 | 1,152,620,140 | pass |
| 4 | 260 | 1,769,150,783 | pass |
| 8 | 416 | 5,628,742,795 | fail byte envelope |

The larger bound at eight sibling loops is conservative loss, not an observed
failure of this currently admitted program. In particular, the all-node
shape-length envelope grows with siblings which are not on one parent path,
and its maximum local weight still applies to every ordinary Main occurrence.
A future refinement can count shape-bearing occurrences and parent depth
separately. The old aggregate rejected two loops already; preserving occurrence
counts in imports and keeping field/module classes distinct improves the useful
region without changing the external tool or selecting a new arbitrary cap.

The four separate fixed library processes retain their own measured graphs,
files and intern counters. Their ordinary Main frontend constant must not be
reused as a library-body frontend bound. Process-specific frontend/domain
connection, native/backend bounds, and the whole-rule review remain separate
delivery requirements; passing the calculations here does not complete #119.

Reproduce the arithmetic and graph expansion with:

```sh
python3 docs/evidence/retained-producer-composition-20261018/check.py
```
