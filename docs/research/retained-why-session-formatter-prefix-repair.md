# Formatter prefix repair: linked-library wrappers

2026-10-19, Linux x86_64. This disposes of M1 in review
`6f5d6a7775a5bd421f674aa9915e0ce7a352119c`, tracked by
[#142](https://github.com/berkeleynerd/silver/issues/142), within
[#119](https://github.com/berkeleynerd/silver/issues/119). It supersedes the
primitive-only `out_string` row and the incomplete tag-family/preservation
paragraphs in the frozen [formatter prefix note](retained-why-session-formatter-prefix.md)
at `1ad16d731098e98e94caaa91f0a39f4b58bd6eb8`. That note and its evidence remain
unchanged. The accepted queue/accumulator distinction, Why wrappers and
`Compress_none` selection are reused.

The normal formatter component still has **zero direct Why identifier
registrations under the scoped source/runtime correspondence, valid typed-heap
and fixed-loaded-code premises**. Its family includes the linked OCaml
compiler-library wrappers below, even when an exception or interruption prevents
restoration. This is not a zero-charge claim for the surrounding supplied
printer, exception handling or runtime callback dispatch. **Complete `R` remains
null.** No complete endpoint or callback-capacity result is asserted.

## Corrected family and preservation

The family is given by a finite set of formation rules; the number of installed
wrapper layers is not fixed by the argument. Each actual finite initialization
prefix produces finite captured chains.

| Field | Admitted formation rule | Direct identifier effect |
| --- | --- | --- |
| Output string | Primitive buffer/channel output, or Location newline counting followed by an admitted saved output-string function | zero |
| Flush | Primitive channel flush or `ignore` | zero |
| Newline, spaces, indentation | Format defaults reading the current admitted output string; Debug's saved newline then saved flush; `Pp.wnl`'s saved spaces | zero |
| Tag markers | Format defaults; Why ANSI functions; or compiler-library Color handling with fallback to an admitted saved marker | zero |
| Tag print callbacks | Default `ignore`, preserved by the admitted updates | zero |

`parsing/location.ml:120–134` snapshots the whole output record. Its newly
installed `out_string` counts newline characters, adds the count to
`num_loc_lines`, and delegates to the snapshotted `out_string`. The arbitrary
parameter `f` is invoked immediately by `print_updating_num_loc_lines`; it is
**not captured by this output wrapper**. The wrapper captures its saved output
record, not a route back to `f`. `f`, its immediate effects, and exceptional
printing require their own analysis.

The helper flushes and restores the old record only after `f` returns. We do not
assume that either step succeeds. Installing the wrapper preserves the family;
leaving it installed preserves the same family; restoring any previously
snapshotted admitted record also preserves it. Nesting or interruption can
therefore leave several counting layers without introducing a logical printer.
The counting operation and its possible arithmetic or string-access failure
are not an identifier-construction operation. An exception can leave this
component and enter separately unclosed exceptional handling.

`utils/misc.ml:609–738`, module `Color`, is a distinct tag implementation from
Why's `Util.ansi_color_tags`. `style_of_tag` recognizes the three named string
tags and `Style of style list`. Colors and styles are data with no callback
fields. For a recognized tag, the marker computes an ANSI string or an empty
string; for an unrecognized tag it invokes the captured prior marker. It never
executes the representation of an opaque extension payload. Its setter replaces
only the open/close markers, preserving the print callbacks, and enables mark
tags. `setup` names all three standard formatters. The proof includes this
installation regardless of whether that setup ran in PID 97103 or a particular
environment enables colors. Its once-only guard is unnecessary to the
zero-charge argument: repeated installations still preserve the family.

The inductive argument permits interleaving the Why, Location and Color
updates. An output wrapper captures earlier callbacks; a tag wrapper captures
earlier markers. Default newline/spaces may read the current formatter's output
field, but every admitted replacement of that field remains in the corrected
family. Failed restoration, successful restoration of a stale snapshot, and
reentrant queue operations can change formatter behavior without adding a
logical printer to these fields. We claim no output-fidelity, termination,
allocation, queue-size, byte-count or wrapper-depth bound here.

The already accepted `pp_token`/`Acc_delay` separation therefore applies with
this larger family. Queue draining calls these admitted fields; it does not
replay the synchronous `f` passed to Location or the `%a`/`%t` printer used to
produce an earlier format accumulator. Pending-action processing reached by
allocation or I/O remains at the existing runtime callback boundary.

## Reconciliation beyond the Why source census

The [repair packet](../evidence/retained-why-formatter-prefix-repair-20261019/README.md)
retains the complete official OCaml archive at the **same selected revision**
`8eb41f72ded84df884c3671734c947f612091f84`. Its two review source hashes match
exactly. A reproducible lexical census now covers all **2,708** ML/interface/
lexer/parser/C/header files in that archive, including tests and tools, and
repeats the relevant patterns across the existing **603** Why files. The new
patterns include constructors and output/tag record-field assignments, as well
as modern and deprecated setters and their unqualified names. This keeps
comments, interfaces and examples rather than silently interpreting them as
calls or excluding aliases by qualification.

The production OCaml library matches outside Format identify Location's two
output setters and Misc.Color's tag setter. Other production constructor
matches are channel/buffer construction in `driver/compmisc.ml`,
`middle_end/flambda/inlining_stats.ml`, `typing/parmatch.ml` and
`typing/shape.ml`. The full inventory also records compiler tests and standalone
tools, including `ocamldoc/odoc_print.ml`'s newline wrapper; those are not
installed `Dynlink_compilerlibs` clients in this executable. Their mere presence
in the upstream archive is not a claim that those programs initialized these
formatters.

To reconcile the actual linked application, the packet independently scans all
executable ELF sections for raw E8/E9 references to the **12 named Format
output/tag mutators and constructors**. There are **51 candidates**. It also
records **12 aligned data words** holding these function addresses, all in
Format's static closure objects. The relevant groups are:

| Installed client group | Reconciliation |
| --- | --- |
| Why Debug and `Pp.wnl` output setters | Previously accepted saved-callback wrappers; unchanged |
| `Dynlink_compilerlibs.Misc.set_color_tag_handling` | Corrected tag rule above |
| `Dynlink_compilerlibs.Location.print_updating_num_loc_lines` | Corrected output rule and snapshot restoration above |
| `Dynlink_compilerlibs.Shape.output` | New channel formatter from `typing/shape.ml:37`; primitive base family |
| Sexplib0's `to_buffer_hum_inner` and Re.Fmt's `to_to_string` | Installed calls to `formatter_of_buffer`; primitive base family |
| Yojson Basic/Raw/Safe/T `to_channel` | Installed calls to `formatter_of_out_channel`; primitive base family |
| Other Why and GNAT constructor clients | Buffer/channel constructors in the retained pinned Why source; primitive base family |
| Format internal construction, deprecated adapters and exported aliases | Source implementations and closures of the API itself, not evidence that an application supplied arbitrary output/tag functions |

The two retained plugins are included at their existing exact identities.
`ada_terms.cmxs` has only `Format.fprintf` among its Format symbol references;
`gnat_json.cmxs` additionally names the Format module, buffer-based string
formatting/list formatting helpers, and `formatter_of_out_channel`. Its pinned
Why source supplies the corresponding constructor case. No plugin symbol names
an output/tag mutator. Reading the module symbol alone is not treated as proof
about which field is used.

The exact review sites are reproduced:

| Address | Bytes | Target |
| --- | --- | --- |
| `0x8a28b9` | `e8c2570e00` | `pp_set_formatter_stag_functions` |
| `0x8b41d9` | `e8724b0d00` | `pp_set_formatter_out_functions` |
| `0x8b420e` | `e93d4b0d00` | `pp_set_formatter_out_functions` |

Fourteen source-relevant native bodies, **2,352 bytes**, are extracted from the
previously retained disassembly and checked byte-for-byte against the installed
ELF. These include the three Location bodies, four Color bodies, Shape and all
six external constructor clients. Thus the repair does not substitute guessed
versions of Sexplib0, Yojson or Re source: it records their installed constructor
calls and uses the already matched constructor implementation. This is evidence
about those constructor sites, not a universal theorem about those packages.

The lexical census, raw branch-byte scan, static words and symbol inventory are
**diagnostics, not a decoded whole-program or indirect-call completeness proof**.
Source abstraction and the existing fixed-loaded-context and exclusion of
unmodeled foreign/unchecked mutation remain premises of the prefix argument.
We do not derive source/binary refinement from a version string, infer absence
of indirect clients from these scans, or extend the claim to applications that
can install arbitrary callbacks. The new evidence reconciles the linked clients
discovered by the review and expanded census with the corrected family; it does
not silently promote a lexical inventory into the semantic proof.

## Scope and continuation

M1 was independently confirmed and repaired by adding the two omitted formation
rules and their installed/source correspondence, not by excluding potentially
surviving wrappers. The bound `B_binders = 966`, the same-process accounted inline
registrations and conditional formula `63,573 + 2R` are unchanged. That formula
is not an established endpoint. The separate missing-word packet still means
what it said about the capture; no missing formatter words were invented.

The next authorized source task remains exceptional unwinding through GNAT,
`Exn_printer`, and every applicable wrapper. It will use a separate packet and
must distinguish reachable primitive exceptions from logical-term-printing
branches. This repair does not assign a charge to those branches or require a
new native observation. Root owns issue/publication/harness bookkeeping.
