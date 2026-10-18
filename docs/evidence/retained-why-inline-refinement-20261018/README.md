# Refined bound for the frozen inlining entry

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
See the [source argument and scope](../../research/retained-why-inline-refinement.md).

```sh
python3 -B docs/evidence/retained-why-inline-refinement-20261018/check.py
```

Replay is source-only and offline. It reuses the immutable first-entry capture
and its full source/driver/input verification; it launches no native target,
server, debugger, compiler or solver.

`refine.py` interprets the opened input graph, retains types and binding scopes,
tracks source-eligible symbols in declaration order, and uses formal-occurrence
weights at matching application sites. Optional hit/miss choices cover every
`inline:no` exclusion set, whose exact payload was not captured. Eligibility
must be uniform across those choices; ambiguous eligibility, self-reference,
unsupported declarations and type mismatches fail closed.

`compose.py` exports the compact conditional result and the detailed mapped
root/eligibility/hit record. `inputs.json` pins the exact frozen graph and
predecessor artifacts; all used Why3 sources are retained in the predecessor's
`sources.tar.gz`. `details.json` includes ordered root coordinates, symbol
identities, every eligibility decision and every weighted hit calculation.
`result.json` retains the numerical bounds and explicit unclosed obligations.

`check.py` compares the complete outputs, exercises 156 concrete exclusion
scenarios, and checks formal/trigger duplication, capture avoidance, type
instantiation, source eligibility edge cases and malformed input. The universal
all-exclusion claim rests on the inspected source induction, not those finite
scenarios. The source argument is not machine checked.

The maximum output root mass is 99, goal mass at most 73, and kernel fresh
variable identifiers at most 235. These conditional bounds cover one captured
pair. Complete hidden operational work, validators, counter/cache lifetimes,
all-pair preparation and whole-pipeline capacity remain open. No old astronomical
recurrence is evaluated by this packet.
