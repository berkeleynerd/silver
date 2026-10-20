# Independent review: retained JSON byte escape

2026-10-20 UTC; research #119 / #153.

**Accepted within the stated conditional scope. No repair is required for this
packet.** The fixed byte-escape path supports the prospective data/event bounds,
direct-object accounting and local owned-stack interface below. This does not
establish complete formatter, save, exit or pipeline capacity; the actual joined
exports must remain null and the completeness flags false.

## Target, authority and review record

- Exact author freeze: `32a84eb0b9d2e5493e03d30a5769d21e8bb96f16`, based on
  `9fd8e81a452caa563637c76ec636119d2f205780`.
- Reviewed [research argument](../research/retained-why-json-byte-escape.md) and
  all ten files in the [new packet](../evidence/retained-why-json-byte-escape-20261020/README.md):
  README, checker, input manifest, source witnesses, native bodies, native frames,
  native control, byte cases, result and round record. Their exact input identities
  are retained in [inputs.json](../evidence/retained-why-json-byte-escape-20261020/inputs.json).
- Reused the accepted formatter basis and its source-selected closure,
  multiplicities and frames; scalar, allocation and core interfaces; and the
  [conditional external behavior relation](../research/retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary).
  No predecessor checker was replayed. The old F interface is conditional on its
  selected environment; it is not a theorem about arbitrary formatters.
- The lead authorized only this independent research review and this report.
  The lead supplied the applicable Oracle requirements and milestone state:
  #119 remains active/incomplete, production #88–#94 are unstarted and draft #121
  is unmerged. This review neither changes those states nor authorizes production
  work. AGENTS.md, the Oracle, relevant assurance/trust sections and the review
  bookkeeping rules were read. No Oracle, tool, pin or admission change is made.
- Selected reviewer setting: **GPT-6 Astra / Extra High**. Runtime-confirmed
  model/effort and token/cost telemetry are unavailable. The observed interval
  through report validation was **15:52:45–15:58:17 UTC, 332 seconds**, at
  one-second clock resolution; this excludes commit. Task-receipt timing was
  unavailable. Local harness goal lookup returned null; no goal was changed.
- Review worktree: `tmp/json-byte-escape-review`, branch
  `review/json-byte-escape-20261020`, created directly at the author freeze.
  Only this report is committed. No recursive reviewer or native worker was used.

## Findings and accepted interface

**All byte branches and selected format.** The retained Why3 source partitions
0..255 into seven special escapes, 93 other printable ASCII bytes and 156 hex
escapes. The native unsigned comparisons agree: bytes 35..126 take the first
range arm, with a separate backslash target; only bytes 8..34 can index the
27-slot switch. Bytes 32/33 reach the printable target, quote reaches its escape,
and zero, other controls, DEL and bytes 128..255 reach hex conversion. This
accounts for all 256 values without assuming UTF-8 validity.

The static object at `0xb25170` selects the literal `\\u`, Int_x, literal
Zeros padding of four and No_precision. Its literal/data accumulator nodes
produce two direct `pp_print_string` operations. The seven special strings
produce one operation each; ordinary printable bytes use `pp_print_char`.
Including the two quotes in `Json_base.string` gives, for `n=s+p+u`,

```text
B = 2 + 2s + p + 6u <= 2 + 6n
E = 2 + s + p + 2u <= 2 + 2n.
```

These count prospective formatter inputs. Suppression, earlier queued material,
indentation, callback effects and physical channel output are not equated with
them. A standalone string does not flush. The fresh-core transfer still needs
the complete stream, settings, ownership and representation guards; adding a
requested final flush contributes a separate operation.

**Conversion and padding allocations.** Source and native control agree that
`fun_6592` is the literal-padding/no-precision integer closure. Its reservation
is 88 bytes, with header `0x28f7` and ten payload words. The initial `caml_apply2`
calls the arity-one format closure and then this arity-one integer closure;
it introduces no intervening curry object.

The converter application was additionally checked directly against the retained
ELF/disassembly. Module-entry instructions at `0x97a4cb` have bytes
`488d051e2c5f0048898748020000`, installing closure `0xf6d0f0` in module slot
`0x248`, read by the selected Int branch at `0x96f685`. Its header and words at
`0xf6d0e8` are
`[0xff7, 0x52b2e0, 0x0200000000000007, 0x96f0c0]`: stored curry2 entry,
arity two, and raw `convert_int_3465` entry. Thus this fully supplied converter
call selects the exact-arity entry. This read-only byte inspection uses the same
executable identity as the packet; it is not a new disassembly or binary proof.
Preserved module bindings remain an explicit premise.

Under the normal returning GNU numeric contract, `%x` becomes `%lx` and a byte
produces one or two lowercase hex digits with no sign/prefix. The Int_x
transform returns that string unchanged. Width four therefore always exceeds
its length. `Bytes.make` creates one four-byte zero-filled object; sign and base
prefix arms are unreachable. The final blit reads `[0,len)` and writes
`[4-len,4)`, with all indices and arithmetic represented. The unsafe bytes/string
coercion makes no copy. The source/native path requires no precision helper,
dynamic format Buffer or grouped-number allocation.

The distinct hex-owned objects sum to
`48+40+24+88+16+16+24 = 256` bytes: returned fprintf closure, output continuation,
literal node, integer closure, raw result, padded result and data node. Printable
characters own a 16-byte temporary; special literal escapes share static strings.
One string owns a single 40-byte iterator closure and two 16-byte quote
temporaries. Consequently

```text
Q_noncore = 72 + 16p + 256u <= 72 + 256n.
```

The empty-string case is included. This subtotal replaces the corresponding
generic argument/scalar charges when composed. Retaining those charges as well
would double count. Core objects, destinations, callers and runtime internals
remain separate owners; cumulative direct requests are not whole-heap or RSS.

**Simultaneous stack ownership.** The new ordinary formatter bodies own 16 and
48 bytes including return slots. The previously owned Bytes.make/blit wrappers
cover their newly selected padding invocations. The formatter expression is
therefore `2456H+176J+32O`, with a genuine `64H` extension to the old basis.
The JSON/string-side sum is `32+32+8+48=120` bytes. The native iterator uses one
back edge; its single created callback tail-calls char. It neither retains a
frame nor allocates a closure per byte. Counting the replaced callback/char
return slots together is conservative.

For the specified isolated non-reentrant lane and selected default leaf output
callbacks, one formatted call is active, construction tail-transfers, conversion
finishes before output, and the two-node accumulator has at most three active
output_acc entries. No annotation or serializer callback is selected. Reusing
the deliberately generous per-body `H=4,J=64` allowances with `O=3` is sound in
this restricted environment: formatter ownership is 21,184 bytes, giving
**21,304 bytes for a string lane** or **21,216 for a char lane**. This does not
replace the old per-save F or establish those counts for global formatters.

The normal C wrapper chain has own bound `80+400+32+32=544` bytes. Its 128-byte
formatting buffer suffices; parse-format and padding service branches are
shallower. This wrapper shell belongs in R, with bridges, libc operations,
allocator/GC, exceptional internals and ambient stack still separately owned.
It is not physical stack sufficiency or a completed bound on R.

**Failures and global composition.** Prospective object/event budgets cover
abandoned prefixes, including interruption after reserving an object and before
emitting a token. Neither JSON helper catches/retries or resurrects such a
partial invocation. This needs the stated immutable input, binding integrity
and callback ownership premises. Nested runtime activity has its own invocation
ownership and must retain suspended caller frames in the global composition.
Across the whole suffix, at most two callbacks, three saves (`r<=3`) and `e<=2`
remain global budgets; none restarts at a JSON root or error/exit root.

A negative `vsnprintf` return does **not** satisfy the small-result claim:
the native unsigned comparison at `0x9cd406` takes the long branch. Its extra
format copy, second conversion and exceptional behavior remain outside this
normal-service lemma. A nonreturning service cannot produce a later JSON event,
but its own capacity/unwinding remains unresolved. The packet correctly keeps
continued numeric success and the actual ownership/caller joins false.

## Verification and remaining scope

Ran only the new packet's `check.py`, once, on **Linux 7.0.14 x86_64**
(platform query reported glibc 2.43). It passed: 29 native bodies, six new bodies,
8,056 instruction bytes and all 256 byte cases. The census was 1,045 data bytes,
414 text operations and 41,496 non-core requested object bytes, including quotes.
The wrapper ran from **15:54:38.934347 to 15:54:41.054474 UTC**, taking
**2.120067 seconds**; the checker recorded **2.063204 seconds** internally.
These timings are checker execution, not target/native execution.

All generated JSON except `round.json` was byte-identical to the freeze.
Its only differences were `check_start_utc`, `check_end_utc` and `check_seconds`;
the original round bytes were restored. The retained executable SHA256 was
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`, and existing
disassembly SHA256 was
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
The checked source archives and every reused packet identity are in inputs.json.
The script validates witnesses and arithmetic; source semantics and ownership
were reviewed separately under the named external relation.

There were zero target executions, captures, disassembler runs, source fetches,
solver/Lean runs, broad validation runs or predecessor checker replays. One
read-only display helper initially mistook a JSON list for a dictionary; its
corrected inspection succeeded. This was not a checker or evidence failure.

No repair is requested. The remaining integration obligations are the explicit
normal-service joins, actual formatter state/callback ownership and complete
stream guards, caller occurrence and simultaneous/reentrant instance bounds,
and the separately owned runtime/ambient/resource terms. The allocator/GC/OS
assumption for valid represented requests cannot substitute for these caller
arguments. Retain all null/false actual and completeness exports. This accepted
component advances #119/#153 without closing either issue or establishing the
Oracle's universal pipeline guarantee.
