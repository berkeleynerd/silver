# Selected Main and fixed-link interface

Supports [the source transfer](../../research/retained-linker-interface.md)
for #119. The checker verifies 13 complete source files, 10 preceding input
records, both historical objects against the actual successful no-LTO link
capture, and the accepted binder object. It resolves ELF symbol names before
comparing records, so a string-table offset shift cannot masquerade as a
semantic change. It also rereads the 15 fixed inputs and 1,161 archive members
to exclude a competing external `_ada_main` record.

```sh
python3 docs/evidence/retained-linker-interface-20261018/check.py \
  --prior-repo ../retained-tool-capacity --output /tmp/link-interface-replay.json
```

After integration, use `--prior-repo .`. The historical objects are small
retained inputs, not newly compiled results. Only Python/offline byte reads
run. The source argument remains handwritten; the checker verifies identities
and ELF comparison, not arbitrary C/C++ semantics. The packet establishes
neither exact bytes for every variable Main nor complete linker capacity.

Independent native-lane replay:
`/tmp/link-interface-native-review.json`; the source review accepted Main's
external metadata and the fixed compatibility/read projection. Independent
binder-lane replay: `/tmp/retained-linker-interface-binder-review.json`; it
accepted the 179-record binder comparison and historical-success bridge.
