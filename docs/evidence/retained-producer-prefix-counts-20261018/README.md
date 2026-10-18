# Fixed-prefix semantic count evidence

Supports the [source and arithmetic argument](../../research/retained-producer-prefix-counts.md)
for #119 on Linux x86_64, 2026-10-18.

- `observations.tar.gz` retains the five fixed-input guarded prefixes, plans,
  runner/debugger scripts, process environments, native JSON/configuration,
  per-site operand streams, GC snapshots, installed static disassembly and
  managed-run logs. Each `.operands` record is two little-endian signed 64-bit
  integers, decoded from the observed tagged OCaml operands before arithmetic.
- `sources.tar.gz` contains eight complete inspected Why3 source/interface
  files and a consumer/writer scan whose 293 implementation/parser identities
  match the earlier fixed-prefix packet.
- `identity.json` pins both archives and every member, the preceding evidence,
  executable identity and the three instruction sites. Historical absolute
  paths identify the actual run; they are not portable replay paths.
- `check.py` reconciles the fixed context and original allocations, then checks
  every operand pair with arbitrary-precision arithmetic. `result.json` is its
  retained result. The source argument and observation-site completeness remain
  inspected claims under the existing source-correspondence premise.

```sh
python3 docs/evidence/retained-producer-prefix-counts-20261018/check.py
```

Use `--output /tmp/result.json` to recompute instead of comparing the retained
result. The checker launches no toolchain, debugger, solver or network call.

Managed run `20261018T133533-614e2bd1c3dd` completed once in 31.1862 seconds,
with one worker and five serial debugger invocations totaling 29.1564 seconds.
All 146,259 observed arithmetic operations fit the signed OCaml domain; the
largest result is 47. The result closes this selected semantic-count gap,
keeps complete-prefix and whole-pipeline capacity false, and changes no
production option, Oracle clause or admitted-language rule.
