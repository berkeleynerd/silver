# Session helper formatter prefix: data queues and safe output callbacks

Research [#119](https://github.com/berkeleynerd/silver/issues/119), Linux x86_64,
2026-10-19. The missing live formatter descendants in PID 97103 do **not** by
themselves require another observation to bound normal formatter work.
Under the existing relevant source/runtime correspondence and valid typed-heap
premises, a finite callback-family invariant gives **zero additional Why
`Ident.id_register` calls from those formatter paths**, for arbitrary pending
queue contents admitted by the formatter's source type. This resolves the
formatter-state obstruction, not complete `R`: exceptional unwinding remains
separate. The [binder packet](retained-why-session-save-state.md) and its
conditional endpoint are unchanged.

## Matching sources and installed implementation

The [new packet](../evidence/retained-why-session-helper-source-20261019/README.md)
retains official OCaml source at the already selected commit
`8eb41f72ded84df884c3671734c947f612091f84`. Its `VERSION` is **4.14.2**;
the prior retained installed-runtime record identifies that string at nine
offsets of the same executable SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The new checker verifies those bytes. Each new source has its exact official
commit URL, HTTP result and SHA-256. No version substitution, installed-tool
change or pin change occurred. This extends the existing scoped correspondence
premise; an embedded version is not a universal source/binary refinement proof.

Eight newly retrieved files cover Format, its abstract interface, both internal
format modules, Buffer, Printexc, runtime I/O and VERSION. The previous pinned
`stdlib.ml` is also retained. Ten additional bodies, **9,110 bytes**, were
extracted from existing disassembly and checked against the pinned executable:
Format initialization, its constructors/setters/queue flush/accumulator runner,
the Debug newline wrapper, `Pp.wnl`, and Compress initialization. Together with
the prior packet's nine helper bodies, they corroborate the source interfaces
used below. No target, debugger or disassembler was executed.

The installed `camlWhy3__Compress__entry` stores tagged false in
`compression_supported` and fills both exported channel modules from Stdlib
functions. There are no Gzip/Zlib module symbols. This corresponds to pinned
`src/session/compress_none.ml`, **not** `compress_z.ml`. The selected save path
therefore needs ordinary channel I/O, not an additional compressor callback
closure. This is installed code evidence, not a runtime value inferred from BSS.

## Queue state does not retain arbitrary printers

`format.ml:68–102` defines the formatter queue token type. Its alternatives
contain strings, numbers, boxes, tab-stop data or an extensible semantic tag.
There is no function-valued token field. `pp_queue_elem` and the queue retain
these tokens (`format.ml:106–114`). The open tag's payload may have any OCaml
representation, but the default tag functions match `String_tag` and ignore
other constructors; they do not execute an extension payload.

Custom `%a` and `%t` printers do exist in a **different** type:
`CamlinternalFormat.acc` has `Acc_delay` (`camlinternalFormat.ml:120–140`), and
`make_printf` constructs it for those conversions at 1544–1546.
`Format.output_acc` invokes that function synchronously at `format.ml:1308`.
`kfprintf` consumes the accumulator before its continuation (`1354–1358`).
It does not place `Acc_delay` in `pp_queue`. `kdprintf` can explicitly return
an accumulator closure, but that is also not a queue token.

Consequently flushing arbitrary pending formatter tokens cannot revive an
earlier task/term printer merely because it was used by a preceding `fprintf`.
The callbacks reachable from the queue processor are the formatter's output
and semantic-tag function fields. The source family below closes those fields.
No bound on pending queue length, output byte count, termination or memory
allocation is claimed or needed for the zero identifier-registration charge.

## Finite callback-family invariant

The invariant is about callable fields, not exact heap addresses or queue sizes:

| Callable field or operation | Admitted implementation | Why Ident effect |
| --- | --- | --- |
| Output string | `Buffer.add_substring` or Stdlib `output_substring` on a captured buffer/channel | none |
| Flush | `ignore` or Stdlib `flush` on a captured channel | none |
| Default newline | `display_newline`, invoking the same formatter's output-string field | none |
| Spaces/indent | `display_blanks`/`display_indent`, invoking that output-string field | none |
| Debug newline wrapper | old newline, then old flush | none |
| `Pp.wnl` newline wrapper | old spaces with argument 1 | none |
| Default semantic tags | strings for `String_tag`, empty strings for other tags; print functions `ignore` | none |
| Optional Why ANSI tag functions | string parsing/concatenation and primitive formatting | none |

Base construction is `pp_make_formatter`/`make_formatter`
(`format.ml:924–1007`). Constructors choose the output-string/flush pair and
install the standard newline/spaces/indent functions and default tags.
`std_formatter` and `err_formatter` are channel formatters; `str_formatter`
is a buffer formatter (`1021–1023`).

The retained whole Why `src/` and `plugins/` source projection has a reproducible
setter inventory. The behavior relevant to this invariant is:

- `Debug.set_debug_formatter` snapshots the existing output record, replaces
  only newline with old-newline followed by old-flush, and publishes that
  formatter (`debug.ml:65–75`).
- GNAT constructs `escape_formatter` with `formatter_of_buffer`, then applies
  that Debug wrapper (`gnat_main.ml:265–268`). The optional log branch constructs
  a channel formatter and applies the same wrapper (`322–330`); it is not taken
  by the exact retained environment, which lacks `GNATWHY3LOG`.
- `Pp.wnl` changes newline to invoke the snapshotted spaces function
  (`pp.ml:189–199`), preserving this family even if it is included conservatively.
- The remaining active Why tag-setter call is the separate why3prove tool's
  ANSI-color setup; its `Util.ansi_color_tags` functions manipulate strings and
  primitive formatting (`util.ml:82–116`). Including this family conservatively
  does not add Why identifier registrations.

The inventory retains interface declarations and comments as well as calls;
it is not itself a semantic completeness theorem. The argument also uses the
source type abstraction (`format.mli` makes `formatter` abstract), the fixed
loaded source context, and the existing exclusion of unmodeled foreign mutation.
It does not generalize to an application allowed to install arbitrary output
functions or use unchecked mutation of formatter records.

The wrappers capture prior function records. Their finite initialization chain
bottoms out in primitive buffer/channel operations; none changes the base
output-string callback into a logical printer. Default newline/spaces functions
may read the formatter's current output-string field, but every admitted update
preserves that base family. No direct inlining or session-save operation installs
another output or tag callback. The current capture's Debug tag flags are false
and its tag fields point at the static default closures; the source-family
argument does not require using those observations to ignore latent tag tokens.

`format_pp_token`, `advance_left` and `pp_flush_queue` inspect queue data and
invoke only this family. `pp_print_flush` first drains the queue, then calls
the flush field. Thus all these paths preserve the family and do not call Why
identifier constructors. The same holds for the source-identifiable standard
formatters even though their runtime root words were not captured. Reentrant
save callbacks may affect queue/format state, but the direct save paths do not
replace these callable fields; their binder work is charged separately by the
accepted two-save interface.

## What remains before complete R

This argument covers normal formatter work, direct buffer/channel output and
the installed no-compression choice. It does not replace the separate runtime
callback premises: allocation and I/O can reach pending-action dispatch, whose
signal/finalizer/foreign-hook obligations stay in their existing scope.

An actual exceptional exit route is visible in the pinned source. If save or
exit output raises, the exception can unwind to GNAT's outer handler
(`gnat_main.ml:356–362`), which calls `Exn_printer.exn_printer`. GNAT also installs
an uncaught-exception handler (`gnat_util.ml:12–23`) that uses this printer and
then emits primitive JSON through `abort_with_message` (`4–9`). These are source
routes, not an observed failure of this run or a revived missing-raw-task witness.

`Exn_printer` dispatches registered callbacks (`exn_printer.ml:22–49`). Some
registered handlers, such as `Pretty`'s `Term.TermExpected` and `FmlaExpected`
branches (`pretty.ml:850–853`), can print logical terms and open binders. They
cannot be given zero charge merely because the normal serialization formats
are primitive. The next source obligation is to classify the exceptions
reachable from this valid session's save/exit paths and every intervening
wrapper, then prove that the applicable registered-printer branches preserve
the charged state and add no uncharged binders (or supply their bound).

The retained source corpus and exception-registration inventory support that
next check. No additional live formatter root is required for the normal
formatter invariant just established. No next native experiment is proposed
without first exhausting this narrower exception/source question. **Complete
`R`, the composed endpoint and complete callback capacity remain unestablished.**
