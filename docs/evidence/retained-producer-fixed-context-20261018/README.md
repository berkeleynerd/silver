# Fixed backend context evidence

2026-10-18, Linux x86_64, #119. Supports
[the context source projection](../../research/retained-producer-fixed-context.md).
No native tool was run for this packet.

- `identity.json` pins the existing five native JSON inputs and their archive,
  eleven complete installed Why3 library files, and fifteen complete Why3
  implementation files at revision `9390baf120ef260547dfa14f08e11c890b203d9c`.
- `sources.tar.gz` contains those twenty-six source files. It has deterministic
  member metadata and gzip time zero.
- `result.json` retains exact native-to-Ptree declaration multiplicities and
  every library use/clone target with its source line, plus the fixed closure.
- `check.py` verifies archive/member hashes and reproduces the projection. It
  is an offline restricted scanner/counter, not a Why3 type checker or proof.
  It fails on unhandled native declarations/substitutions, unresolved file
  paths, unrecognized unqualified module targets, or comma-separated use
  targets outside the retained syntax.

From an integrated checkout:

```sh
python3 docs/evidence/retained-producer-fixed-context-20261018/check.py
```

Before integration, provide the checkout containing the unchanged fixed-body
packet with `--prior-repo /path/to/checkout`. `--output /tmp/result.json`
recomputes the detailed result instead of comparing it with the retained one.
Native input data is reused from the existing fixed-body archive rather than
duplicated. No backend launch or proof success is inferred from that archive,
whose capture explicitly disabled the backend.
