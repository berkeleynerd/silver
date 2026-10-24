# Independent reported-time provider review evidence

The [review report](../../reviews/review-reported-time-capacity-20261024.md)
accepts the bounded #206 provider at
`fd19cd4c3c4847795b04a2a194bf49ce52eacfc5`, including the #210 repair.
This directory contains only reviewer-owned evidence.

- `checkpoint.json` preserves the historical first-phase handoff at the initial
  `ae33d531d9` freeze. Its pending status is historical, superseded by the final
  report and receipt.
- `audit.py` is the new independent static audit. It verifies frozen files,
  source members/spans, the recipe/import graph and fixed lexical census,
  parser/wrapper attachments, allocation arithmetic, five concrete entry
  envelopes and discriminating interface cases. It imports only the two
  evidence arithmetic providers and an ELF reader; it runs no target or checker.
- `result.json` is the single passing final-audit receipt, including exact input
  identities, host, selected reviewer setting and available timing. Runtime
  model/effort confirmation and token/cost measurements are unavailable.

The audit ran once in 1.234037 seconds:

```sh
python3 -B docs/evidence/review-reported-time-capacity-20261024/audit.py \
  fd19cd4c3c4847795b04a2a194bf49ce52eacfc5 \
  /home/canto/src/github.com/berkeleynerd/silver/tmp/retained-tool-capacity
```

The command requires the author freeze as HEAD in its isolated checkout. It
accepts the external dependency root only after checking the exact accepted
native and entry-provider identities. Reproduction is not required to consume
the retained successful evidence when these inputs remain unchanged.

The complete source/control argument was reviewed separately from the audit's
identity and arithmetic checks. The report distinguishes the completed symbolic
provider from parent resource integration and future #88 production refinement.
