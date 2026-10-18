# Producer parent and bundled compiler evidence

See the [source argument](../../research/retained-producer-parent.md).
`sources.tar.gz` and `sources.json` retain 48 inspected source files and the
installed native/producer GCC, gnat1 and System identities. They are collected
by `collect-sources.py`; collection executes no compiler or prover.

`fixed-gcc-prefix-witness/` retains the managed prefix execution, exact launch
and frontend environments, fixtures, debugger script, four counter streams,
phase snapshots, instruction map and disassembly. Its manifest hashes every
retained file. Compressed streams additionally have their raw hashes recorded.
The run stops deliberately before Main translation; it is not a full compile.

Offline checks:

```sh
python3 docs/evidence/retained-producer-parent-20261018/check-parent.py
python3 docs/evidence/retained-producer-parent-20261018/replay-prefix.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --gnat1 /home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/image-tools/libexec/spark/libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1 \
  --output /tmp/silver-producer-prefix-replay.json
```

The supplied source-root paths can be reconstructed from the archive: it
contains all 27 sources required by the prefix replay under `gcc/`.
The executable is an installed dependency, not included in the packet.
`prefix-result.json` retains the successful replay. These checks verify retained
inputs and event arithmetic; the companion source argument establishes the
transfer scope. Whole producer capacity and production admission remain open.
