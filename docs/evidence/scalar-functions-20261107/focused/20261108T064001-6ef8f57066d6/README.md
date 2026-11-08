# Serial function-source closure: failed, retained

The Linux run actually exited 1 at 08:54:01 UTC on 2026-11-08; the managed
finished event records failure after 8,037.462 s. Production source/proof/scripts
remained byte-identical to `47fe4003c0`. This did not complete the source consumer
or its fresh audit.

Successful objects for 78 of 80 independent source leaves remain cached. The
two failures are `CallsIncludedImpl`'s ambiguous `expectedTokens` name and
`CallsCalleeAtBody`'s use of a reader that expects a single-token result type
for `Functions.Function_Count`. Prepared repairs qualify the first helper and
use the existing qualified-result reader for the second complete body check.
They were not applied during the run; the second remained under independent
review when this evidence was retained. Typed trees, denotations, domains and
required body/header checks are not weakened.

[summary.json](summary.json) records the outcome, retained object inventory and
observed memory; [index.json](index.json) identifies the exact log, events,
264 read-only memory samples, observer and prepared repairs. All thirteen gzip
members were independently decompressed and compared by size/hash and original
bytes. The sampled largest leaf was 15.418 GiB and minimum host availability
38.528 GiB. These observations are not resource bounds. No process was signalled.

Next, review and integrate the source-check fixes alongside the separately
required native corrections and their source/semantic correspondence, retaining
all useful objects. Reassess the worker/thread budget before affected validation
and the mandatory complete native and Lean/source/module/axiom checkpoints.
No clean build or optional independent replay is selected.
