# Complete Unit procedure refines to the unit model — 2026-11-22

The [focused check](evidence.json) proves that every computed result of the
complete typed Unit procedure executes the independently defined phased unit
model. It covers declaration initialization, prefix returns, object and routine
loop exits, partial failure metadata and the final acceptance test. All local
values and callee results remain arbitrary. The proof derives this execution;
it does not assume parser safety or a successful semantic checker.

The fresh axiom audit checked 20,877 declarations. Linux x86-64 used two Lake
workers and two threads per process within the host's shared eight-CPU budget.
The [index](index.json) records exact implementation and managed artifacts.
Earlier attempts found Boolean-normalization and local-alias rewrite issues;
their failed records remain in the managed history. The prior intermediate
loop simulation success is retained there as well.

Concrete native callee/source binding must still supply the progress/preservation
contracts that eliminate evaluator exhaustion. The already checked generic loop
and phased-unit totality theorems are not treated as instantiated native evidence.
Completion, Application_Statement interpretation, semantic decoding and the
original-Bundle safety/discharge endpoint remain open. This is focused validation,
not a complete integrated checkpoint or independent kernel replay. Selected
proof setting is Astra Max; live model/effort and token/cost telemetry are
unavailable. CLI memory was not updated.
