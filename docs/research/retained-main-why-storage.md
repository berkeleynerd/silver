# Main Why storage: substitution, opening and candidate selection

2026-10-24 UTC; first author unit of #202 under owner-authorized #119.
**The case-free substitution/opening kernel and the initial-VC selection gate
have a closed request/counter transfer. The source-to-initial-VC storage
composition remains open.** In particular this does not supply Main typing,
kode/SP/WP construction multiplicities or a populated pre-JSON entry state.
The [packet](../evidence/retained-main-why-storage-20261024/README.md) contains
the finite model, exact source/provider identities and focused checks.
Independent exact-freeze review is pending.

This unit counts work before `Vc.add_vc_decl` decides to discard a candidate.
It stops before the body of `mk_vc_decl`; outer quantification, type-invariant
injection and subsequent matcher/cast processing are later work. It also
exports the same kernel for the earlier contract/VC helpers that actually
call it. A request site's **number of entries** still needs its source-derived
caller argument. Merely naming this finite kernel does not supply that count.

The installed-source/runtime relation, current grammar/frontend/type premises,
physical memory/stack/disk premises, and one process-global `e <= 2`, two
callbacks and three saves remain unchanged. No aggregate RAM cap, demand
certificate, production implementation, tool option, Oracle amendment or
admission rule is introduced.

## Domain and state carried by the transfer

The input is an actual source-constructed immutable term graph with variable
identities, types, attributes, binding lists, bodies, triggers, `bv_vars` and
**every** `bv_subst` key/image. Shared subgraphs may be shared; accounting
counts occurrences when a helper visits them again. It does not collapse
terms that are merely alpha-equivalent or have the same printed formula.

The supported node family is `Tvar`, `Tconst`, `Tapp`, `Tif`, `Tlet`, `Teps`,
`Tquant` (both quantifiers), `Tbinop` (all four operators), `Tnot`, `Ttrue`
and `Tfalse`. Binder bodies, triggers and all saved images must satisfy the
same case-free family, including otherwise dead images. Bound/epsilon tuples
have one variable; quantifier tuples have a nonempty list. Types and existing
constant/identifier/attribute strings are retained immutable inputs. Input
maps are valid persistent maps; identities are unique before wrap; free-variable
caches have the native construction meaning; substitutions are well typed.

`Tcase`/patterns and foreign constructors are explicitly unsupported, not a
zero-cost row. The accepted [#178 typing transfer](retained-producer-typing.md)
excludes ordinary handler-generated Kcase, and #185 excludes an additional
all-solid type-invariant case family. Those facts alone do **not** establish
case-freedom of every source-dependent declaration contract, clone, saved
image and temporary formula. **Full current-Main attachment to this domain is
still open.** The executable gate entry rejects a case anywhere in its stored
input graph, even in a branch the particular gate would skip.

The owner input is an unwrapped Ident counter `I` attached to the real
process cut, with every input variable tag in `[1,I]`. The kernel returns an
Ident increment count `J`, a prospective endpoint `I+J`, request demand,
actual occurrence-arithmetic operands and native guards. A batch of
candidates carries the same counter through the entire batch; it never starts
a fresh counter at each candidate. The executable batch fixture has all inputs
preconstructed at its entry; a real interleaved construction must add its
intervening constructor increments before the next gate. The other hashcons
owner requests are zero
**for these functions**. Their insertion history and all pre-existing domain
and backing obligations are retained; allocation-triggered weak clearing is
not forbidden by a fictional unchanged-heap assertion.

The full intended interface remains

```text
initial_vc_storage(source, selected_config, source-derived entry_state)
  -> typed body/contracts, every candidate, retained f_j,
     owner-state exit, creation-demand vector, native guards.
```

This first unit supplies a subfunction on those actual term values, not that
whole interface. Its fixture input graphs and test counters are not Main
admission inputs, fixed captures, or evidence of a useful arbitrary-Main bound.

## Ordinary term records and actual owners

`term.ml:223–254` stores four fields in each term and a separate two-field
`bind_info`. The section title says “hash-consing”, but `mk_term:628–633` and
`t_attr_set/add/remove/copy:648–661` construct ordinary records. There is no
term `Hashcons.Make` owner to charge. Attribute sets are persistent maps over
existing immutable attribute tags; union does not call `create_attribute`.

`Mvs` is `Vsym.M`; `MakeMSHW` selects `Extmap.Make` with identifier-tag
comparison (`term.ml:22–30`, `wstdlib.ml:87–99`). It is not Task's Patricia
Hcpt. In particular `Mvs.set_disjoint` allocates temporary truncated Nodes
in its unequal-root branches (`extmap.ml:477–485`); its Boolean result does
not make it free.

Pure `t_subst`/`t_subst_unsafe`, `t_vars` and closing binders create no
identifier, type, declaration, tdecl, task, Hcpt or attribute identity.
`fresh_vsymbol`, reached by opening a binder, creates exactly one identifier
per opened slot: `create_vsymbol` invokes `id_register`, whose only counter
operation is `incr r` (`ident.ml:187–192`). `id_clone` alone creates a preid,
reuses the original string/type/location and unions existing attributes.
`Weakhtbl.create_tag` is the identity function on the integer tag. Thus the
kernel has no hidden tag allocation or fresh-string family.

The unsafe substitution definitions lexically call the **earlier raw** term
constructors, before their later checked aliases. Its public wrapper checks
substitution image types through physical `ty_equal`; it does not instantiate
types. `t_attr_copy` uses `t_similar`, whose term children are compared by
pointer, not alpha comparison. Constants are returned unchanged and hit its
`s==t` fast path; substituting a constant for a variable takes the different
node-kind arm. The numeric-constant comparison arm is therefore not reached
by this kernel. These distinctions justify zero Hsty/attribute requests and
exclude an unpriced type traversal or arbitrary numeric comparator.

## The request fold

Reuse the accepted
[persistent-map request lemma](retained-why-save-shape-builder-allocation.md#a-cumulative-extmap-request-lemma):

```text
M(n,m) = 4096*(n+m+1)^3 direct bytes.
```

It bounds the selected operation's own nodes, tuples/options, enumeration
cells, fixed closures and set-wrapper callbacks on maps with `n,m` keys.
Nontrivial callbacks are charged separately. The proof charges split/join
spines and at most `n+m` union/inter/diff pivots; disjoint's temporary-node
comparisons occupy disjoint rectangles of the Cartesian key product.
This unit imports that theorem and its native/provider identities without
replaying its checker or redoing its fixed-process proof.

The new fold uses actual map cardinalities at each request, not one whole-program
scalar. It charges the following sequence at an updated binder
(`term.ml:738–779`). Let `V=b.bv_vars`, `H=b.bv_subst` and input `m`:

1. Charge disjoint on `(m,V)`. A disjoint result returns the old tuple.
2. Charge inter to obtain `r = m restricted to dom(V)`. Charge diff to
   obtain `S = V without dom(r)`.
3. Charge `fold2_inter(V,r)`. For each `(v,image)` in `r`, separately evaluate
   and charge `t_vars(image)`. If `V[v] != 1`, charge its scalar map and every
   product. Union that weighted map into `S`, charging the union and its sums.
4. Charge `map(H)` and recursively substitute **r** into every old image,
   including dead keys. No leaf-only assumption is made here.
5. Charge `set_union(rewritten_H,r)`. The native union keeps the **left**
   rewritten-old value at a duplicate key. Allocate the new `bind_info` and
   reached binder tuple, retaining the original body/triggers.

A substituted `Tlet` separately visits its definition. An epsilon/quantifier
updates the binder record without descending into the bound body or triggers.
An application maps its child list; ordinary conditionals/binary/not nodes
visit their corresponding children. A variable performs one lookup and one
attribute-copy attempt; it does not recursively substitute into the returned
image. The empty-map wrapper returns immediately. Every attribute-copy attempt
is charged for a possible ordinary term record and attribute union, even when
native sharing returns an old object. Overconstructing that result preserves
its node structure, attributes and binding maps. It can only overcharge these
selected helpers; it changes no selected gate test.

`t_vars:605–624` has its own fold: variable singleton; union over ordinary
children; existing `bv_vars` at a binder. It does not traverse a saved image
unless the caller specifically asks for that image's variables. Consequently
neither the substitution traversal nor its free-variable callbacks are
replaced by a final formula-node count.

For local non-map work, reserve `4096` bytes per source helper visit, with
additional slots for application child-list cells and opening's bound/trigger
lists. Nontrivial recursive calls receive their own visits. The retained
native site census has, for example, total reservations `208` for
`t_subst_unsafe`, `64` for `bv_subst_unsafe`, `40` for `t_attr_copy`, zero for
`t_vars`, and `72` for `t_open_quant`; `mk_term` costs `40`. These are body
site sums, not measured dynamic counts. A visit's fixed constructors and
immediate wrapper group fit the conservative allowance. Existing map callbacks
and fresh-symbol wrappers likewise fit it; list recursion is charged per
cell, not once for an unbounded list. Gate callbacks add only their fixed
closures and nullary `FoldSkip` control, which fit one such allowance. No
source branch in this unit creates an array, string, buffer, arbitrary-width
integer or variable-sized object. Each individual direct request is fixed
size, bounded by the same 4096-byte local ceiling; map Nodes and list cells
are smaller. Cumulative bytes may greatly exceed a machine integer: that sum
is mathematical accounting, not a native field or physical-memory cap.

`kernel.py` returns both this direct-byte upper bound and selected ordinary
record/list candidate counts. The latter deliberately exclude map internals
and closures, whose complete own request envelope is already in M/local
bytes. No double-count subtraction is used. Compiler/native service, GC and
physical resources retain their accepted separate premises.

## Native arithmetic and storage induction

All demand arithmetic is mathematical. Actual native scalar operations in
these selected helpers are the Ident successor, map-height arithmetic and
the occurrence counts in `vars_union`/`add_nt_vars`. For an updated binder,

```text
V' = (V without dom(r)) + sum_(v in dom(r)) V[v] * FV(r[v]).
```

The sum is pointwise and nonnegative. The fold records each actual product
and every collided-key addition, including products used only for a result
subsequently discarded. Every partial sum is bounded by the corresponding
completed coefficient, because no later step subtracts from it. The same
argument applies to `t_vars`' child unions. Before the first violation, the
native tagged operations equal these natural-number operations if all recorded
operands/results are at most `max_int = 2^62−1`. This supplies the multiplicity
arithmetic obligation that the earlier fixed save-allocation bound explicitly
did not claim. It is not inferred from the final retained goal.

For each persistent-map operation let `d` bound the union of its input domains
(the executable uses the conservative sum of their cardinalities). All
intermediate valid-map key domains are subsets of that union, including
split/join reconstruction. Heights are at most `d`; temporary disjoint
nodes use height zero and are never balanced. `d+3 <= max_int` covers the
selected height successors and `height+2` comparisons. Fresh identifiers
satisfy `0 <= I` and `I+J <= max_int`. All direct object headers are constant
and fit the retained ordinary-header limit `2^54−1`; the packet conservatively
checks a 512-word envelope. None of the selected list traversals computes an
integer length; finite list structure and physical stack remain their own
premises. No fictitious list-size counter is introduced.

The proof is mutual induction over the constructive stored graph:

- A new close computes FV and removes the bound keys, with empty saved map.
  Each direct request is charged before returning the binding.
- Ordinary substitution follows the source cases above. Recursive calls on
  old saved images follow edges in the immutable input graph. Returned images
  are not recursively substituted. New saved-map entries refer to existing
  input images, so the output remains finite and acyclic.
- The displayed coefficient equation preserves the semantic cache relation.
  The old-image rewrite and left-biased union preserve delayed simultaneous
  substitution. All source requests occur in a charged helper or callback.
- Opening freshens each bound slot once, inserts a leaf in the old saved map,
  then substitutes into the body and **every** trigger. It returns the opened
  terms and carries `I+J` forward. Original strings/types are reused.
- Interpreting a binder by its body/triggers and its saved images is finite.
  As in `Term.descend`, looking up an image drops the frame that owns it;
  images do not recursively re-enter the same substitution frame. The
  constructive acyclic graph plus finite frames supplies a finite fully
  interpreted tree. Gate recursion descends that tree; it does not iterate
  source loop executions.

This is a source argument under valid-input and native-behavior premises.
The Python checks test diagrams and boundary operands; they are not a
machine-checked universal proof. In particular their structural validation
cannot manufacture the source-derived typing/cache premises for an arbitrary
caller-created `Binding`.

## A useful leaf substitution corollary

For leaf-only input `m`, every new saved image is one variable. Old images may
still be nonleaf: the transfer rewrites them in full. Let `R(t)` count term
occurrences through all ordinary children, binder bodies/triggers and **all**
saved images. For each updated binder occurrence let `k_b=|r_b|`. Then

```text
R(subst(m,t)) <= R(t) + sum_updated_binders k_b.
```

Ordinary node reconstruction preserves one output occurrence per input
occurrence. Rewriting an old image satisfies the same induction. The union
can add at most `k_b` leaf images, while duplicate keys only reduce it.
No exponential multiplier on whole-program storage is needed for this edge.
The sum includes binder occurrences reached inside old saved images.

Leaf renaming also preserves total free-variable occurrence mass at each
updated binder: it redistributes existing nonnegative coefficients among
new variable keys. It need not preserve the maximum coefficient, because
several source keys can rename to one key. The exact sum/product guard remains
valid, or the pre-update total mass can supply a sufficient bound.

This corollary applies to the actual specification substitution in the
same-type branch of `Ity.cty_apply:1436–1489`: its formal-to-actual values are
program variables converted by `t_var`. Saturated ordinary calls and empty
oldies remove the remaining-formal/old-value loops under the accepted #178
premises. **This is not a complete cty_apply demand result**: type matching,
effects, read sets, optional different-type `t_ty_subst`/Wty work and the
creation of its input contracts still need their own caller/owner account.
No inherited saved image is assumed leaf-only without that account.

A source-kernel witness explains why the stored state cannot be dropped.
Start with `forall z. P(x0)` whose saved map is empty. Apply `x0->x1`, then
`x1->x2`, and so on through `x12`. The opened term always has three nodes;
its free cache always has one key of count one. After twelve calls the binder
contains twelve saved keys, all ending at `x12`, and the stored term count is
fifteen. Dead entries are rewritten even though opening uses only the original
`x0` occurrence. This is a constructive kernel witness, not a claim that a
particular accepted Main follows exactly those twelve calls.

## The candidate gate, including discarded work

`vc.ml:1691–1711` selects a candidate using

```text
if is_trivial_vc f && not (has_attr annot_attr f)
then drop else enter mk_vc_decl.
```

The transfer follows native short circuiting. True is trivial; let and forall
open then recurse into their bodies; implication tests only its consequent;
conjunction tests left then right; conditional tests both result arms.
Other supported nodes are nontrivial. A nontrivial result skips `has_attr`.

The annotation test uses `Term.t_any`, hence the **safe opening fold**
(`term.ml:1284–1299`), not a read-only walk over stored nodes. It can therefore
register the same binder's variables again after triviality checking already
opened it. For a let it opens the body **before** testing the definition.
For a quantifier it substitutes into every trigger before testing its body,
even if an annotation in the body then stops the traversal. Triggers ignored
by `is_trivial_vc` are still reconstructed by its `t_open_quant` call.
A root annotation stops the annotation pass immediately; a nontrivial left
conjunct stops triviality before a later right binder. Both optimizations are
preserved, while all preceding requests remain charged.

The focused witness feeds the same two-variable quantified True candidate
twice, with one trigger. Both candidates are dropped, yet each pays two fresh
variables in triviality and two more in annotation traversal: eight Ident
increments across the batch. Neither a retained-goal count of zero nor a
counter reset per candidate would cover this work. The construction of those
input candidates remains outside this gate charge and must be added by the
source-to-kode/SPWP caller account.

## Entry cut and remaining composition

The bounded read-only entry review identifies cut C immediately after
`Gnat_checks.init_cont` creates its controller (`gnat_checks.ml:396`) and
before `Controller_itp.add_file` (`:399`). Controller construction completes
all selected driver loads (`controller_itp.ml:114–137`). `add_file` reaches
`Session_itp.read_file` and then the native JSON converter's
`Yojson.Safe.from_channel`, Gnat AST/Ptree conversion and Typing
(`gnat_ast_to_ptree.ml:1382–1410`). C is independent of Main **contents** only
with fixed effective argv/config/plugins/loadpath/path/existence/fresh-session
and native-behavior premises. Selected configuration remains an input; a
changed driver timing recipe changes this prefix state and cannot inherit a
frozen empty timing-list assumption.

No inspected accepted provider supplies populated six-owner dimensions at C.
The [import closure](retained-producer-import-context.md) and six
[startup constructions](retained-producer-startup-vcs.md) are reusable inputs,
not a complete native constructor/backing ledger. A fresh session starts its
own counters/tables empty; that says nothing about populated Ident/type/
declaration owners. The retained `Exn_printer__entry` facts precede those Why
owners' initialization. The full fixed-prefix `W=86,632,681` endpoint includes
JSON typing, VC and session construction for the five exact fixed processes.
It cannot be transplanted to changed Main or turned into a startup vector by
subtracting unrelated final live observations. A new source initialization-to-C
ledger, or a separately proved restriction of a matching cumulative prefix
bound, is still required. No such restriction lemma is claimed here.

The remaining #202 obligations are explicit:

- Derive all actual stored input graphs and kernel call multiplicities from
  the admitted source/declaration fold, including generated nullary candidates,
  failed extraction, both extraction outputs, reflow deletions and SP/WP
  temporaries. Complete the supported-family attachment or extend the kernel.
- Account for typing/cty/type-instantiation/proxy/clone requests, attributes,
  strings, declarations and all actual memo owners, including hits, misses and
  discarded candidates, with one transported owner history.
- Join C's populated source-derived entry state and every other native scalar
  family. Retained #178/#185 U/H/terminal-size projections are useful semantic
  measures but are not these missing creation counts.
- Continue through outer quantification/type injection, preparation, request
  printers, callbacks, saves and the useful arbitrary-Main failure-payload
  provider, reusing #153 results only at matching process cuts.

Selected author: GPT-6 Astra / Extra High. Entry-cut inquiry: selected GPT-6
Astra / Extra High, read-only bounded review. Runtime model/effort telemetry,
token use and cost are unavailable. The packet records focused check time;
no native/compiler/prover/solver or predecessor-checker replay occurred.
