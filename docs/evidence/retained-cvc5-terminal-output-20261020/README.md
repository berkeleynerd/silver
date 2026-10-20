# CVC5 terminal control and incomplete payload interface

The [note](../../research/retained-cvc5-terminal-output.md) derives a conditional
single-thread six-entry terminal count and names the remaining payload and
signal-point caller requirements. It does not export complete q/O.

```sh
python3 -B docs/evidence/retained-cvc5-terminal-output-20261020/check.py
```

`inputs.json` retains seven complete source-member identities and exact excerpts
from the existing CVC5 archive, plus accepted predecessor identities. The checker
checks those bytes and arithmetic; source review is necessary for the control
argument. It does not validate native signal behavior, thread count, pointer
state, safe numeric domains or the statically linked termination handler.

Lead-authored lane; actual runtime model/effort, isolated author elapsed time
and token/cost telemetry unavailable. No model switch is claimed. No native
target, solver, compiler, capture, proof or network run occurred. The selected
independent review belongs to the lead integration round.
