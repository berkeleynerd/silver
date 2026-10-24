# Review: Main Why stored-term kernel and candidate gate

2026-10-24 UTC. **Accept the bounded first #202 unit at
`3a9be892c22061dddac367eb2d5d636405207525`.** No material finding remains in
that unit. This accepts the conditional case-free substitution/closing/opening
request and integer transfer, including `add_vc_decl` selection through entry
to `mk_vc_decl`. It does not close #202, #119, or arbitrary-Main capacity.

## Exact target and review conditions

Reviewed the new
[research note](../research/retained-main-why-storage.md) and all eight files
in its [author packet](../evidence/retained-main-why-storage-20261024/README.md).
The [independent receipt](../evidence/review-main-why-storage-20261024/result.json)
records SHA-256 identities of those nine exact inputs. Source review used the
retained Why3 revision `9390baf120ef260547dfa14f08e11c890b203d9c`, the packet's
two archives, and the provider versions named by its manifest. It did not
replace the existing selected source/native/runtime relation with a new
installed-binary or build-history claim.

This was an owner-authorized independent review under #119, in the separate
`review/main-why-storage-20261024` worktree based on the target commit. Owned
paths are this report and its review evidence directory. Root retains issue,
board, integration and publication responsibility. No GitHub write, merge,
native capture, compiler, prover, Lean, solver, disassembler, author-checker
replay or predecessor-checker replay occurred.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime-confirmed model and
effort telemetry, token usage and monetary cost were unavailable. The live
harness goal read returned null. The first recorded UTC clock was 03:13:45;
the source review and successful audit were complete by 03:19:01, a measured
316-second interval that excludes subsequent report/commit work. The new audit
itself took **0.895582477 seconds**; its tool invocation reported 0.916547337
seconds. These are distinct elapsed measurements, not total team cost.

## Source correspondence and challenged cases

The review followed the actual source operations rather than treating the
Python model or branch-anchor checks as the proof:

- **Stored bindings and branch coverage.** `term.ml:739–781` restricts a
  substitution to the binder's cached free keys; recomputes the weighted
  cache; maps that restricted substitution over every old saved image; then
  joins rewritten old images on the left. The model preserves that order and
  left bias, and does not replace a saved image by its opened formula size.
  Ordinary lets also substitute their definition; the lazy binder update
  leaves the original body/triggers stored. Applications and all other
  supported ordinary nodes use their actual child walks. Variable lookup
  returns its image without recursively substituting that returned image.
  `Tcase` and patterns remain explicit unsupported input families.
- **Closing and opening.** `t_close_bound`, `t_close_quant` and the checked
  closing aliases have the stated cache/removal behavior and ordinary
  constructors. `t_open_bound` and `t_open_quant` insert one fresh variable
  for each bound slot. Quantifier opening reconstructs every trigger before
  returning the body. The checked epsilon alias supplies the type option
  that the author explicitly added to its selected record counters.
- **Actual owners.** `mk_term` and attribute-copy helpers allocate ordinary
  records despite the surrounding hash-consing comments. Substitution's
  lexical raw constructors do not invoke later type-instantiating aliases.
  `id_clone` reuses strings/type/location and unions existing attributes;
  `create_vsymbol` then registers exactly one identifier. This supports zero
  Hsdecl/Hsty/Hstdecl/Hstask/Hcpt/Hsattr requests for these selected routines,
  while preserving their existing owner histories and possible GC effects.
  It does not support a claim that the process heap is unchanged.
- **Map work and arithmetic.** The imported generic Extmap request lemma
  covers map internals, including temporary disjoint nodes and enumerators;
  callback term traversal and arithmetic are separately charged. The actual
  operations use valid map domains contained in their input-domain union.
  Successors and `height+2` comparisons are consequently covered by the
  conservative `d+3` guard. The height-zero disjoint temporaries are never
  passed to balancing. Occurrence multiplication and collision addition are
  recorded separately, including work later discarded. Nonnegative partial
  sums cannot exceed their completed coefficient. No cumulative byte bound
  is incorrectly treated as a native integer or a physical-memory cap.
- **Local allocation and sharing.** The retained native body/site census is
  an existing input, not a new capture. The 4096-byte helper allowance and
  additional list slots cover ordinary records, variants, local closures and
  list work; per-map envelopes cover map nodes/options/enumerators. Physical
  sharing can reduce actual requests. Overconstructing attribute-copy
  results preserves structure, cached counts and attributes, so the selected
  gate tests remain unchanged. Constant substitution returns the same object
  and avoids the otherwise unpriced numeric comparison arm of `t_similar`.
  The selected record counters are partial categories, not an alternative
  complete byte census.
- **Discarded candidate lifetime.** `vc.ml:1691–1708` first executes
  triviality and only then conditionally executes the annotation pass.
  `Term.t_any` uses the safe opening fold, including its let-definition and
  body/trigger ordering. Root annotation and Boolean short circuiting stop
  later work, but cannot erase earlier fresh identifiers or requests. One
  counter is carried across the whole preconstructed candidate batch. Real
  interleaved construction remains an additional transported demand.

The immutable stored-graph induction is adequate for this input family:
recursive substitution traverses existing stored-image edges; newly inserted
images are not recursively re-substituted in the same call; interpretation
drops the frame that resolved an image. Opening follows the finite interpreted
tree. These are reviewed source arguments with explicit validity and native
premises, not a machine-checked universal theorem supplied by the audit.

## New independent evidence

The [offline audit](../evidence/review-main-why-storage-20261024/audit.py) passed
**1,272 assertions**. It independently checked 2 archive identities, 15 complete
source files, 23 source spans and 12 providers. It confirmed that its run left
the author packet unchanged.

The new semantic check interprets saved environments eagerly with opaque
bound tokens and transports term attributes, then predicts the complete
candidate decision and fresh-identifier count. All 15 supported node kinds
were exercised in 300 repeated-substitution diagrams. The combined batch
carried the sum of independently predicted openings through one Ident owner.
This adds coverage beyond checking triviality alone: annotation transport and
its traversal stops affect the whole gate and its fresh counts.

Focused cases also checked a collision where an old saved key becomes live
again: its rewritten nonleaf image must win the left-biased union. A dead
unsupported saved image still fails the model's structural input check.
Two discarded quantified candidates pay eight increments, reaching the exact
Ident endpoint from `max_int-8` and failing from `max_int-7`.

The arithmetic fixtures use small, constructively closed shared graphs with
large valid cached multiplicities. They reach the actual kernel product site
with `2^30 * 2^31` (safe) and `2^31 * 2^31` (unsafe), and construct the exact
`max_int` cache before reaching a real `max_int+1` collision sum. They do not
merely call the ledger arithmetic methods directly or require an enormous
expanded tree. The failing guards are model diagnostics under conditional
premises; they are not new language-admission rules.

## Remaining boundary and disposition

The note correctly limits the same-type `cty_apply` corollary to its leaf
specification substitutions. Type matching, effects, reads, different-type
substitution and input-contract creation are outside that corollary. The
source-to-typing/kode/SPWP number of entries, generated/nullary/discarded
candidates and full current-Main case-free attachment remain open.

The inspected control path confirms cut C after controller construction and
driver loading, before `add_file` reaches JSON parsing and typing. Its content
independence retains fixed effective argv/config/plugins/loadpath/path/
existence/fresh-session and native premises. No populated six-owner vector at
C is supplied by this unit. The fixed-process prefix endpoint includes Main
work and cannot be transferred to arbitrary Main by subtracting final live
observations. A new prefix ledger or a proved matching restriction remains
necessary; configuration changes must preserve or rederive its premises.

The installed-source/runtime relation, current grammar/frontend/type
premises, sufficient physical memory/stack/disk and the one process-wide
`e <= 2`, two callbacks and three saves remain intact. No production #88–#94
work, Oracle amendment, tool/pin change, useful arbitrary-Main failure payload
provider or completed admission guard is claimed. No additional finding issue
is requested by this review; retain the existing open #202/#119 obligations.

| Round | Selected setting | Intended result | Achieved result / rework | Available evidence |
| --- | --- | --- | --- | --- |
| First #202 exact-freeze review | GPT-6 Astra / Extra High; runtime telemetry unavailable | Challenge native storage, integer, owner and gate correspondence | Bounded interface accepted; no author repair or repeated audit | Source/audit interval 316 s; audit 0.895582477 s; tokens/cost unavailable |

No CLI memory write was made. The review commit adds only the report and its
evidence; it leaves the author freeze and all unrelated files unchanged.
