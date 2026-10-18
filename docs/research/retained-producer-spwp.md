# Ordinary Main SP/WP formula-size transfers

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119) research.
These source-derived transfers bound retained lexical formula size from
Why3's intermediate `kode`, after `reflow`, for the
[closed scalar/String/reference type frontier](retained-producer-main-types.md).
They expose the exact typed-code, variable and outcome inputs still needed
from the source producer. They do not claim that those earlier inputs or
complete producer allocations are already bounded.

The retained `vc.ml`, `term.ml` and related sources are identified by the
[first-split](../evidence/retained-producer-firstsplit-20261018/identity.json)
and [Main type](../evidence/retained-producer-main-types-20261018/identity.json)
archives. No compiler/prover execution is involved.
The [offline checker](../evidence/retained-producer-spwp-20261018/check.py)
verifies the source archive and small arithmetic identities below. It does
not execute or formally verify the SP/WP implementation.

## Size measure and small constructors

Use the lexical `E0` occurrence envelope from the
[post-split record](retained-producer-postsplit.md). At a function boundary,
unbound variables have weight one. The envelope counts let definitions at
their own position and again at each use; ordinary constructors add one.
Type/variable metadata, attributes and temporary allocations are separate.

All `adjustment` and `advancement` substitutions in SP/WP map variables to
variables (`vc.ml:1186–1192`). Capture-avoiding renaming preserves this
measure. It is not an arbitrary term substitution.
The `wrt_forall`/`wrt_exists` helpers also only clone logical variables,
substitute those variables, and add the respective trigger-free quantifier
(`:1353–1372`). Write-location attributes do not change term-node counts.

For a term of cost `a>=1` and a formula of cost `b>=1`, use

```text
Let(a,b) = 3 + a + a*b.
```

This bounds both `wp_let` and `sp_let` (`:274–285`). A retained let has cost
at most `1+a+a*b`: its body is affine in the bound variable's weight, so
raising that weight from one to `a` increases it by at most a factor `a`.
Substitution/removal is no larger in this envelope. The SP read-visible
case instead constructs `v=t /\ body`, costing at most `3+a+b`, also
covered by `Let`. Unit substitution has cost one and is smaller.

Conjunction/disjunction/implication add at most one to their two input costs.
Quantifier closure without triggers adds at most one. Conditional helpers
with the fixed Boolean test `v=True` cost at most `4+a+b`; the shortcut using
a negated test also fits because the removed true/false branch had cost one
(`:207–269`). Attribute-only explanation and trace changes add no term nodes.

Let `U` bound the original program-variable keys present in the intermediate
code and its contracts. SP destination/read/write maps use subsets of these
keys. Fresh post-write **logical** names are map values, not new keys.
`sp_complete` adds at most one equality and conjunction per differing key,
at most `4*U`; merging two outcome postconditions adds at most `8*U+1`
(`:1319–1330`). A conditional outcome merge costs at most `8*U+5`.

## Flat-reference havoc

An affected ordinary Main reference takes the directly written-region branch
of `havoc`; its one field has a pure snapshot type. For each destination:

- a known field assignment adds at most a four-node projection/value equality;
- an unchanged field equality costs at most five nodes;
- a possible top-level destination equality costs at most three;
- joining the field/top-level constraints and the outer accumulated formula
  costs at most two more nodes.

Thus ten nodes per destination suffice. In SP the initial true and possible
existential binder add two, and the safety component is true, giving total
`3+10*U`. In WP the constraints and possible let wrapper add at most ten per
destination, plus a universal binder, giving `q0+10*U+1`. The right-hand
sides in this branch are typed variables; no arbitrary value-expression
substitution hides inside these constants. This is specific to the flat
Main frontier, not the general havoc fallback.

In particular, `name_regions` (`:1224–1236`) starts from destination
variables. `explore_paths` stops at each pure field, so no nontrivial field
path can become the name of another affected region. Every region name
used by `havoc` here is therefore a variable. The WP fallback let binds a
variable to a variable and adds at most two nodes in the lexical envelope;
it cannot multiply the continuation by a hidden composite region term.

## Strongest-postcondition recurrence

For `sp_expr`, write `w` for the returned safety-formula cost and `s_i` for
each exported outcome's postcondition cost. Let

```text
S = sum_i s_i
W = w + S.
```

Let `H` bound the number of outcome keys exposed at the current call.
Keeping actual key sets/cardinalities is more precise than replacing every
`H` by a global exception count. Every row below bounds retained results,
including a true safety formula where the implementation returns it.
`Kcase` is deliberately outside these rows: the earlier source-to-kode
transfer must exclude it for ordinary Main. A case-free input contract or
an all-solid type list alone is not a proof that no program match introduced
a `Kcase`. Generated unit/variable handlers and the reviewed converter paths
are the relevant source restriction.

| Intermediate form | Sufficient bound on `W` |
| --- | --- |
| `Klet(v,t,f)` with costs `a=E0(t)`, `b=E0(f)` | `1 + Let(a,b)` |
| `Kval(vs,f)` | `E0(f)+2` |
| `Kcut f` | `2*E0(f)` |
| `Kstop f` | `E0(f)` |
| `Kcont i` | `2` |
| Flat `Khavoc` | `3+10*U` |
| `Kpar(k1,k2)` | `W1+W2+1+H*(8*U+1)` |
| `Kif(v,k1,k2)` | `W1+W2+4+H*(8*U+5)` |
| `Kaxiom k` | `1+F(k,empty)` using the WP recurrence below |
| Off/Out tags | The child's bound; filtering removes outcomes |

The special sequence `Kseq(Klet(v,t,f),0,k2)` is handled before the general
sequence branch (`:1421–1427`). If `h2` outcomes of `k2` remain exported,
its bound is

```text
W <= a*W2 + (h2+1)*(3+2*a+a*b).
```

Each safety/postcondition receives `f`, followed by the same let closure;
the formula follows by summing `Let(a,1+b+child_cost)`. It charges definition
reuse explicitly.

For the general `Kseq(k1,i,k2)` (`:1428–1491`), let `s0` be `k1`'s
postcondition for the consumed outcome `i`, and `h2` the number of retained
outcomes of `k2`. Then

```text
W <= W1 + W2 + h2*s0 + 3 + 2*h2 + H*(8*U+1).
```

To see the multiplicity, the new safety condition contains `s0` once in
`wp1 /\ forall(..., s0 -> wp2)`, while `s0` is removed from `k1`'s exported
map. Those two occurrences cancel in the summed accounting. Each exported
outcome of `k2` then receives one copy of `s0`, a conjunction and an optional
existential binder. The final outcome-map merge adds at most the stated
completion/disjunction allowance. Adjustment/advancement only rename.

If `k2` exports no outcomes, the `h2*s0` term vanishes. This is relevant at
a final stop/postcondition and is why multiplying every sequence by a global
branch count loses useful structure. If only a coarse child summary is kept,
use `s0<=W1`; a future predicate should prefer the actual per-outcome vector.

## Weakest-precondition recurrence

Let `F(k,q)` bound the returned WP cost for a map `q` from outcomes to positive
formula costs. Use the actual key set expected by the well-formed intermediate
code. `vc.ml:1598–1646` gives:

| Intermediate form | Bound |
| --- | --- |
| `Kseq(k1,i,k2)` | `F(k1,q[i := F(k2,q)])` |
| `Kpar(k1,k2)` | `1+F(k1,q)+F(k2,q)` |
| `Kif(v,k1,k2)` | `4+F(k1,q)+F(k2,q)` |
| Flat `Khavoc` | `q[0]+10*U+1` |
| `Klet(v,t,f)` | `Let(E0(t),1+E0(f)+q[0])` |
| `Kval(vs,f)` | `2+E0(f)+q[0]` |
| `Kcut f` | `1+E0(f)+q[0]` |
| `Kstop f` | `E0(f)` |
| `Kcont i` | `q[i]` |
| `Kaxiom k` | `1+F(k,empty)+q[0]` |
| Off/Out tags | Child recurrence, restricting keys for Out |

At a WP-to-SP boundary, the code appends one `Kseq(...,i,Kstop(q[i]))` per
outcome, then invokes SP and keeps its safety formula. Use those exact
wrappers and the SP recurrence. At an SP-to-WP boundary, the code requires
an empty outcome map and returns `F(k,empty)` with no exported SP outcome.
The forbidden Push/WP/SP cases remain forbidden by `reflow`; no error branch
is used as an admission-size shortcut.

## Earlier typed-code and final joins

These equations are useful inputs to a source counter, not a substitute for
its source correspondence. The remaining earlier obligations are concrete:

- Charge the GNAT-JSON-to-Ptree and Ptree-to-typed-expression constructors,
  bindings, effects and instantiated contracts. Distinguish program bodies
  from large literal axioms which add context without the same goal growth.
- Derive the intermediate `kode` and its attached term costs through
  `k_expr`, `k_fun` and `reflow`, with each original variable and outcome key
  charged. `Abstract_expr` really creates a zero-argument function in the
  converter (`gnat_ast_to_ptree.ml:889–905`), so Cfun/local-function WP and
  axiom paths cannot be excluded merely because Silver source has no user
  subprogram declarations.
- The converter's generated loops are `while True` with an empty native
  variant list; their variant assertions are already in the lowered body.
  The all-solid frontier eliminates their type-invariant injections.
  Main's `vc:divergent` attribute sets `env.divergent`, excluding the added
  missing-divergence warning/check wrapper. Those are valid reached-branch
  reductions when counting this intermediate code.
- Carry the term structure, bound-variable types and marked-definition map
  needed by the [matcher envelope](retained-producer-matchsize.md) and `E1`.
  A scalar total `W` alone loses the equality/alias/variable-use information
  needed for a sharp composition with those passes.

Retained formula bounds also leave temporary traversals/maps, generated names,
type substitutions, context/lemma declarations, the fixed library-body
processes and other essential Why3/solver representations outstanding. The
whole producer rule and useful-domain comparison remain incomplete.

Independent source review on 2026-10-18 found no material issue in the flat
havoc allowance or either sequence recurrence. It corrected source anchors
and requested the explicit Kcase restriction above. That review performed
no native or Lean execution and did not establish the earlier source join.
