# Formatter prefix repair review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119)
and review finding [#142](https://github.com/berkeleynerd/silver/issues/142).
**Accept the bounded M1 repair. No new material finding.** The corrected
formatter family includes the linked Location and Misc.Color wrappers and
preserves zero direct Why identifier work when wrappers survive, nest or are
partially restored. This acceptance retains the stated source/runtime,
typed-heap and fixed-loaded-context premises. Complete `R` and exceptional
unwinding remain open.

## Inputs and review record

Frozen repair target: `72096d190945da9e9697627b81e3631387574b8a`, specifically
the [repair note](../research/retained-why-session-formatter-prefix-repair.md)
and all ten files of its
[evidence packet](../evidence/retained-why-formatter-prefix-repair-20261019/README.md).
The original finding was read from
[`review-why-formatter-prefix-1ad16d7310.md`](review-why-formatter-prefix-1ad16d7310.md)
at integration commit `2590c68fe9`; its recorded report commit is
`6f5d6a7775a5bd421f674aa9915e0ce7a352119c`. The original formatter note and
dependency blobs were read at the frozen repair target, whose base is
`1ad16d731098e98e94caaa91f0a39f4b58bd6eb8`. Previously accepted queue/accumulator,
Why-wrapper and Compress-selection results were reused.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime model/effort confirmation, token usage and monetary cost are unavailable.
Review began **01:02:06 UTC** and reached the report checkpoint at
**01:06:57 UTC**, **291 seconds** at one-second resolution, including report
preparation and excluding final commit. This is reviewer wall time, not native
execution time or whole-team cost. Actual host: Linux 7.0.14 x86_64. Work used an isolated sparse worktree
at the exact repair commit; only this report is committed. The live subthread
harness goal was null. The continuing owner-authorized #119 work, unchanged
Oracle and source-correspondence requirements govern this bounded review.

No target execution, native capture, debugger, disassembler, compiler, prover,
solver, full/aggregate/predecessor Context, successful suite replay, source or
executable census replay, GitHub write or delegation was performed. CLI memory
was not updated. The packet's retained final successful check
(**1.6498485049996816 seconds**) was inspected and reused, not rerun.

## Preservation argument

At OCaml revision `8eb41f72ded84df884c3671734c947f612091f84`,
`parsing/location.ml:120–134` installs newline counting followed by the saved
record's `out_string`. The installed closure captures that record; the supplied
printer `f` is called immediately by the enclosing helper and is not a captured
output action. The retained installer, output wrapper and count bodies agree:
the installer captures the saved record, calls `f` through `caml_apply2`, flushes
and restores; the output wrapper counts and delegates through the saved record
using `caml_apply3`.

This proves the required new formation rule without assuming restoration.
Starting from an admitted output function, installation creates an admitted
counting wrapper; leaving it installed preserves membership; restoring an old
snapshot also preserves membership. A nested installation can retain multiple
layers, including after failure of `f` or flush. Each finite installation
history supplies earlier captured output functions. String-bound failure or
stack exhaustion exits this component; it does not turn the counting body into
a Why identifier constructor. The enclosing printer and subsequent exception
dispatch are separate obligations.

`utils/misc.ml:609–738` supplies the other new rule. Recognized string tags and
`Style of style list` carry color/style data, not callable fields. Open/close
markers compute ANSI or empty strings; an unrecognized tag delegates to the
captured prior marker. The retained `mark_close_tag` body checks the `Not_found`
exception before calling the saved fallback; other exceptions propagate. The
setter wraps the two saved markers and preserves both print callbacks. Thus
unknown extensible-tag payloads are not executed. `setup` names the standard,
error and string formatters, but acceptance does not depend on that setup having
run in the captured process, on color enablement or on the once-only guard.

The preservation claim also survives interruption between field assignments.
`Format.pp_set_formatter_out_functions` at lines 863–874 assigns five fields
separately; its tag counterpart at lines 580–589 assigns four. Every old and new
field value in these admitted updates satisfies the relevant formation rule.
A mixture of those values, or restoration of a stale snapshot, can affect output
behavior while preserving this property. Default newline/spaces functions read
the current admitted output field; previously accepted Debug/Pp wrappers call
their saved admitted callbacks. Interleaving these updates cannot introduce the
immediately supplied Location printer into the formatter fields.

Consequently, the accepted queue/accumulator distinction applies to the enlarged
family. There is no bounded-layer-count premise, termination claim, allocation
bound or output-fidelity claim. Pending-action processing reached by allocation
or I/O remains at the existing unclosed runtime boundary. The zero in
`result.json` records the prose conclusion under these premises; it is not a
theorem established by the packet's lexical checker.

## Linked-client reconciliation and independent evidence

The retained source census covers 2,708 selected OCaml files and 603 Why files.
I inspected its relevant production matches and the native candidate inventory.
Outside Format, the recorded non-Why mutators are the two repaired compiler
library clients. Additional production OCaml matches construct buffer/channel
formatters; tests, ocamldoc and standalone tools are distinguished from linked
Dynlink compiler-library clients. The retained installed bodies reconcile
Shape's channel constructor, Sexplib0 and Re's buffer constructors and the four
Yojson channel constructors. Their subsequent supplied printers are not claimed
to be zero-charge formatter fields.

The twelve named native targets cover modern/deprecated output/tag mutators and
the relevant constructor APIs. The 51 recorded E8/E9 candidates include the
original three setter sites at `0x8a28b9`, `0x8b41d9` and `0x8b420e`; their bytes
and destinations agree. The twelve recorded aligned pointer words name Format
static closure objects. Both retained plugin symbol inventories agree with the
note; a Format module-symbol reference is not used to exclude indirect access.

One independent diagnostic passed in **0.6196102039975813 seconds**. It used
Python's standard library, a separately written ELF64 program-header mapper and
symbol-table reader, with frozen Git blobs for dependencies. It checked:

- Four dependency identities, three local-input identities, all three installed
  executable/plugin identities and the complete retained OCaml archive identity.
- The eight source files read for this review against the archive and recorded
  source identities; all eight prior selected OCaml source overlaps, plus the
  prior `VERSION` member, agreed exactly.
- All twelve target symbol addresses, all fourteen body symbol addresses/sizes
  and every retained byte span: **2,352 bytes**, including retained padding.
- The 51 recorded branch spans, their relative destinations and enclosing
  function symbols; the twelve recorded pointer words and their closure labels;
  both plugin Format-symbol inventories.
- `complete_R = null`, `full_R_established = false` and
  `composed_endpoint_established = false` in the retained result.

This diagnostic verified the recorded candidates, without searching the
executable for additional candidates or repeating either corpus census. Review
scratch is retained under the isolated worktree's `tmp/`; the diagnostic script
SHA-256 is `a6f635997acd7c1655f151ad6147074bb43b464976ea4a6f46bf27ffdd7d78b0`,
and its result SHA-256 is
`2bf772f69404adb3722dc41d62c7cfdddff0a9d80ec0bd7c1acef4b82b6f9d50`.

The repair correctly treats lexical matches, raw branch candidates, static
pointer words and plugin symbols as diagnostics. They do not establish
indirect-call completeness or universal source/binary refinement. The corrected
family reconciles the discovered linked clients under the same scoped premises;
it does not license arbitrary callback installation or unmodeled foreign or
unchecked mutation. I found no omitted client in the reviewed inventory that
contradicts that bounded repair.

**Disposition:** M1/#142 is satisfied at the frozen repair target. `B_binders =
966`, the separately accounted inline registrations and the conditional
`63,573 + 2R` expression are unchanged. That expression is not an established
endpoint. Exceptional unwinding, complete `R`, full-grammar/pipeline #119
capacity and production #88–#94 remain unfinished. Oracle, tool pins and current
admission are unchanged. The lead owns issue/publication and harness bookkeeping.
