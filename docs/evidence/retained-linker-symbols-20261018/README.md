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

`registration-sources.json` and its archive add the selected x86 backend and
linker scheduling sources. `check-registrations.py` checks all 25 source
identities and the direct registration-site partition for the lifetime transfer:

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check-registrations.py --output /tmp/registration-check.json
```

The selected target has no dynamic section-symbol prefix or backend-local
dynamic list. The reviewed schedule gives a conditional high-water bound from
input records, global entries, script assignments, section visits and version
definitions, retaining registrations lost to rollback or hiding. It does not
supply all those caller counts or complete whole-link capacity. The checker
is source/hash/arithmetic reconciliation, not a C evaluator; no native tool runs.

`check-name-inputs.py` adds the exact fixed ELF section-name tables, including
the `.gnu.warning.<symbol>` input names. Capture mode checked complete
installed-file/member identities; default replay uses the retained capsule.
All 29,004 section names lack `@`. `check-global-names.py` joins the three
exact selected scripts and six further source files to the global-name and
assignment domains:

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check-name-inputs.py --output /tmp/fixed-name-check.json
python3 docs/evidence/retained-linker-symbols-20261018/check-global-names.py --output /tmp/global-name-check.json
```

The selected assignment walk has at most16 non-dot visits. The live global
table/traversal domain is bounded by `3R+2Q+V+21`; this is not a lifetime
constructor/arena bound across rollback. The no-additional-version-suffix
conclusion remains conditional on the generated Main/binder name domains.
The checker reconciles source-reviewed paths and exact script inventories;
it does not evaluate C or implement the linker-script parser.

`check-dynamic-strings.py` reuses those source and input inventories to join
the selected `.dynstr` names and positive-reference events, preserving dead
entries and increments later undone by rollback:

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check-dynamic-strings.py --output /tmp/dynamic-string-check.json
```

Its bounds retain generated-input name counts/bytes, configured rpath length
and the earlier registration term J. They do not cover the separate ordinary
symbol/section String tables or supply a whole-link capacity result.
