# Retained Debug Stats hook capacity

2026-10-20, Linux x86_64, research #119 / #153.

The [source argument](../../research/retained-why-debug-hook-capacity.md)
composes the accepted first-use state, timing growth, static format extension,
and formatter allocation/stack interfaces. `check.py` checks their exact result
bytes, projects source and native witnesses from retained inputs, compares the
selected instructions with the retained ELF, and evaluates the arithmetic.
It does not prove the semantic argument or run any predecessor checker.

Run from this worktree:

```sh
python3 docs/evidence/retained-why-debug-hook-capacity-20261020/check.py
```

`result.json` exports conditional source-owned bounds. `transfer.json` separates
new requests, the preexisting owned formatter/Buffer objects, output, individual
representation guards, and native caller stack. `native-control.json` identifies
the selected callers, callback targets, excluded branches and service frontier.
`source-witnesses.json`, `native-bodies.json`, `native-frames.json` and
`inputs.json` attach the argument to the retained inputs. `manifest.json` covers
packet files present when the check finishes, excluding itself and `round.json`;
the latter records check count, elapsed time and model-selection limitations.

No target execution, capture, disassembly, fetch, solver or full proof run is
performed. Numeric/allocation service success, runtime stack R, ambient A_pre,
physical sufficiency and complete exit/save capacity remain separate.
