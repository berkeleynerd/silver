# Selected ordinary-map writer closure

2026-10-19, Linux x86-64, research [#119](https://github.com/berkeleynerd/silver/issues/119).
For the selected literal Main native invocation, **no ordinary source-map
backing request follows gigi's preallocation**. Combined with the accepted
[preallocation argument](retained-literal-ordinary-maps.md), the entire
ordinary-map array lifetime therefore has at most three GGC requests:
8,192, 32,768 and 131,072 bytes, with zero finalizers. This is a source argument
under the same selected configuration and source-correspondence premises;
it is not a measured trace or a whole-native capacity result. Independent
review of this new closure is pending.

The [packet](../evidence/retained-literal-ordinary-map-writers-20261019/README.md)
retains a complete symbol-reference census over the available `gcc` and
`libcpp` source trees, identities of matching and supporting files, and an
offline consistency check. The census includes declarations and comments and
does not purport to be a parsed call graph. Reachability follows from the
entry points and configuration exclusions below, rather than from the absence
of a function name in a small set of files. The GCC source revision remains
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; no installed tool or pin changes.

## Entry and storage boundary

The existing [invocation argument](retained-literal-invocation-join.md) supplies
the actual-source Main compile role: `-c -x ada`, O0, no debug, x86-64 generic,
the three reviewed native selectors and controlled naming/mapping inputs.
There is no `-flto`, `-fself-test`, plugin, user specs, response file, comparison
mode or alternate frontend. These are properties of that selected graph and
its controlled environment, not new optional predicates that a caller can
assert. The Main source family admits no free-form compiler-options pragma.
This note does not generalize its bound to an arbitrary GNAT invocation.

`toplev.cc:1145–1149` creates the one `line_table`, initializes it and installs
the GGC reallocator. `misc.cc:104–124` selects GNAT's own Ada driver, and
`misc.cc:377` sets zero range bits. The accepted gigi loop in `trans.cc:346–363`
then creates exactly one ordinary map per permanent source entry under its
logical-line and population premises. Those premises, the 1,589-entry upper
bound and eight-column-bit argument are unchanged here.

`libcpp/line-map.cc:470–523` owns ordinary backing growth: `line_map_new_raw`
rounds and reallocates the ordinary array only when called with `macro_p=false`
and additional demand. Its direct callers are `new_linemap` and C++ module
deserialization. The former is reached for ordinary maps through `linemap_add`,
including its line/column and module wrappers; macro maps have separate backing.
The census covers the raw allocator, `linemap_add`, `linemap_line_start`,
`linemap_position_for_column`, `linemap_module_loc` and `linemap_module_restore`.
It also records ordinary backing/count member accesses and the mutable
`LINEMAPS_ALLOCATED`/`LINEMAPS_USED` accessors. The only ordinary storage/count
writes beyond this allocator/initialization are libcpp's preprocessing rewind
and the standalone diagnostics manager's destruction, both excluded below.
Lookup cache changes and module `included_from` changes do not resize backing.

## Remaining entry points

| Family | Source reason it adds no later ordinary map on this route |
| --- | --- |
| Ada source locations | All four allocating-API calls in Ada are the accepted gigi preallocation. Later `Sloc_to_locus`, `trans.cc:11006–11036`, selects the existing file-indexed map and calls `linemap_position_for_line_and_column`. That routine, `line-map.cc:1057–1079`, computes a location and may raise `highest_location`; it never calls an allocator, line-start or column-growth routine. |
| Other frontends | C/C++, Algol68, COBOL, D, Fortran, Go, JIT, Modula-2 and Rust writers belong to their language-specific entry points. `Make-lang.in:298–309,592–594,757,793–797` links the Ada frontend and shared backend. `-x ada` selects its hook; it does not enter another parser. C++ module imports/restores and raw map deserialization are confined to `cp/module.cc`. |
| LTO deserialization | `lto-streamer-in.cc:430–485` creates maps from its queued streamed locations. This route has no LTO input or LTO reader. The two shared IPA ODR paths in `ipa-devirt.cc:985–986,1871–1872` call it only through a non-null `lto_location_cache::current_cache`; the static starts null (`lto-streamer-in.cc:381`) and is set only by the reader cache constructor (`lto-streamer.h:280–292`). Other calls consume `data_in` streamed input. Ordinary native Ada compilation neither constructs that reader nor queues its locations. |
| Shared diagnostics/input/dump self-tests | Every allocating-API occurrence in the eight files listed below lies in its CHECKING_P self-test section. Their test entry points run through `selftest::run_tests`, called by `toplev::run_self_tests`, and the latter is reached only for `flag_self_test` (`toplev.cc:2275–2289,2391–2397`). The selected argv does not set it. This exclusion does not assume CHECKING_P is disabled in the installed compiler. |
| Runtime physical-location maker | This is genuine runtime code, not a self-test. `diagnostics/physical-location-maker.cc:35–72` can enter/rename a map and grow its line/column encoding. Its clients are `gcc_json_context` and the standalone `libgdiagnostics` manager. `json-diagnostic.cc:255–270` forwards to it, but that context's sole external construction is AArch64 JSON tuning (`config/aarch64/aarch64-json-tunings-parser.cc:524`), not the selected x86-64 target. The diagnostics manager is a separate library (`Makefile.in:2374–2375,2474–2480`), not a GNAT frontend client. Shared ordinary diagnostic printing and JSON/SARIF output do not instantiate this input-location maker. |
| libcpp lexer, directives, files and PCH | These APIs act on a `cpp_reader`. Its construction sites are C-family/C parsers, Fortran preprocessing, the build-time `genmatch` tool and `input.cc` self-tests. Ada initializes its own driver, with no `cpp_reader` client. Linking libcpp for line-map/identifier support does not start the C preprocessor. The file-change/directive, lexer column, PCH restoration, `CPP_INCREMENT_LINE` macro and `init.cc:840` rewind therefore have no reader on this route. No macro expansion is entered either. |

The self-test sections containing all named map writers are:

| File under `gcc/` | CHECKING_P section |
| --- | --- |
| `input.cc` | 1106–3369 |
| `opt-problem.cc` | 95–334 |
| `dumpfile.cc` | 2144–2796 |
| `diagnostics/changes.cc` | 902–1854 |
| `diagnostics/context.cc` | 2001–2333 |
| `diagnostics/source-printing.cc` | 4040–7048 |
| `diagnostics/paths-output.cc` | 1460–2794 |
| `diagnostics/sarif-sink.cc` | 4668–5426 |

The retained check verifies all census matches against these intervals and
their exact preprocessor boundaries. The human source argument additionally
checks their self-test ownership and the flag-gated entry. Compiled availability
alone is not treated as runtime reachability.

## Composition and limits

After the accepted preallocation, no reachable function in this selected
native Main route can increase ordinary map demand or resize its backing.
Thus the three accepted requests cover the ordinary-array lifetime, and later
ordinary-array demand is zero. This charges neither the global line-table
control, combined/ad-hoc locations, source filenames, warning containers nor
collector metadata; their existing owners and remaining obligations persist.
No old backing release earns negative allocation credit.

The accepted preallocation leaf remains frozen and continues to call its own
result preallocation-only. Its aggregate attachment is independently scoped;
this new lifetime result still needs reviewed attachment. Shared 768-event,
partial 2,312-event and separate location/warning ledgers are unchanged. Native,
proof and parent capacity totals remain unknown. The argument does not close
the generated-binder or GNATprove phases by analogy, and full current-grammar
composition remains part of #119.
