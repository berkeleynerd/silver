# Original writable actual targets

The focused `Silver.ApplicationPackageProcedureActualTargets` check passed on
Linux x86-64 with a fresh 12,703-declaration audit. [index.json](index.json)
retains the managed run and captured inputs; every captured source hash matched
before retention. Two workers, two Lean threads and 8192 MiB were allocated.
Dependencies were cached; no complete feature check or independent kernel replay
is claimed.

Each final physical actual row retains the result of `stateTarget` at that
actual's original payload position when writable, and zero when input-only.
Combining this invariant with the checked formal permutation and write-mask
trace gives the exact final mask: the callee's existing writes plus all explicit
writable source targets. Named reordering, empty lists and unfilled storage are
covered. Only source table bounds and the zero-position target equation are
required; semantic alias safety and complete metadata validity are not assumed.
The visibility/layout proof consumes this target relation separately.

The first draft needed two local simplification corrections; the retained
managed history records it. No native source, domain or trust assumption changed.
Selected GPT-6 Astra Max; runtime model/effort and cost/token measurements were
not independently exposed. Phase timings are retained in the evidence.
