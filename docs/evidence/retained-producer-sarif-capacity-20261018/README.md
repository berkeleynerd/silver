# Null-family SARIF/VSS evidence

2026-10-18, Refs #119. Supports the
[source transfer](../../research/retained-producer-sarif-capacity.md).
No native compiler, assembler, linker, GNATprove, solver or Lean process ran.

`sources.tar.gz` retains 33 complete files from the reviewed SPARK, SARIF,
VSS, GCC runtime and release recipe candidates. `source-manifest.json` gives
their byte counts, SHA256 hashes and immutable retrieval URLs. Tag/ref API
responses establish the currently resolved VSS release tags. The SARIF query
was `https://api.github.com/repos/AdaCore/sarif-ada/commits?until=2026-06-26T15:45:48Z&per_page=1`.
Its pre-build date does not establish historical binary source identity.

Run the offline check:

```sh
python3 docs/evidence/retained-producer-sarif-capacity-20261018/check.py \
  --output /tmp/retained-sarif-check.json
```

It rechecks all retained source bytes, tag resolutions, enum/constant-text
counts, vector growth and a conservative declaration-derived record-size
calculation. The report supplies caller reachability, selected ABI leaf
envelopes and reference-copy arguments. The checker is not an Ada compiler
or formal verification of those external sources. `check-results.json`
records its arithmetic results. Source retrieval, hashing and arithmetic were
the only new execution; no tool installation or admission changed.
