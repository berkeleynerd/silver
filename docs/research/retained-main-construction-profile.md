# Ordinary Main construction profile

2026-10-23, ongoing [#178](https://github.com/berkeleynerd/silver/issues/178)
research under #119. This continuation imports the exact selected-contract
provider at `3040c6736d3a004239256b2ba50f25144e68bec8`, independently accepted
in review `00a37442cc2912a4a456717d33ee852facd1f2fc`. That fixed provider is
immutable. **This closes the restricted conversion/interface row, not #178.** No
compiler, prover or target execution is part of this calculation.

The input is the recognized authoritative source tree with binding and
static-shape summaries. Source sizes and counts are symbolic; old policy
caps are not substituted. The objective is a constructor-preserving monotone
profile, with explicit source child occurrences, attached term bindings and
effects. An enumeration of arbitrary trees below a scalar occurrence budget
would not supply the required usable source transfer.

## Ordinary primitive contracts

In `expr.ml`, `make_post:102–108` adds a result equality for a value symbol,
and a result-equals-True equivalence for a predicate symbol. For actual
argument weights `a_i` and result weight `r`, their opened profiles are:

```text
value symbol:     2 + r + sum a_i
predicate symbol: 4 + r + sum a_i.
```

For the predicate symbol, `term_of_post ~prop:false` returns the predicate
converted to a Boolean value, with definition bound `4+sum a_i` and residual
True. For a value symbol it returns definition `1+sum a_i` and residual True.
Closing a postcondition adds its separate epsilon node. Fully applied
`c_pur:846–854` introduces no remaining formal arguments. Projection and
record constructors use the same value-equality form
(`create_projection:173–184`, `create_constructor:193–211`). A mutable
one-field constructor has a reset effect; its field is a pure snapshot.

These formulas do not silently inline imported function bodies. The body
enrichment path is restricted to RKnone Cfun with an empty postcondition
(`expr.ml:691–703`). RKfunc and RKpred keep their parsed contracts and receive
their logical equality/equivalence in `create_rsymbol:138–150`.
`dexpr.ml:1773–1789,1801–1816` carries those kinds through lambda/let typing.
`pdecl.ml:582–613` may add a separate logical declaration or axiom; that
context cost is distinct from the instantiated call contract.

Consequently Integer arithmetic and predicate operations,
Array__1 `get`, `slice`, `slide`, `concat`, and Unconstr_Array `to_array` and
`of_array` have these small call profiles when their declarations have no
additional explicit specification. String `first`, `last` and `length` are
separate RKnone val declarations with an explicit result equality, giving
the same value profile. Their potentially larger logical definitions stay
outside this call-contract substitution.

Checks must retain their module-specific explicit contracts. In
`ada__model.Static_Discrete_Base:77–89`, a range check has
`pre=in_range(n)` and `post=result=n /\ in_range(n)`, with profiles
`1+n` and `3+r+2n`. Its extracted definition has weight `n`; the unsimplified
residual is bounded by `3+n`. The not-first/not-last checks similarly retain
their inequality in the postcondition. Dynamic_Discrete uses the three
arguments first, last and value. The Standard Boolean check helpers have
smaller result-equality-only postconditions. They must not be silently
identified with the larger Discrete contracts or vice versa.

## Temporary-map state is part of construction

`New_Temp_For_Expr` is not merely a test for a cheap expression. At
`why-gen-expr.adb:4962–4996`, it creates and records a fresh temporary when

```text
(Need_Temp and kind not in {W_Identifier,W_Deref})
or Temp_Names_Map.Contains(expression_identity).
```

`Binding_For_Temp` later consumes that entry and inserts its definition once.
The profile algebra must therefore carry native expression identity and the
pending temporary map while constructing a helper's context. Binding identity
is distinct from printed spelling. Rebinding an already pending temporary is
required even though its node is an Identifier.

Conversely, forcibly binding every cheap input is not a valid retained-size
majorant. The actual no-binding branch can repeat a dereference/application
at several uses. Replacing those program occurrences by a single evaluation
and variable reads can make the proposed profile smaller. Preserve the cheap
reference at every actual use, or take an explicitly justified maximum of
the original and binding paths.

## Restricted array-conversion row

Under the accepted ordinary String shape invariant, `Insert_Array_Conversion`
(`why-gen-expr.adb:982–1512`) has this constructor-level form. Here `map(a)`,
`first(a)` and `last(a)` use the source representation: a static map is already
its map and has static type bounds; an unconstrained String uses its named
accessors. The source child is `e`, and `temp` means the stateful rule above.

1. If source and target Ada type identities agree, return `e`. The eager
   split-type allocations are separate metadata and do not alter this body.
2. Otherwise obtain `a=temp(e)`. The original complex child is the recorded
   definition, while a cheap identifier/dereference remains repeated at uses.
3. Construct the split-map expression `m`:
   - with sliding, `slide(map(a),first(a),target_first)`;
   - without sliding and with an unconstrained target, `map(a)`, retaining
     `first(a)` and `last(a)` as reconstruction arguments;
   - with static source and target, `a`;
   - with only the target static, `map(a)`.
4. Wrap `m` in the empty type Label and obtain `b=temp(label(m))`.
5. The value is `of_array(b,first(a),last(a))` for an unconstrained target,
   otherwise `b`.
6. When the program-domain check is requested, prepend the target length
   assertion for a constrained target, otherwise its range/dynamic-property
   assertion. Both use `a`, not another evaluation of the source child.
7. Consume the `b` binding around that context, then the `a` binding.

Sliding to an unconstrained/fixed-lower-bound target is excluded by the
ordinary shape invariant. So are qualification index checks, relaxed
initialization conversion, component-type conversion and user predicate
checks. Each excluded source branch has its existing shape premise; a generic
arbitrary-array conversion would need more rows.

The second binding is mandatory in this reached row: the dummy Label is a
real native node even with an empty label set (`:1403–1419`). The generated
builder appends the specific node kind unconditionally
(`xgen/xtree_builders.adb:238–249,486–492`; Label schema
`xgen/xtree_sinfo.adb:277–282`). Thus it is not an Identifier/Deref at the
temporary decision. The later Ptree converter may discard attributes without
removing this already generated binding.

`New_Length_Equality` is retained as an explicit term, with six applications,
one conjunction and one conditional (`why-gen-arrays.adb:3396–3462`):

```text
if lf <= ll then rf <= rl /\ (ll-lf = rl-rf) else rl < rf
E0 = 8 + 2*lf + 2*ll + 3*rf + 3*rl.
```

Its `else` native call has `Typ => Base_Ty`, despite selecting the `Int.<`
predicate. The typed profile follows the declared symbol and proposition
context, not that annotation. The outer rank-one helper removes its initial
True conjunct; both static types with equal lengths return True without this
term. `Insert_Length_Check` returns Void in that case, and `Sequence` removes
that Void (`why-gen-progs.adb:329–341`). The split binding remains.

For an unconstrained target, the dynamic check is exactly one four-argument
predicate call, with explicit bound trees:

```text
dynamic_property(target_first, target_last, first(a), last(a)).
```

The transfer is `why-gen-expr.adb:4337–4389` followed by
`why-gen-arrays.adb:3305–3366`. Under the ordinary Integer-index premise, the
additional conversions to the already selected integer representation are
identities. Its lexical profile is
`1+target_first+target_last+first(a)+last(a)`; for an unconstrained source this
is `3+target_first+target_last+2*a`. The static-source accessors instead retain
the source type's supplied bound expressions; they do not use `a`.

## Bound trees and program/term context

Bounds are inputs as complete normalized constructor trees in Integer
representation. `Get_Array_Attr` builds a `New_Attribute_Expr` and then a
representation conversion (`why-gen-arrays.adb:2813–2834`;
`why-gen-expr.adb:3600–3748`). A static bound can be a literal, a nullary
symbol/call, or the already bounded ordinary itype expression. It is not
unconditionally a constant leaf. `Add_Attr_Arg:249–277` adds another conversion
to representation; this second conversion is identity for the present rank-one
Integer indices because `Get_Array_Attr` has already selected that representation.

Ordinary Integer/Positive first and last declarations use nullary program
symbols. The converter's `Function_Decl` Pterm branch emits a RKfunc declaration
with an Any specification (`gnat_ast_to_ptree.ml:1044–1059`). The corresponding
nullary `dexpr.ml:1817–1833` path retains the logical-symbol result equality as
the later call contract. Thus its opened cost is `2+r`, its extracted definition
is the constant application of cost one, and its residual is True. Literal
subtype bounds remain literal leaves. The executable interface distinguishes
variable identifiers from identifiers resolved to these nullary symbols.

A native domain tag alone does not put an accessor in an Epure node.
`mk_of_expr` recurses using the caller's E/T implementation
(`gnat_ast_to_ptree.ml:386–395,590–592,952–975`). Accessors appearing as arguments
to sliding/reconstruction are program applications, including their call
contracts and argument evaluations. Accessors in assertions are logical
applications. The term projection uses declared signatures and inserts the
actual Boolean-to-proposition equality (`+2`) or proposition-to-Boolean
conditional (`+3`) where needed. Empty Labels disappear at `:539–542`, after
the native temporary decision and binding construction.

The catalogue separately retains module-specific Boolean and projection specs:

| Program binding | Opened post profile | `term_of_post(false)` input/output |
| --- | --- | --- |
| Standard Boolean `bool_eq`/`bool_ne` | `5+r+x+y` | definition `4+x+y`, residual True |
| Discrete_Base `bool_eq` | `7+x+y+2*r` | raw conditional envelope only; later simplification not classified here |
| Rep_Proj_Base `to_rep` | `2+x+r` | reversed equality; no extraction |
| Rep_Proj_Base `of_rep` | `2+r+x` | result beneath projection; no extraction |

These come from `_gnatprove_standard.mlw:1826–1830` and
`ada__model.mlw:11–15,38–42`. A Cpur use of a logical symbol is a different
route from its explicit RKnone program binding. In particular, the two
Rep_Proj_Base rows cannot be replaced by generic result-first make_post
contracts. Module-qualified catalogue aliases denote the selected clone/type
binding; they are not name-only matching against native JSON strings.

## Executable interface and monotonicity

The [new packet](../evidence/retained-main-construction-profile-20261023/README.md)
retains the algebra, 43 primitive signatures/contract templates, 84 conversion
parameter cases and their normalized native and resolved-program/logical
diagrams. All source sizes remain symbolic. These cases check the transcribed
control partition and algebra; they are not a proof by sampling source programs.
The row above supplies the source correspondence, subject to its explicit shape
premises and the accepted provider's installed-source assumptions.

`Builder` preserves native node identity and the pending-map domain. Nodes must
belong to the same builder. External identity tokens cannot use the reserved
`tmp:` namespace; temporary identity never comes from a source spelling. A
pending input temporary belongs to the caller: the conversion rebinds it, consumes
its own new entries, and leaves the caller's original entry intact. The recorded
input/output maps expose that ownership rather than requiring an empty incoming
map. Every native child use remains an occurrence, even when IDs are shared.

`program` emits a resolved-application interface. Each application keeps its
actual occurrences and a separate formal contract reference. The accepted
typing transfer gives `2+2*arity+sum E(child)` expression nodes; each nontrivial
actual is later evaluated once behind its own proxy, and contract instantiation
uses those variables. The interface does **not** substitute expression trees
into formal contracts or combine extracted definition/residual weights before
the lexical transfer. Let/sequence/if cost one plus child counts; Boolean
and/or cost two and not costs three. Assertions cost one expression node and
retain their separate term. Closed post storage retains its epsilon separately.

For an as-yet unexpanded source child, a supplied handle denotes its **whole**
independently derived profile and binding context: body, contracts, attached
terms, effects and free/bound identities. Each occurrence imports that profile
with the required scope-preserving fresh identities. A complex source child
appears once behind the conversion's first binding; cheap expressions retain
each repeated occurrence. The native kind and pending-map membership are decided
before substituting a profile handle. A symbolic expression-size coefficient
is only one projection of this interface. It discharges none of the referenced
child's unresolved source, lexical, contract or effect obligations. The local
E projector is deliberately partial outside its implemented constructors; it
requires a supplied child profile for other constructors.

For fixed constructors, symbol/type resolution and control decisions, lexical
weights and typed child-size weights have nonnegative affine coefficients.
Structural induction gives their monotonicity for positive weights. A logical
let contributes `1+E(def)+E(body)[bound := E(def)]`; the checker compares its
affine result with independent direct environment evaluation. This is not
monotonicity under arbitrary syntax replacement: changing a cheap child to a
complex child changes the temporary branch and can reduce repeated program
calls. The full resolved profile preserves the branch and binder structure
needed for later kode/SP/WP composition instead of taking an arbitrary finite-tree
cover or scalar maximum.

## Remaining Main join

The accepted fixed tranche and this constructor row remain distinct from a
complete Main construction profile. Next are the concat/comparison/Image/Length
callers, declaration and assignment invariant suffixes, observation and warning
wrappers, range-loop captures/index/frame/handler clauses, and the enclosing
Main input/output properties. Their complete body/term/effect profiles must be
joined with proxy typing, internal Cfun traversal and variable/outcome accounting
before publishing source-derived U/H or closing #178. The ordinary physical
resource premise and one global `e <= 2` are unchanged. No compiler, prover,
target or Lean run is part of this packet.
