# Independent review: Main prefix consumer representation

Accepted with no material finding, **conditional on the stated inherited
source/producer/runtime, numeric primitive and physical-resource premises**.
Reviewed exact author **`17b1b2b35e81b6244077de982331111b5f387e87`**, #202/#119.
The three new consumer arguments support the complete **C→T individual
representation join** with the accepted source-prefix and auxiliary results.
T→builder transport and whole-pipeline capacity remain open. Both issues stay
open; production work remains unstarted.

The review covers only the new
[`prefix-consumers/`](../evidence/retained-main-construction-demand-20261024/prefix-consumers/README.md)
packet and appended “Source-derived prefix consumer representation” research
section. The auxiliary acceptance at
`bee34a8db1a84991cbf7491343223c5d71735afd` remains unchanged, along with all 96
earlier packet files. Exact author inputs and retained provider/source hashes
are recorded in the independent
[`result.json`](../evidence/review-main-prefix-consumers-20261024/result.json).

## Yojson source attachment and parser requests

The new source-family selection has two distinct parts. The previously pinned
gnatwhy3 bytes contain the retained Yojson 3.0.0 build-path window, and the
packet retains the official version 3.0.0 source archive and retrieval hash.
Those facts corroborate the selected family. **They do not independently
prove historical source-to-binary provenance.** The result explicitly relies
on the inherited compiled source/library behavior relation, including generated
lexer tables and constructors. Acceptance preserves that condition; it does
not treat a path string as a correspondence proof or impose a new attestation
gate. The audit checked the whole existing binary identity and exact window
without executing or disassembling it.

The actual converter entry invokes `Yojson.Safe.from_channel c` without
optional arguments. Safe selects INT/INTLIT/FLOAT/STRING, with `read.ml`
generated from the retained `read.mll`. `from_channel` creates both a fresh
Lexing buffer and fresh lexer state, and the default nonstream route calls
`finish` for trailing whitespace/EOF. Fname=None and lnum=1 attach the error
coordinate bounds to this concrete entry. The producer-domain argument, not
Safe's general capabilities, excludes floating tokens and overflowing Intlit
conversion: numeric magnitudes in Uint/Ureal fields are quoted; unquoted
IDs/locations/enums/bases have the inherited bounded Int/Natural values.

Let B≤2^31−2 be the accepted producer body bound, and N=B+1 the file including
Close's final LF. The source growth argument is sound:

- Lexing owns a 512-byte refill buffer and 1024-byte initial lexbuf. Growth
  occurs only when the retained suffix plus newly read bytes exceeds current
  capacity; that sum is at most N. Doubling thus gives backing at most
  `max(1024,2N)`. Compaction preserves absolute positions and blit bounds.
- The decoded-string accumulator starts at 256. Plain bytes copy once; each
  escape emits no more bytes than it consumes, including surrogate pairs.
  Clearing resets position, so reuse retains at most `max(256,2N)` backing.
  Contents copies at most N bytes; no total-allocation estimate replaces
  this individual-request proof.
- Positive lexer positions/offsets are input-bounded. Negative sentinels and
  refill adjustments fit the exported absolute arithmetic envelope. Both
  native lexer engines use `Long_val` for input indexing and tagged increments
  of 2; their C-int state/base fields index source-fixed DFA tables. The
  generated tables/memory slots remain part of the inherited compiler/library
  relation, not new input-sized arrays inferred from sample runs.
- `read_json` builds fixed-arity wrappers, pairs, refs and lists; completion
  reverses finite lists. The separate variable-array reader is not reached
  from this entry. Token/container progress follows the source recursion and
  input consumption, under the inherited physical stack/resource premise.

Stopping errors are included. A lexeme and subsequently collected junk are
parts of the finite input; `long_error` adds a 32-byte buffer and can consume
one extra unstored character. Its saved-position restoration feeds bounded
error coordinates and then raises; it does not resume a parse/blit with that
restored state. Fixed error text plus at most three decimal coordinates and
the retained lexeme fit N+256. Blank-input and fixed runtime errors are
smaller. These claims concern represented requests on evaluated prefixes,
not merely successful JSON results.

## Complete numeric origins and intermediate arithmetic

The ten Ureal tuples are attached by the **accepted complete fixed-state
reduction**, not a new inference from six example programs. All 18 retained
snapshots include allocated numeric fields, including discarded/unprinted
ones. The new projection enumerates every archived numeric snapshot and
reconciles every referenced Ureal against the accepted decoded numerator,
denominator, base and sign fields. Main's separate source induction emits no
Ureal; immutable fixed numeric nodes cannot be rewritten by Main, and import
growth adds module references rather than numeric values. Those conditions
make the complete tuple union applicable to this route. The earlier raw-byte
decoding/reconciliation was reused by identity and was not rerun.

The union contains both signs of five numerator/denominator/base triples.
Numerators are positive and below 2^64, denominators have magnitude at most 4080,
and bases are 2/16. The converter parses the compact components, applies sign,
negates the denominator, and multiplies the base 16 exponent by 4. It passes
stored exponents to `Constant.real_const`/`Number.real_value`; it does not
expand a radix power or shift. The base-zero `real_literal` branch and its
`int_of_string` exponent path are absent under this complete origin relation.
The Float_constant negative=false copy changes sign selection, not the
numerator/denominator/base domain. Ordinary integer/range conversion retains
its own fixed wrappers and does not normalize a real value.

The d=40 premise is used only for decimal parsing. A magnitude below 10^40
needs at most 133 bits; the retained Zarith parser's scratch has at most 41
bytes and its provisional custom allocation at most three limbs. Its selected
small decimal path accepts at most 18 digits, whose prefixes fit the native
integer arithmetic. This is not a bound on an arbitrary decimal exponent.

For `Number.normalize`, a recursive square is computed only after division
by positive p has zero remainder. For nonzero v, this gives p≤|v|<2^64, hence
the next trial divisor is below 2^128. The next dividend has strictly smaller
magnitude. The returned valuation is at most 63; initial exponent magnitude
at most 16320 plus that valuation fits the conservative 16384 endpoint. Zero
bypasses normalization. This induction includes the last failed trial, not
just final normalized results.

Both signed correction layers matter. `Z.ediv_rem` adjusts truncated negative
remainders to Euclidean ones; `BigInt.computer_div_mod` can undo that adjustment.
Their temporary quotient/remainder values remain below 2^129 in magnitude.
Thus every reached arithmetic operand fits three limbs. The inspected C
request shapes allow at most four provisional limbs for addition/correction,
six for multiplication, and three each for quotient/remainder. Negation and
the fixed pair/record construction also fit. Six limbs plus the size/sign
word, custom operations pointer and block header gives 72 total bytes, with
eight payload words. This counts provisional requests rather than only
normalized retained payloads.

Faithful Zarith/GMP numeric behavior and ordinary allocation for these bounded
operands remain inherited primitive premises. The review closes reached
operand sizes; it does not claim a proof of GMP internals or an aggregate GMP
scratch price. Independent repeated-division references checked 32 positive/
negative normalization controls against the author's squaring trace, including
both correction layers, powers of two/five, and the actual fixed numerators.
The source induction supplies the general bound; controls alone do not.

## Private formatter ownership and flush behavior

The pre-T Format calls are converter lines 335, 372, 393, 395 and the `find_path` error
at 1354 using `pp_path` at 1337–1343. The exact R78 configuration disables the
debug AST printer. The mlw/sexp printer closure is created before T but called
only after typing starts. Registered exception printers belong to later
reporting; creating the exception payload does not execute them. The accepted
outer failure-report interfaces remain separate.

Each selected Format string call owns a fresh 512-byte buffer and formatter;
Yojson's Printf calls own fresh 64-byte buffers. The selected formats contain
fixed text, `%s`, represented `%d`/`%i`, and a fixed `%a` path printer.
`pp_path` supplies an empty separator and uses only literal brackets/dots and
integer text. There are no user formats, widths, precision, boxes, breaks,
tags or magic sizes. An `@` inside a `%s` argument stays literal data. Fixed
accumulator/closure arities therefore suffice; no generic arbitrary formatter
behavior is assumed by this argument.

With `L=max(64B+128,N+256)`, output is at most L, private backing at most
`max(512,2L)`, and the contents copy at most L. Buffer growth/substring checks
and source-fixed output callbacks preserve valid indices. No shared lifetime
counter is accumulated across conversions. Private buffers have no published
aliases, and the accepted C→T control relation excludes save-origin mutation
during a resize.

The formatter starts with one unknown system box, margin 78, and left/right
totals 1. At pending length 78 the system box is forced; it is first, so its
insertion point is zero. All subsequent tokens are known nonnegative-length
text. No new user box can appear. Totals are at most L+1 during ordinary
output; text can make space_left negative, which remains represented.
At flush, setting right_total to 1000000010 cannot block known text even when
L is larger. If the system box is still unknown, emitted length is below 78
and the sentinel forces it. Draining is finite; reinitialization resets the
counters and recreates one system box. Thus pp_infinity is a flush sentinel,
not a maximum accepted output length. Queue length, differences and buffer
doubling fit the exported bounds at L=2^37.

The review's scalar source model checked 44 chunk layouts around the margin,
sentinel, word boundaries and maximum L, including zero-length text. It
includes system-box creation, forcing, draining and reset. Its 792 refill
controls check compaction/growth and absolute-position identities. These are
mathematical controls, not executions of a generated lexer, native parser or
OCaml formatter.

## Joined claim, evidence and handoff

The five role exports preserve the exact configuration, accepted auxiliary
owner projection, source relation and one process-global e≤2/two save-entering
callbacks/three saves. Each rounded string payload/header, unsigned allocation
byte request and parser/formatter arithmetic bound was recomputed. No
successful typed-node count or physical cumulative-byte observation substitutes
for the actual individual operands. The public byte interface is conditional;
it is not a schema/origin validator or an admission check.

The accepted conclusion is the joined representation interface from C through
parsing/Gnat decoding/Ptree conversion to the **entry** of `Typing.type_mlw_file`.
The typing body and subsequent imports/clones/proxies/failed candidates remain
outside it. Oracle guarantees, language admission, tool pins and physical
assumptions are unchanged. No new cumulative physical allocation or aggregate
RAM/stack obligation was introduced.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation and token/cost telemetry are unavailable. Review began
2026-10-24 09:16:56 UTC in a fresh isolated worktree at the exact author commit.
The acceptance checkpoint was 09:22:06 UTC, 310 seconds later; final reporting
and commit work are excluded from that observation. `scripts/dev.py paths`
identified Linux x86-64. The live harness goal was read as null; no goal or
CLI-memory write occurred.

The independent
[`audit.py`](../evidence/review-main-prefix-consumers-20261024/audit.py)
passed **1,514 checks in 1.777760993 seconds**, once, on
`Linux-7.0.14-x86_64-with-glibc2.43`. The command receipt reports 1.763851417
seconds; checker/tool timings are reported separately. Evidence includes 17
exact author inputs, 118 provider/prior-packet identities, 24 complete source
identities, 72 excerpts, 18 numeric snapshots, 32 normalization controls, 792
refill controls and 44 formatter layouts. A preliminary read-only source
printing command requested a range past the end of `bigInt.ml` and raised
IndexError; it wrote nothing and was corrected before the audit. No audit
failure or native failure is hidden by that inspection error.

The author's successful 899-check draft and final 944-check receipt are retained
as author history. The final rerun followed replacement of a vacuous formatter
control by an actual queue/flush simulation and a stronger Safe selector.
The author's recorded extraction-span and nonarchive-inspection errors remain
preparation history. None of those author scripts was executed for this review.

No new retrieval, native target/capture, compiler/prover/Lean, disassembler,
service, author/predecessor checker or extractor was run. The review adds only
its evidence directory and this report, then freezes a local review commit.
Root owns integration/publication and issue/session-memory updates. No GitHub,
push, author-file or goal mutation belongs to this review.
