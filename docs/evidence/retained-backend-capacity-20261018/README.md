# Native backend capacity component evidence

Supports the [location, String and constant-pool derivation](../../research/retained-backend-capacity.md)
for #119. No compiler, GNATprove, Lean, suite or near-limit allocation was run.

`source-manifest.json` identifies twenty-one complete GCC source files at
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Six newly retrieved files are retained
in `new-sources.tar.gz`; their immutable retrieval URLs are in the manifest.
The three additional allocator sources are in `allocator-sources.tar.gz`;
five constant-pool/header sources are in `pool-sources.tar.gz`.
Four Ada files reuse the complete frontend inventory, and three generic GCC
files reuse the earlier emission archive. These identities describe source
bytes, not a binary attestation. The ordinary Linux LP64 layout remains an
explicit premise of the String allocation arithmetic.

`check.py` verifies all twenty-one complete-file hashes, checks reused identities
against their earlier manifests, extracts LF-numbered source ranges and
recomputes local integer arithmetic, including ordinary-map growth and the two
GNAT-node association backbones, constant-label mutation inventory and label
buffers, and constant-pool hash capacity/probe arithmetic. `checks.json` and `source-excerpts.md`
retain its outputs. The script does not establish caller coverage or replace
the report's manual source argument.

From this directory, using the pinned source tree retained by the earlier audit:

```sh
python3 check.py --ada /path/to/gcc/ada --output /path/to/new-scratch
```

Compare both generated files with the retained outputs. The script reads the
archives directly without extracting them or executing any upstream program.
Keep the input tree, archives and existing caches intact.
