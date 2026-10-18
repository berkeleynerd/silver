# Independent review: retained Why3 inlining operational demand

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: changes required for one material scope finding.** The packet
provides useful captured-input inventories, request arithmetic and conditional
table transfers. It does not yet establish its advertised local stored-term
and hidden-work transfer through task validation. A declaration hashcons hit
can return an older representation whose delayed maps are outside the captured
input envelope. The acknowledged cost of comparing old objects does not cover
the subsequent use of the selected old object.

This finding does not establish an observed native overflow or show that the
1,145 identifier increment is false. It requires an additional, currently
uninstantiated representative premise for the affected operational bounds.
Complete transformation, preparation and whole-pipeline capacity remain open.

## Exact inputs and method

Reviewed freeze: `b68756eea4daae31f221eb72eefb9d40665d7b70`, based on
`28697404fa1971ed310d19a7ab434e593ca2b075`, on the worker branch
`research/why-inline-operations`. Review used the initially clean isolated
branch `review/why-inline-operations-b68756eea4`; the target worktree was not
edited. This report is the only owned file.

The complete new target is the
[research note](../research/retained-why-inline-operations.md) and
[evidence packet](../evidence/retained-why-inline-operations-20261018/README.md):
`README.md`, `compose.py`, `inventory.py`, `inventory.json`, `result.json`,
`inputs.json`, `check.py`, `round.json` and `sources.tar.gz`.

I reused the accepted
[entry review](review-why-preparation-entry-7c89b21e24.md) at
`7c89b21e2489d984bdabcae3d5bd88a6dd38e2b8` and
[semantic-refinement review](review-why-inline-refinement-3509848447.md) at
`35098484475dbb2da7a0e663194c2251abb8d1a1`. The retained graph is
1,490,344 bytes, SHA-256
`d7f49ce0181875434292f228c3d599c8c8157b3d1f0ac6793f0d12c2558184be`.
No capture, installed-instruction audit or successful predecessor suite was
repeated. Applicable AGENTS, Oracle, assurance/trusted-boundary and review
bookkeeping requirements govern this bounded review. The child goal was null.

Source inspection used the archived complete files at Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
`8eb41f72ded84df884c3671734c947f612091f84`. The new archive is 103,401 bytes,
SHA-256 `1c33b259040cee14ba1c9babd10ae223fb66a06a560629794b432d069328dd07`.
Relevant files include `inlining.ml`, `term.ml`, `decl.ml`, `task.ml`,
`theory.ml`, `trans.ml`, `ty.ml`, `pattern.ml`, `ident.ml`, `hashcons.ml`,
`hcpt.ml`, `weakhtbl.ml`, `extmap.ml`, `weak.ml` and `ephemeron.ml`.
Source references below are to those archived versions. Relevant-source/runtime,
well-formedness and noncolliding-identifier assumptions remain premises.

## Material finding: selected hashcons representatives enter later traversals

The source chain is explicit:

1. `decl_map` reconstructs a logic or proposition declaration
   (`decl.ml:621–634`). `create_logic_decl` performs termination checking and
   then calls `mk_decl` (`:526–535`). Except for a goal, `mk_decl` calls
   `Hsdecl.hashcons` (`:411–419`).
2. `Decl.Hsdecl` compares logic definitions and propositions using
   `t_equal_strict` (`decl.ml:350–366`). This is equality through alpha-binding
   and delayed-substitution frames; it is not equality of stored binding maps.
   `term.ml:266–281,325–379` follows entries reached from raw variable leaves.
   It does not enumerate or compare every `bv_subst` key. Strict hashing uses
   the same frame interpretation (`term.ml:441–510`).
3. `Hashcons.Make.hashcons` returns the object returned by `WH.merge`
   (`hashcons.ml:41–45`). A hit therefore replaces the new candidate with the
   preexisting representative. `Weak.Make.find_or` returns that old live
   object after equality succeeds (`weak.ml:272–294`).
4. `inlining.ml:64–76` subsequently inspects the returned declaration with
   `get_used_syms_decl`, may open its definition for eligibility/environment
   storage, and may pass it to `Task.add_decl`.
5. `Task.add_decl` reaches `known_add_decl` (`task.ml:147–165`), which runs
   used-symbol checking and `check_match` (`decl.ml:699–709,821–826`).
   Used-symbol traversal opens logic formals and folds stored values
   (`decl.ml:518–524`, `term.ml:596,1177–1205`). Match checking independently
   opens the returned representation's binders (`decl.ml:741–748`).

Thus the old object is a downstream input, in addition to being an equality
comparand. The packet's initial eight saved entries describe the captured
logical roots. They do not describe every older declaration that the shared
table could return after mapping changes a formula. The packet supplies no
projection or source invariant establishing such a bound for selectable old
representatives.

### Why strict equality does not supply the missing representation bound

A variable-only specialization of the real substitution rule suffices. Begin
with a quantified body `forall z. P(x0)`, with `z` distinct from all `xi`.
Repeatedly substitute `xi -> x(i+1)` into that body. At each step,
`bv_subst_unsafe` restricts the new substitution to the current free-variable
map, rewrites every old saved value, and unions in the new entry
(`term.ml:764–778`). After `n` steps the inner binding has:

```text
bv_vars  = { xn : 1 }
bv_subst = { x0 -> xn, x1 -> xn, ..., x(n-1) -> xn }
raw body = P(x0)
```

Every saved value is a variable leaf. Opening yields `P(xn)` regardless of
`n`. Closing `xn` as an outer formal produces the same alpha-bound formula
as the corresponding clean representation of `forall xn. forall z. P(xn)`.
With the same symbols, types, locations and empty attributes, strict equality
and hashing do not distinguish these representations. This construction uses
the substitution and closing rules; it does not rely on corrupt maps or
colliding identifiers. It also remains valid for a logic definition formed
with that formal and body.

A focused Python specialization of the variable-only recurrence checked 37
successive substitutions. It produced 37 saved keys, each with one-node value,
and one semantic free occurrence, exceeding the exported `K = 36`. The
argument is parametric in `n`; the small check is only an arithmetic and
recurrence sanity check. It is not a native Why3 experiment, nor evidence that
this particular historical representative was selected in the captured run.
Its purpose is to show why equal opened formulas and well-formedness alone do
not imply the claimed stored-map bound.

### Affected exports and minimum correction

The finding affects at least the following assertions when applied to all
downstream representations of the invocation:

| Export | Frozen bound |
| --- | ---: |
| Delayed map entries | 36 |
| Opening substitution map entries | 50 |
| Stored occurrences per formula | 21,483 |
| Hidden recursive substitution entries/updates | 88,982,586 |
| Free-variable scan entries | 52,907,301,372 |
| Symbol/type validator stored-term entries | 8,292,438 |

The last four depend on the missing stored-representation envelope. Their
derived type-fold and immutable-map work also needs that premise. Merely
adding equality-callback cost to the already documented old-comparand residual
would not repair these downstream bounds.

The minimum safe interface correction is to make the stored/hidden operational
bounds conditional on an explicit envelope for every declaration representative
that `Hsdecl` may return. The envelope must include the representation and
relevant inventory/semantic invariants required by later openings and folds,
then propagate through those operations. An alternative is a source/process
argument proving that all selectable representatives satisfy the existing
envelope. Until that premise is instantiated or proved, the packet must not
set `local_structural_and_registration_transfer_established` to true or state
that the local operational transfer is established through `Task.add_decl`.

The pure shared counter, weak-table and ephemeron callables can be retained.
The map-only witness does not refute the six opening-site count, the 1,145
identifier increment, or the registration/request arithmetic. Those results
should be retained under their stated semantic/inventory premises, separately
from the unresolved stored-representation claim. No new native run is required
to make this scope correction reviewable.

## Other reviewed arguments

The following source and arithmetic work remains useful; acceptance of these
parts is not acceptance of the unresolved representative premise:

- **Captured delayed maps and mapper ancestry.** The inventory explicitly
  includes all eight initial entries, checks that the two nonunit keys occur
  in none of the eight values' free sets, and checks binder-free values with
  at most one free occurrence. For objects derived only by the stated mapper
  and independent validators, the `8 + 2*(8+6) = 36` argument pays for original
  ancestor keys and two renaming ancestries. Validators do not chain their
  opened results into one another. The gap occurs at representative selection.
- **Opening and registration sites.** The six outer-formal sites are the
  declaration mapper, termination check, inlining used-symbol guard, candidate
  opening, task used-symbol check and match-check declaration fold. The
  accepted kernel contributes 235 registrations, formals contribute
  `6*123`, and full termination/match body openings contribute `4+168`, giving
  1,145. The extra twelve branch openings in match checking must remain in
  the substitution-start charge. Nullary patterns and nonempty scrutinee lists
  avoid both pattern compiler variable-creation branches. `id_clone` itself
  constructs a pre-identifier; `create_vsymbol` performs registration.
- **Declaration validators.** Reused type/data/parameter declarations still
  pass through task validation. The packet correctly separates sixteen data
  revalidations from zero data-constructor calls, and includes the ground-type
  dependency traversal in positivity/foundedness. The nonrecursive singleton
  termination path creates two empty `Hid` tables per definition.
- **Type and request accounting.** The accepted 156 hit-body nodes plus 67
  free-formal keys, with type occurrence size three, give 669 recursive
  instantiation/hashcons requests. The memo wrapper covers term traversal;
  free-variable type instantiation is outside that memo. Declaration, theory
  and task requests are bounded by 143, 244 and 512. The Patricia allowance
  is `64*(192+42+34) = 17,152`; these are history insertions under `add_tdecl`,
  not recursive `use_export` calls.
- **Fresh caches and shared backing.** The selected goal bypasses the two
  enclosing `Trans.store` caches. The metadata and fold caches are newly
  constructed; the goal is not inserted into the latter. Ephemeron `replace`
  adds at most one entry and uses the same resize threshold as `add`.
  Cleaning precedes growth, supporting `max(initial_array,4*N)` under the
  callable's valid-initial-state premise. The weak-table transfer separately
  charges inherited cleared slots and the possible inherited-table resize;
  rehashing uses cached hashes. Both transfers expose pre-saturation arithmetic
  and retain representation conditions. They do not instantiate shared state
  or establish aggregate/runtime allocation capacity.

## Evidence and review round

The author's successful offline check is reused: `python3 -B
docs/evidence/retained-why-inline-operations-20261018/check.py`, recorded as
passing in **0.261118 seconds**. I read its replay, counter boundary,
ephemeron-clearing and malformed-delayed-value checks. It cannot detect the
finding because it does not model representative substitution by the shared
declaration table. No full successful replay was rerun.

The only new computational concern check was the variable-only recurrence
above, passing in **0.000190 seconds**. Source inspection supplies the link
from that recurrence to hashcons selection and later consumers; no Python
simulation is presented as machine-checked OCaml semantics. Report checks
are limited to local links and `git diff --check`.

Selected reviewer: **GPT-6 Astra / Extra High**, assigned by the parent.
Independent runtime model/effort confirmation and token/cost measurements are
unavailable. Actual host: Linux 7.0.14, x86_64. New native capture, compiler,
prover, debugger, server, solver, build, proof or full-suite runs: **zero**.
No GitHub write or CLI-memory update occurred. The parent owns repair,
integration, publication, issue status and durable memory. Earlier review
reports remain unchanged historical records.

Intended outcome: challenge hidden paths, registration/request groups,
delayed-map closure and shared backing at the frozen endpoint. Achieved
outcome: one material returned-representative scope finding, with a bounded
interface repair that preserves reusable evidence. Review timing below
excludes the later commit and parent integration/publication.

Review interval: `2026-10-18 21:02:19 UTC` to `2026-10-18 21:12:54 UTC`,
635 seconds through report preparation and local-link checks. The parent
acknowledged the material scope gap and owns its correction; this report
assesses the original frozen target and does not pre-approve that repair.
