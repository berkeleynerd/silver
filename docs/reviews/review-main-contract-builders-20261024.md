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

## R1 repair disposition — 2026-10-24

**R1 / #213 is fixed in author repair
`93fdabb2232e0fc7fe2fd7c39f167c1985991f5a`. The repaired contract-builder
request partition is accepted within its stated scope.** The provisional
finding above remains the historical disposition of the original author
freeze; its report text and evidence have been preserved. No other material
finding arose in this narrow repair review. #202/#119 remain open.

The review workspace applied that repair as
`43d4bfc5f81a061546990b52539f3f57ac402d0b` over original review
`7fe4a33a75b5ed9346ca5cff4f72b14aa8bcf511`. The
[repair audit result](../evidence/review-main-contract-builders-20261024/audit-r1-result.json)
binds all fifteen frozen author inputs, the six preserved author evidence
files, three preserved original review artifacts, and the three source spans
used for this delta. The repaired builder SHA-256 is
`cb7f1233cb6033f0b7c07de81c82a4071d04aaadac27a2a38eb86500558d3778`.
All thirteen provider identities and both retained archive identities agree
with the unchanged manifest.

The source correspondence argument now closes the reported gap. At a first
failure at pair j, earlier pairs have completed both sibling argument
expressions before recursion advances. The current `vsb_add` either runs
before `match_v` fails, or is skipped when the match runs first. Charging
its nonidentity add in both cases bounds either order. Identity pairs add
nothing. The recursive callee for pair j is never entered after failure,
so later pairs are absent; `ity.ml:1449–1471` does not reach cut/oldie tuples
or `Mvs.map` Tvars, and `expr.ml:841–844` does not reach tuple lookup or
Capp/cexp construction. `dexpr.ml:1486–1489` still catches the candidate
failure; accumulated demand must therefore survive to subsequent candidates.
This argument uses source sequencing, not an assumed target evaluation order
or a native execution experiment.

The complete builder AST differs only by moving the existing add block ahead
of the existing type walk and failure test. On successful matching those
operations commute: the add changes the substitution map and map ledger,
while the successful type walk changes visit counts and does not inspect the
substitution map. Their inputs, resulting counts and downstream code remain
identical. This establishes the narrow success-preservation argument rather
than relying solely on unchanged samples. All ten original exports, including
the successful effect/owner diagrams and the earlier failure diagrams, remain
byte-identical in their original file. The author's retained 299-check result
also compares those exports; that checker was inspected, not replayed.

One new [focused independent audit](../evidence/review-main-contract-builders-20261024/audit-r1.py)
passed **524 assertions in 0.448912709 seconds** on Linux x86_64. Its 52
failure diagrams vary first/later failure, identity prefixes and aliased
actuals. It independently reproduces both new author exports, checks exact
map subtotals and absence of downstream records/owners, and exercises two
caught failures followed by a selected call without losing spent demand.
These finite checks challenge the executable fold; they are not the universal
source argument. There was one audit attempt and no failure. The original
2,711-assertion audit, author checker and predecessor checkers were not rerun
or imported. Only the builder under review and its existing bridge/kernel
implementation dependencies were imported.

This acceptance does not price new Ity helper/frame/closure bytes, lookup
services, hashcons backing or nontrivial callbacks. Remaining builder site
partitions and source-derived candidate multiplicities still need their
source folds. Complete native bytes, complete Main classification and whole
source-to-VC storage remain open, including the other already recorded
construction/continuation obligations. Physical tool, resource, I/O and
completion premises are unchanged. One global `e <= 2`, two save-entering
callbacks and three saves remain unchanged; no new allowance is introduced.

Selected reviewer setting: **GPT-6 Astra / Extra High**; runtime model/effort
confirmation, tokens and cost unavailable. The captured review interval was
2026-10-24 06:08:04–06:10:53 UTC, **169 seconds**, covering the later source
inspection, repair application and focused audit; it excludes initial
inspection before the first clock reading and subsequent report/commit work.
It is not whole-team time. The live harness goal was null. The
[repair receipt](../evidence/review-main-contract-builders-20261024/receipt-r1.json)
records these limits. No native/compiler/prover/Lean runs, GitHub writes,
CLI-memory updates, production changes, Oracle/admission/tool changes or merge
occurred. Parent owns issue disposition, integration and publication; next
required work is integrating this accepted delta and closing the remaining
builder/helper/native-byte and full source-to-VC obligations.

| Round | Selected setting | Intended result | Achieved result / rework | Available evidence |
| --- | --- | --- | --- | --- |
| R1 repair review | GPT-6 Astra / Extra High; runtime unconfirmed | Establish current failing-pair map envelope and preserve accepted scope | R1 fixed; repair accepted; no further material delta finding | 169 s captured interval; one 524-assertion audit in 0.448912709 s; tokens/cost unavailable |
