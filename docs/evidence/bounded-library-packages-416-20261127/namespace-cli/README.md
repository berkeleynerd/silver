# Integrated namespace CLI checks — 2026-11-27

Linux x86-64, two managed workers per run under the host's eight-CPU allocation.
Build `20261127T183110-7541c9fe4e7b` passed on the integrated namespace repairs
and updated catalogue emitter. Run `20261127T183527-88bbb020e8f5` regenerated
`catalogue/silver.json` from that binary.

Run `20261127T183554-86532f5bb1e9` passed four selected unittest identities in
9.372 seconds: all Standard-name exclusions in both case spellings, Standard/Nul
positive controls, all five bare/qualified runtime-operation collisions, and
the catalogue's complete JSON/content comparison. Unlike the earlier direct
analyzer matrix, these checks exercise the built command-line driver. These are
admission/catalogue regressions, not application proof or a full test suite.

One earlier custom-tool invocation failed because it used a relative binary
path inside the toolchain working directory (`183444-8b0345b32bda`). One test
invocation supplied named tests to the runner's discovery interface
(`183535-d8e1029bdea6`); no test ran. Both are retained as failures. Absolute
paths and discovery filters corrected the invocations without changing source.
A prior launch was refused before execution because the native proof held the
compiler workspace; no active proof was interrupted.

Compressed managed logs/events retain exact inputs, commands and outcomes.
The manifest records both compressed and original hashes. Broader #416 source
integration, complete native/Lean checks, final regressions, Rosetta and delivery
review remain open. No feature-support or merge claim follows from this packet.
