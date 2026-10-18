# Three fixed library path calculations

Offline evidence for [the source argument](../../research/retained-producer-fixed-paths.md),
#119, 2026-10-18, Linux x86_64. No compiler, Why3, solver or Lean execution.

`identity.json` pins the complete three native inputs in the existing
`retained-producer-bodies-20261018/inputs-and-outputs.tar.gz`, the relevant
current library files, and inspected sources retained in the earlier
fixed-check-spines and main-types archives. No evidence relies on `/tmp`.

Run from the repository root:

```text
python3 docs/evidence/retained-producer-fixed-paths-20261018/check.py
```

The checker validates those identities and traverses each complete native
body with the outcome-aware recurrence in the source argument. It includes
every native assertion, Any_expr precondition, Abstract_expr body/postcondition
and loop invariant. Every call receives a conservative two-leaf charge.
Its call-symbol list describes the accounting walk, not runtime call counts.
It rejects unsupported expression/predicate shapes, exceptional call effects,
branching call arguments, escaping Abstract_expr outcomes, additional context
program bodies and changed expected totals. It confirms array bool_eq has no
GP_Inline attribute and the marked in_range definitions have two leaves.

`result.json` records body routes/check budgets, postcondition costs, loop
components, check labels and response composition. The checker implements
the source-derived arithmetic, not Why3's transformations. It is not a
mechanized proof of the source-to-task argument. The independent review's
scope and the remaining capacity domains are stated in the linked record.
