# Main frontend entity evidence

Companion to [the derivation](../../../research/retained-frontend-entities.md),
2026-10-17, Linux x86_64. No compiler, GNATprove or Lean execution.

`derive.py` verifies 17 complete frontend files against the retained pinned
manifest, then emits `source-manifest.json` and LF-numbered `source-excerpts.md`.
The excerpts support manual caller/guard review. The script does not mechanically
prove the entity formula or binary/source correspondence.

From the repository root:

```sh
python3 docs/evidence/unbounded-programs/retained-frontend-entities-20261017/derive.py \
  --source /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada
```

Use `--output /tmp/silver-frontend-entity-check` for an independent regeneration
without overwriting the retained files. The source directory is an environmental
input, not a portable installation promise. The pinned commit and whole-file
hashes identify the intended input. Existing tool installation, caches and
other worktrees were preserved.
