# Review: selected save capacity, Round 33

2026-10-20 UTC, Linux x86_64, owner-authorized research #119 / #153.

The three component arguments and their exact input-identity reconciliation
are accepted at their explicit conditional scope. This aggregation adds no
combined resource envelope. Complete save, restore-table, formatter
allocation/native stack and pipeline capacity are not accepted. The positive-write service attachment remains open; this review does
not add a new assumption to #119's required guarantee. Round 32 successes
remain dependencies at their recorded scope and have not been replayed.

## Exact scope and inputs

The isolated review worktree starts at
`2cb11d8b5dcb7146694103616d1abea13ab8808d`. The reviewer owns only this report.
The three component freezes are:

| Component | Author freeze | Integration correspondence |
| --- | --- | --- |
| [Typed-format accumulator](../research/retained-why-save-format-accumulator.md) | `5ab8c5a72bea169b13d2a8fc1b6adb451fd5fd1e` | `642bc12620820c3bc090259e281cf00c9c700916` |
| [Filename/channel extents](../research/retained-why-save-file-capacity.md) | `27a7786b9c8831169dc681d26663eaddb398f988` | Same lead commit |
| [Restored-path lookup](../research/retained-why-path-lookup-capacity.md) | `8b799eeeca536aefa18d16c600b493145a9b8965` | `2a202a040729f73ce30f6da5ca8cc8dd57bea7fc` |

The review includes each note, transfer, focused checker, generated inputs and
results, retained source witnesses and selected native instruction projections.
The semantic aggregate is `2a202a040729f73ce30f6da5ca8cc8dd57bea7fc`; the
[input reconciliation](../evidence/retained-why-save-round33-20261020/README.md)
is `7017f71d3e1c90bc0f823a556e472eaaa061d04e`. The review worktree fast-forwarded
to that exact reconciliation without changing component files. Byte identity
corroborates these source/native arguments; the focused Python checks are not
semantic machine proofs or whole-binary refinement proofs.

Selected reviewer: GPT-6 Astra / Extra High, per parent assignment. Runtime
setting introspection and token/cost attribution are unavailable. Review began
at 11:46:19 UTC. The interval 11:47:11–11:53:45 (394 seconds) was spent waiting
for the first packet, with brief I/O scope coordination; it is not counted as
completed source review. A second wait, 12:04:46–12:06:09, lasted 83 seconds
for the exact aggregate. Through the final substantive review checkpoint at
12:06:29 UTC, overall elapsed time was 1,210 seconds, including 477 seconds of
explicit waiting. The remaining 733 seconds include source/native review,
coordination, handoff recovery and report drafting, not measured model compute.
The child live goal is null; the parent confirms the full #119 objective remains
active and unfinished.

## Review findings and disposition

The initial interface review preserved three boundaries: payload length does
not bound table traversal/cardinality or retained old arrays; Format-core token
bounds do not cover prior accumulator construction; offered XML extents do not
establish backup/shape-file, pathname, descriptor or physical-write capacity.
All packets retain the one global save budget r≤3, including nested attempts
and abandoned prefixes.

**The file/channel draft required a positive-write condition.** `Putch` flushes
once when full and immediately appends a character. A zero return on a nonempty
write would leave that buffer full. The source's `CAMLassert(retcode > 0)` is
not terminal handling in the selected release body: the retained native write
wrapper has no active check. Ordinary POSIX count bounds alone do not establish
positivity. The final packet therefore makes positive progress for a nonempty
write an additional explicit service premise, keeps its actual attachment
false, and exports null usable bounds when that premise is absent even if all
others hold. This repairs the conditional claim by exposing an obligation; it
does not discharge the actual service frontier. EINTR/EAGAIN handling remains
separate. The older materializer's checked write loop does not repair this
implementation.

**Cached-offset initialization needed its lseek attachment.** A fresh regular
file description starts at zero, but `caml_open_descriptor_in` stores the lseek
result without checking -1. The final note states explicitly that cached O=0
uses the named normal lseek service; it does not attribute a success check to
the wrapper. This is retained as a service condition, not a new observation.

No additional correction was needed for the reviewed lookup or accumulator
packets. Their explicit exclusions are necessary parts of the accepted result.

## Restored-path lookup

The source induction covers completed publication and every interrupted prefix
of replace, clean and resize. Cons tails are immutable strong links into already
completed finite tails. A caught Not_found can create duplicate hashes; neither
uniqueness nor accurate `size` is assumed. The accepted initial-state and
selected-writer closure exclude a suspended pre-cut mutation and reentrant
Theory mutation from the selected pending roots. Cleaning and resize preserve
finite chains under that relation.

At bucket capture, distinct 32-byte Cons objects coexist in the valid,
nonoverlapping 64-bit address-space representation. Thus L≤2^59 is a valid
representation ceiling. It is not usable physical-memory headroom or a lifetime
allocation bound. The saved logical tail cannot lengthen through ephemeron
key/data changes, table replacement or faithful GC relocation. A normal step
consumes one node; a nonreturning runtime service contributes no further direct
visits, while its own capacity remains unclosed.

The native find loads length/index/bucket from the same current array after
hashing without an intervening callback. The private resize guard preserves
power-of-two capacity 4096≤C≤2^53 independently of stale size, so masking any
represented signed tag gives an in-range index. Find_rec's three backedges
follow its prologue and its GC return follows the current poll: its own reserve
is 40 bytes once, excluding return/callees, with no per-node frame growth.
The retained Ident tag closure, functor construction and final W installation
attach the constant field-load hash/equality route.

Getter request counts include disappearing keys/data and failing last prefixes.
Each matching-hash visit requests at most two getter options and two explicit
optionalize pending entries. Runtime allocator/mark/clean/pending work and
bridges are additional. The practical W bound counts actual post-cut replace
publications; it stays null. The old normal preparation count and the selected
path-payload bound cannot fill it. Writer size arithmetic, recursive clean/copy
stack and all retained arrays remain open.

## Typed-format accumulator

The 29 fixed literal sites admit only the enumerated conversions and formatting
controls. The census agrees with retained format constructors/parser cases:
maximum 26 main nodes, 27 including annotations. Data strings are not parsed
as formats, and the selected asprintf route evaluates output_acc. Construction
advances a fixed AST suffix; immutable delayed printers do not restart it.
The synchronous callback graph has at most two unfinished formatted invocations
per save; serializer forest recursion follows completed opening calls.

The weighted occurrence bounds C≤8Q and O≤2Q cover every selected static site,
including prover options, argument separators, identifiers, shape asprintf and
fixed box annotations. Z=27C charges construction before any output. Native
node/closure allocation sizes support the conservative 192Z+128C requested-block
subtotal. The direct output_acc subtotal 32r(2(32+1)+2)≤6,528 bytes covers its
own frames only. Selected make_printf transitions and list/HTML loops have no
per-node/item/byte direct frame growth; callbacks and runtime frames are extra.

Fixed box descriptions h/v 0/v 1/hov 1 have length at most five. The parser's
indices, substring extents and optional integer inputs 0/1 stay represented;
parse_intnat reaches the terminator without a multiplication iteration. Its
208rO requested-byte subtotal includes the native closure group, pair and three
small strings. Buffer/formatter backing, scalar/character strings, caller-built
printer closures, allocation-region reserve/metadata and GC are excluded.
These scoped subtotals include abandoned attempts without assuming reclamation.

## Filenames and new channel descriptions

Immutable directory lengths attach to the five actual captures. Filename
joins/backups, C copies and new-channel attempts have bounded source counts
and small intermediate string extents. The native channel request is 65,616
bytes, with a 65,536-byte buffer, yielding at most 393,696 bytes for six new
channel records over the global budget. This does not count custom wrappers,
mutexes, allocator metadata or preexisting channels.

For each open new description, committed O plus pending P obeys
0≤P≤65,536 and O+P≤A≤X. The flush pending check precedes rereading curr, so a
nested flush drains existing debt before the outer read. Selected no-pending
blocking entry and signal-recording return dispatch no OCaml callback between
successful write and offset/buffer commit. Positive partial writes conserve
debt by moving residual bytes. The channel's closed tombstone is not treated
as newly buffered data. These facts use the classified hooks and rooted native
lifetime relation.

The accepted XML extents and independently derived shape extents fit signed
64-bit per-description offsets. Individual string extents are checked apart
from aggregate file size. Nested rename/truncate operations do not merge open
descriptions or increase an older description's offset. This establishes a
conditional representation argument, not final file contents or delivery.
Global-channel traversal/refcounts, total interrupted syscall/poll counts,
error/exit effects and physical resources remain unclosed.

## Verification and remaining scope

Each new component checker ran once after its author freeze, on Linux x86_64:

| New focused check | Reconciled evidence | Reviewer elapsed seconds |
| --- | --- | ---: |
| Accumulator | 4 generated JSON comparisons; 17 source excerpts; 31 native bodies / 9,072 instruction bytes; 29 literal presences | 0.556 |
| Filename/channel | 26 source excerpts; 19 native bodies / 2,752 instruction bytes; 5 input cases; 30 missing-premise challenges | 0.653175 |
| Lookup | 16 source excerpts; 25 native bodies / 5,776 instruction bytes plus 16 closure literal bytes; 5 topologies; 378 index and 576 mutation-prefix challenges | 4.628685 |
| Aggregate identity | 32 author files; 94 unchanged native pins; 6 Python parses; 17 local links | 0.280 |

The finite challenges exercise the interfaces and source induction; they do not
replace the universal argument. No native target, capture, disassembler, fetch,
solver/proof/full-suite run or predecessor checker replay was performed. No
reviewer subdelegation, GitHub write or CLI-memory update was performed.

The aggregate check compared the exact author freezes without rerunning any
component or predecessor checker. Four report-local links, the integration
checker syntax and staged whitespace were also checked. No unresolved finding blocks the stated
conditional component claims. The unresolved positive-write attachment, useful
writer count and whole-resource obligations prevent any broader acceptance.
Complete #119 and #153 remain unfinished. Production #88–#94 remains
unstarted; PR #121 remains draft/unmerged. Oracle, admission, production source
and installed tool pins are unchanged. The parent owns integration, issue and
durable-memory bookkeeping, live goal status and publication.
