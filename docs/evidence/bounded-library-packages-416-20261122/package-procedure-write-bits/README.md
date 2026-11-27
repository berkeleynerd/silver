# Original actual-list write bits

The focused `Silver.ApplicationPackageProcedureWriteBits` check passed on Linux
x86-64 with a fresh 12,689-declaration audit. [index.json](index.json) retains the
run and captured inputs; their hashes matched before retention. Two workers,
two Lean threads per process and 8192 MiB were allocated. Dependencies were
cached; no complete feature check or independent kernel replay is claimed.

The original source actual-list trace now retains every exact write-mask update.
For each live mask bit, the final value is the original callee write effect or
the written-state field of an actual row. The existing complete formal permutation
and final row retention move this result from source order to formal order,
including named and empty lists. Target identities and the source layout remain
separate links; this theorem assumes no semantic safety certificate.

Three drafts exposed overloaded monadic-bind normalization, redundant rewriting
of an already eliminated payload, and local simp lint details. Their failures
remain in the managed history and task diagnostic. No native source, domain or
trust assumption changed. Selected GPT-6 Astra Max; runtime model/effort and
cost/token measurements were not independently exposed. Phase timings are retained.
