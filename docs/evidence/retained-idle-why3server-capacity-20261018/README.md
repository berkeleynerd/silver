# Idle Why3 server source packet

Supports the [startup derivation](../../research/retained-idle-why3server-capacity.md)
for #119. Native platform: Linux x86_64, 2026-10-18.

`sources.tar.gz` retains 14 complete Why3 files at revision
`9390baf120ef260547dfa14f08e11c890b203d9c` and five complete installed Linux
interface headers. Why3 bytes were checked against the already retrieved
complete source zip; its hash, source URL and entries are recorded in
`source-manifest.json`. The headers describe the selected ABI, not historical
build provenance. The existing external relevant-behavior premise applies.

`check.py` reads only this packet, checks full-file identities and selected
call/field anchors, and recomputes ABI layouts and request arithmetic.
The report supplies the conditional reachability argument; the checker is
not a C verifier and does not establish libc/kernel storage bounds.

```sh
python3 docs/evidence/retained-idle-why3server-capacity-20261018/check.py \
  --output /tmp/idle-why3server-check.json
```

No compiler, assembler, linker, server, solver, native audit, Lean build,
test suite, macOS validation or CI was run for this packet.
