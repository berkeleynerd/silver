# Main stored construction: type instantiation and caller obligations

This #202 / #119 unit proves a stored-term invariant needed to connect native
contract instantiation to the accepted
[case-free substitution kernel](retained-main-why-storage.md). It gives the
generic mapper's stored-node, type-callback and freshening recurrences and
attaches them to `Ity.cty_apply` stage 4 and `Pmodule.clone_term`. **It does not
close source-to-initial-VC storage demand.** The source-dependent typing,
clone, kode, extraction, reflow and SP/WP caller construction still has the
obligations listed below. In particular, no arbitrary typed-term fixture or
caller-demand certificate becomes a Main admission input here.

The [packet](../evidence/retained-main-construction-demand-20261024/README.md)
uses only retained sources at Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`; its manifest identifies complete
files and exact relevant spans. It reuses the accepted kernel implementation
without replaying its checker. Native execution, captures and compiler/prover
runs are all zero. These are mathematical constructions and source arguments,
not measured dynamic allocation counts.

## Saved-image support, including capture

For a stored binder write `V = bv_vars` and `H = bv_subst`. In addition to the
accepted well-typed, finite, cache-correct graph premises, retain:

```text
V[v] > 0 for every stored cache entry v;
FV(image) ⊆ dom(V) for every image in H;
the same properties recursively hold inside body, triggers and every image.
```

`FV` is the native cached free-variable operation, counting saved-image
semantics in the surrounding scope. This invariant includes dead saved keys;
it does not remove their images. It is stronger than merely checking an
opened formula's variable set or its term-node count. An arbitrary fixture
with a hidden free variable in an old image need not satisfy it.

Here is the constructor/substitution proof. New closing operations use
`bnd_new` with **empty H** (`term.ml:785–795`); removing bound variables from
the new positive cache cannot invalidate an image property because there are
no saved images in that new frame. Existing inner frames retain their own
invariant. The `t_vars` rows add positive occurrence counts and never insert
zero coefficients.

For a substitution M on an existing frame, let `R = M restricted to dom(V)`.
If R is empty the native frame is returned. Otherwise `bv_subst_unsafe`
constructs

```text
V' = (V without dom(R)) + Σ[v in dom(R)] V[v] * vars(R[v])
H' = map (subst R) H  left-biased-union  R.
```

This is the actual old-image rewriting order, including left-biased union;
it is not an eager replacement of the whole stored binder. By the ordinary
substitution support induction,

```text
FV(subst R image)
  ⊆ (FV(image) without dom(R))
      ∪ ⋃[v in FV(image) ∩ dom(R)] FV(R[v]).
```

The first set is in `dom(V')` by the incoming invariant. Each variable in the
second set has a positive contribution because `V[v] > 0`. Every new image
R[v] has the same positive contribution. Left-biased union retains one of
these already-valid alternatives. Positive additions and products preserve
positivity. Mutual induction on the finite stored graph establishes the
recursive clause for image/body subcalls. Native arithmetic must still pass
the accepted kernel's occurrence guards; this is an unbounded-integer proof,
not permission for a wrapping coefficient.

The proof does **not** assume that `dom(V)` is disjoint from the frame's bound
variable identities. For example, substituting `x ↦ v` into
`forall v. R(x,v)` can store an image mentioning the same identity v as the
binder. That occurrence is free in the image: interpreting an image drops
its owning binder frame. Fresh opening and generic mapping must preserve
that distinction. The packet checks precisely this example, including type
instantiation; its two occurrences remain free and bound respectively.

This establishes the invariant from source-built ordinary closing and the
accepted substitution/opening operations. It does not assert that every
unexamined typing helper has already been attached to those constructors.

## The actual generic mapper

`t_subst_types` first obtains `t_vars t`, then `gen_mapV` creates a new
variable only when `ty_inst mapT` changes that variable's type. Next
`t_gen_map` traverses the stored graph. Only afterwards does
`fold2_inter` attach supplied term images to the newly typed variables;
`t_ty_subst` finally runs the accepted term substitution
(`term.ml:1163–1173`). A simultaneous type-and-term substitution is therefore
not one leaf substitution on an opened formula.

The critical `gen_bnd_rename` row (`:1103–1111`) is:

1. Rename each key of V through the **incoming** variable map h, retaining
   its occurrence coefficient.
2. Fold **all** entries `(key,image)` of H. Type-rename each saved key,
   extending a running map nh, and map its image through `fnE`.
3. `fnE` was closed over the original h at `:1114`. It does not use the
   progressively extended nh. Return nh and the newly constructed V/H.
4. Rename the frame's bound variables after the saved-key fold. Use this
   resulting map for body/triggers. A let's defining value still uses h.

The support invariant makes this total on `t_subst_types` inputs. h covers
every free variable in every saved image because it covers V. The freshening
map is injective on those variables: unchanged types retain their old symbol;
changed types get distinct fresh symbols, assuming the transported Ident
counter does not wrap. Thus renaming V cannot collapse two positive counts.
The mapped images' support is contained in the renamed V. Bound and saved
key renaming is kept separate from free-variable renaming, even when an old
identity occurs in more than one of those roles. Structural induction gives
well-typed output and preserves saved support and positivity.

All stored term occurrences are visited once, including triggers and every
saved image. The generic mapper preserves term constructors and binder-map
cardinalities; it does not open and flatten the binder. Its output denotes
the ordinary capture-avoiding type/symbol transformation of its input.
Term attribute copying is retained. Physical record reuse is not assumed.

The same mapper has explicit `Tcase` and all five native pattern rows
(`Pwild`, `Pvar`, `Papp`, `Por`, `Pas`). Each case branch applies the same
V/H rule, separately type-renames its pattern-variable set, maps the pattern,
and maps its body using the extended map (`:1130–1136`). The packet implements
this generic context row and checks its shape. **It does not extend the
accepted substitution or candidate gate to cases.** Its composed
`ty_subst` interface rejects a case anywhere in its stored input. Generic
mapping preserves case-freedom when it is present and preserves existing
cases when it is absent; mapping is no proof that an entire imported context
was case-free.

## Demand recurrences and owner transport

Count occurrences over the actual stored input, recursively including all
saved images. Let N be term occurrences; K saved entries; B bound-variable
slots (including distinct pattern variables per case branch); P pattern
occurrences; F the root's cached free-variable cardinality. Let A be typed
application occurrences, X variable-term occurrences and C constant-term
occurrences. For one `t_subst_types` call:

```text
generic term visits = N;
generic pattern visits = P;
gen_fresh_vsymbol attempts = F + K + B;
Ident increments = number of those attempts whose type changes;
outer type-callback requests = F + K + B + P + X + C + A.
```

Repeated variable/type occurrences count repeatedly. F callbacks occur in
`gen_mapV` **before** the public generic mapper creates its
`Wty.memoize 17` wrapper. The remaining callbacks share that one local
ephemeron table. The wrapper's lookup count is `K+B+P+X+C+A`; its successful
set count is at most that number, without a no-GC premise. Each independent
root gets a new table. There is no once-per-module or once-per-type credit.

For `ty_inst` on a resolved canonical type, count all callbacks as misses for
the purpose of bounding its work. Each callback visits the old type's syntax;
each old `Tyapp` occurrence requests `Ty.Hsty.hashcons`, including nullary
and unchanged applications (`ty.ml:126–128,234–236`). A `Tyvar` lookup returns
its image without recursively substituting inside that image. Consequently
the sum of old `Tyapp` occurrences over those callbacks bounds Hsty requests
and hence new tags. This bound does not claim that every lookup misses or
change the native canonical-type equality used by the freshening test. The
still-live input type remains available for canonical equality when the
result is unchanged. Cloning's different type callback needs its own bound;
the generic mapper only supplies its callback multiplicity.

Feed the same Ident history through free-variable freshening, saved-key and
bound-variable freshening, the accepted term substitution, and later opening
or gate operations. Similarly add every Hsty request to the existing Hsty
history. The [cut-C provider](retained-main-entry-capacity.md) supplies
populated upper histories, not empty tables or a renewed counter. For its
current accepted R56/R78 maximum, Ident enters at most 27,104,344 and Hsty
at most `floor(135521724/3)`; intervening construction must be included before
using a later endpoint. The exact-role/configuration relation remains
required. Proposed #206 timing configuration is not included.

The packet's map/local-byte fields are only the reused kernel charges and
the explicitly recorded map operations. **They are not a complete native
byte bound for this new mapper.** Generic constructors' type checks, pattern
set construction, callback frames, Hsty and ephemeron backing requests still
need their source/native request consumers. The request recurrences above
make those consumers concrete; an arbitrary 4,096-byte charge on every new
function would not establish them.

## Source callers attached by this unit

For a nontrivial `cty_apply`, stage 4 maps every precondition, every
epsilon-closed postcondition and every exceptional postcondition list
(`ity.ml:1480–1489`). Put
`r = |pre| + |post| + sum_x |xpost[x]|`.

- If the source-computed final `same` test holds, there are r ordinary
  `t_subst` calls and no generic-map tables. The test includes identity
  type-variable substitutions even when an earlier Ity comparison differed.
- Otherwise there are r `t_ty_subst` calls and r local generic-map tables,
  with the recurrences above evaluated separately on each stored contract.
- The earlier `same && vl=[]` return (`:1473`) bypasses stage 4 entirely;
  stage-1/2 work already executed is not refunded.
- Saturation and empty oldies remove the remaining-formal and oldie
  freshening loops, as established in the accepted Main typing frontier.
  The actual map is still constructed from program pvsymbols and then
  mapped to fresh `t_var` records at `:1471`; its images are leaves.
  Type matching, result/effect instantiation, freeze operations and their
  temporary maps are separate stage-1/2/3 demands.

These rules attach a **call's contract transformation**, not the number of
native calls issued by a source application. For example, overload resolution
may attempt several `Expr.c_app` candidates and catch failures before selecting
one; a count of resolved typed calls does not count those failed prefixes.

For context cloning, `clone_term` calls the generic mapper with `clone_ty`,
`cl_find_ls` and the supplied variable map (`pmodule.ml:672–678`).
`clone_cty` maps preconditions using `sm_args`, normal and exceptional
postconditions using `sm_olds`, after cloning actual formal and old variables
(`:893–915`). Apply the stored-support proof under the clone caller's
type-compatible, injective free-variable map. This makes the mapper's demand
and preservation rule available for both case-free contracts and case-bearing
context. It does not yet price `clone_ty`, routine/type construction or the
whole clone/declaration traversal.

## Remaining source-to-candidate joins

The [#185 construction](retained-main-vc-composition.md) deliberately denotes
opened typed terms and explicitly excludes native fixed-parser/typing
temporary allocations. Its termination argument and the cut-C carrier are
not substitutes for the missing stored construction. These are the concrete
remaining rows within the assigned boundary:

| Row | Required construction demand and domain attachment |
| --- | --- |
| Source/parser/type/declaration fold | Construct actual stored initial contracts through native closing, type inference, proxies, overload attempts and failures; account for types, symbols, attributes and strings. Separate fixed/imported case-bearing context from every contract actually passed into Main's VC construction. The invariant above supplies the saved-image part of the induction. |
| Native clone fold | Count all reached ordered units and instantiated type/symbol/cty builders, including case-bearing context records, callback type demand and old-return representative histories. `clone_term` is now available as a precise suboperation. |
| Candidate enumeration | Keep Main and each generated nullary Pterm/undefined-Pred `LDsym Cfun` candidate. Internal ignored Cfun checks are Par children, not extra candidates. Count construction before the gate even when a candidate is discarded. |
| k_expr / k_fun | Include pre/post opening, result/proxy allocation, implicit unit enrichment, invariant inspection, assignment maps, location/trace attributes and associated strings at their actual native sites. Accepted program-key U/H measures are not creation counts. |
| term_of_kode | Retain both unwind outputs: value first, then the closedness test and possible predicate unwind. A later `Exit` keeps all earlier work. Returning the original kode on failure does not erase those requests. |
| Reflow | Count construction before dead-continuation deletion and every mark/push temporary, map and continuation wrapper. The retained `3B+2` node bound alone does not count those requests. |
| SP/WP | Derive calls from actual outcome/read/write maps, distinguishing the special Let sequence and general sequence. Include adjustment/advancement substitutions, written-name freshening, quantifier/let simplifiers, attribute relocation, havoc and all temporary formulas. `Vc.ht_written = Hvs.create 17` is shared state (`vc.ml:1334`), not a new table per expression. |
| Selection | After those constructions, invoke the accepted `add_vc_decl` gate on the actual stored candidate with the transported owner state. Stop at entry to `mk_vc_decl`; its outer quantification, injection, matching and declaration creation remain beyond this unit's boundary. |

The next source proof must discharge these rows, rather than defining an
uninterpreted operator that says to count every helper. Successful source
closure requires both actual stored values and caller multiplicities; samples,
opened semantic sizes and source-constructed key unions are insufficient.

The single process-wide `e <= 2`, two save-entering callbacks and three saves
are unchanged. Physical resource premises, current language admission, Oracle
and source/tool pins are unchanged. This bounded result does not complete
#202 or #119, adopt #206 or start production #88–#94.
