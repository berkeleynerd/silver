# Symbol-sensitive inlining on the retained entry

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119), based on
`7c89b21e2489d984bdabcae3d5bd88a6dd38e2b8`.

The [captured first Input_Is_Valid/cvc5 entry](retained-why-preparation-entry.md)
now has a **computable conditional semantic bound for `inline_trivial`**.
Tracking eligible definitions, matching application symbols and formal-variable
occurrences removes the previous recurrence's demonstrated loss of precision.
The maximum output root mass is **99**; the goal mass is at most **73**.
This is a source-derived bound on the retained pair, not an observation of
native inlining or complete Why3 capacity.

The [offline packet](../evidence/retained-why-inline-refinement-20261018/README.md)
uses the frozen complete graph and pinned Why3 source
`9390baf120ef260547dfa14f08e11c890b203d9c`. It neither changes that capture nor
runs a native tool. The unchanged relevant-source/runtime, well-formedness and
noncolliding-symbol assumptions remain explicit. The source induction is
inspected; it is not a machine-checked proof of OCaml semantics.

## Concrete result

There are 81 singleton logic declarations and 62 proposition roots. Of those
logic declarations, **45 pass the source's shape/attribute eligibility test
uniformly across all modeled exclusion choices**. No possible self-reference
was found, including a conservative propagation of symbols in stored delayed
substitution values. At most 45 definitions enter the environment.

Exactly **85 input application occurrences** match one of those eligible
symbols in the preceding environment. These are *possible hits*, not an
assertion that the native run would inline 85 applications. The other input
applications cannot hit this environment. The largest saved hit body has mass
at most 5, and every formal-occurrence coefficient used at these sites is at
most 1.

| Bound over all 143 mapped roots | `n` | `b` | `p` | `a` | Mass |
| --- | ---: | ---: | ---: | ---: | ---: |
| Sum of output coordinate bounds | 1,613 | 168 | 12 | 594 | 1,793 |
| Coordinate maxima / maximum root mass | 91 | 8 | 2 | 36 | 99 |
| Goal | 68 | 5 | 0 | 36 | 73 |

The maxima need not occur at the same root. Each individual output coordinate
bound equals its corresponding input coordinate on this captured context;
this is a computed fact for these 143 roots, not a universal property of
`inline_trivial`. The 512-node input chain remains an output-chain upper bound.
Reconstructed definition axioms and proposition formulas have summed mass at
most 2,263 and maximum individual mass at most 99, including definition heads
and formal binders.

Reusing the source event accounting from the
[conditional kernel transfer](retained-why-preparation-bound.md), with the
actual matching sites and their body dimensions, yields:

| Kernel event | Upper bound |
| --- | ---: |
| Recursive `t_replace_all` entries | 1,613 |
| `t_unfold` entries, hits and misses | 594 |
| Environment hits | 85 |
| Recursive `relocate` term entries | 156 |
| Term entries in hit-body type mapping | 156 |
| Final post-type `t_subst_unsafe` entries | 156 |
| Fresh variable identifiers inside this kernel | 235 |

The last row is `168 + Σ_hits (2*B_body + F_body)`. Here `F_body` is bounded
by the number of formals with nonzero occurrence coefficients, rather than a
global body-size maximum. These are increments/events in the stated kernel,
not a completed native counter no-wrap claim. The mapped declaration
constructor-call upper bound is 143; declaration validation and identifier
creation outside the kernel remain separate.

## Metadata is quantified, not guessed

The frozen capture retains complete logical declaration payloads and the
ordered task chain, but only kind/tag/address rows for its 192 `Meta` nodes.
It therefore does **not** supply the actual `inline:no` symbol set used by
`Trans.on_tagged_ls`. Such exclusions are relevant: the fixed library sources
contain projection exclusions, and matching projection names occur among the
captured logic definitions. No empty-set assumption or reconstruction from
names is made.

The model instead covers **every exclusion set**. At an eligible symbol's
application it retains both possibilities: rebuilding the application after
mapping its arguments, and substituting the saved body. These `Choice` nodes
can select independently at different occurrences and in saved bodies. That
permits more combinations than one consistent native metadata set, which
only weakens an upper bound. Additional `notls` exclusions are covered by the
same missing-environment alternative.

This handling does not admit every singleton definition. The actual
`notdef`/`trivial` predicates are evaluated on the possible transformed shape:
variables, constants and Boolean constants qualify; application arguments
must each be distinct variables or closed non-epsilon terms; an
`inline:trivial` attribute overrides that shape test
(`inlining.ml:119–145`). Root attributes include the symbol attributes for
this test, as `Inlining.fold` does. The saved body itself retains its ordinary
term attributes, not that temporary union.

The checker computes both possible and certain eligibility. Distinct variable
choices use a finite matching check; certainty rejects any bad argument or
possible duplicate variable. On **all 81 actual definitions**, the two answers
agree. Thus actual metadata choices cannot change which definitions pass this
shape test. Ambiguous eligibility or possible self-reference aborts this
restricted replay rather than silently adding a definition.

`get_used_syms_decl` can traverse stored substitution values that disappear
from the opened tree (`decl.ml:518–524`, `term.ml:1183–1205`). Consequently the
nonrecursion check is not based solely on visible applications. The model
collects symbols from original stored bodies, outer definition substitutions
and triggers, then adds stored-symbol provenance from every possible hit
body. This is a conservative superset of retained symbols after mapping.
None of the 81 definitions references itself in that superset. Type-symbol
identities cannot equal these logic-symbol identities under the existing
noncollision invariant.

## The weighted transfer

For each possible saved body and its distinct formal variables `v_i`, retain
four nonformal coordinate bounds `c = (n,b,p,a)` and occurrence bounds `q_i`.
A formal-variable leaf contributes zero to `c` and one to its own `q_i`;
other constructors contribute their node, binder-slot and pattern weights.
At an optional choice take the coordinatewise maximum of `c` and each `q_i`.
This deliberately allows maxima from different alternatives.

If transformed argument `i` has coordinate bounds `u_i`, simultaneous,
capture-avoiding substitution has coordinate bound

```text
c + Σ_i q_i * u_i .
```

In particular, its mass is bounded by nonformal mass plus the sum of each
formal's occurrences times its argument mass. A formal leaf is replaced once;
its replacement is not recursively substituted by the same map. The packet
checks this arithmetic against its constructed replacement at every hit.
Repeated arguments, repeated shared edges and trigger occurrences all
contribute their multiplicities. No global body maximum is exponentiated.

At a nonmatching application, retain its application node and the transformed
arguments. At a matching application, keep the maximum of that miss result
and the weighted hit result. Recursion still visits the opened input tree;
returned hit bodies are not sent back through `t_replace_all`
(`inlining.ml:22–40`). All roots of a declaration see the preceding environment.
Only after mapping a singleton definition is its eligible body made available
for later declarations (`:57–84`). This excludes both forward use and use of
a definition within its own batch.

An induction over the ordered declaration batches establishes the environment
inclusion invariant: each actual saved body is represented by its model body
under some choices. A structural induction over each input root preserves this
inclusion through mapped children, misses and weighted hits. Uniform eligibility
then preserves it when the next definition is considered. This explains why
the bound covers all metadata exclusions without enumerating their `2^45`
possible subsets. The finite exclusion regressions are checks of the
implementation; they do not establish that universal induction.

## Bindings, types and representation boundaries

The input reader materializes the frozen delayed substitutions using the
binding-frame interpretation in `term.ml:258–283`. Its 143 opened root vectors
must agree exactly with the separately replayed capture decoder, which checks
all 157 binder free-count records, pattern variables and map order. Every
quantifier trigger is retained. Branch pattern node counts, bound-variable
slots and logic symbols are retained even though the model does not evaluate
pattern matches.

Substitution freshly renames body binders and their references, including
pattern and trigger scopes. Argument free variables remain free when they
share an old body binder's identity. Repeated references to the same free
variable stay identical. This models the alpha-equivalent semantic result of
`relocate`, followed by the type map and final simultaneous substitution;
it does not equate model variable numbers with runtime identifier tags.

Types are represented structurally. Each hit matches formal types and the
body result type against the mapped arguments and application result, applies
the resulting type substitution, and checks the replacement's result type.
Choices must have identical result types. Type instantiation does not change
the measured term/pattern/binder shape (`ty.ml:234–254`,
`term.ml:1083–1173`). The analysis therefore preserves type distinctions needed
for valid hits while leaving type-constructor allocation, matching work and
hashcons capacity as separate obligations.

The model uses opened immutable templates. It does not claim those templates
are the native stored representation: physical-equality fast paths may retain
bindings and their delayed maps, and validators may traverse structures beyond
the mapped root. The source event bound for the final substitution relies on
relocation reclosing the hit body, as established in the earlier kernel
argument. It is not reused for all substitution work during original binder
opening or for hidden unused substitution values.

## Verification and remaining work

Offline replay matches every frozen input-root vector, recomputes the 45
uniformly eligible candidates, the 85 symbol-matched sites and every weighted
substitution result. Regression checks cover 156 concrete exclusion scenarios,
formal duplication greater than one, trigger multiplicity, binder capture
avoidance, type instantiation, duplicate-variable rejection, closed repeated
arguments, epsilon rejection, attribute override, ambiguous eligibility,
malformed input and type mismatch. No native process or new capture is used.

This closes the excessively loose **semantic inlining recurrence for the one
retained pair**. It leaves exact native inclusion/hit counts unknown and does
not close complete preparation capacity. Required work still includes all
fixed-input/driver entry projections, hidden substitution operations, complete
type/declaration-validator work, fresh tags outside the kernel, initial-counter
and shared-cache joins, later transformations, printing and serialization.
The current result is a bounded numerical component for that composition.
