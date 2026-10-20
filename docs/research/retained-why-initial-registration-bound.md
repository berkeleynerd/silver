# Initial identifier and type-family bound

2026-10-20 UTC, #119 / #155, Round 35; base `6cf8d32209`.
This result concerns the five **retained, debugger-controlled prefixes**. It
does not assert absence of signals, collections, failures or tag wrapping in
their later continuations, nor reproduce these prefixes in a production run.
The existing source/configuration-to-retained-state relation remains required.

The initial identifier-registration counts are **136,844 / 121,505 / 77,806 /
59,035 / 60,496**, for Put_Line / Put / First_Or_Default / Is_Message /
Input_Is_Valid, respectively. Each also bounds the number of initial type-symbol
objects, including objects held only by restoration caches, and the number of
initial tuple-registry entries. This supplies a conservative input to the
library-publication argument without a new registry capture.

## Why the captured counter is a count here

`Ident.id_register` initializes its private ref to zero and increments it once
per call (`ident.ml:187–192`). The retained native body at `0x56d4e0` increments
the tagged word, subtracts 40 bytes from the minor allocation pointer, constructs
the four-field identifier and returns. The only slow edge is `caml_call_gc`.
Initialization order places the protected `Exn_printer.entry` before `Ident.entry`
and `Ty.entry`; the same counter ref is captured through the initialized closure.

**No collection alone is insufficient.** `caml_alloc_small_dispatch` can undo
the allocation and run pending actions before calling the guarded collector.
A raised signal callback could therefore increment the counter without retaining
the five-word charge. The native slow path also touches stack space. The proof
uses the following additional facts about these actual captures:

- Both retained launchers run the pinned GDB with `-nx -q -batch`, disable
  auto-loading, and issue one `continue` after `starti`. Their fixed scripts and
  observers contain no signal-policy override or signal-stop continuation loop.
- A target-free query of that **same pinned debugger binary**, retained in the
  [packet](../evidence/retained-why-initial-registration-bound-20261020/README.md),
  confirms its default stop policy for SIGINT, SIGSEGV and SIGBUS. A stop on any
  of them would return from that sole continue before the selected endpoint;
  `finish_capture` would report an incomplete capture. All five captures reached
  their specified endpoint with no failures or signal stop. Thus neither a
  delivered SIGINT save callback nor a native stack-fault signal abandoned a
  registration in these prefixes. This relies on ordinary debugger stop/delivery
  semantics, not an inference from an empty collection log.
- The accepted [source-prefix callback closure](retained-why-path-initial-state.md#exact-input-and-initialization-attachment)
  excludes application finalizer/alarm registration, Memprof start, reflection
  and additional OCaml workers. Its only other signal client is Thread's
  SIGVTALRM preemption closure; the one-worker native yield returns without an
  application callback. The selected ordinary native services do not inject an
  additional exception into this valid five-word allocation. These are the
  existing source/runtime/OS premises, not properties established by hashes.
- The retained protected intervals have no collection, collection request or
  heap-configuration override. Their native minor allocation pointer is measured
  at the cut; no minor-heap reset or reclamation is credited. Cuts cannot be
  reached by the classified pending clients while an outer registration is
  suspended, by the same local control argument used for the restore table.

Every increment therefore completes its five-word allocation before the actual
cut. If N is the mathematical number of registrations and B is the recorded
minor bump usage, then `5*N <= B < 2^28`. The displayed B includes earlier
allocations and deliberately overcounts; it need not isolate identifier bytes.
A first tagged-counter wrap would require at least `2^62` increments, contradicting
this allocation bound. Thus N equals the captured nonnegative counter I. This
argument uses the actual native allocation sequence, not a presumed unbounded
meaning for the counter being bounded.

| Case | PID | Minor words B | Registration count I |
| --- | ---: | ---: | ---: |
| Put_Line | 17310 | 127,939,731 | 136,844 |
| Put | 17514 | 116,661,081 | 121,505 |
| First_Or_Default | 17631 | 87,937,967 | 77,806 |
| Is_Message | 17704 | 77,776,179 | 59,035 |
| Input_Is_Valid | 17869 | 79,191,224 | 60,496 |

## Consequences and limits

`Ty.tysymbol` is private with immutable fields. Its only record constructor,
`mk_ts`, calls `id_register` for each new object (`ty.ml:50–88`, `ty.mli:42–47`).
`create_tysymbol` validates the supplied arguments and then calls `mk_ts`; it
does not manufacture a different kind of type head. Hence all initially live
type symbols, not merely those in the captured task forests, number at most I.
Their distinct `List.length ts.ts_args` values also number at most I. This is a
cardinality bound, **not a maximum arity**.

The only writer of `Ty.ts_tuple_ids` is the `ts_tuple` constructor. Before each
registry addition it creates a type symbol and registers its identifier
(`ty.ml:278–292`). There is no pre-existing serialized registry under the fixed
typed initialization relation. Thus at most I entries were ever added before
the cut, even allowing abandoned publication prefixes or repeated keys.
Its distinct stored integer arities number at most I. This includes negative
arities: the argument does not assume that `tuple_theory_name` rejects them.

The union of these two initial arity families consequently has cardinality at
most `2*I`; later source-local arities and continuation memo behavior must still
be bounded separately. Initial routine-contract sizes, later registrations,
foreign formula sizes, parser publications and the whole writer/save capacity
are not bounded merely by this initial result.

The focused check binds exact retained members and source/native witnesses,
verifies the five arithmetic applications and the debugger query identity, and
reuses prior successful memory replays. It does not replay the captures or any
predecessor checker. One target-free debugger-policy query was run; no compiler,
solver, GNATprove, Lean, full-suite or target execution occurred. Independent
acceptance belongs to the combined Round 35 review.
