# Null-family producer-tail evidence

Offline source specialization and schema arithmetic for #119, 2026-10-18.
No compiler, GNATprove, Why3, solver, debugger or Lean ran.

The [report](../../research/retained-producer-null-tail.md) owns the source
reachability argument. `identity.json` reuses complete source files in the
existing SPARK frontend and producer-response archives; it pins the current
null recognizer and dispatch source separately. These are the existing
candidate-source/installed-behavior premises, not new binary attestations.
`runtime-sources.tar.gz` retains the complete installed GNAT 16.1 runtime
source files used for Text_IO closing and the following storage analysis.

Run `python3 docs/evidence/retained-producer-null-tail-20261018/check.py`.
It checks identities and decisive source fragments, inventories every
`Entity_To_Subp_Assumption` caller in the 279-file native source frontier,
and computes the maximal two-claim report's pretty serialization envelope,
distinguishing JSON.Write's String from the file's final closing LF.
The number/image/filename bounds are stated in the report. The checker does
not execute or formally verify the external toolchain. Its schema is a bound,
not a captured native report.

`result.json` keeps remaining flow-storage, JSON-reference and downstream
orchestration obligations explicit. No source-length or aggregate-RAM gate
is introduced by this evidence.
