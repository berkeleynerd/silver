# Independent semantic review — named scalar arguments #392

Reviewed on 2026-11-17, on Linux aarch64. Selected reviewer setting: GPT-6
Astra, Max, as specified by the lead and `AGENTS.md`; runtime model/effort,
elapsed review time, token usage and cost are not independently exposed to
this reviewer. The live harness goal returned `null`.

## Scope and disposition

**No findings in the reviewed semantic slice.** No implementation fix is
requested by this review. This does not establish completion of #392 or of
the unfinished native/actual-source integration.

Reviewed all 18 committed proof-module changes in `24bc775bc`, `78e61f3e2`
and `3983a1c9312237d8f2bd2c115bfc387d3c0a8395` against `bf285bc57`, in
`tmp/named-model-392`, plus the source author's uncommitted
`proof/Silver/PredicateProcedureCallFields.lean`. The draft's SHA256 is
`f999111c4a3cec1072ad36dcd0b6e1f60bcb1812c92e4851b742bd2301f76ed7`.
The review covered the owner's named/reordered/mixed scalar-call scope,
Oracle requirements, `docs/named-scalar-arguments.md`, and the relevant
language, assurance, trusted-boundary and review guidance. It was read-only
apart from this scratch report.

## Semantic checks

- **Exact formal coverage and labels.**
  `PredicateAssociationAdmission.lean:27` resolves against the called formal
  slice through the existing case-folded `Named.equalName`. The named-state
  transition rejects a positional actual after a named association. The
  source traces retain formal indices and fresh selections; their exact
  lengths and bounds establish a permutation of the complete formal slice
  (`ScalarAssociations.lean:54`, `PredicateFunctionCallReadings.lean:311`,
  `PredicateProcedureCallReadings.lean:269`). The argument does not assume
  unique metadata spellings. Arbitrary duplicate spellings retain deterministic
  first-match behavior; selected indices still cannot repeat.
- **Payloads and frame binding.**
  `ScalarAssociations.lean:130` proves a permutation of whole keyed entries,
  preserving each payload with its formal. The default payload cannot be
  introduced on a complete trace. Function checking consumes the resulting
  formal-order keys (`PredicateFunctionCallMeaning.lean:66`). Procedure
  checking permutes paired formal models and actuals together
  (`PredicateProcedureUpdatesMeaning.lean:284`), retaining mode/domain and
  target identity. All payload readers use the same incoming flow; neither
  Boolean outcomes nor preceding output updates refine a later input.
- **Selectors and actual reads.**
  `PredicateProcedureCallAdmission.lean:71` replays associations and runs the
  existing lexical exclusion only over payload spans. Its exception requires
  the exact writable payload's start and endpoint. Strictly increasing source
  endpoints (`ProcedureNameActualReadings.lean:148`) prevent any other actual
  from using that exception. The replay-to-reader proof retains real payload
  reads, including preceding inputs, and derives semantic separation
  (`ProcedureNameActualsApart.lean:47` and `:71`). Selector/value-name collisions
  therefore do not become spurious reads or erase actual reads.
- **Source-order updates and formal-order meaning.**
  `PredicateProcedureUpdatesMeaning.lean:88` proves disjoint abstract updates
  commute, and `:124` transports the meaning through paired permutations.
  This preserves output domains and input/output formal bindings. The
  unchanged `ScalarProcedureAliasing.lean:120` supplies concrete copy-back
  order independence once the new source proof has established separation.
  The updated count, flow-readiness, assignment-flag, body-shape, String-bound
  origin and draft stable-fields proofs preserve their existing conclusions.
- **Domains.** Resolver, cursor and trace proofs keep explicit premises; there
  is no new metadata-name-uniqueness premise or restriction to sampled values.
  Total definitions retain failure/default behavior on malformed helper
  states. The added start/bounds premises on `ProcedureUpdatesAt.meaning` are
  discharged directly at its call consumer. This checks the Lean semantic
  domains, not the source author's still-unfinished native helper contracts.

## Evidence and limits

Inspected retained focused run `20261117T024754-5841dfd88330` in
`docs/evidence/named-scalar-arguments-392-20261117/model`. It records successful
selected targets and a fresh transitive module/axiom audit of 314 modules and
26,420 declarations, with only `propext`, `Classical.choice` and `Quot.sound`.
It used cached dependencies and is not a clean rebuild or independent kernel
replay. At 2026-11-17 02:55:51 UTC, I independently recomputed every one of
the 1,119 manifest input hashes: none were missing or mismatched. All 19
reviewed proof modules, including the draft fields module, appear in the
recorded audited import closure. I did not rerun Lean or native proof jobs.

The inherited restricted Ada-to-Lean interpretation, trusted external
tool/completion assumptions, and local Lean-cache boundary remain as documented
in `docs/trusted-boundary.md`; these are not new defects introduced by the
reviewed changes. Final native source correspondence, complete helper-contract
checks, full integrated native/Lean assurance, producer observations, boundary
and behavioral regressions, and delivery-document consistency remain the
lead/source author's integration scope and were not certified by this review.
