# Fixed backend context evidence

2026-10-18, Linux x86_64, #119. Supports
[the context source projection](../../research/retained-producer-fixed-context.md).
No native tool was run for this packet.

- `identity.json` pins the existing five native JSON inputs and their archive,
  eleven complete installed Why3 library files, and twenty-six complete Why3
  implementation files at revision `9390baf120ef260547dfa14f08e11c890b203d9c`.
- `sources.tar.gz` contains those thirty-seven source files. It has deterministic
  member metadata and gzip time zero.
- `result.json` retains exact native-to-Ptree declaration multiplicities and
  every library use/clone target with its source line, plus the fixed closure.
- `check.py` verifies archive/member hashes and reproduces the projection. It
  is an offline restricted scanner/counter, not a Why3 type checker or proof.
  It fails on unhandled native declarations/substitutions, unresolved file
  paths, unrecognized unqualified module targets, or comma-separated use
  targets outside the retained syntax.
- `success-identity.json` and `success-witness.tar.gz` retain the ordinary
  successful `program-Z0j19G` workspace's five JSON inputs, six library sources,
  five Why3 sessions/shapes, two `.spark` reports, summary and local execution
  log. The packet also includes the complete managed log/events and the
  historical executed `silver.adb` recovered from its recorded git snapshot.
- `success_check.py` compares all five inputs without normalization to the
  fixed-body packet, reconciles the 47 library proof records, checks the local
  execution log against managed run `20261017T121442-e0df446200f8`, and compares
  the six sources with both the current tree and the recorded test inputs.
  `success-result.json` retains that result, including failed individual
  attempts alongside the proved session files.

From an integrated checkout:

```sh
python3 docs/evidence/retained-producer-fixed-context-20261018/check.py
```

Before integration, provide the checkout containing the unchanged fixed-body
packet with `--prior-repo /path/to/checkout`. `--output /tmp/result.json`
recomputes the detailed result instead of comparing it with the retained one.
The five historical successful inputs are deliberately retained independently
for byte comparison with the fixed-body capture. No backend launch or proof
success is inferred from that capture, whose backend was disabled. The
successful witness is a separate earlier run. It is not a new proof replay,
an exact lifetime counter trace, or a complete historical executable/driver
attestation: the test ledger did not capture a separate `gnatwhy3` hash, and
its producer option temporary files are gone. The source record distinguishes
the direct eleven-file closure from driver-loaded context and retains the
independent weak-table/counter and solver-tail obligations.
