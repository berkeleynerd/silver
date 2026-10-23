# Ordinary Main typed-body and contract profile

2026-10-23, research for [#178](https://github.com/berkeleynerd/silver/issues/178)
under [#119](https://github.com/berkeleynerd/silver/issues/119). **Working
checkpoint: the five selected API contract profiles below are concrete; the
general source-body construction is not yet closed.** This record does not
change admission, production configuration, the Oracle, the ordinary physical
resource premise or the single global `e <= 2` requirement.

The input is recognized authoritative source and its semantic summaries, fixed
dependencies and the selected tool/options. Source size, expression counts,
literal lengths and nesting stay symbolic. None of the old 4096-byte, 63-operator
or 64-leaf policy limits is an analysis ceiling. Fixed dependency constants
such as the API's `Max_Length` retain their meaning in those dependency bytes.

## Reusable inputs and the missing interface

The [ordinary producer](retained-producer-capacity.md) and
[composition](retained-producer-composition.md) bound native Why occurrences
from source, including both source branch arms, generated loop-bound captures,
the enclosing wrapper and fixed imported declarations. Their scalar occurrence
total is not itself a binder-aware typed expression or contract profile.

The [typing](retained-producer-typing.md),
[kode](retained-producer-kode.md) and [SP/WP](retained-producer-spwp.md)
transfers accept a structural input. A source-body profile must preserve:

- Every expression child and generated internal function body; source absence
  of subprogram declarations does not exclude `Abstract_expr`'s zero-argument
  `Cfun`.
- Each attached precondition, postcondition, assertion, invariant and saved
  definition, with alpha-fresh binder identity and actual types.
- Local exception/effect sets and old-value maps, rather than a statement that
  the public Ada specification has no exceptional contract.
- Every variable-use multiplicity. A proxy evaluates an actual expression
  once, but lexical SP/WP accounting charges its definition again at each use.

The fixed imported-node provider `K_fixed=(15349,3310,4729,22621)` remains valid
under its reviewed isolated-root source/control transfer. This work neither
replays that provider nor installs its entire occurrence count at each call.
Its raw-memory child graphs omit scalar names, so they cannot alone recover
binding identities. A complete existing native input is retained instead in
the [new packet](../evidence/retained-main-typed-profile-20261023/identity.json).

## Five selected API contracts

The existing Linux artifact `program-Q0NIav/obj/gnatprove/main.gnat-json`
contains all five program declarations. Its six copied Silver library files
hash-match the current repository sources, including the bodies and runtime
specification. The packet retains those bytes, its author source and project
file, and the complete native JSON. It was read without launching a compiler,
prover or target. It supplies an inspectable fixed template, not a membership
oracle or, by itself, a universal source bound.

The source/control justification is `Generate_Subprogram_Program_Fun` in the
pinned SPARK `gnat2why-subprograms.adb:7614–8447`, combined with the existing
[selected-call frontier](retained-producer-calls.md). The generator installs
local formal bindings before translating the fixed specification, computes
the effects, and translates its explicit postcondition. For queries it also
adds the result dynamic invariant, result-to-logic-function equality and
optional function guard (`:7770–7922`). For procedures it adds the dynamic
properties of the outputs (`:8122–8150`). No Main expression is substituted
into these declarations. Main identifier serials and declaration order may
alpha-rename these fixed templates; they do not change the definition bodies
or formal-use coefficients. Source-dependent actual expressions enter through
the later variable/proxy instantiation transfer.

In particular, the public Post alone is insufficient. The First_Or_Default
formal occurs in its logic equality and guard even though the explicit Post
does not mention Default. The output contracts contain a saved slice value,
multiple uses of that saved value and implicit output dynamic properties.

The [binder-aware projection](../evidence/retained-main-typed-profile-20261023/profile.py)
retains their trees and types in
[selected-contracts.json](../evidence/retained-main-typed-profile-20261023/selected-contracts.json).
Let `r`, `a`, `b`, `c`, `f`, and `s` respectively denote the positive lexical
weights of result, argument, Written_Bytes, Written_Count, Flushed and
Succeeded. Counts include let definitions at their own sites and again at
each use. The opened postcondition profiles are:

| Selected program declaration | Opened lexical profile | Unit-weight cost |
| --- | --- | ---: |
| Input_Is_Valid | `3+r` | 4 |
| First_Or_Default | `60+2a+12r` | 74 |
| Reject | `1` | 1 |
| Put_Line | `98+17a+6b+3c+f+2s` | 127 |
| Put | `89+17a+5b+2c+f+2s` | 116 |

The result epsilon used to store a closed postcondition is separate: charge
one further term node for that representation. Opening it with a result
variable preserves the displayed profile. These profiles do not recursively
unfold imported logic definitions. Imported aliases, marked definitions and
their lifetimes remain the separate subsequent interface.

Typing is checked rather than inferred from native `W_CALL` annotations.
`typing.ml:331–471` can synthesize a closure for an unsaturated application;
`dterm.ml:606–712` can add two Boolean-to-proposition nodes or three
proposition-to-Boolean nodes. The concrete selected signatures are:

| Family | Arity | Logical result |
| --- | ---: | --- |
| Builtin equality; Integer `<=` | 2 | proposition |
| Integer `+` | 2 | Integer |
| Character map `bool_eq` | 6 | Boolean value |
| Character map `get`, `slice` | 2, 3 | Character, map |
| Named `map__content`, `int__content`, `bool__content` | 1 | respective snapshot |
| Character `to_rep` | 1 | Integer |
| String and generated slice type `first`, `last`, `length`, `to_array` | 1 | Integer, Integer, Integer, map |
| Generated slice type `of_array` | 3 | String |
| String/output `dynamic_invariant` | 5 | proposition |
| Input_Is_Valid logic symbol, including its exported alias | 1 (unit) | Boolean value |
| First_Or_Default logic symbol and guard | 1, 2 | String, proposition |

These group all 29 symbols used by the selected trees. Their native declarations
and clone/export routes, plus the installed `Array__1`, `Unconstr_Array`,
`Rep_Proj_Int` and `Int` declarations, fix their logical signatures. In
particular, the guard's native return annotation says bool but the converter's
Pred declaration branch creates a **proposition**. Slice types export and alias
the existing String family; they do not add a new mutable record shape.

Every application has its declared first-order arity. Boolean-valued calls
and reference projections appear as equality operands; predicate calls appear
in formula positions. Let definitions are value terms, and conditional tests
and quantifier bodies are formulas. There is no trigger, higher-order
application, record update, embedded-application identifier spelling or complex
result pattern in the five complete trees. The converter uses nonassociative
comparison/connection constructors, so the parser's chained-infix duplication
case is absent. Thus these selected terms require no closure, implicit Boolean
wrapper or new coercion path. Attributes and scalar constant casts change no
term shape; simplification can only reduce the lexical envelope. The displayed
profiles consequently bound the opened typed postconditions as well as
describing their native templates. The exact independent review report is
linked separately when the author freeze is accepted.

The First_Or_Default template includes its optional guard. Removing that guard
reduces the envelope. Input_Is_Valid's Boolean result needs no dynamic invariant
and it has no explicit post/contract cases, so the guard predicate in
`gnat2why-util.adb:1843–1872` is false for it even when guard generation is
enabled.

Contract application maps formal program variables to actual program
variables, and then to variable terms (`Ity.cty_apply:1436–1489`), as already
established by the typing provider. When several formals map to the same
actual key, add their affine coefficients. Never erase repeated occurrences
because their underlying term node is shared.

The selected normal `term_of_post ~prop:false` split is sharper than the
general `H+3,H` bound. `expr.ml:560–582` finds the leftmost result equality,
whose RHS does not mention result. Input_Is_Valid therefore supplies a
definition of cost 2 and residual True of cost 1. First_Or_Default supplies
definition `1+a` and residual bounded by `59+a+11r`; this retains the replaced
True and its conjunction, even if simplification removes them. The three
procedures have unit result and no result equality or Boolean-iff/function
case, so this extraction returns None and their postconditions stay on Kval.
The packet retains these definition/residual trees separately. They must not
be collapsed into one maximum before the later lexical let transfer.

## Effects are eleven keys, not five

The declaration-level File_System name expands before Why effects are built.
`Get_Proof_Globals` expands abstract states separately in read and write sets
(`flow_utility.adb:2659–2674`). The expansion recursively includes Part_Of
constituents and retains the residual abstract state when no complete
refinement replaces it
(`flow_generated_globals-phase_2.adb:4793–4875`). The selected installed
`a-textio.ads:758–771` has six such constituents: standard and current input,
output and error files. The runtime body does contain a ten-object
Refined_State annotation, but its explicit `SPARK_Mode => Off` excludes that
complete refinement: the sole `GG_Register_State_Refinement` caller is guarded
by an absent body SPARK pragma or mode On
(`flow_generated_globals-partial.adb:522–534`). Phase one serializes only that
registered map (`phase_1.adb:593–611`), and phase two's sole
`State_Comp_Map.Insert` reads it (`phase_2.adb:1562–1584`). Thus this is the
Part_Of-plus-residual branch, not a measurement-based assumption that the body
has no refinement. The fixed external-state family has **seven**
keys, all translated as private-state references. The output operations add
four Silver globals.

| Declaration | Native read keys | Native write keys | Typed external-key union |
| --- | ---: | ---: | ---: |
| Input_Is_Valid, First_Or_Default | 0 | 0 | 0 |
| Reject | 7 | 7 | 7 |
| Put, Put_Line | 7 | 11 | 11 |

`Ity.create_cty:1375–1383` also adds free postcondition program variables to
the read effect, so the native read-list cardinality is not a typed-read
bound for Put/Put_Line. Use the eleven-key union. An identifier's native type
annotation is its snapshot type; the global declaration converter appends
`__ref` (`gnat_ast_to_ptree.ml:1209–1224`). The packet records these actual
reference types. Their fields have the pure scalar/map/private snapshot
types from the accepted [Main frontier](retained-producer-main-types.md),
so the flat-havoc argument remains applicable.

All five declarations have no exceptional posts and no old-value references.
For their ordinary `Eexec` branches, `h=0`, `o=0`; the query havoc flag is
zero and procedure havoc flag is at most one. Conservatively use **`p=1`**:
the native declaration contains a True precondition, the converter makes a
singleton requires list, typing maps that list, and `create_cty` preserves
it. Absence of a public Ada Pre does not justify `p=0`. This gives local
kode bounds 5 for each query and 7 for each procedure before an optional
WP/SP tag, excluding already evaluated argument-proxy definitions.

## Variable and outcome accounting at the structural interface

For a fully constructed typed profile, let `U0` be the cardinality of its
program-variable key union, including formal/actual keys, typed read/write
effects and both sides of old-value maps. Sum the following **occurrences**
over the actual `k_expr/k_fun` traversal, including nested Cfun bodies:

```text
nv     = reached nonvariable var_or_proxy operands
nf     = reached k_fun invocations, including the enclosing Main invocation
xf     = completed exceptional posts across those k_fun invocations
tr     = optional Eexec trace results, normal and exceptional
lost   = white-box lost-exception entries
unit_h = payload-free handler placeholders
lemma  = local RLlemma results
rlpv   = possible RLpv Cfun enrichment results

U <= U0 + nv + nf + xf + tr + lost + unit_h + lemma + rlpv.
```

These are disjoint creation families from the accepted kode transfer; sharing
can reduce the key union, so summing is conservative. SP/WP's fresh logical
post-write names are map values, not new program-variable keys. No recursive
variant-oldification family is added in the selected ordinary fragment.

If `nh` counts reached try-handler entries, the fresh outcome increments are
`Delta = nh + lost + xf`. Carry the incoming process counter `C0`: its final
value is at most `C0+Delta`. For an incoming reachable nonnormal outcome-key
set of cardinality `H0`, the exported cardinality bound is
`H <= 1+H0+Delta`, including normal outcome zero. Counter magnitude and map
cardinality are separate; neither is reset at every internal function.

At each call or internal function the local `h`, `o`, `v`, `p` remain attached
to that occurrence. In particular `h` is obtained after `complete_xpost` or
the white-box pass/lost partition, not from source exception syntax alone.
The SP/WP sequence equations consume the actual outcome vectors and lexical
definitions. Replacing each continuation by a global maximum is optional
loss of precision, not part of this interface.

## Main construction still to discharge

The accepted conversions already fix several important source multiplicities:
resolved application children occur once behind their proxies; both branches
are present; simple singleton handlers do not create Kcase; generated abstract
functions return unit; and an ordinary lowered Loop has Ptree bound
`P(code_after)+14`, not twice its nested source body. Those results remain
unchanged and are not rerun here.

The remaining Main row is a constructor-preserving source traversal. In
particular, the scalar aggregate for `Insert_Array_Conversion`
(`why-gen-expr.adb:982–1512`) combines alternative slide/accessor branches
and two possible temporary bindings. It does not specify which later terms
read each saved temporary. The next implementation step is to express those
branches in the binder-aware profile algebra, with the original child at its
single definition hole, then compose concat, assignment and declaration rows.
The branch-observation assignment, warning Abstract_expr, generated loop
frame/index assumptions and enclosing Main contract must be carried through
the same construction. A finite set of arbitrary trees of the scalar total
size would not complete this obligation or demonstrate a useful rule.

The five fixed contracts, the additional primitive contracts and this general
source traversal must be joined before #178 can be marked complete. This
checkpoint does not close source-to-terminal-goal counts, full imported
declaration typing/lifetimes, fixed library-body processes or #119.
