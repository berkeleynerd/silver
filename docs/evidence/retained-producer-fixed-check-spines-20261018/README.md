# Two fixed library check-path joins

Offline evidence for [the source derivation](../../research/retained-producer-fixed-check-spines.md),
#119, 2026-10-18, Linux x86_64. No new compiler, Why3, solver or Lean run.

`identity.json` identifies the complete inspected Why3 sources, current library
sources and two complete emitted JSON inputs in the existing
`retained-producer-bodies-20261018/inputs-and-outputs.tar.gz`. That older native
capture used a disabled backend; no solver results underlie these bounds.

`python3 docs/evidence/retained-producer-fixed-check-spines-20261018/check.py`
checks these identities and the selected native shapes, including every
Abstract_expr, Any_expr and assertion in each entity body. It checks the
fixed native context has no additional program body. It records the source
derivation's terminal-task bounds (1 and 3) and response-record bounds (1 each).
The record is not an execution of Why3's SP/WP or splitting implementation and
does not mechanically prove the source argument. Is_Message's third task is a
conservative allowance for an annotated True helper postcondition.
