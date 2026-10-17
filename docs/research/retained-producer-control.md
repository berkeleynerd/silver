# Retained producer: Length and branch wrappers

Source-derived component for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-17, Linux x86_64. This extends the
[producer cost derivation](retained-producer-capacity.md) for the inspected
SPARK snapshot `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. The existing
source-to-installed-producer premise remains explicit. No admission, production
implementation, proof, tool pin or Oracle changes here.

Costs use `(fresh nodes, fresh lists, appended list elements, emitted node
occurrences)`. Allocations include discarded work; occurrences expand shared
children every time they are serialized. Symbol interning, identifier byte
lengths, fixed module initialization and theory imports are separate components.
This record prices the wrappers below, not all source-to-producer invocations.
The [evidence](../evidence/retained-producer-control-20261017/README.md)
verifies the cited source identities and checks the small serialization/count
arithmetic without launching a compiler or prover.

## Object Length

For an admitted `Name'Length`, the prefix denotes an ordinary initialized
rank-one Character String. The [Main String shape invariant](retained-frontend-entities.md#string-types-under-light-expansion)
excludes dynamically constrained String subtypes. Standard.Integer is the index
base; no modular-index or validity/relaxed-initialization branch applies.
The result computation uses builtin Why Integer. An enclosing expected-type
conversion/range or overflow check remains a separate caller cost.

The attribute handler eagerly translates the object prefix and calls
`New_Temp_For_Expr`, even though a simple name subsequently uses its binder's
bounds directly (`src/why/gnat2why-expr.adb:19903–20101`). The program path may
bind that temporary; the term path can leave its allocations discarded. Thus
reading only the returned length expression would undercount allocation.

| Component | Nodes | Lists | Elements | Occurrences |
| --- | ---: | ---: | ---: | ---: |
| Eager object read, including expected type and same-type conversion | 14 | 3 | 5 | 48 |
| Eager optional temporary identifier/name | 2 | 0 | 0 | counted in binding below |
| Binder-specific length computation | 3 | 3 | 4 | 36 |
| Optional binding around the length expression | 1 | 0 | 0 | 8 |
| **Core total** | **20** | **6** | **9** | **92** |

The prefix row composes the earlier split-String read bound of six nodes with
two nodes for implicit expected-type construction and six eager nodes in the
same-entity array conversion. Identity conversion returns the original read,
so it does not add emitted occurrences. Regular/static reads are smaller.
The implicit-expected-type overload is at `:25668–25724`; ordinary same-entity
array conversion and read costs retain the earlier producer component's premises.

For a split-array binder, `Get_Array_Attr(Item, Length)` supplies its two stored
bounds to `Build_Length_Expr` (`src/why/why-gen-arrays.adb:2894–2928,537–580`).
Each bound-to-Integer conversion costs at most one call/list/element and fourteen
occurrences; the length call adds one node/list, two elements and eight
occurrences. This gives `3/3/4/36`. A regular static array instead returns a
length constant; a regular unconstrained array uses one accessor on the cheap
binder name. Both are covered by the same row.

`Binding_For_Temp` creates at most one typed binding and retains its definition
once (`src/why/why-gen-expr.adb:311–347`). Its overhead is one binding node,
the temporary's at-most-five occurrences and the result's two-occurrence builtin
Integer type, totaling eight. The temporary's allocated nodes were charged in
the preceding row. There is no multiplication by the String's runtime length.

## Branch-observation assignment

Every translated if/elsif condition passes through `New_Counterexample_Assign`
(`src/why/why-gen-expr.adb:4728–4758`). This helper has no counterexample-option
guard: disabling requested counterexamples does not remove its construction.
It stores the condition in the existing `spark__branch` symbol, then reads its
Boolean content through a record access. The supplied condition occurs once.

| Constructed wrapper | Nodes | Lists | Elements |
| --- | ---: | ---: | ---: |
| Assignment and optional location label | 2 | 0 | 0 |
| Label on the existing branch identifier | 1 | 0 | 0 |
| Fresh `bool__content` identifier and name | 2 | 0 | 0 |
| Record access | 1 | 0 | 0 |
| Two-item sequence | 1 | 1 | 2 |
| **Total** | **7** | **1** | **2** |

The existing branch identifier has five occurrences: identifier, name, module,
and the two-occurrence builtin Boolean type
(`src/why/why-atree-modules.adb:529–533,2805–2810`). The field identifier has
two; its overload defaults to no type/module
(`src/why/why-gen-names.ads:83–89`; `.adb:786–808`). The assignment contributes
eight occurrences besides its condition, its location label one, the label
on the branch identifier eight, the record-access wrapper/field/type five,
and the sequence one. Total emitted overhead is **23**. Source-location and
branch-label text are primitive serialized fields, not additional Why nodes.

## If and elsif structure

Let `q = 1 + number_of_elsif_parts` for one source if statement, and let
`b = q + 1` conservatively count all branch bodies including the possibly absent
else body. The handler translates every condition and body once
(`src/why/gnat2why-expr.adb:29733–29862`). It constructs the elsif chain in
reverse order without retranslating those children. Runtime reachability does
not remove their allocation charge.

Each of the `q` condition points gets the preceding `7/1/2/23` observation
wrapper and at most one `New_Conditional` node. The conditional's empty
`Elsif_Parts` field allocates one list; its type is empty or builtin unit, so
it contributes at most three occurrences besides its three children
(`src/why/why-gen-expr.adb:4937–4956`;
`src/why/xgen/xtree_sinfo.adb:357–368`). The node's own list remains empty:
the source elsif arms are nested conditionals, not elements in that field.
`Get_Type` maps assignments/assertions/loops to builtin unit and follows
location labels and a sequence's final element (`src/why/why-gen-expr.adb:712–820`).
Ordinary procedure calls and their bindings also return unit; the type charge
is therefore independent of a String assignment's target type.

Each body can receive one previously derived warning wrapper
`9/1/3/27`. Consequently the complete branch skeleton, excluding condition
translations, body-list translations and their children, is bounded by:

```text
nodes       <= 8*q + 9*b
lists       <= 2*q + b
elements    <= 2*q + 3*b
occurrences <= 26*q + 27*b
```

Condition actions on elsif arms pass through `Transform_Expr_With_Actions` and
must be charged separately when present. This formula does not declare their
cost zero. Each supplied condition/body result still occurs once in the
skeleton. Disabled warnings or constant-condition simplifications only reduce
the charge; the formula takes no such credit.

## Source statement lists and locations

`Transform_Statements_And_Declarations` allocates `Void_Sequence` before checking
whether its input is empty (`src/why/gnat2why-expr.adb:30195–30215`). This creates
one sequence, one list and one initial element containing the existing Void
identifier (`src/why/why-gen-progs.adb:366–369`). Void has four occurrences,
including its builtin unit type (`src/why/why-atree-modules.adb:715–717`).
The initialization therefore costs `1/1/1/5`, even if subsequently discarded.

For `m` ordinary source statements whose `Safe_First_Sloc` is positive, the
list worker wraps each translated result in one location label, then appends
it once (`src/why/gnat2why-expr.adb:30068–30088`;
`src/why/why-gen-expr.adb:1956–1987`). The label has one node/occurrence and
prevents the append helper from flattening a statement-sequence child into
multiple entries (`src/why/why-gen-progs.adb:57–85`). Thus the list wrapper,
excluding child translations, is:

```text
(nodes, lists, elements, occurrences) <= (m+1, 1, m+1, m+5)
```

The formula covers the empty input conservatively: the initial sequence is
discarded and the returned Void is smaller. An ignored source statement's core
returns existing Void with no fresh node; the outer source-location wrapper
is still counted. Labels/gotos and Assert_And_Cut are excluded by the grammar.
The latter would introduce additional work in the list worker.

This simple list formula must not be reused for generated actions with absent
source locations or for the distinct `Transform_Declarations` routine. Without
the location wrapper, append can flatten a returned sequence, appending one
element per member. Such callers need the supplied result's top-level sequence
length as an additional transfer parameter. Native source locations, generated
declaration/action counts, fixed-library bodies and whole-process counters
remain part of the surrounding coverage argument.
