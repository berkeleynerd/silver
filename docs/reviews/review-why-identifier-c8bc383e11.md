# Review of the retained inlining identifier counter

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Reviewed implementation commit `c8bc383e111b5b5d5460d5bb568bf37417cbe6eb`.
**Accepted within its accounted-source counter scope after metadata repair
`554839c115df02bb18208e92871651f72ac5472a`.** The private starting ref and its
composition with the accounted source registrations are supported. One
low-priority inventory metadata error was confirmed and fixed. No defect was
found in the counter, same-process attachment or explicit limitation of the
capacity claim.

## Inputs and scope

The review covers the [source argument](../research/retained-why-inline-identifier-state.md)
and all eleven files in the [new evidence packet](../evidence/retained-why-inline-identifier-state-20261018/README.md)
at the reviewed commit. Its `inputs.json` identifies the exact archives,
members, local inputs and reused preparation-entry, refinement, operations,
representative-state and comparand packets. The focused check verified those
identities. The source review inspected the new observer, launcher and native
disassembly, `Ident.id_register` and `Weakhtbl.create_tag`, the reused table
projection and input-isomorphism implementation, the accepted registration
arithmetic, and the seven selected OCaml runtime source files and destructor
disassembly. This review reuses the previously accepted local source bound;
it does not reprove every earlier transfer argument.

The installed executable was read as data to check ELF storage classification.
Its 24,561,432 bytes have SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`,
matching the retained executable identity. No native target, debugger,
compiler, solver, proof or broad suite ran during this review. The host was
confirmed as Linux x86_64 with `uname` and `scripts/dev.py paths`.

## Findings and evidence

The source and retained native instructions agree on one persistent private
ref, initialized to zero and reached through `Ident` module offset `0xe8`,
registration closure field 2. `fun_6183` loads that ref and adds two to its
tagged word before allocating the identifier. Its allocation slow path
returns after the increment; it does not repeat the increment. The retained
one-word ref contains raw `120993`, hence **60,496**. The source's
`create_tag` is identity. Reachable old tags are not used as a substitute for
this private state.

The observer flushes each successful memory read before interpreting it and
saves the core counter before optional auxiliary traversal. Its entire probe
and launcher are compared with the accepted predecessors, allowing only the
declared relocation and insertions. The stop occurs before the selected
`inline_trivial` application executes; the launcher kills the stopped
inferior after capture. Guards and final invariants pass. This is a shared
stop in one process, not a filename-based join between runs.

The focused check passed in **5.760381 seconds**. It replays the private-ref
and auxiliary observers, the full representative projection and exact
input-sharing join, and exercises arithmetic boundaries and malformed raw
state fixtures. It confirms 244 input roots, 14,477 exactly corresponding
input blocks, all 5,003 declaration-table buckets and 6,704 distinct old
objects. The new projection has 143 distinct mapped keys, 142 retained input
representatives and the same three strict-shape exclusions. Those actual
checks attach the accepted **E=8, V=6, T=3, A=80** envelope to this entry.

A separate bounded reviewer check independently compared all **326,456**
retained graph block headers and payloads with the raw memory log, then
re-executed the complete table observer against those recorded reads. The
table JSON and its roots matched exactly. All repeated address/size reads
in the **752,836** records from the private module-field read onward agreed;
there were 741,311 distinct recorded spans. This check passed in
**3.412746 seconds**. Its first helper attempt requested a combined
32-byte span where the original helper used separate 8-byte reads; it failed
with `KeyError` and was corrected to reproduce that read granularity.
That was reviewer helper rework, not a retained-capture failure.

The source arithmetic is `235 + 6*123 + 4 + 168 = 1145`, giving
`60496 + 1145 = 61641 < 2^62 - 1`. The callable requires natural integers,
checks the endpoint before claiming no overflow, handles zero registrations,
and propagates additional registrations. This establishes the endpoint only
for the accounted operations under the stated source/runtime, cache,
well-formedness and freshness premises. The positive snapshot does not prove
nonoverflow or noncollision in its prior history.

The report correctly distinguishes no foreign declaration insertion from no
foreign identifier registration. The selected C destructor bodies support
their bounded local non-registration observations; channel cleanup still
uses an indirect hook whose full ownership is unproved. The runtime
finalizer dispatcher can invoke `f.fun` through `caml_callback_exn`.
Textual Why3 and direct native-reference inventories do not exclude indirect
`Gc` wrapper/alarm use or library-held closures reaching identifier creation.
Complete callback registration/reachability, returning handlers and mutable
hook ownership remain open. Accordingly, complete continuing-call,
transformation, pipeline, family and auxiliary-capacity claims remain false.

All three managed attempts are preserved, including the exported/internal
module-shape error and the Hcpt constructor-tag error. Their totals agree
with **21.292916666003293 debugger seconds** and **27.194257249 managed
seconds**. The successful capture was not repeated. Diagnostic time/address
space limits are not presented as capacity evidence.

## L1: low-priority metadata finding, fixed

In `callback-inventory.json`,
`selected_installed_finalization_symbols.finalisable_first`,
`.finalisable_last` and `.running_finalisation_function` assign nonzero
`first32` strings to ELF zero-fill storage. Their respective addresses are
`0xfaec40`, `0xfaec20` and `0xfaec00`; the containing `PT_LOAD` segment's
file-backed extent ends at `0xfaa9e8`, while its memory extent ends at
`0xfb1970`. The strings therefore are not installed-image bytes for those
objects or observations of their live values. Record symbol identity/size
and zero-fill classification, with runtime value explicitly unobserved,
instead of those byte strings.

This defect does not affect the private-ref capture or arithmetic. The
packet already sets runtime registry observation and callback closure false
and does not use these three strings in the capacity composition. Zero-filled
initial storage would also provide no evidence about the later queue state.
Disposition: confirmed and fixed in
`554839c115df02bb18208e92871651f72ac5472a`. The repair removes the three invalid
strings, records the exact `PT_LOAD` tuple and sets each runtime-observation
field false. A narrow recheck against that commit and the unchanged installed
ELF verified all three object extents, the corrected local input identity and
all eleven `round.json` review-input identities in **0.250476 seconds**.
The correction diff passes `git diff --check`. Capture archives, callable
code and `result.json` are unchanged; no native capture or successful core
replay was repeated for the metadata correction.

## Review record

The independent reviewer was selected as **GPT-6 Astra / Extra High**.
Runtime model/effort confirmation and token/monetary measurements were not
exposed. Review ran from **2026-10-18 22:39:24 UTC** through the final metadata
recheck at **22:43:02 UTC**, **218 seconds** at the clock's one-second
resolution, excluding final report/commit preparation. The review branch owns
only this report. Parent integration, issue/memory updates and publication
remain separate; this review made no GitHub, CLI-memory or harness writes.
