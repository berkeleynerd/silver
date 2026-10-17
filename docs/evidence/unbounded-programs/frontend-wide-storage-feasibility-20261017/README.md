# Wider frontend storage design evidence

Research for #113, 2026-10-17, Linux x86_64. This directory supports
[the candidate design](../../../research/frontend-wide-storage-feasibility.md).
No compiler patch/build, large native allocation experiment, proof run or
language adoption occurred. The arithmetic concerns a conditional proposed
representation, not observed native limits or a completed universal proof.

Sources are GCC commit `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, Ada tree
`a3b9f0d4c999c8c127cebdc239ca8218284137aa`. `source-files.json` records exact
size, SHA-256 and Git blob SHA-1 for each source consulted here, checked against
the preceding verified complete inventory. The source archive named on each
entry identifies where its bytes are retained:

- `additional-sources.tar.gz` contains the newly retained interface and runtime
  table files, with original copyright/license notices.
- `../continuation-20261017/frontend-lifetimes/selected-sources.tar.gz` holds
  the reused package snapshots. That directory also retains the full tree
  inventory, the complete source manifest, the resolved lifetime inventory,
  the GPLv3 text and its source-license note. The lifetime audit was reused,
  not rerun for this design.

`COPYING.RUNTIME` inside `additional-sources.tar.gz` supplies the exception text
referenced by the additional runtime-table snapshots. `license-source.json` records its exact upstream
commit URL and digest; the GPLv3 text is retained at the earlier directory's
`COPYING3`. No upstream source notices were removed or changed.

Extracting both selected-source archives into one temporary directory gives
the sources needed to reproduce this stream under `gcc/ada/`. Alternatively
use the exact GCC subtree from the prior complete extraction. With the source directory named
`/path/to/gcc/ada`, run:

```sh
python3 audit.py /path/to/gcc/ada /tmp/frontend-wide-recheck
```

The script checks each selected source hash before evaluating the hardcoded
integer premises (and verifies their exact declarations occur in `types.ads`).
It emits `source-recheck.json`, `derived-arithmetic.json` and the deliberately
inclusive `uintp-offset-inventory.json` search aid. Compare those outputs with
the retained copies. Growth boundary examples check the arithmetic script;
the design document states the general invariant and remaining obligations.
No compilation or tool installation is needed to reproduce these outputs.

The interface/change inventory is the table in the research document; it was
resolved by reading the complete retained packages, not inferred solely from
the numeric-pool search. `MANIFEST.json` records this directory's file sizes
and SHA-256 hashes, excluding itself. Neither manifest nor upstream source
hashes prove the construction of installed compiler/prover binaries.
