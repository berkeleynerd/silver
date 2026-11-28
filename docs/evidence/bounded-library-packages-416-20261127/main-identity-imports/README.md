# Main import identity composition — 2026-11-27

Run `20261127T205105-7278a2b7ef38` passed `ApplicationPackageMainIdentityImports`
and a fresh 48,532-declaration audit. All 1,572 captured source hashes match.
It composes the already interpreted original import scanner and full-bound
spelling helper into Main's call dictionary. Scanner execution terminates with
the same original name bytes for arbitrary incoming local storage. The spelling
comparison is independent of the returned Word's lower bound, justifying Main's
byte-list representation without assuming that the native returned String starts
at one. The original import guard is preserved exactly.

This is a focused imported-call result. The authoritative spelling extraction,
other declaration/body callees and complete application endpoint remain separate
requirements. Matching cached dependencies were reused; two Lake workers, two
threads per process and an 8,192 MiB per-process threshold shared the host's
eight-CPU allocation. No independent kernel replay or complete feature audit is
claimed.
