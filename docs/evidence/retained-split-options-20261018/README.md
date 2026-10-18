# Native split-wide option evidence

Offline evidence for [#119](https://github.com/berkeleynerd/silver/issues/119).
The [source argument](../../research/retained-split-options.md) joins the stock
`-fsplit-wide-types` option to the existing driver, frontend and ALI interfaces.
The flag reaches binder compilation; its former object witness is explicitly
not claimed to cover the new option. No native, producer or production run
belongs to this packet.

Portable source-pin/arithmetic replay:

```sh
python3 docs/evidence/retained-split-options-20261018/check.py \
  --output /tmp/retained-split-options.json
cmp docs/evidence/retained-split-options-20261018/result.json \
  /tmp/retained-split-options.json
```

The optional `--gcc-root` argument additionally verifies and searches the
complete existing 4,929-file GCC corpus. It was run with
`/tmp/silver-backend-compose-20261018/full-source`. The retained corpus
manifest hash is the same as the earlier fixed-prefix source inventory.
This optional check is required to replay the negative lexical inventory;
the portable subset check alone does not prove absence in omitted files.
Neither mode is a compiler model or replaces the companion selected-path
source interpretation.

- `sources.tar.gz` and `sources.json` retain 29 complete relevant source files.
- `gcc-corpus-manifest.json.gz` retains the exact prior source inventory;
  `flag-mentions.json` records fourteen matching lines, counting literal LF.
- `ada-source-manifest.json.gz` reconciles the retained Ada sources with the
  existing complete source manifest at the same GCC commit.
- `driver-before.json` and `process-shell-before.json` are immutable copied
  predecessor records with their identities in `inputs.json`.
- `check.py` and `result.json` retain the source landmarks and exact container,
  option-string and ALI arithmetic, with unresolved binder/whole-capacity fields.

Historical native executions keep their original option identity. No existing
source snapshot, counter total or object is relabelled as a new execution.
