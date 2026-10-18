# Literal-output linker composition evidence

Research for [#119](https://github.com/berkeleynerd/silver/issues/119). Read the
[source argument](../../research/retained-literal-linker.md) for the precise
conditional claim, descriptor, no-plugin compatibility transfer and scope.
This packet is awaiting independent review. It changes no production rule.

From the repository root:

```sh
python3 docs/evidence/retained-literal-linker-20261018/check.py \
  --output /tmp/retained-literal-linker.json
cmp docs/evidence/retained-literal-linker-20261018/result.json \
  /tmp/retained-literal-linker.json
```

- `compose.py`: callable `Context()` and `evaluate(source_bytes, context,
  path_bytes=512, host_page_bytes=4096)`. Calls the accepted complete source
  recognizer/assembler/storage interfaces; computes counts, payload, layout,
  relocation/EH, reader, ID and individual-request predicates.
- `check.py`: required Hello, 8192-byte literal and 5000-call examples; invalid
  complete sources; empty/escaped literals with nulls; page arithmetic; adjacent
  sufficient-envelope boundary. It does not launch native tools.
- `inputs.json`: exact predecessor identities. Accepted installed-input
  inventories are reused, not remeasured. The extra ELF/FDE scan reads only four
  objects from the accepted fixed output-delta archive.
- `sources.json`, `sources.tar.gz`: eight complete source files for the new
  compatibility argument, with predecessor source correspondence and original
  source revision identifiers. Other contracts retain their cited capsules.
- `result.json`: replay output, including fixed generated FDE ranges and all
  example conditions/failed sufficient checks.
- `round.json`: selected settings, elapsed implementation evidence and handoff.

Hello and the 8192-byte literal pass this conditional representation predicate.
The 5000-call case fails only the conservative inherited fixed signed-relocation
condition; its assembler, storage and other linker checks pass. The adjacent
4821/4822-call boundary applies only to this sufficient envelope, not to actual
linkability or current language admission. The current 4096-byte library rule
is unchanged. `whole_literal_pipeline_capacity_established=False` and
`aggregate_RAM_gate=False` throughout; allocation/I/O/stack resources remain
separate assumptions. Historical output links had plugins; no exact-descriptor
output link was run or claimed here.
