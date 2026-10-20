# Independent review: selected disabled backtraces

2026-10-20 UTC; research #119 / #153.

**Accepted within the named selected source/native/runtime/loader relation.
No repair is required for this packet.** The inactive-recording invariant,
empty-raw provenance and conditional per-invocation allocation/output/stack
interfaces are supported. This acceptance does not cover arbitrary raw arrays,
the complete diagnostic/report graph or physical resource sufficiency.

## Review target and record

- Exact author freeze: `d511d706e3a585b099c3950733b69a8d9c572ad3`; author base
  `c80fe75816cff369030b2c6e5ffaa0fcd165ad52`.
- Reviewed the [research argument](../research/retained-why-disabled-backtrace.md)
  and all twelve files in its [evidence packet](../evidence/retained-why-disabled-backtrace-20261020/README.md):
  README, checker, fallback layout, input attachment, input manifest, native
  bodies/control/frames, result, round record, source-client inventory and source
  witnesses. The exact consumed identities are in
  [inputs.json](../evidence/retained-why-disabled-backtrace-20261020/inputs.json).
- Reused the accepted Debug control and five-process prefix/capability attachment,
  source identity relation, direct bridge interface and save-stack ownership
  convention. Their relevant source/control and ownership sections were read;
  no previous checker was replayed. The governing AGENTS.md, Oracle and relevant
  review/assurance/trust instructions were unchanged from the preceding review,
  as checked by Git diff.
- Lead-authorized scope: independent bounded review, with only this report owned.
  Lead-supplied state remains #119/#153 active/incomplete, production #88–#94
  unstarted and PR #121 draft/unmerged. No Oracle, tool, pin, language-admission,
  production or GitHub change is authorized or made by this review.
- Selected reviewer: **GPT-6 Astra / Extra High**. Runtime-confirmed model/effort,
  token usage and cost telemetry are unavailable. The observed review interval
  through report validation was **16:15:51 to 16:21:16 UTC, 325 seconds**, at
  one-second clock resolution; commit is outside that interval. Task-receipt
  timing is unavailable. Local harness goal lookup returned null; no goal changed.
- Separate worktree `tmp/disabled-backtrace-review-20261020`, branch
  `review/disabled-backtrace-20261020`, based directly on the author freeze.
  No native worker or recursive reviewer was used. Only this report is committed.

## Reviewed control argument

**Recording-client closure is explicit.** The complete retained 603-source
Why projection has four recording occurrences. The two GNAT closures are gated
by absent argv options; the browser worker is outside the selected frontend;
the Debug setter is in its excluded argument-initialization route. GNAT's direct
configuration read does not invoke that route. All Printexc identifier and local
open uses were inspected, including the callstack and raise/restore clients.
They do not hide an additional recording alias. The Stdlib module alias re-exports
the API without calling it. The OCaml and Sexplib/Sexplib0/Parsexp inventories
agree with these owners.

This conclusion depends on the already accepted fixed-loaded-code, typed-client
and native-owner relation. Neither a text census nor matching image maps alone
would exclude fabricated pointers, unreviewed plugins or application callbacks.
The reused attachment supplies the selected two plugins, seven images, single
OCaml worker, excluded reflection/finalizer/alarm/Memprof-start capabilities,
and the classified pending clients. Those restrictions remain premises here.

**The active-field induction survives errors and thread operations.** Native
startup calls domain initialization before runtime-option parsing. The zeroed
vector store at `0x9e36bd` initializes active/position, including active offset
`0xe8`; the vector is explicitly cleared beforehand. Every attached environment
has `OCAMLRUNPARAM=s=256M,h=16M,M=1000`, with no recording option `b`. The native
startup route does not use bytecode's `-b` switch. The five argv omit the GNAT
debug options and the selected suffix does not reopen configuration/plugin
initialization.

The recording setter, domain initialization and default C fatal-handler
save/disable/restore are the source-owned active-field writers. A fatal handler
entered with zero saves zero, writes zero and restores zero; failure or nested
entry cannot manufacture a saved one. The native stores corroborate that source
sequence. Thread context save/restore and raw-backtrace restoration modify
position/buffer/last-exception fields, not active. Raises and partial Stats work
do not introduce a setter. Thus preservation does not require all those other
fields to remain zero, successful exit hooks, or the absence of earlier signals.
The earlier Debug result's first-use freshness restriction is not being used as
a whole-suffix freshness claim.

**The diagnostic raw input has a checked origin.** The inactive native getter
branches at `0x9dd7af` to the `caml_alloc(0,0)` call at `0x9dd7cb`, before using
buffer/position. The selected allocator returns Atom(0), with no object request
or allocation loop. The standard uncaught route and its secondary-handler-failure
route use that getter or their fixed empty constant. GNAT passes the supplied
raw value directly to conversion. Convenience getters/printers share this origin.
The separate Pinterp `get_callstack 100` use does not supply these diagnostic
arguments; inactive recording alone would not bound an arbitrary get_callstack
result.

As a supplementary retained-ELF check, the standard fallback empty array at
`0xf80988` has header bytes `0003000000000000` at `0xf80980`, namely tag zero
and zero payload words. The format wrapper header at `0xf80c28` is `0xb00`,
tag zero with two payload words. These reads used the packet's exact executable
SHA256; no new disassembly was generated.

## Reviewed allocations, failures and native stack

Native debug availability returns one. With empty raw input, both C conversion
loops are skipped and `caml_alloc(0,0)` again returns the atom. The OCaml wrapper
reserves 16 bytes for `Some empty` while its two-word trap is still installed.
A pending `Failure` at that reservation can select `None`; its native constructor
test is at `0x97de4c–0x97de68`. The fixed fallback is therefore correctly included
despite the constant availability result. Other exceptions propagate or
terminate. Failures in later Buffer or Printf work lie outside this catch and do
not restart conversion.

For `Some empty`, the slot loops execute zero times. Buffer.create receives
tagged 1024, creates one 1,040-byte backing object and one 40-byte record sharing
that backing in both fields, with position zero. Contents uses Bytes.sub at
offset/length zero, creating a 16-byte empty string and performing a zero-length
blit. The sizes, bounds, length arithmetic and small-allocation predicates are
represented. There is no resize, slot-formatting or Buffer-add path. Together
with the 16-byte Some reservation, this gives **1,112 bytes** of cumulative direct
object requests. The None branch returns the static 59-byte literal without an
additional string allocation. Returning results have length **zero or 59**;
propagation/termination remains possible.

The print fallback's ELF format is exactly one String_literal followed by
End_of_format. Its node/literal addresses, 59-byte length, make_printf switch arm,
output_acc switch arm and fixed ignore continuation are attached. Native
Printf.fprintf tail-transfers directly to kfprintf; it does not add the returned
format-argument closure used by Format.fprintf in other packets. This route
allocates a 40-byte captured continuation and a 24-byte literal accumulator.
Including the potentially abandoned 16-byte Some reservation gives **80 bytes**.
Its one-node output traversal requests output_string once with
`(offset,length)=(0,59)`. No formatting queue, arbitrary printer, dynamic format or `%a`/`%t`
callback is selected. Zero-slot Some output requests no channel write.

These are direct prospective caller charges, including abandoned prefixes.
They exclude runtime allocation retries, collector workspace, exception creation,
channel internals and separately owned pending-client work. A 59-byte channel
request may flush older buffered data or fail; it is not a total OS-traffic or
successful-output bound. Caller-retained results and physical heap demand are
separate composition terms.

The native frame list covers the selected C and OCaml paths, including C local
root/stack-canary reservations, both OCaml traps, getters and optional wrappers.
The valid-size create_bytes branch tail-transfers before its sole error-branch
push, justifying eight own bytes there. The ordinary success/fallback alternatives
are sequential or tail transfers, and have no selected recursive slot traversal.
Only output_acc has two simultaneous entries, for its literal and terminator.
Charging every listed ordinary body once and output_acc twice therefore gives
the conservative **912-byte own-frame projection**. Unselected generic branches
are excluded by the empty input and fixed format, not by their symbol absence.

The reused **4,104-byte direct C/GC bridge** allowance includes the transient
4 KiB stack touch. One direct crossing suspends this local invocation until
return/unwind; a reentrant diagnostic is another active invocation. The checked
C helper frames are separate from the bridge, and service-owned nested crossings
remain separate. Thus **`5016*d` bytes** is an accepted component projection for
`d` simultaneously active covered invocations. It includes the optional getter
frames already, and must not be imported alongside duplicate getter/bridge
charges. It does not establish `d` for the complete suffix or bound all service
and enclosing diagnostic stack.

## Verification and disposition

Ran the new focused checker **once** on Linux 7.0.14 x86_64; the host query
reported glibc 2.43. It passed with **38 bodies, 8,298 instruction bytes and
33 source excerpts**. Every generated JSON file was **byte-identical to the
author freeze**, including the unchanged historical round record. The review
run lasted **4.121909 seconds**, from **16:16:47.932641 to 16:16:52.054591 UTC**.
This measures the Python retained-input check, not native target execution.

The author record separately reports 757.962 seconds and four checker attempts:
one extraction failure at the `.fini` section header, then three successes with
the stated witness/parser improvements. Those are historical author measurements,
not review runs. This review encountered no checker failure and did not replay
successful predecessors. Instruction equality and the checker arithmetic
corroborate the separately reviewed semantic/ownership argument; they do not
prove binary refinement.

The frozen executable SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`; the retained
disassembly SHA256 is
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
Source/archive/provider identities remain those in inputs.json. No target,
capture, disassembler, source fetch, solver/proof, broad validation or predecessor
checker was run. No CLI memory or shared session record was changed.

**No repair requested.** Minimal remaining joins are whole-suffix diagnostic
occurrence/reentry counts, all non-backtrace exception/report/exit callers and
text, global formatter/channel state, complete R, ambient A_pre and physical
resource conversion. The historical first-inline reporting allowance cannot
serve as the missing whole-suffix count. At most two callbacks, three saves and
`e<=2` remain one global suffix budget, never reset by a getter, fallback, report
or new root. Pending-client source work retains its explicit owner. Trusted
allocator/GC/OS correctness for valid represented requests does not supply any
missing caller arithmetic or physical sufficiency. Whole-suffix report count
remains null and complete save/exit/process-stack claims remain false; #119/#153
remain incomplete.
