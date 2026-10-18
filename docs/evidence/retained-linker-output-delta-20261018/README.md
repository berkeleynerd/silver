# Fixed output linker delta evidence

Research for [#119](https://github.com/berkeleynerd/silver/issues/119).
See the [source argument](../../research/retained-linker-output-delta.md).
This packet establishes fixed library/binder input identities and symbolic
linker deltas for direct literal output/null Main bodies. Whole output-link
and pipeline capacity remain open. Current library/admission limits do not
change.

Replay from the repository root, pointing `--prior-repo` to a checkout with
the nine immutable prior records listed in `inputs.json`:

```sh
python3 docs/evidence/retained-linker-output-delta-20261018/check.py \
  --prior-repo . --output /tmp/retained-linker-output-delta.json
cmp docs/evidence/retained-linker-output-delta-20261018/result.json \
  /tmp/retained-linker-output-delta.json
```

The checker reads retained archives and the installed fixed files named by
the earlier linker inventory, checking their exact identities. It executes
no compiler, assembler, linker, prover, solver or Lean command. Python checks
bytes, ELF/ALI records and arithmetic; the accompanying source argument
supplies the compiler/binder/linker control-flow interpretation.

- `inputs.json`: nine immutable predecessor identities.
- `manifest.json`: original paths, sizes and SHA-256 for153 artifacts and13
  complete source files, plus source revision identifiers and archive hashes.
- `artifacts.tar.gz`:38 files copied byte-for-byte from the prior native-options
  archive; surviving object files from four historical option workspaces;
  the indexed-output source/ALI/binder/object witness and recorded executable
  identity; and the83-file literal-output ALI closure.
- `sources.tar.gz`: complete selected compiler/binder/linker source files and
  the three current Silver library sources.
- `result.json`: replayed counts, external definitions, EH entry walks, indexed
  binder bridge, symbolic linker offsets and explicit scope flags.

The archive records where newly collected surviving object files came from;
it does not claim they were in the original options packet. The historical
output links used ordinary GCC driver plugin selection. No exact no-plugin
output link was executed for this packet. Library identities match across
all five retained object locations. The indexed executable hash matches its
earlier independently recorded identity; executable bytes are not duplicated
here. No output program or runtime artifact was created by this work.
