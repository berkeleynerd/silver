# ELF dynamic symbols and versions

Read-only source and arithmetic evidence for [the transfer](../../research/retained-linker-symbols.md)
in research #119. `sources.json` and `sources.tar.gz` preserve the complete
source files and immutable retrieval identities. The release-source behavior
premise does not identify the historical installed build revision.

`check.py` verifies those bytes, selected source expressions and the
no-overflow arithmetic, including every GNU hash shift-region boundary. It
does not prove source-to-event counts, selected configuration or whole-link
capacity. No native tool executes:

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check.py --output /tmp/symbol-check.json
```

`check-results.json` records this offline check. The retained source includes
the explicit optimized-bucket branch, which is excluded by this transfer's
caller premise rather than silently treated as the default branch.

`fixed-version-inputs.json` joins every fixed object/member identity to the
earlier input inventory. `fixed-version-regions.tar.gz` retains ELF headers,
symbol/name tables and DSO version definitions. The capture mode of
`check-fixed-versions.py` verified full installed files/members and extracted
these regions. Default mode parses the retained regions; `--installed`
additionally repeats the full-file/member hashes and extraction comparison:

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check-fixed-versions.py --output /tmp/fixed-version-check.json
```

`fixed-version-results.json` records installed extraction and replay. No
generated Main/binder object is included, and no whole-link claim is made.
