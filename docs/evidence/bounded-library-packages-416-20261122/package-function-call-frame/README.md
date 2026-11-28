# Input-only function call frame

The focused Linux x86-64 check of `Silver.ApplicationPackageFunctionCallFrame`
passed a fresh 28,847-declaration audit. The managed run, exact native-source
identity, evidence hashes and phase timings are recorded in [index.json](index.json)
and its artifacts. Allocation: two workers, two Lean threads per process, 8192 MiB.

For every accepted raw function call with input-only formals and an empty
callee write mask, actual scanning preserves all BodyScan fields, the call
permission flag, and the caller's write mask. The proof covers the complete
source-order fold, including named associations and zero formals. Actuals start
with zero written-state identities; every selected input cell retains that fact,
so argument reading cannot manufacture writes. The alias fold is the identity
for accepted input formals, and every empty-mask state reset is the identity.
The final result changes only the scan endpoint and accumulates read masks.
Its exact write union is retained for arbitrary incoming mask storage.

The source-derived formal-mode and completed-row invariants are supplied by
separate checked modules and still need the final caller composition. This raw
frame theorem assumes neither body safety nor whole-bundle validity on a body
prefix. It does not establish external automatic completion or complete feature
assurance.

Four draft checks failed on explicit Lean normalization/binder issues: the first
used an abbreviated constructor namespace, the second split the nested separator
choice before its failure guard, and two followups retained no-progress
normalization steps. The recorded diagnostic selected the exact zero-separator
split; normalizing the successful record once completed the proof. All failed
records remain in the managed ledger. No domain, memory cap or proof trust
changed. Selected GPT-6 Astra Max; actual runtime model/effort and agent token/cost
measurements were unavailable.
