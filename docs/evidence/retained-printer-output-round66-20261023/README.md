# R66: reviewed selected request-output and formatter operands

2026-10-23 UTC, Linux x86_64; #119 / #153. The
[independent review](../../reviews/review-printer-output-20261023.md) accepts
author `b5aad6d57b2f215ac047edb931314812c6687905`, review
`32fdc06f27eeb71ac29d4c861d74f3a3af2bd6b1`, under retained premises.
[inputs.json](inputs.json) fixes those exact files and the accepted R65 input
attachment. The scoped [source argument](../../research/retained-why-printer-output.md)
supplies per-request text/events, fresh Format/Buffer operands, individual
solver-input file extent and a separate shared-stderr fragment.

All fifteen case/driver applications fit. The largest individual file bound is
96,048,951,340,887,500 bytes, below the selected maximum string length. This is
a conservative mathematical representation bound, not observed output or a
physical-resource guarantee. Buffer's temporary doubling may reach 2^57;
the source clamps it before allocation. Cumulative files/helpers are not treated
as one Buffer, formatter or native operand. The three driver rows are
alternatives within each process's single episode allowance; integration exports
their identical stderr fragment once, without renewing or summing the budget.

The new fresh-formatter drain theorem requires every break to be inside a user
box, or a stream without breaks. The actual Driver outer box and final internal
flush supply that lifecycle. A system-scope-break counterexample refutes the
unrestricted draft theorem and remains in the evidence. The historical
small-stream and shared-formatter theorems are unchanged. Review also required
the one-placeholder count for selected integer literal templates and the actual
`Pp.sprintf = Format.asprintf` alias. All three source-argument repairs precede
the accepted freeze.
They are tracked as [#166](https://github.com/berkeleynerd/silver/issues/166),
[#167](https://github.com/berkeleynerd/silver/issues/167) and
[#168](https://github.com/berkeleynerd/silver/issues/168), technically repaired
and In review pending draft delivery.

One successful independent audit passed 429 checks in 20.230005 seconds over
45 source ranges, 18 complete members and all fifteen arithmetic rows. Its
10,001 selected finite Format streams support the source argument; no universal
proof by testing is claimed. An initial reviewer extractor mistake and repair
are recorded separately. The previously accepted name/attribute source review
was attached in 0.023011 seconds without replay or self-review. Root
[integration](integration-result.json) passed in 0.505572 seconds, retaining
94 native source pins and the installed Why identity. No component checker,
native compiler, solver, capture or broad proof was rerun for integration.

Remaining: private printer maps/containers, formatting accumulator layout and
structural recursion, complete shared stderr/report composition, and the wider
startup/failure/output and full current-grammar rule. The stderr contribution
is 64E text bytes and 8E events for each process's existing E; it must join the
existing whole-interval owner. Ordinary physical stack, memory and I/O
sufficiency retain the existing trusted boundary. No aggregate resource gate
is introduced. Whole-printer/process capacity and #119/#153 remain incomplete.

Author/reviewer selections and measured scopes are in [round.json](round.json).
Oracle, tools/pins, current admission and the one global e<=2/two callbacks/
three saves remain unchanged. Production #88–#94 is unstarted and PR #121
draft/unmerged. The next two source lanes own private maps/containers and
formatting accumulator/layout respectively; their work is not an R66 claim.
