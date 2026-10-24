# Fixed proof-mode frontend diagnostic evidence

Offline attachment to [the fixed GCC diagnostic carry](../../research/retained-producer-frontend-diagnostics.md),
research #119 and #193. It reuses the retained 2026-10-18 proof-mode lifetime
captures. It does not execute a compiler, debugger, prover or provider, and
does not use the native-compilation zero-diagnostic capture.

```sh
python3 docs/evidence/retained-producer-frontend-diagnostics-20261024/check.py
```

The check passes and reconciles whole-prefix positive increases for
Non_Instance_Msgs, Errors and Locations: Main fixed contribution 0, Silver_IO
12, Silver_Arguments 7, Silver_Output_Libc 0, Silver_Runtime 0. Edits/Fixes and
the inspected warning/deferred-warning positions are zero. These are not
isolated GCC warning counts. The source argument promotes the complete
nonnegative prefix totals as conservative upper bounds on their earlier GCC
subsets and preserves the incoming SPARK counts separately.

`identity.json` pins the prior capture, coverage, options and manifest artifacts.
The check reconciles exact lifetime arithmetic and the existing 2,299-store
partition; it does not repeat the ELF disassembly. `gcc-sources.tar.gz` retains
the complete GCC files cited or used by the fixed runtime-input inventory, each
checked against the earlier complete source manifest at
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. SPARK Back_End is read from the
already retained archive at `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`.
`source-excerpts.md` is generated from these verified bytes.

`result.json` records the source/configuration identities, selected positions,
runtime/source pragma inventory and the 474-file compiler-source byte envelope.
Its small arithmetic example checks representability only; it is not a source
name/path measurement or a whole-program admission decision.

`raw-argument-inventory.json` inventories 4,422 direct Errout calls, including
228 nonliteral first arguments; the largest direct literal argument is 147
bytes. It includes unrelated tools and error paths and proves no reachability
or invocation bound. To regenerate this optional audit input from the exact
pinned source tree:

```sh
python3 docs/evidence/retained-producer-frontend-diagnostics-20261024/inventory.py --gcc-root /path/to/pinned/gcc/ada
```

The inventory reader checks every scanned complete source against the prior
manifest before extracting argument expressions. The ordinary check above
reconciles its source identities and recorded totals without requiring a GCC
source checkout.

The manual obligations are explicit in the companion note: the fixed-source
event reduction, Main fixed-dependency noninterference, Normal/Treat_As_Error
and brief/pretty option correspondence, raw-message recipe classification, and
the separate absence of displayed earlier GCC diagnostics. Neither lexical
inventory nor positive table counts prove these obligations by themselves.
The argument records the focused independent source review and its exact input.

The broad raw-history envelope does not become a printed-line length. It is
deliberately separate from native formatted text, fixed buffer indices and
later SPARK reporting. Physical resources and source-to-installed-tool
correspondence remain existing premises. No current language/admission or
production command was changed.
