# Flat-token declaration depth — 2026-11-27

The complete certificate build in `20261122T191426-0274eb4d5d2f` retained all
eight successful OutputBody line chunks but failed at the flattened token
definition in `OutputBodyCertificate`. Its 100,000 recursion-depth setting
was too small for the enlarged output-profile source. This was a build failure,
not a successful authoritative source checkpoint.

Managed diagnostic `20261127T121451-c08bd193fe42` isolated that same declaration
with the current 99,910 tokens and the certificate's existing 10,000,000 heartbeat
budget. The baseline failed with maximum recursion depth after 18.386 s. The
size-based local setting of 400,000 passed after 121.608 s. Both used Lean 4.34.1
with two threads under the host's eight-CPU reservation/affinity controls. An
earlier diagnostic omitted the certificate's heartbeat setting and failed on
that different limit; it is not supporting evidence for this repair.

The generator now scales only the flattened token declaration's recursion budget,
using the existing large-list threshold. Comparing generated output for all
source bindings found exactly one added line, on OutputBody; every other generated
declaration is unchanged. The complete source reconstruction and lexer equality
still require ordinary kernel acceptance. This diagnostic establishes only the
literal-elaboration repair; the complete certificate and feature source audit
remain pending at the stable checkpoint.

The compressed diagnostic script, output, result and managed events/input map are
retained here. The comparison records the exact changed declaration setting.
