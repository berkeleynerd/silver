# Native environment and installed defaults

Evidence for [the source argument](../../research/retained-native-environment.md).
Managed Linux run `20261018T063601-938bdebc01d5` used an exact seven-entry child
environment for five GCC driver-only queries and three static disassemblies.
It did not execute a compiler frontend, assembler, linker or prover.

`artifacts.tar.gz` retains 23 files: the exact runner, fixture inputs, stdout/
stderr, static-default data and managed events/log. `identity.json` binds their
bytes. `capture.json` duplicates the retained result for convenient inspection.
`sources.tar.gz` and `sources.json` retain ten complete pinned GCC source files.
Static ELF inspection establishes the three recorded constant arguments only;
the handwritten relocation and capacity arguments retain their tool/source
premises. Original scratch is `/tmp/silver-native-environment-20261018/`.
The original runner refuses to replace its capture directory.

Reconcile the retained evidence without invoking any toolchain process:

```sh
python3 docs/evidence/retained-native-environment-20261018/check.py
```

The source argument and production launcher remain distinct from this evidence.
No compiler source, tool pin, admission rule or production environment changed.
