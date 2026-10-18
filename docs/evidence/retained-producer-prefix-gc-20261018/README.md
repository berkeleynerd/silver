# Fixed Why3 prefix evidence

2026-10-18, Linux x86_64, #119. Supports the
[collection and counter argument](../../research/retained-producer-prefix-gc.md).

- `observations.tar.gz` retains the complete successful five-input diagnostic,
  three stopped native diagnostics, the setup failure and all managed logs.
  The original plans, runners, debugger scripts/logs, argv/environment capture,
  native JSON, configs, runtime snapshots, mappings and installed static
  disassembly are preserved. Empty private session/temp directories are not
  archive files. Original machine paths are historical data, not replay paths.
- `sources.tar.gz` contains 24 complete OCaml implementation/stdlib files and
  their upstream identity record; 32 complete selected Why3 files, including
  its license; and a hash inventory/search result over 293 Why3 implementation
  and parser files. Sources use LF line numbers. The source scan is supporting
  inspection evidence, not a call-graph proof or binary equivalence certificate.
- `identity.json` pins every archive and member. The native plan independently
  pins 191 actual tool/config/input files. Mapped system libraries are recorded
  per process. Tool binaries and system libraries are identified by hash rather
  than duplicated in this packet.
- `check.py` validates the packet, compares all five native JSON files with the
  existing fixed-body packet, checks configuration and endpoint/guard states,
  recomputes allocation deltas and trigger margins, and preserves the distinction
  between successful and stopped diagnostics. `result.json` is its output.

Run from an integrated checkout:

```sh
python3 docs/evidence/retained-producer-prefix-gc-20261018/check.py
```

Use `--prior-repo /path/to/checkout` if the fixed-body packet is elsewhere.
`--output /tmp/result.json` recomputes instead of comparing the retained result.
The checker needs no installed toolchain or debugger, makes no network calls
and launches no native producer, solver or proof checker. It verifies evidence
arithmetic and identities; it does not machine-prove the linked source argument.

The successful observation is managed run
`20261018T125544-a11ebc3568d2`, one worker. The protected interval ends before
Why3-server connection. Its no-collection result requires the exact controlled
configuration and the fixed input/path/session projection in the research
record. It is neither the default production runner nor a variable-program
memory cap, complete proof run or whole-pipeline capacity result. Stopped setup,
forced-startup collection, missing-entity and custom-resource-trigger attempts
are retained as diagnosed attempts, not successful validation.
