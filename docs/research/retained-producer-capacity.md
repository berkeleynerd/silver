# Retained GNATprove producer capacity: partial derivation

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-17, on Linux x86_64. This closes several producer-cost components and
identifies the remaining source-to-producer obligations. **It does not establish
a complete capacity rule, choose a new language limit, or authorize admission
changes.** The dependent implementation still needs that complete rule.

The inspected source is SPARK revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, from the source archive already retained
by the [frontend representation research](frontend-representation-result.md).
The installed package is Alire GNATprove 16.1.0, release archive digest
`82528bef29857e239373fcc36732837d743f5a00805d502c70455422ffc97191`.
Source/recipe/package correspondence retains the explicit premise of the earlier
research; this work neither rebuilds nor attests the external compiler binary.
The existing [producer review](../for-loops-image-producer-review.md) remains the
source of the Image producer/consumer correspondence claims.

Evidence is in
[`docs/evidence/retained-producer-capacity-20261017`](../evidence/retained-producer-capacity-20261017/).
The [manifest](../evidence/retained-producer-capacity-20261017/source-manifest.json)
hashes complete source files; the
[excerpts](../evidence/retained-producer-capacity-20261017/source-excerpts.md)
retain numbered LF-based source ranges. References below are paths relative to
that pinned source tree. No compiler invocation, proof invocation, installation,
or expensive validation was performed for this research.

## The producer has two different counting problems

`src/why/why-types.ads:35–43` defines signed 32-bit `Why_Int` and
`Why_Node_Id = 0 .. 2^30 - 1`; zero is reserved. Lists occupy the other part of
the ID range. The node and list vectors are defined in
`src/why/xgen/why-atree.ads-tmpl:101–116`.
`New_Why_Node_Id` and `New_List` append to those vectors
(`src/why/why-atree.adb:74–89`). Generated builders append one node, including
nodes subsequently discarded or omitted from output
(`src/why/xgen/xtree_builders.adb:238–249`). Their list-valued fields also allocate
list records (`:207–225`). A count of the final printed syntax alone cannot bound
these lifetime allocation totals.

Separately, the JSON emitter has a package-global
`Why_Node_Counter : Natural := 0`. It increments once per emitted node occurrence
and writes the integer as the occurrence ID
(`src/why/xgen/xtree_why_ast.adb:169–230`). The intended maximum is
`2^31 - 1`. The inspected generator contains no reset between output files.
Prior binary inspection recorded unchecked native increments; no checked overflow
guard is asserted here.

This is input production for proof, not optional reporting afterward.
`Do_Generate_VCs` calls `Print_GNAT_Json_File` **before** `Run_Gnatwhy3`
(`src/why/gnat2why-driver.adb:590–604`). Making user-facing confirmation optional
does not remove this representation limit from an automatic-discharge argument.

## Exact serialization recurrence

The serializer follows every referenced node, including repeated references to
the same internal node. It does not memoize a previously emitted subtree:
`Why_Node_Id_To_Json` calls `Why_Node_To_Json(Node_Table(Id))`, and list traversal
does the same for every element
(`src/why/xgen/why-atree-to_json.adb-tmpl:113–156`). For a finite acyclic Why DAG,
the exact emitted-occurrence recurrence is therefore

```text
occ(absent) = 0
occ(node)  = 1 + sum(occ(child) for every serialized node field/list entry)
occ(plan)  = sum(occ(root) for every theory root in that printing plan)
counter   = sum(occ(plan) for every emitted file in the process)
```

Primitive fields, strings and symbols contribute bytes, but no further node
occurrences. The AST schema in `src/why/xgen/xtree_sinfo.adb` identifies which
fields are node references. Internal sharing can save allocation without saving
emitted occurrences.

`Build_Printing_Plan` visits each theory symbol once **within that invocation**,
following includes with no external filename
(`src/why/gnat2why-util.adb:503–540`). It does not establish a single-print bound
across files. `Do_Generate_VCs` clears `WF_Main` per entity but does not free the
node tables; `Why.Atree.Free` occurs after all entity processing
(`src/why/gnat2why-driver.adb:507–525, 1432–1455`).

There is a useful compositional import bound. `Close_Theory` unconditionally adds
two standard imports. Its definition import and axiom-closure loops each visit
a set of module IDs once (`src/why/why-inter.adb:578–746`). If `M` bounds all module
IDs, a close adds at most `2 + 2M` include nodes. Each include serializes its
module once, so contributes two occurrences. The still-needed bounds on `M`,
the number of closes, and emitted files cannot be replaced by a raw source-byte
count without deriving their source relation.

## A closed ordinary String-literal component

Consider a static ordinary `Standard.String` literal, with `Standard.Character`
components, static Integer indexing and no relaxed initialization. Charge
standard symbol/module setup separately. The character loop in
`Transform_String_Literal`
(`src/why/gnat2why-expr.adb:30325–30362`) allocates these nodes per decoded
character:

| Operation | Fresh Why nodes |
| --- | ---: |
| Integer index constant | 1 |
| Character name/type for array-access result | 2 |
| Array-access call | 1 |
| Character numeric constant | 1 |
| Character-to-integer conversion call | 1 |
| Equality call | 1 |
| **Total per character** | **7** |

The helper paths are `New_Discrete_Constant`, `New_Array_Access`, `EW_Abstract`,
`New_Kind_Base_Type`, `To_Why_Type`, `Insert_Simple_Conversion`, `Conversion_Name`
and `New_Comparison`. They are retained in the excerpts. Standard symbol lookup
can lazily initialize symbols; it is not free setup for a whole program.

For decoded length `L`, the loop and `New_And_Pred` together add:

```text
fresh nodes         = 7L + [L >= 2]
fresh lists         = 3L + [L >= 2]
fresh list elements = 5L + max(L - 2, 0)
```

The three argument lists per character have lengths two, one and two. For two
or more conjuncts `New_And_Pred` creates one connection, whose `More_Right` list
holds the remaining `L-2` operands
(`src/why/why-gen-expr.adb:3533–3569`). Its two temporary predicate arrays are
also length `L`; these are a memory requirement rather than additional Why IDs.
For `L=0` this component reuses `True_Pred` and allocates none of the above.

The serialized equality subtree is larger because it repeats shared type,
name, function and argument structures:

| Serialized subtree | Occurrences |
| --- | ---: |
| Builtin Integer/Boolean/Unit type | 2 |
| Character or array-map type with module name | 3 |
| Equality identifier | 4 |
| Character `to_rep` identifier | 5 |
| Array `get` identifier | 6 |
| Literal function identifier | 5 |
| Unit parameter identifier | 4 |
| Literal function call | `1 + 5 + 4 + 3 = 13` |
| Array access | `1 + 6 + 13 + 1 + 3 = 24` |
| Conversion | `1 + 5 + 24 + 2 = 32` |
| Equality | `1 + 4 + 32 + 1 + 2 = 40` |

Thus this **character-definition predicate**, excluding the enclosing theory,
declarations, quantifier, trigger, imports and other producer work, emits

```text
P(0) = 1
P(1) = 40
P(L) = 40L + 1, when L >= 2
```

This is a component result, not a safe literal-length cutoff. For example,
dividing `2^31-1` by forty omits the rest of the producer and its earlier files.
`L` is the length of the frontend literal reaching this transformation. A future
source-sensitive rule must include frontend-generated/folded literals and
transformation multiplicities; summing only source token contents is unjustified.

### Retained-artifact corroboration

The evidence extracts three unchanged literal theories from the existing
`program-cKuh3x/obj/gnatprove/main.gnat-json`, alongside its original source.
The full original JSON and source hashes are recorded in
[retained-input.json](../evidence/retained-producer-capacity-20261017/retained-input.json).
This is inspection of an existing artifact, not a new validation run or a claim
about the provenance of the whole old run.

Each equality has forty occurrences. The three module totals are:

| Decoded length | Character predicate | Whole observed literal theory |
| ---: | ---: | ---: |
| 1 | 40 | 130 |
| 3 | 121 | 211 |
| 7 | 281 | 371 |

All three observed theories have eight imports and seventy-four other
occurrences, giving `74 + P(L) + 2*8`. That observed fixed overhead is
corroboration, not a universal whole-module bound. The retained script checks
these values and contiguous serialized occurrence IDs without invoking GNATprove.

## Source-child multiplicities that are now closed

These facts concern reachable ordinary Main transformations, conditional on
their stated frontend shape. They do not price all helper work.

**Concatenation.** `Transform_Concatenation` introduces temporaries for both
operands before using them repeatedly for lengths, bounds and reconstruction
(`src/why/gnat2why-expr.adb:21976–22351`). `New_Temp_For_Expr` replaces a nontrivial
operand with a fresh identifier; an existing identifier/dereference needs no
binding. `Binding_For_Temp` inserts the original definition once and removes its
map entry (`src/why/why-gen-expr.adb:311–348, 4962–4996`). The `W_Binding` schema
has one `Def` and one `Context` field. Hence concatenation repeats bounded-shape
temporary references, not entire complex child expressions. For occurrence cost,
the two complex child coefficients are one; the helper overhead remains to price.

**Branches.** Each then/elsif/else body is translated once and assembled once
into nested conditionals; conditions are likewise translated once at this layer
(`src/why/gnat2why-expr.adb:29733–29862`). There is no enumeration of combinations
of execution paths in this transformation. Predicate and warning helper costs
still need their own bounds.

**Loops.** With `--no-loop-unrolling`, no body declarations or invariant pragmas,
and whole-object assignments, the source-derived recurrence per loop occurrence
has the form

```text
O(loop) <= O(body)
         + Prog(low) + Prog(high) + Term(low) + Term(high)
         + K_loop + sum(H(entity) for entity in Q_loop).
```

No-invariant processing moves the body to `Final_Stmts`, empties `Initial_Stmts`
and clears `Frame_Constants`; the body is translated once. `Wrap_Loop` uses it
once in a try block, and later bindings preserve that context once
(`src/why/gnat2why-expr-loops.adb:510–573, 787–813, 2194–2334`). The repetition
branch is gated by `not No_Loop_Unrolling` (`:1812–1814`). Numeric trip count is
therefore absent from this recurrence.

Both endpoint-domain costs are needed: range-invariant generation re-translates
the endpoints in the term domain, while outer bindings translate them in the
program domain (`src/why/gnat2why-expr-loops.adb:1398–1415, 1937–1960`;
`src/why/gnat2why-expr.adb:14857–14920`). These are frontend range nodes; any
frontend-generated captures or rewrites remain part of source correspondence.

`Q_loop` is a set of distinct non-discarded modified root entities from the loop
and its descendants, including applicable library globals. The frame write map
deduplicates root entities, traverses nested-loop bodies and discards nested
indexes (`src/why/gnat2why-expr-loops-inv.adb:1940–1976, 2291–2350`). For `F` loops,
`D` mutable program objects and `G` applicable fixed library globals, the coarse
bound is `sum |Q_loop| <= F(D+G)`; counting distinct assigned descendant targets
per loop is sharper. Repeated assignment to one object does not add frame entries.

For frame entries classified `Entire_Object`, the preserved-components helper
returns `True_Pred` because `Only_Vars` defaults to true. `Not_Written` entries
instead generate whole-object equality, including where an assignment lies on
a path irrelevant to the invariant. The loop-entry snapshot argument
is nevertheless evaluated eagerly, so snapshot creation must still be charged
(`src/why/gnat2why-expr-loops-inv.adb:181–196, 775–807, 1266–1270`). Snapshots are
deduplicated by Ada `Node_Id` identity in separate `No_Checks` and `Regular` maps
(`src/why/gnat2why-util.adb:1347–1454`). The frame path supplies the root entity
node, allowing at most one frame-created snapshot per entity per loop in that
map. This is not general deduplication of semantically equal expressions.
`H` still needs numerical bounds for identifier/type processing, dynamic
invariants, preservation checks and snapshot bindings. `K_loop` still needs
the fixed index/control/warning wrapper bound. Allocation of discarded nodes
also remains to price independently of this serialization recurrence.

## Precise remaining obligations

A whole-source rule needs both lifetime allocation bounds and emitted-occurrence
bounds, then safe checks against the respective representation ranges. The exact
DAG recurrence above is computable **given the generated DAG**, but is not yet
an independent admission calculation from authoritative Silver source.

| Missing term | Concrete caller closure required |
| --- | --- |
| Frontend-to-producer inputs | Bound generated entities, anonymous types, range captures and static/folded literal nodes for the admitted Main grammar and fixed dependencies; link these to source-derived quantities. |
| Declaration and initializer multiplicity | Close `Transform_Declaration`, `Translate_Entity`, `Translate_Constant_Value` and declaration completion. `Translate_Constant_Value` can separately translate the same initializer in the term domain (`gnat2why-decls.adb:122–270`); executable-declaration cost alone misses it. |
| Type/module count | Close `Translate_Type`, type completion and standard/synthetic array/scalar theory generation for the generated subtype set. This supplies `M` and theory-close bounds for the import term. |
| Expression helper overhead | Price reachable scalar conversions/checks, dynamic String reconstruction, comparisons, Image and assignment helpers, including lazily initialized symbols. Child-once properties do not make these costs zero. |
| Loop per-entity overhead | Close `H` and `K_loop` for the Integer/String shapes and actual library write-global set, retaining the two endpoint domains and snapshot accounting. |
| Fixed libraries at call sites | Separate one-time fixed library theories from per-call argument binding, contract/check substitution, globals and any permitted inlining. Fixed library source size does not imply constant total call-site cost. |
| Number of printing plans | Close `Analysis_Requested`/entity selection and `Generate_VCs_For_Type`'s guards for generated types, as well as the Main subprogram. The driver may emit per entity when new VCs are registered; do not assume one file merely from one source Main. |
| Lifetime nodes and lists | Charge builders and list creation in paths whose results are simplified, discarded or never printed. The final JSON tree cannot observe them. |

The existing source/certificate model supplies useful grammar and semantic
quantities, including declaration/expression/loop structure. It does not yet
establish these external producer transformation bounds. Samples, observed JSON
growth, or a successful large proof run would not close that gap.

The next feasible step is a cost model for this finite reachable grammar,
parameterized by the frontend-generated entity/literal bounds: maintain separate
node, list, list-element and serialized-occurrence components; first close
ordinary declarations and their subtype theories, then expression helpers and
library calls, then emitted-file selection. Each leaf needs source justification
and a composition lemma. The closed literal and child-multiplicity results above
can be reused directly. This investigation does **not** establish that the work
is impossible or that an external toolchain modification is necessary.

Until those terms are closed, no sound expanded threshold follows from this
producer analysis. Retain the current admission rules and the unchanged Oracle;
record the capacity prerequisite as incomplete rather than selecting an
empirical cutoff or proceeding with dependent admission changes.

## Reproducing the evidence checks

Run only the retained-fixture/arithmetic checks:

```sh
python3 docs/evidence/retained-producer-capacity-20261017/capture.py
```

To regenerate source excerpts, add `--source-root` pointing at the already
archived SPARK source snapshot. `--retained-json` and `--retained-source` can
re-extract the old fixture from paths recorded in `retained-input.json`.
Outputs are deterministic; no toolchain or proof subprocess is launched.
These checks validate the arithmetic and captured tree shapes, not a completed
producer theorem or the whole application assurance argument.

A focused independent source/evidence review found no defect in the numerical
literal components. Its loop-entry wording correction above distinguishes
`Entire_Object` from `Not_Written`; the recurrence already includes both in `H`.
The review also requested the additional retained conversion/base-type excerpts.
It independently checked the original artifact hashes, exact three-module
extraction, retained-source equality and complete source-file hashes.
