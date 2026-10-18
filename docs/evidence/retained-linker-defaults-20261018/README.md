# Selected linker defaults and excluded payloads

Supports [the source argument](../../research/retained-linker-defaults.md)
for #119. `sources.tar.gz` retains 12 complete files from Binutils commit
`5e56594815854de5eca35c7c04b11705d0f19c02`; `sources.json` pins their bytes.
`inputs.json` pins the five prior inputs and four retained capture files.

`capture/` preserves the already completed `ld --help` query, including its
original one-off driver. Do not rerun it as part of replay. Its native duration
is 0.00324 seconds; managed run `20261018T112705-2e2b04d26400` used one worker
and ran no compilation or link. The raw output establishes the installed
compression default where source has a configuration-dependent choice.

Replay without executing a native tool:

```sh
python3 docs/evidence/retained-linker-defaults-20261018/check.py --output /tmp/retained-linker-defaults-replay.json
```

The checker verifies retained sources, inputs, current selected linker identity,
all 15 fixed file spellings and 1,161 archive members. It checks section names
and compression flags directly and reconciles the source/option exclusions.
`result.json` is the retained output. The C control-flow and Main/binder
source transfers remain handwritten arguments; the checker does not prove C
semantics or whole-tool capacity. No native tool runs during replay.
