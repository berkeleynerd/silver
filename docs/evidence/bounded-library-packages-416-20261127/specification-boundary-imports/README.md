# Specification boundary imported-call closure — 2026-11-27

The typed complete Signature reader now consumes its interpreted imported calls
through the exact full-domain execution relation, preserving arbitrary inactive
backing storage and assertion locals. Specification entry and footer now use the
actual lexical/name readers and metadata name comparison. Branch and loop callee
composition remains separate work.

Run `20261127T200639-c8a6099a16c9` passed with a fresh 48,264-declaration
axiom audit; every captured source input matches this checkpoint. It reused
matching cached dependencies and ran with two Lake workers, two threads per
process and 8,192 MiB per process within the host’s eight-CPU allocation.
This is focused proof validation, not complete feature assurance or kernel replay.

Three failed attempts are retained in the run ledger. The first exposed an
ambiguous record-update type after rebuilding dependencies. The later drafts
exposed token-reader alias normalization and then redundant trailing tactics
after the rewrites already closed both goals. Available command-output logs are
labelled separately; the middle attempt retains its ledger failure identities.
The repair changes no source model, admission rule, theorem domain or proof budget.
