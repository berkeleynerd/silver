# Main source callers and enclosing clauses

2026-10-23, source-indexed continuation of #178 under #119. Imports the immutable
fixed-contract author `3040c6736d3a004239256b2ba50f25144e68bec8` and construction
interface `767007bf43ad1a7ef82b8d629ab460b6186f694e`, accepted by independent
review `0b29dd9b215566e103e3e856a004abd9cca04a86`. This continuation's exact
freeze requires its own independent review. No compiler,
prover, target or Lean execution is authorized or required for this derivation.

The [Main String shape invariant](retained-producer-capacity.md#main-string-shape-invariant)
remains an explicit premise: every reached Main String type is either static
constrained (possibly null) or unconstrained Standard.String. In particular,
`static=False` in the imported constructor row means unconstrained, not an
arbitrary nonstatic constrained subtype. The frontend light-expansion argument
covers nonstatic initializers and excludes additional Actual_Subtype setters
for ordinary named String objects. Lookup and split reconstruction do not
manufacture new Ada constraints. A general nonstatic constrained type would
need its own length/sliding row; the current interface does not silently apply
the unconstrained dynamic-property check to it.

## Concatenation and scalar/String expression callers

`Transform_Concatenation` (`gnat2why-expr.adb:21976–22351`) retains the following
source decisions for two ordinary String operands, no component or relaxed-init
paths and unconstrained Standard.String as the ultimate result ancestor:

- Obtain separate stateful temporaries for left and right. Consume the left
  binding first, then the right; the right binding is therefore outermost.
- If the left type has static length zero, return the right temporary in its
  existing representation. A static right operand can therefore remain a map.
  The enclosing expected-type conversion is still a required caller operation.
- Otherwise pack each operand as map/first/last and call the seven-argument
  array concat. Its seventh argument is **the result index type's last bound**
  plus the right length (`Build_Last_No_Slide:22063–22098`), as the source
  implementation states; do not replace this by the left operand's last bound
  merely from the helper comment.
- Reconstruct the String with the left first bound and
  `first + (left_length + right_length) - 1`. Program-domain construction calls
  the Positive range check on that last expression. Integer representation
  conversions after this check are identities under the shape premise.
- For a nonstatic left operand, keep an explicit conditional on `left'Length=0`.
  Its then arm reconstructs the right map/first/last; its else arm is the concat
  result above. Both arms occur once. Complex source operands remain bound once;
  cheap operand references repeat at all source-generated uses.

`Build_Length_Expr` (`why-gen-arrays.adb:537–580`) selects the two-argument
`_gnatprove_standard.Integer.length`; it is distinct from the unary
Unconstr_Array String length accessor. Both program declarations have explicit
result-first equality contracts. The logical length definitions do not inline
into the program call postcondition.

`Transform_Array_Comparison` and `Transform_Array_Equality`
(`gnat2why-expr.adb:18547–18735`) pack the same six map/bound arguments behind
operand temporaries. Ordering calls the array comparison function, then a
scalar comparison with zero outside those bindings. Equality uses the generated
array Bool_Eq. Ordinary String `/=` is first expanded to `not (=)` by the
frontend (`exp_spark.adb:1008–1023`; `exp_ch4.adb:10217–10256`, retained in the
accepted Main-semantics provider). The source fold performs that same
normalization: program/predicate mode uses New_Not; only Term uses Boolean
notb (`gnat2why-expr.adb:24547–24565`). Program New_Not therefore becomes a
typed if with False/True constructor applications and a condition proxy. The
direct helper's `/=` notb branch is explicitly marked unreached at `:18723`;
it remains in the generic caller helper, outside the ordinary source route.
The generated array equality has
a Pterm definition with binders (`why-gen-arrays.adb:2131–2192`). The converter
at `:1067–1090` emits a separate logical definition and a RKnone program val
with explicit result equality. Its call post is that logical-symbol equality;
the quantified element comparisons stay in the separate logical definition.
Array compare is `val function` at
`ada__model.mlw:1326`. `Transform_Compare_Op:5446–5541` selects Integer.bool_*
**only in Term**. Program/predicate comparisons select the Int relations or
equality. Program inequality is elaborated to `not (x = y)`
(`typing.ml:1008–1012`); the Int relational program contracts have the accepted
predicate-result equivalence. The ordinary source String grammar reaches only
equality and inequality; the generic ordering row is retained separately.

Initialization checks eagerly call `New_Temp_For_Expr` before returning an
ordinary initialized operand unchanged (`why-gen-init.adb:502–552`). An unused
allocated temporary remains in native pending-map state but is not a body binder.
The comparison constructor must distinguish these entries from its useful
operand temporaries. This affects construction bookkeeping without duplicating
the original operand body.

Integer Image keeps two applications: the scalar image function and
String.to_string(image, maximum_image_size)
(`gnat2why-expr.adb:20256–20300`). The maximum size is the type-derived input,
not a source admission ceiling. The image function is val function
(`ada__model.mlw:46`); to_string is a Pterm declaration with no explicit spec
(`why-gen-arrays.adb:1657–1667`), so both retain generic logical-symbol equality
posts. Its surrounding expected-type String conversion remains separate.

Arithmetic overflow and expected-type scalar range conversion are independent
source decisions. `Transform_Expr:25521–25632` first applies the selected base
overflow check (`Insert_Overflow_Check:12039–12056`); `:25654–25665` then invokes
Insert_Checked_Conversion independently. Its scalar branch selects Do_Check
and calls Insert_Scalar_Conversion (`why-gen-expr.adb:1518–1648`). Thus narrowed
initialization/assignment can have `target_range(base_overflow(operator(...)))`.
The source interface retains distinct `overflow_symbol` and
`expected_range_symbol` indices, both complete actual/contract occurrences,
and the original operator child once. Either check can be absent according to
its actual guard. When both checks resolve to the same range symbol, they
remain two occurrences with separate actual definitions and contracts.
Term replay retains the arithmetic without runtime checks.

The [caller algebra](../evidence/retained-main-callers-profile-20261023/callers.py)
transcribes these rows and imports the immutable constructor algebra.
The new focused packet checks the complete caller/body diagrams, source
identities and scoped contract/key join. It does not replay either accepted
predecessor checker or use a captured compiler run as a universal argument.

## Repair of the enclosing Main root grouping

The older capacity record groups four concrete Silver_IO outputs and File_System
as five source effect roots. The accepted typed fixed tranche establishes eleven
external program-variable keys: four concrete outputs plus seven expanded opaque
states. The grouping must not be reused as a five-key U0 bound.

The older **numeric** wrapper allowance nevertheless remains sufficient:

1. `a-textio.ads:608–609` puts the private part in SPARK_Mode Off. All six
   Part_Of objects at `:758–771` are ordinary private variables without visible
   partial views. `Expand_Abstract_State` converts those non-SPARK variables to
   Magic_String (`flow_generated_globals-phase_2.adb:4836–4866`); its residual
   File_System state is explicitly Magic_String (`:4817,4830`).
2. `Process_Referenced_Entities.Process_All`
   (`spark_util-subprograms.adb:1900–1915`) ignores Magic_String in the input
   dynamic-invariant traversal. `Compute_Dynamic_Property_For_Effects`
   (`gnat2why-subprograms.adb:1495–1536`) processes only Direct_Mapping outputs.
   `Process_Type_Invariants_For_Subprogram`
   (`gnat2why-expr.adb:14718–14761`) likewise skips Magic_String.
3. Therefore each opaque key incurs only the prior eager binder/localization
   and read/write-reference allowance `(11,0,2,12)`. There are no hidden dynamic
   or type-invariant trees for those seven keys. Their combined
   `(77,0,14,84)` is componentwise below one old full-root allowance
   `(136,62,95,156)`.

Thus the actual grouped wrapper bound is at most

```text
(61,31,47,259) + 4*(136,62,95,156) + 7*(11,0,2,12) + (5,0,0,0)
= (687,279,441,967) <= (746,341,522,1039).
```

The fixed older provider stays byte-for-byte intact; this is an explicit
source-supported repair of its grouping explanation. The seven opaque keys
remain present in typed effects and the initial program-variable union.

## Source-indexed fold and coverage

The [source fold](../evidence/retained-main-callers-profile-20261023/source.py)
is a dependent construction interface, not another Silver parser. Its input
is an admitted source syntax tree together with the actual frontend decisions
already covered by the accepted frontend/producer providers: entity/type
identities, static folding, binary concat grouping, expected-type/range/sliding
guards, bound-capture relocation and ordered whole-root write statuses.
These indices select **fixed source branches**; they are not supplied typed
trees, unexplained size certificates or arbitrary tree covers. A parameter
case is valid only when those indices agree with the retained source guards.
The fold rejects unknown constructors, unresolved/unsaturated symbols,
incoherent equal type identities and nonstatic constrained Strings.

The construction induction is on the following complete ordinary Main forms:

| Source or frontend-generated form | Structural result and child multiplicity |
| --- | --- |
| Integer literal/static fold | One integer leaf. A folded subtree is replaced by its actual frontend leaf. |
| Integer/String object or loop index | Immutable object: nullary program symbol; mutable regular object: named field read; mutable UCArray: map field read plus full converted bound trees and `of_array`. No initializer replay at a name use. |
| Static String literal | Unit-argument map function. Its literal-defining axiom remains in the separate entity context. Static lower-bound/last-index checks disappear by the literal source guards. |
| Unary/binary Integer arithmetic | Its exact one/two source children, selected operator, optional base overflow call, then independently selected expected-type scalar range call. Unary plus may retain only its child before these wrappers. |
| Image, concat, Length, comparisons | The caller rows above, including eager prefix reads, actual symbol resolution, two domain conversions and every repeated cheap operand occurrence. |
| `not`, `and then`, `or else` | Each source child once. Program short-circuit right child may have one warning wrapper; typed lowering adds the exact Boolean constructor branch(es). |
| Selected queries/procedures | Saturated fixed API call and separately evaluated actual. Zero-Ada-argument APIs have one Unit actual. Program API contracts import the complete immutable templates, not just their affine totals. |
| Ordinary object declaration | Initializer once, expected-type conversion, assignment/binding row below and one dynamic-invariant suffix. Immutable entity translation separately retains at most one complete term initializer. |
| Whole-object assignment | RHS once, with expected-type conversion; String runtime-length test, target capture, binder conversion, map projection and final assignment remain explicit. |
| Null/ignored entry and statement sequence | A located unit is retained where the converter cannot drop a bare unit; each nonempty source core is retained once in source order. Every retained sequence lowers to its own anonymous Unit LDvar. |
| If/elsif/else | Each condition and arm once; each condition writes/reads `spark__branch`. The absent else is unit. Enabled branch warnings ignore only their false assertion/check. |
| Range loop | Each body once; two program endpoint translations and two term endpoint translations, fixed controls, implicit frame/index assumption, snapshots, index update and both generated handlers. No trip-count factor. |
| Generated bound capture | At most two per source loop. Each relocates its **whole** original scalar endpoint into one immutable declaration; the two endpoint translations then use the generated name. |
| Generated subtype / Itype / frontend ignored entries | Static declaration checks return Void. The accepted reference-site analysis excludes the Itype associated-expression replay. Remaining ignored entries have only located-unit shape. |
| Main | The enclosing row below, one Unit formal and one Return handler. |

Source locations/labels do not add typed expression constructors, but can
prevent sequence simplification. In particular, a null statement must not be
discarded merely because its native core was Void. The new fold preserves its
located unit. Additional ignored frontend list entries have the same closed
unit row; their source-derived count is bounded by `A_Main` in the accepted
Main semantic-node provider. They have no caller-selected arbitrary children.
The accepted source replay bound remains `2*(X+U+3P)+2G`, `G<=2F`; it is not
used as a replacement for this occurrence/scope construction. Entity-context
term initializers are recorded with their complete terms and guarded-query
epsilon construction (`why-gen-expr:5017–5178`); they are distinct from Main's
executable initializers and from fixed call contracts.

For immutable initialization, the producer forces a temporary and assumes
`temporary = object` (`gnat2why-expr:1795–1817`). For mutable regular objects it
assigns the value. For mutable UCArray objects it binds the whole initializer
once, assigns `to_array(temporary)`, and assumes both full converted binder
bounds equal `first/last(temporary)` (`:1621–1668`). The suffix reads the
initialized object: non-itype types call their named five-argument dynamic
invariant; an ordinary static String itype retains its well-formed predicate;
the expanded static scalar path retains the full bound/value property. The
discarded Character/user-type-invariant traversal creates no retained term.
These are source-selected policies, not freely interchangeable predicates.

## Loop and Main implicit clauses

The loop profile derives its root set from descendant whole-object assignments
and the four concrete output globals of Put/Put_Line. Read-only actuals are not
inserted; Reject adds only opaque Magic_String states; nested indexes are
Discard. Every non-discarded ordinary root is Entire_Object. The CFG gives
every admitted statement/arm/nested for a normal path back to Loop_Cond;
`Always_Terminates=>False` does not suppress a procedure's normal edge (that
test is No_Return). No admitted form is an error-signalling statement.
`One_Level_Update` never demotes Entire_Object. The `Not_Written` helper row
is therefore retained as a generic checked alternative, but is not needed by
the ordinary source fold. The fold rejects a missing, extra or non-entire root;
an explicitly supplied root order preserves the producer's iteration order.
The complete source spans are `spark_util.adb:3662–3711,5244–5649` and
`gnat2why-expr-loops-inv.adb:1639–1683,2053–2115,2293–2346`; independent
source review is frozen at `620d990da30f4f12f638db7ae2b547b48f351756`.
Each root retains its
current read, selected invariant/preservation term and its eagerly requested
entry snapshot. A True preservation result does **not** remove the snapshot
request. `Only_Var=True` is used for the frame's dynamic invariant. Empty user
invariant/variant lists stay empty, and no ordinary loop body is copied into
`code_before`.

One mode seam matters quantitatively. The producer combines frame and index
invariants with `New_And_Expr(..., Domain=>Prog)` before putting that expression
in a logical Assume (`gnat2why-expr-loops:1774–1781,Wrap_Loop`). If neither
operand is syntactic True, this is Bool.andb. Logical conversion coerces each
proposition operand to Boolean (+3 each) and its result to a proposition (+2).
Thus the raw envelope is `9+E0(frame)+E0(index)`, rather than a one-node logical
conjunction. The entry condition is a separate **program** Andb with program
comparison contracts. The source-selected True elisions are retained.

Main's native declared effects begin empty (`gnat2why-subprograms:5583`), but
lambda/c_fun infer the actual body's effects; empty declared effects do not
erase reads or writes. The final declaration has one Unit formal, singleton
True precondition and no explicit normal post (`:6253–6263,5316–5355`). The
regular body adds its Return raise and singleton handler (`:5853–5872,5413–5419`).
No source/formal/out-param, inline, refined-post, exceptional or ProgramExit
branch adds another body family. Empty pre/post RTE ignores simplify to unit;
the envelope harmlessly retains their unit/comment padding.

At most two input invariants survive: Written_Bytes and Written_Count, selected
by the actual source effect family. Each is
`dynamic_invariant(__content(key), True, False, True, True)` and has lexical
`E0=6+w(key)`. Local objects are skipped and roots deduplicated
(`gnat2why-expr:2362–2461`); Boolean globals retain no predicate, and the seven
opaque keys are excluded as established above. RefinedPost is absent, so the
Main row has no invented output dynamic-property suffix.

## Complete typed interface and scope

The [typed derivation](../evidence/retained-main-callers-profile-20261023/typed.py)
keeps a tree of resolved body constructors, attached terms, per-call formal
contracts, actual/proxy correspondence, effects and lexical binder identities.
Every repeated occurrence of a native binding receives its own scoped identity.
Every application retains all child occurrences, and each actual has its own
optional proxy slot. A trivially reusable variable can elide that proxy;
retaining the alias adds only a nonnegative definition charge. This does not
share repeated dereference occurrences across distinct actual slots.
The application order is the retained right-to-left proxy order; assignment
evaluates the value before the reference (`dexpr:1405–1436`, `expr:902–932`).

For each saturated call, `cty_apply` substitutes program variables for formals;
it does not substitute argument expression trees (`ity:1436–1489`). The profile
therefore records a full actual definition and a separate renamed contract.
Opened post result binders and quantifier/epsilon binders remain logical
variables; they are not silently counted as program-variable keys. Let-bound
terms preserve their definition weight at their own site and every later use.
The five immutable API coefficient/extraction profiles are imported unchanged.
Predicate primitives retain their result=True equivalence; static range checks
retain their precondition and unsimplified residual. Every Eexec occurrence
retains its own `h,o,p,v`; all current call `h=o=0`, but API `p=1` and procedure
`v<=1`. Reference constructor resets are separate from snapshot projections.

The installed concrete type frontier remains all-solid and flat. It introduces
no additional type-invariant case/pin family. There is no ordinary match/Kcase,
recursive local definition, user function or partial program application.
Boolean operators lower to typed ifs with nullary Boolean rsymbol applications;
Unit and Boolean values are Eexec constructors, not free Econst leaves.

## Ignored-child, exception and local-function closure

`New_Ignore` is **not** an exception suppressor. It creates a discarded binding
inside a nullary Abstract_expr with post True (`why-gen-progs:199–215`); the
converter adds its own discarded let and Unit result (`:889–905`). Its body
effects flow through lambda/c_fun. The ordinary caller inventory consists of:

- enabled dead-code/branch warnings, whose ignored child is only assert/check
  False (`gnat2why-expr:31187–31204,31245–31260`);
- the empty Main pre/post RTE expressions, simplified to unit;
- the general scalar-range helper's optional ignored endpoint evaluations,
  each a raise-free scalar value; current ordinary static endpoint/type guards
  remove them where that helper could be selected.

The packet retains and checks the last helper's broader closed row as well:
`low<=high -> base_first<=low and high<=base_last`, a Unit Cany with True post,
and optional ignored endpoint values. Each full logical endpoint occurs twice;
the supplied program endpoint occurs once in its ignore. This is not a new
language admission. Static safe/empty ranges return Void. Itype-associated
expression replay, nonstatic literal checks, fixed-lower-bound unconstrained
sliding, user assertions, source handlers, overlays, default initialization,
aggregates, pointers, dispatch/variant checks and function-body pragmas are
excluded by the cited ordinary source/frontend premises. The separate ignored
literal Assert fallback is also raise-free if considered conservatively.

Consequently every retained ignored Cfun body has an empty escaping exception
set. Primitive and selected API contracts also have no exceptional effects.
Only the generated Exit and Return raises occur in executable Main; their
own enclosing singleton handlers catch them. Continue handlers remain present
even when unused. `complete_xpost` therefore completes no exceptional entry
for Main or its internal Cfun; the white-box lost set is empty as well.

Any_expr and Abstract_expr have empty binder lists. Binding_ref, ordinary let,
sequence, anonymous discard and Any's local `_f` all bind zero-program-arity
values (`converter:600–611,731–784,889–905`; `dexpr:1528,1572,1719–1730`).
They take LDvar, not LDsym. A function-valued **data type** such as a map is not
a nonempty program parameter list. No source local functions or partial
applications reach the DA-triggered local-symbol proxy path. Thus the local
RLlemma and RLpv enrichment creation families are absent; internal Cfun checks
themselves remain counted.
In particular, `typing.ml:1126–1130` casts a sequence's first child to Unit and
lowers it to `DElet ("_", RKnone, e1, e2)`. The zero-arity branch and var_defn
then call `let_var` (`dexpr.ml:1572–1575,1719–1730`; `expr.ml:721–724`), which
allocates a fresh pvsymbol. The profile retains the sequence notation with an
explicit occurrence-scoped anonymous Unit key and LDvar definition/context
link. This key supplies the first child's result in kode even though it never
appears as a source name in the second child. The rule also covers converter
loop sequences, branch-observation sequences and Main wrapper sequences.
The independent full-source wrapper inventory is frozen at
`fef5579f8da8269d6b6da37dd84d1f0973f4d428`; this inventory review is distinct
from the pending audit of this continuation's Python/diagram freeze.

## Source-derived U/H and kode join

All counters here are folds over the source-constructed typed interface,
including internal Cfun bodies, not unexplained observed compiler totals.
Let `B` count all program binding occurrences, including one anonymous Unit
LDvar per retained sequence; `A` actual-argument slots;
`J` assignments; `R` the resolved free program-variable root union; `S` the
distinct referenced saturated signatures; and `Fields` the named mutable-field
identities retained by projection/constructor/assignment/effect metadata.
The profile explicitly constructs each set/occurrence and its binding context.
It supplies the conservative initial union

```text
U0 <= 1 + |R| + B + A + 2J + sum(arity(s), s in S) + |Fields|.
```

The first key is Main's Unit formal. `R` includes source mutable objects,
loop indexes, selected eleven-key external family and `spark__branch` when
used. Native temps/snapshots and anonymous sequence variables belong to `B`;
`program_binding_slots` records the sum of explicit `binding` and `sequence`
occurrences, and `sequence_binding_slots` records the latter subset.
Typing argument and assignment
proxies belong to `A+2J`. Original signature formals are retained conservatively
even when the applied cty has substituted them away. Named field pvsymbols
are included, allowing per-root effect-field tokens to overcount sharing.
All free attached-term keys are resolved into this same scoped union.
Saturation leaves no residual formal-clone family; every old-value map is empty.
Quantifier/epsilon/term-let logical keys are not added to this union.

Let `F` count source loops, `I` typed if occurrences after Boolean lowering,
`P` ordinary application occurrences, `C` retained nullary Cfun occurrences
and `Y` Unit Cany occurrences. The precise per-occurrence interface supports
the accepted kode transfer; a convenient source-derived fresh-key envelope is

```text
nv <= I                    nf <= 1+C
tr <= P+C+Y                nh = unit_h = 1+2F
xf = lost = lemma = rlpv = 0

U <= U0 + I + P + 2C + Y + 2F + 2
Delta = 1+2F
Cfinal <= C0 + 1+2F
H <= H0 + 2F + 2.
```

`P` conservatively includes the while True constructor even though k_expr skips
that test. Handler increments survive empty escaping frontiers: `vc:857–872`
allocates a fresh outcome and Unit placeholder for **each** handler before
traversing the body. There is one process-level incoming counter `C0`; nested
functions do not reset it. `H0` is an incoming outcome-key cardinality, not a
counter value. The profile's concrete union can be sharper than the displayed
sum, but both derive from the same complete structural inputs.

For kode, each application gets the accepted local Eexec row and the separate
actual definitions; each Cfun gets its separate k_fun traversal. The checker
adds an optional tag allowance per typed expression and per k_fun, and Main's
four-node pre/post wrapper. It then applies the accepted `B_reflow<=3B+2`.
Attached terms, extraction definitions/residuals and outcome vectors remain
available to the lexical SP/WP transfer; the kode scalar total does not replace
them. This closes the ordinary Main source/typed-input seam **subject to this
freeze's independent review**. It does not assert the remaining whole-tool
capacity comparison or fixed-library-body obligations. Physical-resource
premises and the single global `e<=2` premise are unchanged; no source-policy
ceiling has been substituted for a symbolic source parameter.
