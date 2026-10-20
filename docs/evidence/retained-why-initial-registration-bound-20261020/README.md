# Initial registration bound: retained-input checks

See the [source argument](../../research/retained-why-initial-registration-bound.md).
This packet joins five existing prefix captures to an initial identifier/type
cardinality bound. It adds no target execution or production behavior.

`debugger-signal-defaults.json` records one target-free query of the exact GDB
binary pinned by both capture plans. `source-witnesses.json` and
`native-bodies.json` retain the newly inspected code; `inputs.json` identifies
their dependencies and exact selected capture members. `result.json` contains
the five derived applications, conditional on the documented existing source,
runtime, debugger and retained-prefix relation.

Run `python3 -B docs/evidence/retained-why-initial-registration-bound-20261020/check.py`.
This checks identities and arithmetic only; it does not prove the semantic
argument, replay earlier checks, query GDB again or execute the target.
