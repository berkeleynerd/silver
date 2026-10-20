# Fixed-goal attribution evidence, 2026-10-20

R54 author base: `3754303d5969b92364b4a19e356de6afc34f07ab`.
Scope: #119/#153 research; prospective #88 only. The
[research note](../../research/retained-fixed-goal-attribution.md) gives the
source argument, conditional protocol and open joins. R53's sealed adapter
protocol was independently accepted at this base; R54 is a separate review
target, not a replacement review of R53.

Run from the repository root:

```
python3 docs/evidence/retained-fixed-goal-attribution-20261020/check.py
```

The checker prints results and does not rewrite pinned files. The recorded Linux
x86_64 run passed 378 counted assertions plus the internal graph/layout/binding
assertions, in 6.155259 seconds. It validates 48 exact source slices, rereads
the five retained raw forests and compares the resulting labels/root map with
frozen outputs. It checks 6,747 distinct binder records for the variable-only
substitution lemma. It does not rerun native alpha opening; review of that
restricted lemma remains part of source correspondence.

The projection establishes 118 registered roots (116 nontrivial), 47 checks and
161 raw forest nodes. These are registration facts, not scheduled-attempt counts.
The concrete two-goal Is_Message name/location collision is retained. The
finite protocol examples cover all six three-request finish orders, multiple
already-finished solvers behind the one-F gate, FIFO/head-of-line behavior,
queued cancellation without S, non-Done events, wrong prover/unknown goal,
duplicate F, unsolicited Done, missing ack and frontend death. They also retain
the S→Running deadlock and ungated arrival-order counterexamples. The formatter
exercise checks the 91-byte minimum Done JSON against the fresh formatter's
78-column pending threshold. These executable exercises supplement the source
argument; they are not a native runtime trial or a universal protocol proof.

- `inputs.json`: author/source identities and pinned packet/context files.
- `source-witnesses.json`: exact archive/member/slice identities and text.
- `projection-inputs.json`: five captured archive identities, their 25 consumed
  members and accepted goal-certificate identity.
- `project.py`: raw graph projection, parent/root/argv checks and restricted
  binder-image checks. Its direct invocation verifies existing outputs.
- `raw-goal-labels.json`: each captured goal's raw identity, extracted check
  labels, triviality and registration inputs.
- `fixed-root-map.json`: domain-local goal→check/root-index projection.
- `projection-result.json`: retained first successful projection summary and
  timing; subsequent checks do not rewrite it.
- `check.py`, `result.json`, `round.json`: focused checker, observed author result
  and lightweight work/review boundary record.

The source candidate requires `-j>1 --logging`, fresh/private log identity,
unique original request IDs, unchanged stock tools, CE off and fresh Per_Check
forests. Only completion delivery is gated; solver launches and native execution
remain concurrent. The captured serial forests are not yet transferred to that
changed startup/logging configuration. F-message byte capacity, aggregate
response/log/history/control storage, prefix allocations, failure/abort paths
and the whole-rule capacity join remain open. No output/solver limit, identity
time tag or production implementation is introduced. The per-process
two-callback/three-save/e≤2 budget is unchanged.

No GNATwhy3, solver, proof, capture or broad predecessor replay ran for R54.
Successful R53 evidence is reused at its accepted conditional scope. Review
must assess this exact finite map and source protocol while keeping runtime
transfer and the full q outside the closed claim.
