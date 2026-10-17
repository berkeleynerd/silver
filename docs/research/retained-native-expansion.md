# Native String concatenation allocation component

2026-10-17, #119. This component closes the **direct native concatenation
emitter's** control-flow and primitive allocation accounting. It does **not**
close the construct's semantic and generated-action callees, and supplies no
whole-program capacity predicate or new admission limit. Counting generated
syntax alone misses allocations made while GNAT analyzes that syntax.

The source is GCC Ada commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The
[retained evidence](../evidence/unbounded-programs/retained-native-expansion-20261017/local-envelope.json)
records fourteen inspected files hash-checked against the complete source
manifest. Adjacent `derive.py` regenerates the arithmetic and lexical inspection
aid from that source directory. Its rows encode the manual control-flow argument
below; it is not an automatic reachability proof or a membership implementation.
No compiler, prover, Lean build or large program probe was run. Independent
review remains required.

## Phase and type premises

This is the native expansion path in `exp_ch4.adb:2552–3639,8005–8097` under
the selected Linux options: Ada 2022, assertions enabled, strict overflow
checking, optimization level zero, no frontend inlining/debug override.
It does not apply to GNATprove's light expansion. The separate native data
representation invocation must establish the same relevant options before
reusing it. Source-to-installed-tool correspondence remains the premise in the
[capacity contract](retained-tool-capacity.md).

All admitted concatenation operands are Strings: the grammar excludes Character
operands, user-defined array types and overloaded `&`. Thus `Atyp` is
`Standard_String`, its index subtype is `Standard_Positive`, and its index base
`Ityp` is `Standard_Integer`. On the selected 32-bit Integer target,
`Artyp = Ityp` (`exp_ch4.adb:2790–2825`). The local `To_Artyp` and `To_Ityp`
functions return their argument unchanged. This does not exclude the explicit
`Convert_To` calls at 2996 and 3003, or later generated conversions.

`Binary_Op_Validity_Checks` is a no-op under the selected validity switches:
`Validity_Check_Operands` defaults to False (`validsw.ads:85`), and guards its
two `Ensure_Valid` calls (`exp_ch4.adb:298–304`). Configuration closure must
exclude a validity-operand override. Other validity checks remain enabled.

## Dispatch multiplicity

`Expand_N_Op_Concat` returns for a concat that is the left child of another
concat. At the highest node of a surviving left spine it collects that spine's
operands and calls `Expand_Concatenate` (`exp_ch4.adb:8023–8060`). The outer
loop repeats for different array types; the common `Standard_String` base type
excludes that repetition here. Right subtrees have their own spines.

For a finite tree with `a` surviving concat nodes and `g` maximal left spines,
spine `i` with `a_i` concat nodes has `n_i = a_i + 1` operands. Therefore

```text
g <= a
sum_i n_i = a + g <= 2*a.
```

This bounds the initial expansion of that tree. **Copied/reanalyzed trees and
independently generated concatenations need separate charges**. It does not
establish that each source `&` is expanded only once in the entire compilation.
Fixed library sources also have a broader grammar.

Within one call let `n >= 2` be the input operand count and `r <= n` its
retained count after known-null operands are dropped. Its operand loop runs
exactly `n` times. `Get_Known_Bound` visits at most `r` successively larger
indices. The assignment loop visits at most `r` entries. These compile-time
counts do not depend on an enclosing program loop's runtime trip count.

## Direct event envelope

The following charges include constructors, shallow `Convert_To` copies,
the saved old node of the terminal `Rewrite`, and the immediate one-list
wrappers of direct `Insert_Action` calls. Open callees are additional.
Some mutually exclusive branches are deliberately overcounted.

| Direct event | Upper charge for `n` operands |
| --- | ---: |
| Ordinary node identities, excluding `New_Copy_Tree` | `25*n + 45` |
| Fresh temporary entity identities | `2*n + 4` |
| List headers, including dispatch/action lists and immediate insertion wrappers | `3*n + 11` |
| Direct `New_Copy_Tree` invocations | `5*n + 6` |
| Direct `Duplicate_Subexpr` invocations | `2*n + 2` |
| Growing-slot events from the terminal direct `Rewrite` | `1` |
| Internal names from the direct temporaries | `2*n + 4` |

Each ordinary-node term comes from a named emitter region, rather than a
measured coefficient. A constructor contributes one identity independently of
the allocation costs of its child expressions.

| Region in `exp_ch4.adb` | Ordinary charge |
| --- | ---: |
| Initial aggregate zero, 2829 | `1` |
| Per-operand lower bound and length capture, 2870–3045 | `4*n` |
| Last-operand bound capture, 2879–3007 | `8` |
| Aggregate length construction, 3054–3099 | `5*n` |
| Conditional lower-bound spine and optional capture, 3176–3228 | `4*n + 3` |
| High-bound construction, 3237–3253 | `3` |
| Two null-result selectors, 3273–3290 | `6` |
| Static maximum and optional slice range, 3306–3315 | `2` |
| Result subtype syntax, 3326–3342 | `4` |
| Maximum of the two result-storage paths, 3374–3433 | `12` |
| Runtime concat call, 3512–3538 | `3` |
| Slice assignment and optional guard, 3554–3617 | `12*n` |
| Result reference and optional slice, 3629–3632 | `2` |
| Saved original in terminal rewrite, 3453 or 3637 | `1` |

For example, general operand setup makes at most one lower-bound attribute
plus the length declaration, its type occurrence and its length attribute:
four nodes. Aggregate fallback makes one current-length leaf, a declaration,
type occurrence, addition and result identifier: five; copying the previous
aggregate length is separate. Last-operand capture makes two attributes plus
two `Convert_To` calls costing at most three shallow allocations each: eight.
The slice path makes four endpoint nodes, four assignment/slice/range/reference
nodes, and at most four guard nodes.

Temporary entities comprise `n` operand-length captures, at most `n-1`
aggregate captures, one lower-bound capture, one result object and three
secondary-stack declarations: `2*n+4`. Lists comprise one operand list, one
action list, at most `n` lower-bound conditional lists, two null-result lists,
one constraint list, four storage insertion wrappers, two runtime-call lists
and at most `2*n` assignment guard/insertion lists: `3*n+11`.

Generated `Nmake` constructors allocate one node/entity and set its fields
(`gen_il-gen.adb:2610–2699`). `New_Occurrence_Of` makes one identifier without
interning another name (`tbuild.adb:732–756`). `Make_Temporary` makes one
defining identifier and one name (`567–577`). `Convert_To` makes at most one
shallow relocation, type occurrence and conversion (`105–121`).
`Make_Implicit_If_Statement` makes one node after a restriction check
(`286–304`); configuration closure must exclude a restriction diagnostic.

`Rewrite` can save one shallow copy and perform one slot-growing `Copy_Node`
(`atree.adb:2255–2276`). The error-path rewrite and normal terminal rewrite
cannot both execute, because the error branch returns. Its error-reporting
helper is separate. The direct entity-kind change needs no additional entity
slots because entities are allocated at maximum size. Mutations in generated
action callees remain additional.

### A closed leaf-copy subset

Each `Aggr_Length` entry is an integer literal or simple identifier referencing
a captured scalar (`exp_ch4.adb:2621–2628,3054–3099`). It has no owned subtree,
defining entity or associated itype inside the copied subtree. Copying it makes
one ordinary node, with no new entity, list, name, String or Uint value.
`New_Copy_Tree` preserves literal values and references to external entities
(`sem_util.adb:24481–24586,24637–24721,25096–25125,25237–25279`).

There are at most `n-1` such copies for aggregate captures, one for the high
bound and two for null selection: `n+2`. Including these gives **`26*n+47`**
ordinary nodes. Remaining direct copies are at most **`4*n+4`**: operand low
bounds `n`, last literal bounds two, lower-bound recursion `n`, high-bound low
expression one, error-path copy one and assignment low expressions `2*n`.

The [allocator component](retained-table-capacity.md#exact-slot-sizes-from-the-pinned-generator)
gives the direct dynamic-slot contribution

```text
9 * ((26*n + 47) + 1) + 61 * (2*n + 4).
```

The extra one is the possible growing rewrite. Node-link and original-node
tables need separate envelopes. This expression excludes allocations in the
remaining copy/semantic helpers.

### Internal names

`New_Internal_Name` uses one letter, decimal unit serial and a body/spec suffix,
then `Name_Enter` (`tbuild.adb:52–98,719–726`). A serial fitting `Nat` has at
most ten digits, so each direct temporary adds at most twelve characters plus
NUL: **`13*(2*n+4)` name-pool characters**. The unqualified individual name
fits `Short` independently of source identifier length.

The **shared** unit serial must not overflow: `Increment_Serial_Number`
increments a `Nat` (`lib.adb:1062–1067`). Other name-producing helpers count
toward it. Later debug qualification and external names have additional costs;
the twelve-character bound does not apply to them. `Name_Enter` always appends
an entry and every character plus NUL (`namet.adb:1142–1161`).

### Direct Uint work

Explicit emitter expressions make at most `3*n+2` additions and `2*n+2`
subtractions: at most two `Hi-Lo+1` computations per operand (2925,3029), one
aggregate addition per retained operand after the first (3071,3082,3086), and
two add/subtract pairs for result/known maximum (3243,3310). `UI_Max` returns
an existing Uint. Numeric constructor conversions here use only zero/one or
existing Uints.

`UI_Add` allocates at most one retained entry; `UI_Sub` at most two, because
negating its right operand can allocate (`uintp.adb:791–977,2153–2179,
2222–2240,2361–2425`). Thus these expressions add at most **`7*n+6` entries
and `k*(7*n+6)` digit words**, when `k` bounds every operand, negation,
intermediate and result in base-32768 digits. The `UI_From_Int` cache can gain
at most one entry per new retained result through that path; its representation
is separate.

`Get_First_Index_Bounds` has at most `2*n` invocations. Its literal-subtype
branch adds one add/subtract pair (`exp_ch4.adb:13542–13560`). Including those
pairs gives **`13*n+6` entries and `k*(13*n+6)` digit words**. Its `Expr_Value`
calls remain separate.

If `H >= 1` bounds the magnitude of every queried input low/high bound and
literal length, a sufficient magnitude bound for this arithmetic is

```text
M = n * max(2*H + 1, 256) + H + 1
k = max(1, number of base-32768 digits of M).
```

256 is `Too_Large_Length_For_Array` (`exp_ch4.adb:83`), an optimization
sentinel, not a String limit. `Max_Aggr_Length` can accumulate it once per
unknown-length operand. Runtime String lengths alone therefore do not bound
this metadata. The formula covers every `Hi-Lo+1`, partial aggregate and both
result-bound computations. Evidence examples use integer arithmetic only.

Full-circuit addition uses two operand vectors of length at most `k` and three
work vectors of length at most `k+1` (`uintp.adb:825–864`): a local sufficient
peak is `5*k+3` digit words. Check `k+1`, byte products and address arithmetic
separately. Negation returns before addition begins. `UI_Max` comparison uses
at most two length-`k` vectors. Temporary arrays and retained pool demand are
different. Semantic evaluation/generated-expression arithmetic is additional.

## Required transitive closure

At optimization level zero, two through nine retained operands use an available
`System.Concat_n.Str_Concat_n` helper; the actuals loop moves operands without
deeply copying them. Ten or more take the slice-assignment loop
(`exp_ch4.adb:3492–3624`). Fewer than two return the retained operand after
setup. The direct envelope overcounts helper and slice paths, so it does not
assume helper availability. Runtime loading and call analysis remain separate.

Storage has another independent branch. When the enclosing scope already uses
the secondary stack and `RE_SS_Pool` is available, GNAT generates a constrained
subtype, access type, allocator-backed object and renaming (`3355–3419`).
Otherwise it generates an ordinary constrained object (`3430–3433`). The author
grammar's exclusion of access types does not exclude generated access types.
Image/unconstrained function results can affect secondary-stack state. The
secondary path additionally invokes `Freeze_Itype` and runtime lookup.

`Duplicate_Subexpr` calls `Remove_Side_Effects` then `New_Copy_Tree`
(`exp_util.adb:5323–5332`). `Name_Req => True` does not make it constant-cost:
native side-effect removal can generate an access type, reference and object
declaration for an unconstrained function result (`12984–13121`). GNATprove
explicitly uses a different path. Repeated calls can become cheaper after
capture; taking that saving requires an idempotence/result-shape invariant.

General `New_Copy_Tree` can clone associated itypes and entities in expression
actions, then copy their semantic fields, array indices, scalar ranges, entity
lists and names (`sem_util.adb:24136–25624`). Its internal maps/pending-itype
lists are additional representations. A syntactic-descendant count alone does
not discharge it. The leaf-copy result avoids these cases by input shape.

`Insert_Action` allocates its immediate one-element list and delegates to
`Insert_Actions` (`exp_util.adb:7984–8012`). The latter can attach actions to
conditional contexts, preserve transient scopes and analyze inserted actions.
Suppressing checks does not suppress this analysis. The emitter calls it once
with at most `2*n` collected declarations, and calls `Insert_Action` at most
`n+5` times. Generated declaration/access/allocator/call/slice/conditional and
freezing transfers must cover those calls. Final `Analyze_And_Resolve` and the
error path are additional entries.

## Exact remaining obligations

The following missing addends prevent calling the native construct closed:

- Bound incoming String subtype/operand shapes and values. Earlier semantic
  `Eval_Concatenation`/`Fold_Str` work needs its own String/Uint/node/entity costs.
- Attach structural costs to `4*n+4` remaining direct copies and `2*n+2`
  duplications, including side-effect-removal actions and semantic/itype copies.
- Close `2*n` collected declarations, `n+5` individual insertion calls, one
  explicit `Freeze_Itype`, up to two runtime-availability and two runtime-entity
  lookups, final analysis, value/comparison helpers and conditional error path.
  Dependency sharing requires a cache invariant.
- Bound generated/reanalysis multiplicity before replacing expanded-tree `a`
  with the source `&` count.
- Cover caller arithmetic: `List_Length`, `NN`, and the final `J := J+1`
  increment must fit `Nat`, requiring `n+1` to fit. Seven local arrays have
  bounds `1..n` or `0..n` (`exp_ch4.adb:2598–2621`); lengths and representation
  byte products need checks. Lower-bound recursion has depth at most `n`;
  physical stack exhaustion is separate.
- Add backend/object/linker and fixed-dependency costs. There is no direct
  Stringt write in this emitter or the closed primitive subset; that does not
  establish zero String demand for its open callees.

Current source/operator/String limits remain unchanged. This component does
not complete #119 or unlock dependent admission changes.
