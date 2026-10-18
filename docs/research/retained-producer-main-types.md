# Ordinary Main's concrete Why3 type and match frontier

2026-10-18, source analysis for
[#119](https://github.com/berkeleynerd/silver/issues/119). This specializes the
[first-split frontier](retained-producer-firstsplit.md) to the scalar, String,
reference and external-state representations reached by the existing ordinary
Main producer transfer. It closes their type-invariant and havoc case creation;
it does not bound the size of SP/WP construction, match evaluation or complete
Why3 allocation. The four separately translated fixed library bodies require
their own frontier; their implementation types are not admitted by this Main
argument.

Source identities are retained in the
[evidence manifest](../evidence/retained-producer-main-types-20261018/identity.json).
SPARK is `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, Why3 is
`9390baf120ef260547dfa14f08e11c890b203d9c`, and the theory files are from the
retained GNATprove 16.1.0 installation. Silver templates/specifications are
retained as exact input files. No tool is compiled or executed; the checker
only rechecks archive identities and extracted source-module facts.

## Concrete type shapes

The existing [Main scalar/String transfer](retained-producer-composition.md)
and [selected-call analysis](retained-producer-calls.md) supply the semantic
frontier: ordinary initialized Integer/Boolean/String values, one-dimensional
Character arrays, flat mutable objects, and the selected calls' actual public
contracts. No application record, pointer, generic parameter, user subprogram,
relaxed-initialization value or nested mutable component is added here.

| Representation | Source construction | Why3 property |
| --- | --- | --- |
| Builtin `int`, `bool`, `unit`, and function types used by array projection | `ity.ml:581–590,767–796` | Nonfragile; no argument/region flags for int/bool/unit; function argument flags frozen. |
| Signed scalar type, including Integer and derived constrained numeric views | `Declare_Scalar_Type`, `why-gen-scalars.adb:839–867` | A range, alias of the base type, or nullary abstract type; no record payload or mutable nested region. |
| Character representation and abstract image/external-state/heap snapshots | Scalar declaration above; `_gnatprove_standard_th.why:1–10`; `_gnatprove_standard.mlw:21–29`; `silver_image_theory.ads` | Nullary opaque or range types, or aliases of those types. |
| Character array map | `_gnatprove_standard.Array__1:1873–1888`, instantiated by `Get_Array_Theory`/array declaration | Nullary opaque `map`; its element type is not a mutable region carried by the map value. |
| Bounds record `Index_Type.t` | `ada__model.mlw:1231–1254` | Two immutable named fields, each a scalar `base`. |
| Unconstrained String snapshot `Unconstr_Array.__t` | `ada__model.mlw:1588–1635`; `Declare_Unconstrained`, `why-gen-arrays.adb:2652–2801` | Two immutable named fields: opaque `map` and the bounds record. |
| Static constrained String | `Constr_Array.__t`, `ada__model.mlw:2282–2295`; `New_Kind_Base_Type`, `why-inter.adb:1160–1193` | Alias of the same opaque map. |
| Scalar/String/map/global-state reference | `Generate_Ref_Type_And_Havoc_Fun`, `gnat2why-types.adb:1538–1578`; `Emit_Ref_Type_Definition`, `why-gen-decl.adb:234–246`; installed Main/Array__1 records | One named mutable field whose value is one of the pure snapshots above. |

`Declare_Ada_Array` selects an existing clone/alias or the constrained versus
unconstrained module; it does not replace a map with a mutable array container
(`why-gen-arrays.adb:1534–1623`). The String clone substitutes a scalar index
base, `int` representation and the existing Character map. The checked-in
Image adapter's Integer/String templates reproduce these same range,
two-field String and one-field reference shapes; its own theory declares
only opaque `image` and `text` types, substituted by the checked clone.

External objects use `EW_Private_Type`, not an inspectable file descriptor
record (`Translate_External_Object`, `gnat2why-decls.adb:430–452`;
`To_Why_Id(Entity_Name)`, `why-inter.adb:1515–1541`). The public output calls
write a static String, Natural and two Booleans plus `File_System`; the query
calls have `Global => null`. Thus those imported contracts remain inside
this type frontier. No claim about the private implementation of Ada.Text_IO
is necessary for the Main goal's type traversal.

## These types are solid, including their references

For this concrete family the stronger `Typeinv.its_solid` condition holds.
This is a structural result from the type constructors, not an inference
from the absence of an `invariant` keyword:

- Range symbols have `frg=false`, no type arguments and no regions
  (`ity.ml:604–607`). Abstract nullary symbols have the same relevant
  flags. Alias construction freezes all of its argument and region flags
  and sets `frg=false` (`:593–602`).
- A plain record with no invariant is free. With scalar/opaque/pure record
  fields, `ity_fragile` is false for each field; the record constructor's
  `frg` is therefore false (`:691–734`). These records are monomorphic,
  so their argument-flag list is empty. Pure field types contribute no
  top regions, so their region-flag list is also empty.
- This applies equally to the one-field mutable reference. Its **own**
  mutable region belongs to an `Ityreg` instance, not to its symbol's list
  of nested field regions. The field's scalar/String/map snapshot is pure.
  Mutability alone does not make the symbol nonsolid.
- The builtin function symbol is private with frozen type arguments;
  builtin Boolean and unit have no arguments. Thus all-solid closure also
  covers the arrow types in map projection and the unit temporaries.

It follows that `add_gl_cap` and `add_var` stop at their solid-symbol tests,
return `V`, and never construct temporary extraction cases or pins for these
values. `inspect` emits no invariant commitment. The trusted-constructor and
trusted-projection predicates are false for the concrete types, so injection
does not distribute a projection through an if/let. It only traverses and
rebuilds the existing formula structure, with possible simplification. This
closes the type-invariant case-creation branch for ordinary Main; the broader
ranked no-pin result remains useful for other types but is not needed here.

## Flat writes avoid havoc's case fallback

Every pure snapshot is unaffected by region writes. A mutable reference has
one own region and no nested mutable regions. Therefore an affected reference
must have its own region in the write map. It takes the direct-write branch
of `havoc` (`vc.ml:1245–1266`); recursively examined field values are pure
and stop at the initial unaffected test. No ordinary Main value reaches the
constructor-rebuilding fallback that emits a case (`:1289–1306`). This
argument includes each selected call's flat public output objects and opaque
external-state reference.

## Definition and typing boundary for case creation

The JSON converter creates no ordinary expression/term match. Its only
`E.mk_match` is an exception block with no ordinary branches and at most one
payload variable. The corresponding `vc.ml` branch makes no `Kcase`, as
recorded in the first-split analysis. There are two additional typing paths
to check rather than assuming the parsed shape survives unchanged:

1. Regular generated postconditions use one result-variable pattern
   (`ptree_constructors.ml:256–258`). Exception postconditions use either
   one variable or the empty tuple pattern. `typing.ml:733–760` types
   result variables directly and reduces the empty tuple to a wildcard;
   none goes through its general post-pattern case constructor.
2. Term record construction is a constructor application. A record update
   is a constructor application with named projections for unchanged
   fields, plus a let when the source expression needs sharing
   (`typing.ml:472–493`). The source parser does not manufacture a
   term case for these field operations. Generated record-projection
   wrappers have the exact body `field(a)`
   (`why-gen-decl.adb:156–228`), not a pattern-extraction body.

Why3 also creates callable lemma declarations from axioms. Multiple
existential result variables can introduce tuple/case terms into those
declarations (`typing.ml:1567–1580`, `expr.ml:781–828`). They are not called
by ordinary Main and are not inlined by the Main program's call translation.
They **must** still be included in context/typing allocation counts. Therefore
the claim here concerns the types and terms reached by Main VC construction,
not a claim that every declaration in its imported task is case-free.

For `Eval_match.find_inlineable`, the concrete destructible input types are
unit and the one-field references. The two-field String/bounds records are
not destructible, and Boolean has two constructors. This excludes the
imported `bool.Bool` match bodies from this inlining path even though they
are genuinely present in the imported module. Integer/Character ranges,
opaque maps/images and function types have no data constructor to destruct.

The reachable reference-wrapper definitions are the unary named-field
applications just identified. Standard Main's handwritten projection
wrappers have the same form. Their inlining introduces no case. Generated
logic definitions use the converter's case-free terms; regular imported
integer operations have nondestructible scalar arguments. Array `first`,
`last`, `to_array` and index field helper definitions have two-field record
arguments, so this pass does not inline their bodies via `find_inlineable`.
Constants and unit-argument literal/guard functions either have no logical
definition or use generated case-free terms.

The dedicated projection path can follow a let or conditional to its
constructor. If its input and saved definitions are case-free it introduces
only let/conditional/field-selection structure. Quantifier destruction
introduces constructor terms and lets; constructor equality can introduce
conjunctions. Neither introduces a case without an input case or an eligible
case-bodied definition (`eval_match.ml:87–211`). Their occurrence and
temporary costs remain to be charged. `simp_cast_projections` replaces only
a range projection of a constant by that constant (`vc.ml:1649–1657`).

Under the existing ordinary Main producer frontier, these source branches
therefore preserve a case-free goal through type-invariant injection, havoc
and match preprocessing. The
[conditional first-split transfer](retained-producer-firstsplit.md) is usable
for this family once its incoming `n` and `E1` are bounded from source. It
does not yet yield a numerical admission rule: source-to-typed-expression
growth, SP/WP size, match preprocessing size, imported declaration storage
and the four fixed library-body processes remain distinct obligations.

The [subsequent matcher envelope](retained-producer-matchsize.md) supplies a
lexical/product size transfer for this concrete frontier. It leaves its
source-to-SP/WP and marked-definition joins explicit.
