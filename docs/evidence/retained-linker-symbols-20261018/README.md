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

`check-version-names.py` extends that capsule with the three DSOs' dependency
version sections. `fixed-version-need-inputs.json` binds the small supplemental
archive to the original input record. Capture mode verifies complete installed
DSO identities; default mode uses only retained regions. The parser follows
the actual definition/dependency name offsets, including suffix-shared strings,
checks disjoint record extents and visits every retained symbol name:

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check-version-names.py --output /tmp/version-name-check.json
```

The installed capture and offline replay both found 51 fixed version names and
no literal `@` in any input symbol name. This supports the conservative
`V <= 51+W` join, where the additional generated/synthetic suffix budget W
remains open; it does not claim that output version definitions are absent.

`input-symbol-sources.json` and its archive add the generic symbol insertion
and ELF target-default code at the same Binutils commit. Together with the
existing source bundle, `check-input-symbols.py` checks the source anchors and
the fixed pass inventory for the `3R+2Q` global-entry constructor contribution:

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check-input-symbols.py --output /tmp/input-symbol-check.json
```

The 220,109 fixed-input contribution includes a conservative charge for every
input section as a possible warning. Script/generated/synthetic additions,
rollback snapshot storage and other dynamic-symbol registration events remain
separate. The input-pass registration contribution is bounded by `8R`, or
392,648 for the fixed passes, retaining increments lost to as-needed rollback.
These are additive terms, not whole-link counts.
