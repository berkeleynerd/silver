# Adapter outcome-interface evidence, 2026-10-20

Author base: `43f0e9871bb78374dc75af5ed411eea52558dcdf`.
Scope: #119 / #153 source-level design, prospective #88; no implementation or
completed q claim. See the [research note](../../research/retained-adapter-outcome-interface.md).

Run from the repository root:

```
python3 docs/evidence/retained-adapter-outcome-interface-20261020/check.py
```

The checker reads only retained local archives and packet inputs, verifies 42
exact source slices and R51 canonical-table imports, and runs a finite protocol
model. It checks all 64 truncation lengths for each of 31 rows, every two-chunk
split and required EOF, malformed/extra/conflicting records, 30 legal
cross-channel S/F/record/EOF/cancel orders, every canonical write/close failure
prefix, queued cancellation versus actual adapter completion, abnormal child
versus adapter completion, duplicate/late defects, AND/OR loser policy, and
wire/path bounds, the unselected Unknown-only payload length, and the final
producer-closure/control-drain/audit-seal barrier. It includes a duplicate queued
after local V publication but before report completion, and required supervisor
seal receipt/proxy completion. The recorded run passed 9,898 assertions in 0.194277 seconds.
Native PID/signal ABI validation is explicitly a separate required predicate;
`decode_structure` is a structural wire check, not a Linux ABI validator.
The checker is an executable specification exercise, not source correspondence,
a SPARK proof, a complete raw-diagnostic recognizer or universal attribution.
Re-running changes only `result.json`'s elapsed-time field when inputs match.

- `inputs.json`: author base, retained source archives, imported R51 freeze and
  issue #88 identities; no external fetch.
- `source-witnesses.json`: archive/member/slice hashes and exact source text.
- `canonical-table.json`, `loaded-response-directives.json`: byte-identical
  imports from R51 author commit `57901cea8ad2c62f1ad9205cc048b8a994e362b2`.
- `check.py`, `result.json`: focused finite checks and actual author result.
- `round.json`: selected model/effort, actual work and measurement limitations.

The leaf binding result is deliberately limited: request IDs bind to the
correct Why3 attempt internally. The stock final report lacks that identity.
Debug-save-vcs passes a path into the scheduled call but does **not** store it
in fresh automatic proof_script/session XML. Uniform evidence cohorts can
justify conditional attribution; mixed resource/unexplained H cohorts remain
ambiguous without another source-proved relation. Possible source-hook fields
in the note identify missing information; modifying Why3 is outside the
unchanged-stock constraint and is not selected.

The source argument corrects R51's implication that these warnings necessarily
reach `.spark` `warn_error`: the retained SPARK consumer prints them. Warning
presence is retained without inventing a rejection rule.

No native, solver, proof, capture or broad predecessor replay ran. The full q,
original request-ID no-wrap, aggregate queue/control/path storage, raw launch
output, and complete unsuccessful-report join remain outside this packet's
closed claims. Captured serial evidence is not evidence for J>1. The single
per-process two-callback / three-save, e <= 2 budget is unchanged.

Review amendment preserves historical freeze
`fbc95b00cb66a239a84e88bdddb20bb2056ecf38`. The R53 reviewer identified the
report-before-queued-duplicate race and an overbroad ABI validation implication.
This amendment adds the final audit seal and separates structural decoding from
native-fact validation. No new source corpus or native execution was needed.
