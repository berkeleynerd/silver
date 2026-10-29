# Scalar guard frontend repair — 2026-10-29

The owner authorized repair of [blocker #284](https://github.com/berkeleynerd/silver/issues/284).
The current published response target is `88c127b631`, stacked above #266.
This isolated work changes neither published PR while external review proceeds.
The blocker remains open; no repair or complete validation is claimed yet.

## Confirmed counterexample

The independently reconstructed 167-byte source is:

```ada
with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer:=0;R:Integer range 0..9:=0;begin if X>=0 and then X<=9 then if X=99 then R:=X;end if;end if;end Main;
```

The delivered compiler accepts it and GNATprove proves all 67 checks, then native
compilation fails at `R:=X` with “value not in range” and “Constraint_Error would
have been raised at run time”. Removing the inner contradictory guard gives a
passing control. Managed probe `20261028T222332-125b175a567b` retains both outcomes;
its success means the expected rejection/control contrast was observed, not
successful compilation of the counterexample. Exact local evidence was retained
outside `tmp` at `.silver/linux-x86_64/review-guard-frontend-20261028/`.

All 131 compiler source files matched the reviewed response tree. The external
reviewer's original source was unavailable; this is an independent reproducer.
The responsible `Refine_Or_Keep` rule dates to PR #242, before arrays and foreach.
Its runtime-containment theorem is sound for the unreachable outcome, but that
does not establish the pinned frontend's acceptance of the source.

## Investigation and completion criteria

Trace the native compiler's condition-based substitution and compile-time
constraint checking, including grouped/reversed operands, false outcomes,
short-circuit conditions and existing loop/array compositions. Compare a
minimal pinned frontend correction with an explicit admission correction; do
not select a change from one passing sample alone. Preserve source identity,
runtime meaning and every required check.

The repair must include its actual-source/configuration correspondence,
targeted admission/compilation regressions and independent review. Complete
native and Lean/source/module/axiom checkpoints remain mandatory before merge,
after applicable external feedback is integrated. Unchanged successful evidence
is reusable only under the existing input/dependency rules.

| Round | Selected settings | Result and limits |
| --- | --- | --- |
| Initial reproduction, 2026-10-28 | Astra / Extra High for bounded read-only rule/history review; lead runtime settings unavailable | Array-free failure and passing control reproduced with unchanged compiler options. No source repair or full project proof run. |
| Frontend rule and repair design, 2026-10-29 | GPT-6 Astra / Extra High for each of two bounded threads | In progress: pinned producer mechanism, smallest correction and proof impact. No selected repair yet. |

Selected settings are not independently confirmed runtime settings. Token/cost
measurements are unavailable. Detailed probe times belong with their evidence.
