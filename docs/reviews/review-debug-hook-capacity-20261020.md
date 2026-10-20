# Retained Debug Stats hook capacity review

2026-10-20 UTC; #119 / #153. **Accepted under the stated selected-input,
source/native, ownership, runtime and normal-service premises** at author freeze
`8c0e4c37c797dc70a4e8437bf60bbc9aacba1f7a`, whose parent is the first-use
provider cherry-pick `5d0c000255`. No material defect or required repair was
identified. This accepts one once-only hook's output, direct requested OCaml
objects and caller stack to explicit service frontiers, including abandoned
source prefixes. It does not establish complete exit/save or physical capacity.

Selected reviewer setting: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime model/effort confirmation and individual token/cost telemetry
were unavailable. Observed review start was 15:47:33 UTC; semantic review
completed at 15:51:40 UTC, an elapsed 247 seconds. The reviewer used a separate
Linux x86_64 worktree and owns only this report. The lead retains integration,
issues, durable memory and publication. The reviewer did not author the packet.

Exact inputs are the [research argument](../research/retained-why-debug-hook-capacity.md)
and eleven files in its [evidence packet](../evidence/retained-why-debug-hook-capacity-20261020/README.md),
including the checker, pinned provider results, manifest, arithmetic transfer,
21 source excerpts and eleven new retained native witnesses. The review reused
the accepted first-use freeze `7ead79763d239bbd81ed734b2aaa1ef01d8cc747` and its
report `ec08dd19e5ee5efc85885c4b1746672723908a22`, and the accepted Round 39
timing-format and timing-growth interfaces. The first-use packet is unchanged
from its reviewed freeze; the timing/core/allocation/accumulator/scalar/F packets
are unchanged from integration `f79a5736e42c7cac9b414d929b2c64783a1e7b83`.
No predecessor checker was replayed. Source files inspected in the retained
source checkout were matched to this packet's complete-member identities.

Why3 remains `9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml remains
`8eb41f72ded84df884c3671734c947f612091f84`. Installed ELF SHA256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
retained disassembly SHA256 is
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
Oracle 7–9, 13, 21 and 25 govern this conditional composition. The inspected
source/native relation is an explicit external premise; byte correspondence
does not establish universal native refinement or historical build identity.

The critical challenges were resolved as follows:

- **Whole-suffix occurrences and prospective events.** The accepted growth
  interface bounds callback entries by 26 over the entire suffix, including
  interrupted traversal. Each row contributes six text nodes, one open, one
  close and one newline flush. The hook's final main flush is additional:
  E_main=9*26+1=235. Each empty annotation owns a separate fresh helper with
  E=1 for its flush. Charges attach to prospective row/operation slots before
  conversion or allocation succeeds; an exception before enqueueing therefore
  does not erase an allocation charge. Empty registered_stats prevents its
  callback execution, but not the closure allocation preceding List.iter.

- **First-use and core transfer.** The imported state supplies Buffer
  position zero/capacity 42, default callbacks/settings, one constructor
  dummy-box token and two scan entries. No empty-queue assumption is made.
  B=1051+26*348=10099 and E_main=235 give L=10334 and N=944; guards
  10413<=1000000010 and 946<=2^62-1 hold. The empty annotation chooses
  Pp_box with indent zero. Its begin-token behavior fits the imported core
  induction; this stream has no ordinary break token needing an additional
  Pp_box break case. Flush drains under the sentinel assignment and resets
  the system box. Row flushes and the terminal flush are all charged.

- **Output and annotation ownership.** B+70*(E_main+1)=26619 includes the
  conservative automatic newline/indent allowance. It is not merely the raw
  data subtotal plus 26 explicit newlines. There are at most 944 direct core
  output/flush calls; default indentation is at most 68, so display_blanks
  cannot recurse at its 80-byte threshold. The Debug wrapper adds an ignore
  flush, without adding bytes or caller heap objects. An empty annotation
  drains only its zero-length system box, emits zero bytes, and takes the
  Buffer.contents branch. Its Buffer16 does not grow. The empty description
  returns a static pair before parser/scanner allocation or numeric conversion.

- **Selected catches and interruption.** Source inspection of the selected
  Format core/output/factory, Buffer, Queue/Stack option helpers and typed-format
  construction/conversion path finds no local exception handler that resumes
  a partial main or annotation Buffer operation. Queue/Stack option helpers
  pattern-match directly rather than catching an asynchronously raised Empty.
  The inherited F graph's trap-bearing ordinary bodies are open_box_of_string
  and sn_decode. Empty input returns at native 0x97339c, before the former's
  parser allocations and trap setup at 0x973518; sn_decode is not selected.
  Hashtbl.iter does catch exceptions from rows, but its handler restores the
  traversal sign when necessary and reraises at 0x981996 or 0x9819b1. It does
  not continue a row or advance to another row after that failure. A callback
  which catches its own exception and returns resumes the one suspended
  operation; it does not repeat completed source allocations. An escaping
  callback discards the interrupted hook frames. The already-cleared once gate
  excludes reentry or retry even if an outer failure handler later calls exit.
  These are selected source/control facts, not a blanket prohibition on
  exceptions inside formatting libraries.

- **Cumulative Buffer growth, including abandonment.** Each successful main
  resize strictly increases stored capacity along powers of two from 42. A
  large append may skip powers; charging all powers from 84 through 43008 is
  conservative. At most one final resize can allocate a backing and escape
  before publication, because the preceding catch analysis excludes resumed
  same-Buffer printing and same-hook retry. Its capacity has not already been
  successfully published and is already in the charged sum. Thus 86088 bytes
  includes every new backing, including the final abandoned request, without
  reclamation credit. Buffer.resize's native implementation uses registers/
  stack for new_len, as established by the imported allocation witness; no
  heap-ref request is omitted. The original and current backings can remain
  reachable together and are both counted.

- **Direct allocation partition.** Dynamic core requests use
  I=(3*235+1)+26*(3*1+1)=810 and the imported 640I partition. The 26 helper
  factories, Buffer records/backings and empty contents copies are additional.
  Accumulator/argument continuations use 26*(128+192*9); the empty annotation
  has no accumulator node, while its open-box construction is charged through
  the main node. Each Float_f uses the accepted 464-byte conversion subtotal,
  including the eagerly allocated unused hex closure and 328-byte result.
  Its 64-byte argument closure and 24-byte accumulator node remain in the
  accumulator partition. The old 192-byte scalar allowance is not substituted
  for this conversion. Integers receive 32 bytes each; no literal is a char
  node requiring another temporary. Native Debug.print reserves 32 and 40
  bytes for its two closures; Hashtbl.iter reserves 32 for its bucket loop.
  The row loads an existing tuple/boxed time and allocates neither. These
  charges sum to 684672 new caller-owned OCaml bytes.

- **Representation and lifetime limits.** The offered-byte bound implies
  Buffer position+append<=26619 and capacity<=43008. String size S(43008)=43024
  includes the header; its 5377 payload words fit the retained header limit.
  Capacity doubling, indices, counters and core intermediates remain well
  below their tagged-integer limits. The separately charged initial graph is
  1456 bytes: formatter/factory and constructor allowances, Buffer record and
  backing, plus captured functions record and newline wrapper. The sum
  686128 is a no-reclamation envelope for these owned objects and new requests.
  It excludes preexisting timing keys/table, globals, other saves, subsequent
  non-hook work and GC copies/metadata. It is not a peak measured heap value or
  an allocator reservation. The normal C saved-format requests have the separate
  26*21=546-byte subtotal in R; failing-service internals remain outside it.

- **Native closure, frames and multiplicity.** The inspected caller chain is
  Debug hook -> print -> Hashtbl.iter -> do_bucket -> apply2 -> timing row.
  The allocated row closure has native arity two, so apply2 selects fun_3056
  directly rather than running the stored curry2 entry. The row tail-transfers
  through apply4 to the Format wrapper and fixed argument closures. Array and
  bucket traversal use backedges; cells/slots do not retain additional frames.
  Hashtbl.iter's 80-byte own bound includes both 8-byte trap words. The 296-byte
  caller sum also includes the empty Stats List.iter context, caller adapters
  and the additional 16-byte Debug newline wrapper. Shared native bodies are
  charged by invocation context; the Format-internal tag iterator/adapters
  remain in F. Summing tail-replaced or mutually exclusive contexts is safe
  overcounting here.

- **Parameterized F and its frontier.** There is one main format invocation,
  at most one active annotation helper and one terminal/helper allowance, so
  H=3 is conservative. The inherited finite arity-at-most-four adapter argument
  supplies J=3*16=48. Nine main accumulator nodes plus their terminator and
  the empty annotation terminator give O=11; variable string bytes and later
  rows do not add simultaneous output_acc ancestry. Thus F=15976 and
  F+296=16272. The selected callbacks only append to private Buffers or ignore
  flush; no serializer, name/constant, channel or arbitrary %a/%t import is
  exercised. Runtime-mediated saves retain their separately budgeted frames.
  The 512-byte float C shell, OCaml/C bridge, GC/libc/allocator/signal work,
  failure services, A_pre, once-gate wrapper and outer exit dispatcher are
  explicitly outside this caller component. At most one hook term is active;
  r<=3 and e<=2 do not multiply or restart it.

The accepted common bounds for all five retained cases are:

| Quantity | Upper bound |
| --- | ---: |
| Bytes offered to main Buffer | 26,619 |
| Main Buffer capacity | 43,008 |
| Largest new OCaml block | 43,024 bytes |
| New caller-owned OCaml block requests | 684,672 bytes |
| Owned initial objects plus new requests, without reclamation | 686,128 bytes |
| Caller stack to explicit service frontiers | 16,272 bytes |

The new focused checker ran **once**:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-debug-hook-capacity-20261020/check.py
```

It passed exact provider pins, the source/witness projection, eleven native
bodies / 1256 instruction bytes and the stated arithmetic. The reviewer
measured 2.1407443989992316 seconds around the subprocess. The checker regenerates
its artifacts; Git status and diff afterward were empty, establishing equality
with the reviewed freeze. Passing this check does not prove the semantic
occurrence, exception, ownership or simultaneous-frame argument.

Freshness is not reasserted after a partial hook. Continued numeric/locale
service attachment, failed-service resource usage, standard/error formatter
phases, full R, ambient storage/stack and physical adequacy remain separate.
Complete exit stack/capacity and complete save capacity remain false. No
production, language, Oracle or tool-pin change was made; no target execution,
capture, disassembly, source fetch, solver/Lean run, predecessor replay or
duplicate successful check occurred. No GitHub or CLI memory write was made.
The child harness goal was null; no goal status changed.
