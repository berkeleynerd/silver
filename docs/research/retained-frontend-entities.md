# Retained frontend: Main entity and literal multiplicities

Research component for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-17, Linux x86_64. This derives a finite source-sensitive bound on the
ordinary entities generated from Main by semantic analysis and GNATprove light
expansion. It supplies parameters to the [producer derivation](retained-producer-capacity.md),
not a complete tool-capacity predicate. No current language rule, implementation,
proof, tool pin or admission limit changes here.

The inspected frontend is GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Source-to-installed-tool correspondence
retains the explicit premise of the [capacity contract](retained-tool-capacity.md).
In particular, this document does not establish that the inspected SPARK snapshot
contains exactly this frontend. The evidence reproducer verifies each cited
frontend file against the earlier complete pinned-source manifest before retaining
excerpts. No compiler or prover execution was performed.

## Domain and counts

The domain keeps the current [grammar](../../language.md), names, Integer range,
staticness, library placements and semantic restrictions, while allowing the
source, expression leaf, operator and String value budgets to vary. It does not
admit new Ada constructs. A successful analysis is assumed: semantic legality
remains a separate admission obligation. Errors and recovery trees are not an
alternative language domain.

Count syntactic occurrences, including unused declarations and unreachable arms:

| Symbol | Source quantity |
| --- | --- |
| `D` | Ordinary String and Integer object declarations, including the argument binding |
| `R` | Integer declarations with an explicit object-local range |
| `D_s` | String declarations |
| `F` | For loops, including nested and empty loops |
| `S` | String literal tokens in the parsed source |
| `A` | String concatenation operators |
| `P` | Parser flattening events for chains of at least 1,000 plain literal concatenations |

`P <= floor(A/1000)`: each flattening consumes a disjoint run at one invocation
of `P_Simple_Expression`. A parenthesized inner result is an operator node when
returned, so it cannot also be an unmodified literal leaf of an outer qualifying
run. Every event adds an empty literal, a combined literal and an artificial
concatenation. Charge these even though most of the original chain is then
unreachable (`par-ch4.adb:2561–2658`).

The following bounds concern generated **entity identities**, not total syntax
node/slot allocations, bytes, list elements, source positions or Why nodes:

```text
K_literal <= S + 3A + 5P
E_Main    <= 1 + D + R + 2D_s + 5F + K_literal
```

`K_literal` counts all creations of ordinary `E_String_Literal_Subtype` entities
in this Main analysis, including ones later replaced or rendered unreachable.
`E_Main` includes Main itself, source object/index entities, generated loop scope
entities, generated object/range subtypes and bound-capture constants. It excludes
Standard, loaded dependencies and their instantiations: those require separate
fixed/process contributions. It also does not assert that a producer work list
contains each entity once.

## Object declarations and exact type distinctions

Each source declaration supplies one defining entity. For an Integer declaration
without a range, `Find_Type_Of_Object` returns the existing Integer type. With an
explicit range, it builds one explicit subtype declaration using
`Make_Defining_Identifier`, then `Process_Subtype` uses that existing defining
entity and `Constrain_Integer` gives it kind `E_Signed_Integer_Subtype`
(`sem_ch3.adb:19080–19214,23008–23038,23130–23132,15481–15498`). This generated
subtype is **not marked `Is_Itype`**. Its bounds are static by the Silver grammar;
the range's forced-evaluation calls therefore add no captured objects.

String initialization calls `Expand_Subtype_From_Expr` from
`Analyze_Object_Declaration` (`sem_ch3.adb:5138–5145`). In GNATprove mode this
returns immediately for every nonstatic initializer (`exp_util.adb:5873–5899`).
That includes Image and First_Or_Default results and copies of mutable Strings,
even when Silver knows their exact lengths. Ada-staticness, not Silver's value
knowledge, selects this branch.

A static initializer has two relevant forms:

1. A resolved literal, including a folded concatenation, has an ordinary
   `E_String_Literal_Subtype`. `Expand_Subtype_From_Expr` creates one explicit
   array constraint from its length (`exp_util.adb:5920–5930`). The subsequent
   `Find_Type_Of_Object` creates one **non-itype** array subtype. `Constrain_Array`
   iterates once because Standard.String has one index; `Constrain_Index` creates
   one signed Integer **itype** (`sem_ch3.adb:14339–14477,15317–15475`). Its two
   bounds are static, so no capture objects are generated.
2. A static name has a constrained String subtype. The constrained-type branch
   either reuses a suitable existing itype or creates one subtype alias with
   `Make_Temporary`, then explicitly marks it `Is_Itype`
   (`exp_util.adb:5940–6011`). This aliases the existing index; it does not create
   another index subtype.

Thus each String declaration creates at most two entities beyond its object and
the literal entities charged separately in `K_literal`. Nonstatic initializers
create zero through this route. If `D_lit` and `D_alias` respectively count the
two static forms above, the tighter type contributions are:

| Generated type family | Bound | `Is_Itype` |
| --- | ---: | --- |
| Integer object-range subtype | `R` | False |
| String object subtype from literal | `D_lit` | False |
| String object's Integer index subtype | `D_lit` | True |
| String subtype alias | `D_alias` | True |
| Loop-index subtype | `F` | True |
| String-literal subtype | `K_literal` | True |

`D_lit + D_alias <= D_s`. The coarse `2D_s` does not require an admission scanner
to reproduce these frontend branch decisions. Producer formulas conditioned on
`Is_Itype` must retain these distinctions; treating every generated subtype as an
itype omits non-itype completion work.

## Loops: three entities plus at most two captures

An unlabelled loop creates one `E_Loop` scope
(`sem_ch5.adb:4109–4115`). The source defining identifier becomes one
`E_Loop_Parameter`. `Make_Index` creates one `E_Signed_Integer_Subtype`, marked
as an itype by `Create_Itype` (`sem_ch5.adb:3259–3265,3434–3438`;
`sem_ch3.adb:20712–20759`; `itypes.adb:45–85`). Explicit scalar `L .. U` cannot
take the reuse paths for a subtype mark or `'Range`.

The native preliminary `Process_Bounds` path is gated by `Expander_Active`
(`sem_ch5.adb:3298–3303`) and is absent in GNATprove. Nevertheless the later
`Make_Index -> Process_Range_Expr_In_Decl` path calls `Force_Evaluation` for both
bounds when `GNATprove_Mode` is true (`sem_ch3.adb:22704–22719`). Therefore
**light expansion can capture loop bounds**; assuming otherwise loses entities.

Each bound contributes at most one constant:

- `Force_Evaluation` invokes `Remove_Side_Effects` with `Variable_Ref => True`
  (`exp_util.adb:7221–7243`). Constants and compile-time-known values need no
  capture. A reference to a mutable object can require one even when it is a
  simple identifier (`:14429–14457`).
- The permitted bound syntax is scalar Integer arithmetic. The elementary-type
  branch creates one `Rnn : constant Typ := Expr`, relocates the whole bound
  expression into it and rewrites the bound to that constant's name
  (`:12761–12824,13102–13111`). It does not recursively create one temporary per
  arithmetic child and introduces no new subtype.
- A later request sees a constant name and is side-effect-free. The generated
  initializer has an existing definite Integer subtype and cannot re-enter the
  unconstrained-String subtype path. Validity-check expansion is disabled by
  `gnat1drv.adb:511–516` in GNATprove mode.

There are two preanalysis copies of an ordinary loop range: one when preparing
the loop (`sem_ch5.adb:3956–3979`) and one when analyzing its parameter
(`:3309–3311`). `Preanalyze_Range` disables full analysis and freezing
(`:4868–4886`), and `Possible_Side_Effect_In_SPARK` excludes this preanalysis
(`exp_util.adb:12627–12630`). These copies contain only scalar expressions and
references, with no defining entities or String expressions. They still cost
syntax nodes and numeric-evaluation work; neither cost is zeroed here.

No iteration-count multiplier occurs. The ordinary loop has no iterator,
secondary-stack bound call, body declaration, label, exit, or continue.
`Prepare_Param_Spec_Loop` therefore cannot wrap it in a secondary-stack block
(`sem_ch5.adb:3901–3990`), and `Expand_SPARK_N_Loop_Statement` only expands the
excluded array-iterator form (`exp_spark.adb:896–913`). Nesting changes `F` and
the producer's frame work, not this five-per-loop upper bound.

## Literal allocation and re-entry

There is one parser pass. Scanner lookahead may scan a literal token more than
once and allocate unused String-pool contents, but those scans are not extra
semantic expression occurrences. Their pool costs belong to the
[value component](retained-value-capacity.md). The entity formula counts parsed
literal nodes and the parser's explicit replacements, not scanner invocations.

The parser produces at most `S + 2P` literal occurrences and at most `A + P`
concatenation occurrences when charging both original and replacement trees.
Successful semantic folding can replace each concatenation at most once:
`Eval_Concatenation -> Fold_Str` rewrites that node to `N_String_Literal` and
resolves the replacement (`sem_eval.adb:2342–2443,5118–5144`). Static constant
names are read through `Get_String_Val`; `Eval_Entity_Name` keeps the name and
does not copy its initializer (`:2454–2534,5293–5308`).

Each resulting literal resolution creates at most one literal subtype; its
Standard.String lower bound is the static value 1. The nonstatic-low-bound
branch creating two further types in `Set_String_Literal_Subtype` is therefore
excluded (`sem_res.adb:13205–13337`). Separately, a nonfolded concatenation can
call this setter directly on each operand, at most twice per concatenation
(`:10804–10832`). Charge those calls even when an earlier literal resolution
already created a subtype. This gives:

```text
literal resolutions <= (S + 2P) + (A + P)
direct setter calls <= 2(A + P)
K_literal            <= S + 3A + 5P
```

The single semantic traversal matters. `Resolve` returns on an already analyzed
node (`sem_res.adb:2545–2551`); successful GNATprove expansion marks nodes
analyzed (`expander.adb:105–126`). The concatenation walker visits each left-chain
node once, then resolves each right operand once (`sem_res.adb:10570–10619`).
The admitted Main contexts do not introduce a String-expression cloning route:

| Context/path | Why it adds no uncharged Main entity or String replay |
| --- | --- |
| Main procedure | No formals, result, local subprograms or contracts; the synthetic spec for inlining requires a list-member body, excluding the library compilation unit (`sem_ch6.adb:3738–3764,5442–5623`) |
| Ordinary assignments | Actual-subtype construction in `Set_Assignment_Type` requires out/in-out formals, component/dereference/slice operands or a secondary-stack return object, none of which is an admitted assignment target (`sem_ch5.adb:300–365`) |
| String call actuals | `Resolve_Actuals` routes array checks through `Apply_Length_Check` (`sem_res.adb:4861–4877`); the shared `Apply_Selected_Length_Checks` returns with expansion disabled (`checks.adb:3509–3534`) |
| Image / First_Or_Default result | Image is typed Standard.String and integer Image is not folded to a literal (`sem_attr.adb:1571–1603,9725–9745`); nonstatic String declaration expansion returns as above; `Expand` exits the GNATprove branch before ordinary transient-scope/result expansion (`expander.adb:105–127`) |
| Library inlining | All admitted operations have package-spec declarations; `Can_Be_Inlined_In_GNATprove_Mode` rejects those and other-unit bodies (`inline.adb:1974–1988`); no copied argument initializer enters Main |
| String equality / inequality | Predefined comparison uses existing Boolean/operator entities. Light expansion rewrites String `/=` as `not (=)` with the same already analyzed children; it does not copy/reanalyze those children (`exp_spark.adb:1008–1023`; `exp_ch4.adb:10217–10256`) |
| Length | Constant evaluation uses `Get_Actual_Subtype_If_Available`, which only returns an existing type (`sem_attr.adb:8724–8745`; `sem_util.adb:10380–10408`); it does not call the allocating `Get_Actual_Subtype` |
| Other allocating actual-subtype resolution | Remaining resolver calls are packed explicit dereference, indexing, selected components and slicing (`sem_res.adb:9360–9368,9740,11889–11921,13145–13165`), all excluded |
| Renaming and freeze expansion | Main has no object renamings; scalar bound captures are constants. Ordinary Integer/String subtypes have no invariant, DIC, tagged primitives or wrapper requirements (`exp_spark.adb:1073–1105,1138–1253`) |

An upper count of semantic literal occurrences, counting a folding replacement
even if its original is retained, is `S + A + 3P`. For producer character work,
also charge the length of each folded concatenation and each flattened chain,
not just source token lengths. A source-sensitive envelope is

```text
sum(source literal decoded lengths)
  + sum(length bound of each source concatenation result)
  + 2 * sum(decoded length of each parser-flattened chain)
```

The second copy of each flattened length covers its artificial empty-left
semantic fold. This bounds the aggregate lengths of the literal occurrences
above; it does not bound repeated producer translations or repeated JSON
serialization of a shared theory. Those are separate producer multiplicities.

## Limits of this component

This is a manual source derivation with reproducible source identity/excerpts,
not a machine-checked frontend theorem or a measured coefficient. Its required
source/tool correspondence remains explicit. Native expansion additionally
creates concatenation result objects/subtypes, Image helper calls, transient
scopes, assignment checks and backend forms; its counts must not reuse this
GNATprove formula. Data-representation, ALI and translation processes also need
their own configuration and fixed-dependency contributions.

The remaining work includes all dependency entities, exact source-to-producer
work-list/translation multiplicities, frontend node/slot/list and numeric work,
generated-name lengths, Why node/list/serialization costs, and backend/object/
linker representations. No current limit can be removed merely because this
entity component is finite.
