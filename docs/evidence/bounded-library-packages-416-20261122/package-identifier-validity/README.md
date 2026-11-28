# Original identifier metadata validity

The focused `Silver.ApplicationPackageIdentifierValidity` check passed on Linux
x86-64 with a fresh 13,011-declaration audit. [index.json](index.json) retains
the run and captured inputs; every captured source hash matched before retention.
Two workers, two Lean threads and 8192 MiB were allocated. Dependencies were
cached; no complete feature check or independent kernel replay is claimed.

`ApplicationPackageNames.identifier_validName` derives the native metadata
name check from the original `Named.IdentifierAt` derivation, positive start and
bounded source. The induction retains every identifier character and excludes
adjacent and trailing underscores, then proves the exact original source slice.
The visibility proof can use this result at writable actual spans without
assuming whole metadata validity or a separate semantic safety certificate.

Two drafts exposed local constructor naming, Boolean normalization and an
integer-coercion spelling hiding slice arithmetic; the diagnostic and failed
runs remain in the managed history. No native source, domain or trust assumption
changed. Selected GPT-6 Astra Max; runtime model/effort and cost/token measurements
were not independently exposed. Phase timings are retained in the evidence.
