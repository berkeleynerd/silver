# Retained producer: ordinary object and loop theories

Source-derived component for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-17, Linux x86_64. This supplies object setup costs to the
[producer aggregate](retained-producer-capacity.md), using inspected SPARK
revision `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. Its exact identity as the
installed GNATprove archive's source remains the existing separate premise.
No new admission rule, compiler, proof or tool configuration is established.

The domain is ordinary Main Integer and rank-one Character String objects and
loop entities. There are no overlays, partial/full views, access/record types,
relaxed initialization, potentially invalid values, borrowing or move trees.
The [light-expansion String invariant](retained-frontend-entities.md#string-types-under-light-expansion)
allows static constrained or unconstrained String types. Fixed dependency
objects and subprograms need their own accounting.

Costs are `(fresh nodes, fresh lists, appended list elements, emitted node
occurrences)`. Theories here exclude `Close_Theory` imports, charged by the
existing aggregate. Memoized `E_Module` creation, symbols and name bytes are
separate. A direct module created by the type helper is included in its node
count and contributes to the aggregate's module count. An initializer's
translation and expected-type conversion are separate child costs.

## Binder setup

`Mk_Item_Of_Entity` returns an Ada `Item_Type` containing `Binder_Type` data;
it does not allocate a Why `W_Binder` for that record. Its ordinary regular
branch calls `Type_Of_Node` and `To_Why_Id`, at most three and two fresh nodes
respectively (`src/why/why-gen-binders.adb:1079–1121`). Neither creates a Why
list. Optional flag constructors are absent under this domain.

For a mutable nonstatic String, the UCArray branch instead creates:

| Component | Fresh nodes |
| --- | ---: |
| `EW_Split`: map type, name, direct module | 3 |
| Object identifier and name | 2 |
| Abstract Integer index type and name | 2 |
| First and last identifiers and names | 4 |
| **One setup call** | **11** |

This follows `why-gen-binders.adb:897–948`, `why-inter.adb:836–890,1158–1224`,
and `why-gen-names.adb:95–128,714–806`. `EW_Abstract` on the Integer index
uses a memoized entity module, so its module miss belongs to the separate
`E_Module` budget. Static String map setup can create one direct module too.
Thus every ordinary setup call costs at most `(11,0,0,0)` and at most one
direct module; the regular branch is bounded by `(5,0,0,0)`. Its eventual
references are charged where emitted, not at registration.

`Register_Symbol` calls this helper for an object during the entity pass
(`gnat2why-driver.adb:1381–1424`). `Translate_Variable` calls it **again**
(`gnat2why-decls.adb:496–500`). Do not count only the first registration.
Loop translation and local-expression forms have their own setup calls; the
global-pass bound does not subsume them. Whether an object is mutable in Why
is the producer's classification, not simply whether the source says
`constant`.

For the emitted ordinary shapes, a type has at most three occurrences
(type/name/module), a qualified identifier at most six, and its local form
at most five. `To_Local` returning an identifier allocates both an identifier
and a name (`why-gen-names.adb:1136–1169`).

## Definition and axiom theories

`Open_Theory` creates one theory node and two empty lists. A declaration
emission appends one element (`why-inter.adb:1268–1284`,
`why-gen-decl.adb:74–88`). The direct
`Why.Atree.Builders.New_Function_Decl` used by object translation creates an
empty binder list, but **no** Effects, Pre or Post node. These optional fields
default to `Why_Empty`; this is not the higher-level binder helper whose
default constructs effects (`xgen/xtree_tables.adb:110–143,535–548`,
`xgen/xtree_sinfo.adb:579–611`).

| Ordinary theory | Nodes | Lists | Elements | Occurrences |
| --- | ---: | ---: | ---: | ---: |
| Constant definition, using registered binder | 4 | 3 | 1 | 10 |
| Regular mutable definition, including its extra setup call | 9 | 2 | 1 | 10 |
| Split rank-one mutable String definition, including its extra setup call | 21 | 4 | 3 | 28 |
| Constant value axiom overhead, initializer separately charged | 7 | 6 | 5 | 23 |
| Empty axiom theory | 1 | 2 | 0 | 1 |

The constant definition uses one fresh local identifier/name and one direct
function declaration. Its occurrences are `1 + (1 + 5 + 3) = 10`, including
theory and function return type. The mutable definition uses a global ref for
the value; a split String adds two bound constants. Each declaration has at
most nine occurrences, hence `1 + 3*9 = 28`. The bound constant declarations
each allocate an empty binder list. Source:
`gnat2why-decls.adb:66–113,496–588,696–743,770–812`.

The ordinary constant value path translates its initializer to a term once,
with the registered expected type (`gnat2why-decls.adb:207–283`). It may then
omit the axiom if that term contains a dereference; the term's allocations
still happened. An upper bound may charge the axiom regardless.
`New_Defining_Axiom` with empty binders constructs a left call, equality,
trigger, triggers node, dependency and axiom (`why-gen-binders.adb:1151–1182`).
The left call's arguments allocate an empty list. Equality adds one list and
two elements; the trigger pair adds two lists and two elements. Opening the
theory and emitting the axiom give totals of seven nodes, six lists and five
elements. `New_Universal_Quantif` returns the predicate unchanged for empty
binders, discarding the already allocated trigger pair
(`why-gen-binders.adb:1346–1368,1392–1415`). Its serialization therefore has
at most `1 + 1 + 7 + 7 + 7 = 23` occurrences beyond the supplied term:
theory, axiom, equality overhead, left call and dependency. The initializer
occurs once, including its expected-type conversion. Empty theories contain
only the theory node before imports.

For one ordinary entity visit, the driver emits two theories: definition
plus value axiom for an immutable constant, or definition plus empty axiom
for mutable objects and other immutable objects
(`gnat2why-driver.adb:1520–1571`). Thus, with `r` regular registrations,
`u` split registrations, `c` ordinary constant visits, `v` regular mutable
visits and `w` split mutable visits, these rows compose as

```text
registration = r*(5,0,0,0) + u*(11,0,0,0)
object theories <= c*(11,9,6,33) + v*(10,4,1,11) + w*(22,6,3,29)
object theory closes <= 2*(c+v+w)
```

Charge each constant's term initializer separately, in addition to executable
initialization. An immutable nonconstant visit is smaller than the constant
row. Additional setup calls, generated object visits, dependency objects and
source-to-visit multiplicities remain the caller's obligation. The rows do not
assert that each lexical declaration invokes each helper exactly once across
the entire producer.

## Loop exception setup and auxiliary storage

`Translate_Loop_Entity` emits both exit and continue exceptions even when
source jumps are excluded (`gnat2why-decls.adb:451–490`). Each local exception
name allocates one name, no identifier/module, and the exception declaration
adds one node (`why-inter.adb:1129–1143`,
`xgen/xtree_sinfo.adb:652–659`). Its theory is `(5,2,2,5)` before imports.
The driver also emits an empty axiom theory, so the pair is `(6,4,2,6)` and
two closes per loop entity visit. Names use `Short_Name(E)` plus
`__loop_exit` or `__loop_continue`; the symbol-byte budget must include these
suffixes. These rows cover theory setup, not executable loop translation.

`Close_Theory` also appends one entry to `Why_Sections` and inserts one
symbol-to-theory map entry (`why-inter.adb:742–752`). These are auxiliary Ada
containers, not Why list-table elements. Charge at most one entry in each
per close; their capacity arithmetic remains part of auxiliary accounting.

The [evidence](../evidence/retained-producer-objects-20261017/README.md)
checks pinned source/archive equality and the local schema/count arithmetic.
It is not a compiler execution, universal caller-coverage proof or complete
capacity predicate.
