# Session formatter prefix review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**The queue/accumulator argument is accepted. The installed formatter-family
closure needs one bounded correction before acceptance.** Two additional setter
clients in the linked OCaml compiler library are absent from the stated family.
Their source bodies appear to admit a zero-charge extension; this review found
no counterexample with a nonzero Why identifier charge.

## Inputs and review record

Frozen target: `1ad16d731098e98e94caaa91f0a39f4b58bd6eb8`, specifically the
[formatter note](../research/retained-why-session-formatter-prefix.md) and its
[20261019 source packet](../evidence/retained-why-session-helper-source-20261019/README.md).
The accepted binder input is `98fdd88dbf4962c9140493dcf783beb66bf85144`, reviewed
in `960ed47da20ff4534ee52b23f6493d22a8bcff4e`. The helper-read coverage packet
remains a separate missing-input result, not new runtime evidence here.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime model/effort confirmation, token usage and monetary cost are unavailable.
Review began **00:28:47 UTC** and reached the report checkpoint at
**00:35:59 UTC**, **432 seconds** at one-second resolution, including report
preparation and excluding final commit. This is reviewer wall time, not native
execution time or whole-team cost. Actual host is Linux 7.0.14 x86_64. A separate sparse review worktree
preserved the target; only this report is committed. The live subthread harness
goal was null. The lead's continuing full-current-grammar #119 authorization,
unchanged Oracle, source-correspondence and review rules govern this review.

No target, debugger, disassembler, compiler, proof, solver, native run, broad
suite, corpus replay, GitHub write or recursive delegation was performed.
Two additional matching official source files were read into review scratch.
CLI memory was not updated. The existing successful packet checks
(**0.440460635 seconds**, then **0.477335563 seconds**) and earlier binder/replay
evidence were inspected and reused, not rerun.

## M1 — Close linked compiler-library formatter updates

The note's finite-family table and preservation paragraph keep `out_string`
primitive and list default/Why ANSI tag functions. The lexical setter census
covers Why's `src/` and `plugins/` projection, but the installed executable also
contains these setter clients:

| Installed client/site | Setter target | Retained executable bytes |
| --- | --- | --- |
| `camlDynlink_compilerlibs__Misc__set_color_tag_handling_2742`, `0x8a28b9` | `pp_set_formatter_stag_functions`, `0x988080` | `e8c2570e00` |
| `camlDynlink_compilerlibs__Location__print_updating_num_loc_lines_465`, `0x8b41d9` | `pp_set_formatter_out_functions`, `0x988d50` | `e8724b0d00` |
| Same Location function, `0x8b420e` | Same output setter | `e93d4b0d00` |

These were located with a conservative E8/E9 relative-target byte scan over
executable ELF sections, assigning candidate sites to enclosing function
symbols. This is a diagnostic, not a decoded whole-program call graph or a
completeness claim about indirect calls. The exact five-byte spans above match
the already pinned executable. Matching OCaml source independently confirms
that the named routines are real setter clients:

- [`utils/misc.ml`](https://raw.githubusercontent.com/ocaml/ocaml/8eb41f72ded84df884c3671734c947f612091f84/utils/misc.ml),
  34,344 bytes, SHA-256
  `d13bfe71d818cd561cf72e6b50f57334290add9046acde84a015e594194575b3`.
  Lines 681–703 wrap prior open/close tag markers with color handling and
  fallback to those prior markers. `Color.setup` at 719–738 targets the standard,
  error and string formatters. This is distinct from Why's `Util.ansi_color_tags`.
- [`parsing/location.ml`](https://raw.githubusercontent.com/ocaml/ocaml/8eb41f72ded84df884c3671734c947f612091f84/parsing/location.ml),
  30,099 bytes, SHA-256
  `2354eb8d74e8286eef4251ace8b50d3cb8b501ddb6444c98e1488a3e501e2891`.
  Lines 120–134 replace `out_string` with newline counting followed by the
  snapshotted old `out_string`; restoration follows the supplied printer and
  flush. An exception before restoration can leave this wrapper installed.

Both source reads returned HTTP 200 at the exact selected OCaml revision.
They establish the omitted source cases under the same scoped correspondence
premise as the candidate; they do not prove these routines ran in PID 97103.

**Required disposition:** either exclude these clients from every relevant
initialization/preservation prefix with supporting evidence, or extend the
callback family and correspondence evidence to cover them. For the latter,
newline counting plus delegation to an admitted old output function and color
handling plus delegation to admitted old tag markers have the expected zero
Why identifier effect. Account for retained wrappers after interrupted
restoration; separating future exceptional printing does not by itself prove
that the starting formatter has only the listed callbacks. Reconcile other
linked-library formatter clients with that prefix argument as well. No new
native observation is justified by this finding alone.

This is a missing proof edge, not an observed identifier registration, a
production defect, or a claim that complete `R` should already have been closed.
It affects the note's conclusion that the unobserved standard formatter roots
have the stated finite family. The ordinary data-queue argument survives.

## Accepted source and evidence findings

`Format.pp_token` contains no directly callable printer alternative. Extensible
semantic tags can carry arbitrary payloads, but the default functions inspect
`String_tag` and ignore unknown constructors. Merely retaining a closure as an
opaque payload does not execute it. `Acc_delay` belongs to a distinct accumulator;
`make_printf` constructs it for `%a`/`%t`, and `output_acc` invokes it before
`kfprintf`'s continuation. `kdprintf` can retain an accumulator closure, but does
not insert one into `pp_queue`. Flushing queued output therefore does not replay
an earlier logical-term printer.

The inspected queue processor, tag-stack clearing, flush and reinitialization
paths invoke only the formatter's callable fields. Flush/reinitialization does
not replace those fields. This argument does not need a queue-length, byte-count,
termination or allocation bound to establish zero direct identifier work.

The Why setter census agrees with broader source searches for constructors,
output/tag record fields, setter aliases, unchecked mutation and parser actions.
Why uses buffer/channel formatter constructors. The Debug wrapper captures the
old output record and delegates to old newline then old flush; `Pp.wnl` delegates
to old spaces. Repeated installation of those wrappers preserves a finite
capture chain. Default newline/spaces read the current output-string field, so
that field's closed family remains essential. The actual environment's absence
of `GNATWHY3LOG` and the prior empty statistics registry retain their original
captured scopes; neither supplies missing standard-formatter words.

The Compress entry stores tagged false and constructs both exported channel
modules from Stdlib function fields. Its source matches `compress_none.ml`;
the absence of Gzip/Zlib symbols corroborates that choice. This is installed
initialization evidence, not use of static BSS as a live value.

Independent identity/ELF verification passed in **0.207042792 seconds**. It
checked seven dependency identities, five local-input identities, every one of
the 612 unique archive members, 29 comparisons with overlapping prior source
members, all ten native bodies and **9,110 bytes**, and all nine embedded-version
offsets. The independent ELF reader used program headers for address-to-file
mapping and checked symbol addresses/sizes. Neither embedded `4.14.2` nor the
selected-body comparison is a universal source/binary refinement theorem.
The zero-charge field in `result.json` is a conclusion of the prose argument,
not a theorem established by its lexical consistency checker.

The exceptional boundary is correctly left open. GNAT's outer and uncaught
exception handlers reach `Exn_printer`; its registry can invoke Pretty branches
that open term binders. Primitive normal format strings do not eliminate that
route. Runtime I/O explicitly calls pending-action processing; the existing
signal/finalizer/foreign-hook obligations remain separate. Reentrant save work
cannot be silently charged to the zero formatter component.

**Disposition:** accept the queue/accumulator separation, the inspected Why
wrappers and Compress selection; request the M1 prefix-family correction before
accepting the installed normal-formatter closure. `B = 966`, the same-process
1,145 accounted inline registrations and their conditional interface are
unchanged. Complete `R`, the composed endpoint, whole-pipeline/full-grammar #119
capacity and production #88–#94 remain unfinished. Oracle, tool pins and current
admission are unchanged.
