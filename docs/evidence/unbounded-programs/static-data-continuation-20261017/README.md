# Linux static-data continuation evidence

See the [research record](../../../research/unbounded-static-data-continuation.md)
for the conclusion, premises and limitations. Native probes ran on `codex-silver`,
Linux x86_64, with the pinned Alire GNAT 16.1.0 installation. They were direct
research compiles, not currently admitted Silver or proof runs; no executable
was run. The existing runtime still has its current 4096-byte length contract.

- `identity.json`: actual host, compiler/linker/binder/assembler identities and
  exact six runtime input hashes.
- `summary.json`: three serial probes, observed results and distinct RSS measures.
- `probes/`: exact input files, commands, diagnostics, result manifests, Ada
  dependency records, ELF inspection and line-numbered assembly excerpts.
- `run_probe.py`: unchanged guarded harness from the handoff. Each case's
  `planned-command.json` is the argument vector passed after the harness `--`.
  Its `result.json` records the actual command/environment and input/output hashes.
- `sources/retrieval.json`, source excerpts and `source-snapshots.tar.gz`: pinned
  upstream inspection inputs. One unused candidate filename returned HTTP 404;
  no conclusion depends on it. Recipe/source identity is not binary attestation.
- `raw-probes.tar.gz`: complete retained scratch files, including executables,
  objects, binder output and assembly; **do not execute the research programs**.
  Its `backend/RAW_MANIFEST.json` lists every retained raw file other than itself.
- `MANIFEST.json`: SHA-256 and byte sizes for this bundle, excluding itself.

The source capsule retains full retrieved files. The raw capsule also includes
the scratch source copies. Source excerpts identify original line numbers. The
mutable assembly excerpt omits only `.ascii`/`.string` payload lines; its full
3.7 MB assembly is retained in the raw capsule. Original handoff evidence is
unchanged and linked from the research record.

To check an archive without executing anything, read its regular files with
Python `tarfile`, hash each member named by its manifest, and compare both size
and SHA-256. The continuation packaging validation records these comparisons in
`validation.json`. A full build, test suite or proof rerun is unnecessary for
these documentation/evidence additions.
