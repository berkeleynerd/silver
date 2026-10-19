# Ordinary-map preallocation and Why session-input review

2026-10-19, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Both frozen inputs are accepted within their separate stated scopes. No
material finding requires correction.** The ordinary-map result closes initial
gigi preallocation under its explicit line/population/ABI premises. The Why
result establishes missing retained inputs, a fresh-session source prefix and
a prospective observation specification. Neither establishes whole-lifetime or
whole-tool capacity, and this review does not validate an observer implementation.

## Exact inputs and review record

| Item | Frozen target | Base | Owned target files |
| --- | --- | --- | --- |
| A: ordinary maps | `9c52c43a6fd5e2bcb6afbc0fbc684e8baee1c962` | `b68a197d1b7cce47a02a374abb884200813de798` | [Source note](../research/retained-literal-ordinary-maps.md) and six files in [packet](../evidence/retained-literal-ordinary-maps-20261018/) |
| B: session inputs | `c164e913fee6e549d67b9ee64792f3b962b6ff7b` | `e8c320431fd3edf034da3d77d6bbc9a8a85768a0` | [Source note](../research/retained-why-session-save-capacity.md) and nine files in [packet](../evidence/retained-why-session-save-capacity-20261018/) |

Selected reviewer: **GPT-6 Astra / Extra High**, assigned by the lead and
continued from the bounded attachment review. Runtime confirmation of model or
effort, token usage and monetary cost are unavailable. This batch began at
**2026-10-18 23:58:10 UTC** and reached its completed inspection/evidence
checkpoint at **2026-10-19 00:02:16 UTC**, **246 seconds** at one-second
resolution, excluding report preparation and commit. This is reviewer wall time,
not native execution or whole-team cost. The live subthread harness goal was
null; the bounded #119 briefing supplied authority.

The review retained the already-read AGENTS, Oracle, development bookkeeping,
agent-reporting and assurance/trusted-boundary requirements. Actual source
correspondence, explicit premises, complete required obligations and the
distinction between sample checks and universal claims govern both results.
Relevant accepted location/frontend and callback-launch reviews supplied the
bounded dependencies; their broader limitations remain applicable.

The actual host is Linux 7.0.14 x86_64. A separate sparse worktree under the
repository's `tmp` owns only this report. All B candidate inputs were read at
the frozen Git commit; later work in its author's observer worktree is excluded.
No accepted files, root indexes, memory, GitHub state or other worktrees were
changed. No recursive delegation occurred.

## A — One ordinary map per source entry

The selected gigi loop enters each file at logical line one, calls
`linemap_line_start(L,252)`, encodes column 251 and leaves the outermost file.
`back_end.adb:124–131` passes the **logical** last line. The identity to physical
lines is conditional on `Num_SRef_Pragmas=0`, as `sinput.adb:783–796` shows;
virtual instances must retain their template line-array bounds. The note
correctly requires these frontend/actual-source/template premises at attachment,
rather than silently using a physical count for arbitrary logical remapping.

`linemap_init` value-initializes ordinary storage/depth and starts the highest
location at one. GNAT initialization sets default range bits to zero. With
depth zero, LC_ENTER creates a map with `included_from=0`, initial line one,
zero column/range bits and highest line equal to its start. Hint 252 selects
eight column bits. The reuse condition in `line-map.cc:946–962` then holds:
the line delta is nonnegative, the prior last line is the starting line, the
source column is zero, range bits do not decrease, and
`L-1 < 2^(32-8)` for **1 <= L <= 2^24**. It adjusts that map instead of adding
LC_RENAME. Column 251 is below the resulting 256 hint, so it adds no map.

LC_LEAVE with the outermost map and null filename decrements depth and returns
before `new_linemap`. Each iteration therefore restores depth zero and adds
exactly one map. This preserves the file/map order gigi checks. The source
argument is about this initial selected loop; it does not exclude later ordinary
map writers. The starting state, no-logical-remapping premises and selected
1,589-entry frontend bound must remain attached to any future reuse.

The exact highest-location increment per file is `256L-4`. The conservative
endpoint **6,824,703,033,345 = 1+256*1589*2^24** is below the packed-range limit
`0x50000000 << 31`, and therefore below the column and ordinary-map limits.
No overflow branch, disabled-column behavior or dropped-location fallback is
needed. The source's 32-bit line-number and 64-bit location arithmetic remain
distinct; widening location_t does not remove the single-map line-offset test.
At L=`2^24+1`, that reuse test fails, so the inclusive boundary is significant.

## A — Allocation size and owner

The pinned header's selected SysV x86_64 layout is consistent with its explicit
32-byte comment: eight-byte location base, four bytes of flag/bitfields, four-byte
line number, eight-byte included-from location and eight-byte filename pointer.
`line_map_new_raw` starts with 128 candidate slots, raises that candidate to at
least `used+1`, doubles, rounds the byte request and divides by the map size.
It does not merely double the previously rounded capacity at a full table.

| Used maps at growth | Bytes before rounding | Reallocator/GGC bytes | Resulting slots |
| --- | ---: | ---: | ---: |
| 0 | 8,192 | 8,192 | 256 |
| 256 | 16,448 | 32,768 | 1,024 |
| 1,024 | 65,600 | 131,072 | 4,096 |

The selected inputs are above the small-object lookup range, so the ordinary
power-of-two GGC orders apply. Thus at most **three backing requests**, each
at most **131,072 bytes**, cover the selected population. Products, indexes
and rounded sizes fit the stated interfaces.

`toplev.cc:764–766,1145–1148` selects `ggc_realloc`. Each call reaches at most
one allocation in `ggc-common.cc:163–203`. The existing accepted `ggc.h:138–142`
wrapper passes a null finalizer, so this slice adds **zero finalizers**. I
independently checked that supplemental header against the accepted location
pin: 11,939 bytes, SHA-256
`7347400b56f734e1f8c6cd0c3406470bbbcb6fed43392920d67fc53cd1e589a8`.
The global line-table control and its initial ordinary hash retain their old
owners; filename, combined-location and warning storage are not charged again.
Freeing replaced backing gives no negative allocation-event credit.

The packet's 1,609 checks in **0.026610526 seconds** are retained evidence,
mostly the finite populations 0..1,589. They check the arithmetic, rejected
interfaces and scoped flags; the source argument supplies the one-map result.
`complete_ordinary_map_lifetime_closed` remains false, total GGC remains null,
and no aggregate attachment or broader capacity result follows from acceptance.

## B — The precise retained gap and fresh-session prefix

The retained successful scan examines **785,851 raw-read records** using
half-open byte-interval overlap, not just equality of read-start addresses.
Its full-stream applicability is bound to the archived input/capture hashes.
None overlaps the eight-byte runtime words for:

| Root | Runtime address in PID 74171 |
| --- | --- |
| `caml_signal_handlers` | `0x560382547ef0` |
| `camlStdlib + 0x338` | `0x5603824e98d0` |
| `camlWhy3__Debug + 0x128` | `0x5603820c51c0` |

The checker derives the load bias from the observed Ident module and pinned ELF
symbol table. The signal root is in BSS; the ELF's static storage cannot supply
its installed runtime pointer. Initialized module fields likewise do not prove
their later live values. This establishes absence of these **three exact root
words from persisted reads**, not absence of every descendant from other graphs.
The 326,456 retained blocks and 244 input/6,704 Hsdecl roots have no session
membership or traversal-multiplicity contract. The original driver task and
first-inline task are also distinct inputs, not two names for a session forest.

The archived harness creates a new directory, copies only the JSON/configuration
and creates empty temp. Its launch assertion checks that exact starting
inventory. The recorded argv uses `--proof per_check` and no `--proof-dir`.
The source-derived session path is therefore absent at launch, and
`gnat_checks.ml:380–416` takes `empty_session`, adds the selected input and
returns the fresh controller. The existing-session reload/merge branch is not
part of this capture. The historical five-goal XML is not its seed. Absence of
XML archive members alone would not establish that conclusion; the fresh
directory/argv/source branch does.

The inspected prefix reads/types the input, splits theories, constructs proof
nodes, registers raw tasks, installs the controller-capturing SIGINT handler
and schedules Per_Check splitting. Grafted subtasks pass through the same raw
task registration. The prover preparation looks up a session task and then
applies the driver transformations to its local task value. This narrows the
construction route but does not enumerate the resulting current theories,
goals, subtasks or formulas. The note makes no numeric reconstruction claim.

## B — Preservation and observation boundaries

`Driver.prepare_task`, the selected inlining fold and immutable task/term/binder
records construct replacement values without grafting them into the session
forest or replacing its raw-task entries. The direct `save_session` path clears
and rebuilds shape state, changes its version and serializes the existing forest.
Its identified direct operations do not enlarge the charged forest/formulas.
This is appropriately limited: callback/helper reachability and preservation
remain required, and source-level direct preservation is not a theorem about
every indirect callback or a universal binary refinement result.

The live exit chain matters. The standard library's atomic once-per-hook chain
invokes the registered callback and prior chain before exiting. GNAT enables
statistics, whose exit hook iterates registered printer wrappers and timing
state. Observing only the outer exit closure would therefore leave real
callback/global inputs unresolved. The plan preserves these dependencies in
`R`; it does not silently price them as zero or revive the refuted stable
missing-raw-task exception witness.

The ten retained native bodies total **2,414 bytes**, including **46 bytes of
continuation/padding beyond ELF symbol extents**. Every body is contiguous,
matches its ELF symbol start/size and covers that extent. The relevant inspected
instructions support the signal closure's four-word layout and controller at
field 2, controller session at field 0, exit-link callback/gate/previous at
fields 2/3/4, and statistics wrapper/record fields. The standard exit and Debug
module offsets agree with those used in the missing-root scan. Session,
theory/file/node and table layouts match the cited source definitions; the
prospective decoder must still validate them against actual raw observations.

The proposed observer preserves the original counter/input/Hsdecl components
before optional work, stops at the same first-inline entry, uses only stopped
process reads, and flushes raw reads before interpretation. It prohibits target
calls, writes, signal injection, transform/printer/save continuation and prover
requests. Typed layouts, complete bucket/list occurrences, duplicate bindings,
shared nodes, finite visit multiplicity, raw tasks and semantic delayed
substitution remain explicit requirements. Cycles/unsupported layouts and
resource limits produce retained diagnostic failures, not capacity conclusions.
The one-worker/6-GiB/120-second proposal is a bounded attempt specification,
not evidence that a future attempt will complete.

The plan correctly requires a new capture to supply its **own same-process
counter/input/Hsdecl/session join** and re-establish the accepted theorem's input
assumptions. New addresses or formulas cannot fill missing historical PID 74171
bytes. A historical-instance claim would separately require fixed-prefix
invariance. The plan is accepted for this scoped purpose; the future observer
implementation and any execution are outside the reviewed commits.

`B_binders(S)` and `R` remain null. The accounted endpoint remains **61,641**,
and the conditional two-save inequality retains its successful-POSIX,
single-dispatcher/producer, no-reinstallation and no-unmask premises. Neither
the session specification nor the named native bodies establish a family,
history, complete callback/allocation/full-transform or whole-proof bound.

## Narrow verification and final disposition

The B author's **3.771548261-second** successful frozen check is reused,
including its complete raw-read scan. Neither that scan nor the old successful
graph/counter proof was repeated. A reviewer inline audit passed **75 checks in
0.489463953 seconds**, at 2026-10-19 00:01:09.536858–00:01:10.026319 UTC:

- A: ten current source identities and their accepted location/frontend pin
  correspondence; three retained checker hashes; the retained 1,609-check record;
  exact selected output; four native-reuse boundary cases, including the first
  excluded line count; and the location endpoint/scoped completion flags.
- B: nine reused and seven local input identities, note identity, four archived
  source identities, selected executable identity, ten native body extents/bytes,
  the 2,414-byte total, three root symbol/bias joins, seven adverse interval-edge
  cases, retained coverage applicability and unchanged endpoint/missing claims.

This audit answers source applicability, boundary and native-offset questions;
it does not replay the complete capture or future decoder. The supplemental
zero-finalizer header comparison is separate from the 75-check count. Both
target diffs pass `git diff --check`. No review probe failed and no candidate
repair was needed. The inline probes created no additional repository artifacts.

No target, debugger, objdump, compiler, native build, proof, solver, full Context,
full graph/corpus rerun, GitHub write or macOS validation occurred. A remains
an unattached initial-map slice with later writers open. B remains missing-input
research with a prospective plan and no save charge. **#119 remains unfinished.**
