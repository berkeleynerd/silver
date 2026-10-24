# Contract-builder review — provisional finding

Author `49c18b7ef37967c8b6f486721fd006d61857a8fb` is **not yet accepted**.
One material source-correspondence finding remains in the declared failed
application-prefix partition. The accepted bridge and clone-caller reviews
are unchanged. No whole native-byte or source-to-VC conclusion is claimed.

Reviewed inputs are the appended contract-builder continuation of
[retained-main-construction-demand.md](../research/retained-main-construction-demand.md)
and its `contract-builders/` packet. The exact eleven input hashes and retained
source identities are bound by the [audit result](../evidence/review-main-contract-builders-20261024/audit-result.json).

## R1 — retain the map add of a failing argument candidate

**Severity: material; blocks acceptance of this packet's claimed failed-prefix
request bound.** This is a research-evidence defect, not a demonstrated change
to production behavior or an assertion that #119 has been completed.

[builders.py](../evidence/retained-main-construction-demand-20261024/contract-builders/builders.py)
at lines 406–409 walks and checks the formal/actual types before charging
`formal_actual_add`. For a one-formal candidate `u:int`, fresh actual `v:bool`,
and result `int`, `apply_same` raises `SourceFailure` and exports **no map
events and zero map bytes**. The independent audit reproduces exactly that
output; it does not infer it from the author's checker.

The pinned Why3 `src/mlw/ity.ml:1436–1447` instead has:

```ocaml
let vsb_add vsb {pv_vs = u} v =
  if vs_equal u v.pv_vs then vsb else Mvs.add u v vsb
...
apply gh same (match_v isb u v) (vsb_add vsb u v) ul vl
```

These are arguments of one application, with no sequential `let` placing
`match_v` first. In the right-to-left argument order, `vsb_add` allocates the
nonidentity `Mvs.add` before `match_v` raises `TypeMismatch`. A source argument
must cover that order, or supply a verified pinned-order/exclusion premise.
The Python fold silently selects the opposite order and its zero map subtotal
cannot cover that allocation. No OCaml/native execution-order experiment was
performed; the finding is a missing conservative envelope at the source
correspondence boundary, not a measured native allocation count.

The packet explicitly includes mismatching overload-candidate prefixes in its
application argument and asks to add every source-derived candidate prefix.
This cannot be dismissed merely because a useful selected call succeeds:
`src/mlw/dexpr.ml:1486–1489` folds candidates through `Expr.c_app`, catches
`TypeMismatch`, and continues. The newly supplied residual inventory leaves
candidate multiplicities open; it does not exclude the per-entry mismatch
work which this packet purports to bound. A concrete whole-Main overload
occurrence was not executed or measured for this review.

The repair criterion is narrow: bound the nonidentity map add for the
currently examined pair even when its type match fails, independently of
argument evaluation order; keep earlier pairs' spent work and exclude later
unvisited pairs. Add first-pair and later-pair mismatch diagrams and ensure
the failed prefix is not mistaken for later `Mvs.map` Tvar construction or a
completed cty. Preserve the existing successful-application, effect and owner
results. Alternatively, establish and document a source-attached exclusion
which removes these failures from the claimed partition and leaves them
explicitly required elsewhere. Do not silently narrow language admission.

## Other reviewed boundaries

No other material finding was identified in this bounded pass:

- The independent clone-only inventory reaches eleven originals, confirms
  all four executable definitions and preserves the other 58 origins. The
  complete token check agrees on absence of old/at, type variables, exceptions
  and ghost qualifiers in those originals. Accepted generated Main/exception
  and clone histories remain necessary premises; token absence alone is not
  the whole no-oldie/no-xpost argument.
- Successful ground-pure canonical matching gives `same=true`; this does not
  apply to distinct reference regions. Reference, polymorphic, partial and
  promoting application rows remain explicit residuals. The runtime source
  gate supplies regular operands; generated ghost callable lemmas are Cany.
- `create_cty` projects its result even for empty posts, preserves external
  state, and freezes actual region identities. The type-closure traversal
  includes dead saved images, triggers and unused quantified variable types.
  Singleton exceptional posts can open binders in the native source; only
  the complete empty-xpost premise excludes that operation here.
- `c_app` computes `cty_apply` before tuple replacement. Unit retains that
  discarded prefix, then requests two Hsty operations, one Hsity operation
  and one Ident registration. Its unused rho preid is present without a
  registration, and ordinary record constructors still query `fs_tuple_ids`.
  Repeated Unit entries continue the incoming owner histories.
- The set-submap comparison rectangles and temporary-node accounting agree
  with the source recurrence. The audit exercises 529 finite pairs of tree
  shapes; the source induction, not the finite cases, supports the general
  product argument. Nontrivial callbacks still need their own charge.

New Ity local helper/frame/closure bytes, lookup services, shared hashcons
backing and whole source-to-VC storage remain open. The request vectors must
not be promoted to complete builder bytes. Nonzero tuples include a possible
discarded newly constructed contract and remain required residual work.

## Evidence and handoff

One new [independent audit](../evidence/review-main-contract-builders-20261024/audit.py)
passed **2,711 assertions in 1.608728722 seconds** on Linux, including the
assertion that demonstrates R1's zero map subtotal. It binds eleven author
files, thirteen providers, two archives, thirteen complete source files,
45 spans and 115 anchors. It imports the author builder implementation as
the subject under test and thereby its accepted bridge/kernel providers;
no author or predecessor checker module/main was imported or replayed.
There was one audit attempt and no failed audit run.

Selected reviewer setting: **GPT-6 Astra / Extra High**; runtime confirmation,
token counts and cost unavailable. The measured review interval was
2026-10-24 05:57:55–06:02:11 UTC, **256 seconds**, excluding later report and
commit work; it is not whole-team time. The live harness goal was null.
The [receipt](../evidence/review-main-contract-builders-20261024/receipt.json)
records the checkpoint and unchanged scope.

Parent owns author repair activation, issue bookkeeping, integration and
publication. This provisional review owns only this report and its matching
evidence directory. No native/compiler/prover builds, GitHub or CLI-memory
writes, admission/tool/Oracle changes, or production #88–#94 work occurred.
#202/#119 remain open; one global `e <= 2`, two save-entering callbacks and
three saves remain unchanged.

| Round | Selected setting | Intended result | Achieved result / rework | Available evidence |
| --- | --- | --- | --- | --- |
| Contract-builder critical review | GPT-6 Astra / Extra High; runtime unconfirmed | Challenge closed request partition and source gates | R1 found in failed argument-prefix map accounting; author repair required | 256 s recorded interval; sole 2,711-assertion audit success in 1.608728722 s; tokens/cost unavailable |
