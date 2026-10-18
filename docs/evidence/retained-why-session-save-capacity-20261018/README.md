# Retained session-save missing-input packet

Research #119, 2026-10-18, Linux x86_64. See the
[research note](../../research/retained-why-session-save-capacity.md).

The current session graph cannot be joined from the retained roots. This packet
identifies three unobserved runtime root words, binds the fresh-session source
prefix, and specifies a restricted observer for parent coordination. It does
not provide numeric `B_binders` or `R`; the accounted endpoint stays 61,641.

- `capture-coverage.json`: all-read overlap check, exact old capture/member
  identities, fresh-launch assertions and selected task/root counts.
- `native-layout.json`: ten named bodies extracted from existing disassembly;
  all 2,414 instruction/continuation bytes match the pinned ELF. Root/closure
  offsets are explicit; no BSS file bytes are treated as runtime values.
- `sources.tar.gz`: four additional exact Why3 source files and source index,
  checked against the pinned source ZIP. Other cited sources remain in the
  reused callback/multiplicity archives identified by `inputs.json`.
- `observer-plan.json`: prospective invocation, resource limits, root and
  projection layouts, retention protocol, fixtures, guards and completion
  obligations. No native execution is authorized or performed by this packet.
- `check.py`, `inputs.json`, `result.json`, `round.json`: narrow coverage/identity
  check, exact inputs, explicit incomplete flags and actual round record.

The focused check is:

```sh
python3 -B docs/evidence/retained-why-session-save-capacity-20261018/check.py
```

It reads the existing archive and installed ELF as data. It does not start
Why, invoke a debugger/objdump, reconstruct the session, run the old expensive
graph proof, or validate the prospective observer. The original successful
counter/table proof and reviewed two-save result are reused with unchanged
scope. No builds, proofs, compilers or solvers ran.
