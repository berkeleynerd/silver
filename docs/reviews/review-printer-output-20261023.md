# Selected solver-request output: independent review

2026-10-23 UTC, Linux x86_64; #119 / #153. **Accepted under the retained
premises at `b5aad6d57b2f215ac047edb931314812c6687905`.** This accepts the
selected printer byte/event counts, fresh private Format drain argument,
individual Buffer/native operand bounds and explicit shared-stderr fragment.
It does not establish whole printer or whole-process capacity.

The exact target is the [author note](../research/retained-why-printer-output.md)
and its frozen output packet. The [review evidence](../evidence/retained-printer-output-review-20261023/README.md)
records identities, independent arithmetic, the separate provider acceptance
and measured checks. Selected reviewer: GPT-6 Astra / Extra High; runtime
model/effort confirmation and token/cost telemetry are unavailable.

The raw-name and attribute-origin inputs are accepted by a **different**
reviewer in `2533c4962814cc85cda0e76462819d5e16525b30`, at raw-name
`39afb9db41c4052a7b68c2663f2bcc72d72a27ac` and repaired Hsattr
`62f686fe7331c2faf74c3c9f66df93f2626f1fa0`. Its exact targets/result are
attached without replay. This reviewer previously authored the Hsattr candidate
and does not independently endorse that source argument here. The present
review consumes the separately accepted interfaces, including no-at origins,
hypothesis-name length and the raw/comment-name bounds.

## Material findings and their disposition

**M1 — fresh state alone does not imply large-stream flush completion. Fixed
before the final freeze.** The initial draft inferred that closing all user
boxes leaves only an unresolved system begin. A break directly under the
system box is a counterexample: print Pinf+1 bytes, force a newline to restore
space78, enqueue a width-one break followed by one text byte, then flush.
Immediately before flush, left=Pinf+2, right=Pinf+4 and space=78. Flush sets
right=Pinf; the unknown break cannot advance, and reset discards it and the
following text. The forced newline is necessary in this concrete trace;
without it the negative remaining space can make the break advance earlier.
The author supplied that correction to the reviewer's initial shorthand.

The final theorem explicitly requires every break to be under a user box,
or a stream containing no breaks. `Driver.print_task_prepared:403` supplies
`@[%a@]@?` around the entire SMTv2 printer. Selected body/type/header fragments
do not close that outer box; their own opens/closes balance, except for the
goal's additional assert box. The selected printer's only flush is its final
`smtv2.ml:1075` operation. Afterwards there is only an ignored outer close and
redundant flushes. All main-stream breaks are therefore covered. The name and
annotation helpers emit text and flush only. The counterexample and the
restriction remain in the final packet; the inherited small-stream and shared
formatter theorems are unchanged.

**M2 — literal event bound needed a per-literal-template count. Fixed before
the final freeze.** A generic bound of16 placeholders cannot be added to a
65-digit bound as though all literal templates print their value once. The
final census identifies the six integer literal templates, each with exactly
one placeholder: `#x%64x`, `%32x`, `%16x`, `%8x`, `%4x`, `%2x`. Their combined
literal rendering fits the128-event unit allowance. Logic/type placeholders
remain separately charged to their recursive argument units. The three float
templates are explicitly excluded by the accepted input/producer family.

**M3 — unqualified sprintf ownership needed its actual alias. Fixed before
the final freeze.** SMTv2 opens Format then Pp; `Pp.sprintf=Format.asprintf`
at `pp.ml:208`. Those helpers use kasprintf/output_acc and a fresh Buffer512,
rather than Format.sprintf's differently typed strput_acc continuation. The
final source witnesses include both the open order and alias. Its one-name
text-event bound is valid under that attachment.

No unresolved material finding remains within the accepted scope.

## Why the restricted drain argument holds

Review checked45 excerpt ranges against complete retained source members,
including Format. Selected tokens are text, begin/end, ordinary width-zero/one breaks
with offset zero, forced newline and flush. There are no tab, tag, if-newline,
Magic_size, geometry changes or nonempty custom-break strings. Variable driver
strings are data, so their bytes do not introduce Format control tokens.

For each unknown queued begin/break, its identical scan entry survives until
resolution or removal. `scan_push` records the right total after enqueue, which
is at least that token's enqueue position. FIFO removal cannot move left beyond
the position of a still-pending token. Thus `set_size`'s strict obsolete test
cannot discard an entry for a queued unknown token. A stale top entry implies
all entries below it refer to already removed tokens; zero-length tokens and
equal saved totals do not invalidate this direction of implication.

Completed nested closes remove their own scan entries. A new break resolves
the preceding break in its open box, while closing the box resolves its final
break and begin. Under the explicit user-box nesting premise, automatic closes
therefore leave no queued unknown user token. If the system begin remains,
it is the first queue token and left=1. It advances with Pinf−1>=78. If it
was removed earlier, every remaining token already has known size and bypasses
the pending-count test. Each advance removes one token; flush then resets.
This reasoning permits the old left total to exceed Pinf.

The arithmetic induction uses Q=B+F. Nonnegative selected token lengths keep
left/right in [1,1+Q] before the flush assignment. Scan sizes, including their
negations/additions, remain represented; space is in [−Q,78], width in
[−Q−2,78], and current indentation in [0,68]. The unclamped indentation
expression is at most Q+80. `4(Q+Pinf+100)<=max_int` covers these operations
and the potentially negative Pinf−left subtraction during flush. The separate
`4(F+1)+2<=max_int` guard covers queue/stack lengths and keeps depth below
the ellipsis-suppression threshold. This is an argument about actual scalar
operands, not cumulative work fitting a native integer.

Partial operations need not leave a reusable Format invariant. The private
formatter and Buffer are not published to a returning mutation client; the
selected callbacks either leave them untouched or unwind/terminate. Unsupported
wrappers propagate. The literal Exit handler has no custom callback and fails;
the integer-conversion handler reports and asserts outside its own trap.
Optional field catches contain no main-formatter operation. Scanner Exit
catches manipulate only indices before their output action: an interrupted
return either progresses through the bounded fixed template or fails its
substring/index/conversion check. It cannot resume a partially mutated core.
The source/native callback and service premises remain essential here.

The reviewer-written finite model checked10,001 selected streams, including
long text, zero-length tokens, nested boxes of all selected kinds, stale scan
entries and redundant flushes. It also reproduces M1's discarded break/text.
Those tests challenge the reasoning; they are not a universal OCaml proof.

## Source counts, native bounds and retained residuals

The complete retained driver DAG gives expanded byte envelopes
29,890 /31,293 /6,478. The longest quoted token is347 source bytes; decoded
strings cannot be longer. Source/template origin restrictions, ground affine
type rendering, the two accepted repeated-rotation arguments, and nonempty
trigger groups are reused from R61/R62. Original stored constants and the
selected range endpoints fit the integer family; selected producers introduce
neither float/string constants nor an unbounded integer indexer stream.
For negative radix literals the intermediate base^digits+value may exceed
2^64, but its printed digit count is still bounded by the64 padding allowance
and the original65-digit magnitude bound. No native-small-integer claim for
that BigInt intermediate is introduced.

Review checked the author's C partition across body/type entries, binder slots,
declaration shells, constructor fields and deferred definitions. Separators
and trigger-group delimiters are charged to their incoming elements. The
256-byte/128-event direct caps dominate the selected fixed fragments; recursive
arguments receive their own units. Two escaped raw comments per declaration
are charged independently of sanitized names, using `4Lc+2` each. Prelude
visits conservatively pay the full expanded driver envelope even when the
private deduplication table fails to preserve a previous insertion. No
successful-publication count substitutes for prospective output work.

All15 process/driver rows independently reproduce the frozen equations and
pass the scoped native guards. The largest offered-byte bound is
96,048,951,340,887,500 for Put_Line/CVC5. Its temporary Buffer doubling is
144,115,188,075,855,872 (=2^57), which exceeds the native string limit by9.
The source checks the prospective total and clamps the allocation to
2^57−9 before `Bytes.create`; requiring the temporary value itself to fit
the string limit would be an incorrect extra restriction. It does fit max_int,
and the actual offered extent fits the string limit. Later append requests
cannot require another resize after that maximum-capacity clamp.

Temporary name and annotation owners are fresh individual Buffers, not one
aggregate C×W allocation. The per-process E×O file-work product is likewise
a mathematical total, not a single file offset, Buffer or Format counter.
Ordinary physical I/O, allocator/GC and native stack/service sufficiency retain
their existing trusted/delegated boundary; no aggregate RAM gate is added.

The broad `Printer.int_of_string` catch remains relevant even for valid
two-digit source parameters. At most one reporting attempt occurs per request;
its `64E` bytes and `8E` events belong to **shared stderr**. They must be joined
with the other whole-interval stderr writers; no fresh formatter or extra
exception allowance is assumed. This review does not close that join.

The same e<=2, two save-entering callbacks, three saves and E=3N+e remain
process-global. Other private maps/tables, Format accumulator/native layout
and stack, arbitrary attributes/locations, remaining failure/output boundaries,
current-grammar coverage, whole-rule composition/correspondence, useful-domain
comparison and final review remain separate. The whole-printer/process flags
correctly remain false. Oracle, tools/pins, admission and production are unchanged;
PR #121 remains draft/unmerged. Issue/publication/memory updates belong to the
lead; this reviewer made no GitHub or CLI-memory write.

## Verification record

The successful independent audit checked429 finite conditions in20.230005s
on Linux x86_64: exact frozen provider identities,45 valid ranges against18
complete members, the driver DAG, integer-template and constant/trigger census,
all15 arithmetic rows and the independent Format model. No author/predecessor
program, native compiler, solver, capture, disassembler or proof suite ran.

One earlier reviewer audit stopped in the reviewer's own literal-line extractor:
it counted a commented BV alternative and classified the three float templates
as integer templates. The extractor was corrected to remove that same-line
comment and classify float placeholders. The author input did not change;
this is a reviewer tooling repair, not an author failure or a repeated
successful validation. Separate provider acceptance was subsequently attached
by exact targets and result, without rerunning its audit. The complete source
argument remains reviewed reasoning under retained premises, rather than a
machine-checked OCaml simulation or a recovered build attestation.
