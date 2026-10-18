# Independent native graph, summary and helper review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted within the stated conditional graph/summary/helper and attachment
scope, with no unresolved material finding. Review found one material
coalescer-backing omission, corrected and independently checked below.
Whole native and literal-pipeline capacity remain open.

The original graph target was
`264b9f4c7be7482bb2212686b08f5fd9605068e9`. Review then included helper and
assembler attachment `a99e8547ed2095949874cc6626c8e4b2fcc1ddf9`, integrated by
the lead as `7e46512511c8d5e9df0aa0424cd0f9afb9ffbc1e`. The latter was
reconstructed locally at `b7fd3a0edffaa10f62fbbda48a233a0a83dd4b3a`, including
the already accepted assembler implementation/review. The graph callable
was unchanged by that extension. The final correction target was
`676919c36ef1ee921c403c4ab745b6f17c5df079`, reconstructed locally as
`68f6b23786e3c4454213710b8e70384680322e58`.

Reviewer selection: GPT-6 Astra, Extra High, explicitly selected by the parent;
independent runtime confirmation is unavailable. The measured review/replay
interval was 18:08:27–18:17:35 UTC (548 seconds), including draft authoring
and waiting for the correction, excluding final report edits and commit.
Token and cost measurements are unavailable. This was offline source review
and Python arithmetic on Linux x86_64; no compiler, assembler, linker, prover,
native executable, broad suite or new prefix capture ran.

Inputs were the literal-pipeline source argument, callable, checker, descriptor,
both input manifests and retained results; the accepted native-pool review;
the selected IPA partition and relevant graph, summary, ranger/out-of-SSA
predecessor arguments; and their retained source files. Source inspection used
GCC revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` at
`/tmp/silver-backend-compose-20261018/full-source`, the retained Ada tree at
`/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada`, and selected
GNAT 16.1.0 plugin headers. The existing source-behavior, target/ABI,
effective-option and Main-preservation premises remain necessary. Source
identity checks support attachment; they do not prove the source argument.

The graph and summary checks established the following:

- The initial construction and three scheduled rebuilds create at most `4C`
  fresh GGC edges. Rebuilds remove old callees first, bounding live edges by C.
  The call-site table is constructed at most once per generation. Each edge
  is inserted once; pre-hit growth is charged. Both cleanup routes empty and
  null the table, preventing repeated terminal emptying of one lifetime.
  `empty_slow`'s large-table request rounds to 251 slots only after the old
  pointer table exceeds 131,072 slots; its other request is at most twice the
  population. Four separately charged cleanup allocations fit the same
  backing ceiling.
- Released call-summary IDs are reused before increasing their high water.
  Removing one generation before the next gives C summary IDs, distinct from
  the `1+4C` edge-UID endpoint. Two local summary scans occur before the
  parameter manager exists, so one source argument does not imply a parameter
  summary vector. Global generation creates the infrastructure but skips
  O0 Main. True predicates remain null pointers; propagation maps stay empty.
  Cold manager, hook and pool allocations remain charged.
- Direct external calls add no inline candidate, clone or body copy. In the
  queued transform, redirecting an unchanged direct callee adds no edge;
  `node->callees && (optimize || has_inline)` still excludes
  `optimize_inline_calls`. Whole-unit maps and ordering structures follow
  the selected one-defined-function shape, including the forced dummy's
  exclusion from the single-user traversal.
- The move/call/return/prologue source costs support `13C+3` unscaled size
  and the `26C+7` signed rounding check. The `sreal` argument uses the
  representation of profile counts and positive additions, rather than
  sampled block frequencies. Its conservative exponent and normalized
  significand bounds cover intermediate arithmetic under the signed-size
  condition.
- The event rows reconcile to `8C+33`: `4C` edges, four table controls,
  `4+4C` initial/insertion backings, four terminal-empty backings, seven fixed
  symbol constructors and fourteen summary infrastructure requests. The
  at-most-five singleton finalizers are the four table controls and the
  value-range control. Explicit no-destructor/raw allocation routes exclude
  other manager/record finalizers. Shared finalizer backing and collector
  work remain outside this delta.

The helper review checked `z=3C+2` SSA slots and `R=N+5` ranger block slots
against the existing literal lowering interface. Expansion creates its init
block before enabling the ranger and destroys the ranger before later RTL
graph growth. Selected warning gates leave at most two sequential instances.
There is no scalar SSA name, PHI, conditional/debug statement or selected
tail-call/EH block split during those lifetimes. Virtual names and direct
address expressions do not populate the SSA range caches. The fresh vector
recipe, optional oracle backing, inline range storage and fixed object layouts
were checked against their constructors.

The GORI constructor may allocate two empty bitmap headers per block even
without range information. `2R+8` private headers and `2R+13` requests of at
most 65,536 bytes correctly allow replacement chunks as R grows; a fixed
null-case single-chunk allowance would not suffice. Both partition views
allocate z-int forward maps before retaining zero real partitions. Their
reverse maps have logical length zero. The selected coalescer early return
excludes pair/liveness/conflict allocations, while its constructors remain
live obligations. These helper requests are ordinary allocations and add
zero GGC events within the stated family.

The material finding was in `create_coalesce_list`
(`tree-ssa-coalesce.cc:262–275`): it computes unsigned
`size = num_ssa_names * 3`, floors the result at 40, and constructs an eager
hash table before the zero-partition return. The original constant 488-byte
backing therefore did not transfer from the null case. At z=23 the requested
69 slots round to prime 127, requiring 1,016 pointer bytes. Correction
`676919c36e` supplies the source-derived `8*prime(max(40,3z))` request ceiling,
checks unsigned multiplication and the retained prime-table range, and
states the zero-entry/zero-probe premise. The empty iterator and destructor
scans fit the selected capacity; no live-population probe lemma is needed.
The corresponding pointer-byte product fits LP64 under that capacity check.
Focused source/diff review accepted the correction. Adjacent constructors
and the two partition-view routes exposed no second material finding.

The assembler attachment reuses the accepted review at
`5794440714eb6c20a4afc3e1484e6ca8ea2534f5`; this review did not repeat its full
GAS/BFD argument. The aggregate evaluates the assembler callable on the same
raw source and checks its identity, C/N/decoded-byte/maximum-length counts,
final-chain length, text size and padded constant-data size against the
native interfaces. It incorporates the assembler's local predicate and
retains its remaining lifetime/invocation obligations. The dependency loader
checks the pinned assembler packet and its retained 90-file Binutils capsule.

The initial independent offline replay passed all 28 graph-target cases and
reproduced retained `check-results.json` exactly. After correction, the final
independent replay passed all 38 cases and again reproduced that retained
JSON exactly. It checked the 55 pinned aggregate inputs and retained source
attachments, including the 173-entry join manifest. New cases cover C=6/7
coalescer prime growth, prime-table availability and unsigned multiplication;
the former SSA-width tests now isolate that named predicate because the
coalescer condition already fails there. The command was the packet's
`check.py` with the GCC/Ada/plugin roots above and output
`/tmp/review-native-graph-final.json`. These cases check attachment and
arithmetic, including cleanup and signed boundaries; they are not a universal
proof of the compiler source argument. The retained historical 32-case helper
checkpoint did not cover the coalescer omission.

Complete frontend/gigi/initial-GIMPLE lifetimes, the remaining shared pools,
GGC collector/finalizer composition, GAS/BFD subsidiary lifetimes, production
invocation, producer frontends/consumers and binder/linker joins remain open.
Neither the `5C+5` pool delta nor this `8C+33` graph delta is a whole-lifetime
allowance. No null 40,098-event allowance, production admission change or
whole-pipeline verdict is introduced.
