# Complete typed Completion procedure — 2026-11-22

The [focused check](evidence.json) passes the whole typed Completion execution
equation for arbitrary local stores, callee results and evaluator bounds. It
composes checked signature-prefix, local-loop, output-read, output-append,
body-dispatch, function-return and named-footer equations. Every return retains
the exact partial store. The output reads precede output-formal appends, scoped
bindings are restored and the loop index's outer binding is restored on exit.
The exact complete Completion/Unit token candidate passed unchanged.

The fresh axiom audit covered 21,058 declarations. Linux x86-64 used two Lake
workers and two threads per process within the shared eight-CPU budget. The
[index](index.json) records exact implementation and original managed artifacts.
The prefix and final body equations had earlier successful focused checks;
the final run reuses matching objects and freshly audits the complete target.
Earlier failed rounds concerned negative guard normalization, reserved Lean
identifiers and removal of the interpreter's trailing no-op continuations.
Their evidence and diagnostic notes remain in the managed history. No native
source, contract domain, rejection path or obligation was weakened.

This establishes the complete typed local-store equation. Refinement to the
independent Completion reader model, the guarded Routine_Frame callee, concrete
source/callee contracts that eliminate exhaustion, Application_Statement source
interpretation, semantic decoding and original-Bundle assurance remain open.
Source-token proposals alone are not authoritative source binding. No complete
integrated assurance or independent kernel replay is claimed. Selected proof
setting is Astra Max; live model/effort and token/cost telemetry are unavailable.
CLI memory was not updated.
