# Selected fixed linker inputs

Supports [the derivation](../../research/retained-link-inputs.md) for #119.
Native host: Linux x86_64, 2026-10-18.

This preserves the original plugin-enabled query and inventory. The
[explicit no-LTO descriptor](../retained-link-no-lto-20261018/README.md)
now supplies the selected link configuration and its smaller collect2 arrays;
its exact argument comparison preserves this fixed-input inventory.

`capture/` retains eleven driver-only queries, argv, environment and raw
output. `source-build.stdout` identifies the earlier successful null-proposed
build whose link command was reconstructed. `capture-driver.py` is the exact
executed script; copy it to fresh scratch before rerunning since it creates
its capture directory. No rerun is needed to replay the retained evidence.

`link-script/` retains the input-free `ld --verbose` query and matching
installed script. Two display newlines are explicit. `query-link-script.py`
is the executed script. Both managed records/logs are under `managed/`.
Neither query performs a link or compiles code.

`inventory.py` reads the installation, including every ELF section, symbol,
relocation and GNU archive member. `inventory.json` retains file/member hashes,
preceding missing library candidates, SONAME/DT_NEEDED, archive-map offsets
and counts. The parser inverts GCC's argv display escaping without shell
evaluation. Libraries remain at their original paths; their large binary
contents are not duplicated. Generated sample objects are excluded from
fixed sums. `sources.json` and `sources.tar.gz` retain twelve complete reviewed
GCC/Binutils files; these pins identify source, not historical build inputs.
Collect2's target/configure choices reuse two complete files from the native
driver packet. Its argument/search/launch calculation uses the retained driver
query and does not launch collect2 or a linker.

Replay into fresh scratch:

```sh
python3 docs/evidence/retained-link-inputs-20261018/check.py --output /tmp/link-input-check
```

Add `--installed` to reread all original libraries/members and require exact
inventory equality. This executes only Python. The common-probe correction
rechecked the complete installed inventory; the later collect2-only extension
reused that unchanged result and reran the affected offline source/arithmetic
checks. The manual argument supplies file-selection/loop bounds; the
checker does not formally verify vendor code.

This does not establish complete linker capacity, generated names/references,
layout or a larger language. No complete native audit, Lean run, test suite,
macOS validation or CI was performed for this component.
