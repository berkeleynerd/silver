# Basic procedure source reading

The focused `Silver.ApplicationPackageProcedureReading` target passed on Linux
x86-64 with a fresh audit of 32,747 declarations. [index.json](index.json) retains
the run, captured input identities and artifacts. Source hashes matched before
retention. Allocation: two workers, two Lean threads per process, 8192 MiB.
Dependencies were cached; there was no independent kernel replay.

The Basic procedure arm now constructs its original-source call and actual/target
reading, retaining its completion-order identity and exact preceding effect row.
The accepted native call supplies readable arguments, formal binding, copy-in,
copy-out and alias checks, followed by explicit-target and visible-global reset
flow. Semicolon parsing and the final progress guard preserve that flow. The
source-only argument relation has no caller-supplied semantic safety/checker
certificate. A separate endpoint equality covers successful and rejected calls.

The first draft omitted rewriting the rejected call-stage equation in the zero
endpoint branch. The second focused check passed after that local correction;
no native source, input domain or trust assumption changed. Semantic statement
composition still needs original layout/reset membership and declared ranges;
recursive statements, initializer inventory, routine/Main aggregation and external
automatic completion remain open. This is a focused development result, not
complete feature assurance. Selected GPT-6 Astra Max; runtime model/effort and
token/cost measurements were not independently exposed. Phase timings are retained.
