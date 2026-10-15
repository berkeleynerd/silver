# For loops and integers

Authorized on 2026-10-15 by the owner's request to set this milestone as the
goal, update its label and drive it to completion. The live goal and conversation
title identify this work. Parent [stage #10](https://github.com/berkeleynerd/silver/issues/10)
and [milestone 1](https://github.com/berkeleynerd/silver/milestone/1) track delivery.
The [roadmap](../roadmap.md#for-loops-and-integers) records the ordered packages.

## Scope and completion

The motivating programs are Rosetta's
[Colour bars/Display](../rosetta/c/colour-bars/display/silver.md) and
[Loops/For](../rosetta/l/loops/for/silver.md), including nested bounds that read an
enclosing loop index. Determine explicit integer types, expressions, operators,
loop forms and permitted compositions from their semantics and automatic proof
requirements. No new form is supported until the specification, catalogue,
native implementation and complete universal/actual-source assurance agree.

Deliver executable samples and boundary/composition regressions, a stable native
Linux full proof audit/build/test checkpoint and complete cached Lean validation,
independent semantic review, synchronized Rosetta progression and evidence, and
the authorized commits and GitHub tracking. Source preservation and complete
obligation discharge remain mandatory. Existing 4096-byte source/value limits
remain unless an explicit justified change is needed within this capability.

## Design work in progress

Resolve integer representation and overflow/range rules, loop bounds and nesting,
name scope, empty/reverse ranges, interactions with mutable Strings and input
guards, termination and resource bounds, and the exact native report classes.
Use isolated GNATprove probes to understand generated checks; examples do not
establish universal assurance. Neither prover success nor a tool timeout defines
language membership. Document concrete reasons for exclusions.

The existing predicate model has String bindings, length facts and finite branch
sequences. Its semantic, obligation and actual-source models must all grow with
the native recognizer. Updating source certificates alone is insufficient.

## Evidence and recovery

Baseline/review start: `343c2f8f5a`. Implementation branch:
`feat/for-loops-integers`. Host: Linux x86_64, established with
`python3 scripts/dev.py paths`. No capability validation has run yet.
Exploratory evidence is under `tmp/for-loops-probes/`; the running checkpoint is
`tmp/for-loops-integers-active.json`. Existing caches and unrelated scratch remain
intact. macOS validation, hosted CI and independent kernel replay are not claimed.
