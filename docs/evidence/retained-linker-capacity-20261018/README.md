# Retained ELF linker capacity evidence

Supports the [source derivation](../../research/retained-linker-capacity.md)
for #119. `source-manifest.json` records eleven complete files at Binutils
commit `5e56594815854de5eca35c7c04b11705d0f19c02`, their hashes and immutable
retrieval URLs. `release-tag.json` retains the release-tag response.
`sources.tar.gz` contains those source bytes. These identify reviewed source,
not the historical inputs used to build an installed executable.
`selected-tools.json` records the selected compiler's `-print-prog-name`
results and those tools' first `--version` lines.

`check.py` reads the archive without extracting or executing it, checks every
complete-file identity, and recomputes ELF string-table and BFD hash growth
arithmetic. Run it into new scratch and compare `checks.json`:

```sh
python3 check.py --output /tmp/new-linker-capacity-check
```

The report supplies the manual lifecycle and arithmetic arguments. Actual
source-to-symbol/reference counts and whole backend layout remain separate.
No compilation, assembly, linking, proof, test suite or near-limit allocation
was performed. Only tool path/version queries were used to identify the
selected assembler/linker release.
