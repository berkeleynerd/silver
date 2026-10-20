# Selected save formatter: composed direct allocation requests

2026-10-20 UTC, Linux x86_64, research #119 / #153, Round 34.

The selected formatter/printer route has a **complete conditional accounting
of direct requested object representations**. This composes the accepted
accumulator, Format-core, scalar, restored-path and file/channel results with
the missing native object charges. The five interval totals below include
all three allowed save attempts, including nested and abandoned prefixes.
They deliberately assume no reclamation of these objects. They are neither
physical-memory requirements nor whole-formatter/whole-save capacity claims.

The [packet](../evidence/retained-why-save-format-allocation-20261020/README.md)
contains the arithmetic transfer, exact imported identities, source excerpts
and native layout witnesses. Its default export is null; supplying its five
named external premises makes this scoped direct-request bound available.
No new premise saying merely "the allocator is big enough" is inferred from
the sum. Required ordinary runtime services remain at the existing
[trusted boundary](../trusted-boundary.md).

## Boundary and ownership

Inputs are the accepted [Round 32 path/input join](retained-why-save-path-input-join.md),
[Round 33 accumulator result](retained-why-save-format-accumulator.md),
[core transfer](retained-why-save-formatter-core.md),
[scalar transfer](retained-why-save-scalar-format.md),
[state/shape transfer](retained-why-save-state-join.md) and
[file/channel extents](retained-why-save-file-capacity.md). Their occurrence,
typed-value, source/native, scalar-service, ownership and continuation conditions
are retained. In particular, `r <= 3` counts all save entries over the entire
post-cut interval; it is not restarted at each recursive save. Actual service
success is not asserted by the candidate evaluation.

The accounting owns fixed local closures/options/references/context blocks in
`Session_itp.save` and its output printers, `Termcode.string_of_shape` printer
closures, all selected `Format`/`CamlinternalFormat` direct allocations, their
fresh `Buffer`s, restored-path concat destination blocks, and the stated new
file/channel objects. Already present strings, fixed typed-format ASTs, literal
tokens, and existing input lists are not new allocations. `Sysutil.file_path`
is already a string list and `decompose_path p = p` (`sysutil.ml:131–135`), so
printing file-path components introduces no hidden splitting allocation.

Distinct owners retain structural save statistics/maps, fold-produced pair/list
nodes, sorting, shape production/dictionary strings, table/getter allocations,
the preliminary `save_session` shape/counter traversal, signal/error/exit
handlers, and global channel-list traversal/refcounts. The caller-local charge
below includes the closure *passed to* a fold, not the records created *by* that
fold. In the retained save-printer native region, `fun_10184` and `fun_10201`
construct pair/cons groups (48 bytes each), and `fun_10367` constructs a prover
tuple (40 bytes); these three groups belong to structural construction, not
this total. Their bodies are retained to make that boundary inspectable.

## Native blocks and per-stream core accounting

All OCaml charges include the eight-byte header, and no shared object is charged
again because another field points to it. A string/bytes object of length L
requires `S(L) = 8*(1+floor((L+8)/8))` bytes. A two-field record or list cell
requires 24 bytes, a three-field record 32, a one-field option 16. The installed
formatter has 28 fields, hence 232 bytes (`0x7000` header). Its five mutable
Stack records use 120 bytes and its Queue record 32. Three default output
closures use 120; the channel output/flush closures use 80, or the Buffer output
closure 48. Thus **640 bytes per formatter** covers these fixed objects
(584 for a channel formatter, 552 for a Buffer formatter).

Factory-created system queue elements, scan entries, sentinels and cells belong
to the dynamic core charge below, not to that 640. The native factory's own
reservation sites are 64,24,24,328 bytes; its calls to Queue.add, sentinel
initialization and Stack.push expose the remaining initialization objects.
Static system-begin/text tokens are conservatively allowed a fresh-token charge
in the dynamic bound, without asserting that they are actually allocated.

For one fresh formatter stream let E bound prospective direct operations,
including its final flush, and put `I=3E+1`. The accepted core argument bounds
all queue insertions, including automatic closing and reset system boxes, by I.
The following ownership partition bounds **cumulative** dynamic requests:

| Dynamic owner | Bytes per stream | Reason |
| --- | ---: | --- |
| Queue elements, token payloads, break triples, queue cells | `144I` | At most 32+24+64+24 per insertion; ordinary breaks allocate two triples. |
| Scan entries and their stack cons cells | `48I` | At most one two-field scan entry and cons for each scanned insertion, including the factory system box. |
| Formatting entries and their stack cons cells | `48I` | At most one two-field box entry and cons per formatted begin token. |
| Stack `Some` results | `144I` | At most `5I` top and `4I` pop results, 16 bytes each. |
| Queue peek `Some` results | `32I` | At most `I+2E <= 2I` successful peeks. |
| Replaced sentinel entry/queue-record/cons groups | `160I` | At most `1+4E <= 2I` initializations, 80 bytes each. |
| Flush tag-iterator closures | `64I` | At most E flushes; native closure is 32 bytes even with an empty tag stack. |
| **Total** | **`640I`** | Includes old unreachable objects; no collection credit. |

For the option counts, `set_size` is called at most `3E`: once per break and
twice per close, including automatic closes (each consumes a user open).
Each call takes at most one stack top and pop. Formatting a token adds at most
one top or pop, and opening a box may add one top in `pp_force_break_line`.
The displayed `5I`/`4I` allowances exceed those sums. Each `advance_left`
entry has at most one final non-removing peek; at most `2E` such entries and
I removing iterations occur. `Queue.take` allocates nothing. Sentinel
initialization occurs at factory creation, each flush reset, or once per
obsolete `set_size`, giving `1+E+3E`. The 80 bytes are a 32-byte dummy queue
record, 24-byte scan record and 24-byte stack cell; its text token is static.

This analysis uses the selected no-tag/no-tab/no-Magic_size/no-setting-change
route. Generic tab allocation branches visible in `format_pp_token` are not
reachable. Ordinary text output, blank-line output, Queue/Stack clearing and
the selected break arithmetic allocate no additional caller objects. The
`caml_modify` write-barrier service is an allocator/runtime interface, not an
unmentioned OCaml result object.

## Stream composition, scalars and caller closures

Use the accepted C and O occurrence expressions (`C <= 8Q`, `O <= 2Q`).
There is one XML formatter, at most G per-goal shape `asprintf` formatters,
one shape-header formatter and O annotation formatters: `K=G+O+2`.
XML uses the joined E and B. Each fixed annotation has E=2,B=7.

For a bound-shape list, `string_of_shape` prints only nonempty integer strings
and literal `H` separators, with no breaks. Its accepted **per-string** byte
bound W therefore also bounds the number of text events: each event contributes
at least one byte. Add one final flush, giving `Eshape=W+1`, `Bshape=W`.
An empty list only flushes; the Old_shape branch returns an existing string.
The header has fewer than 64 bytes of literal/version text and no breaks, so
E=65,B=64 is sufficient. This uses no shape-file-total as a string length.
Across streams per save:

```text
Estar = E + G*(W+1) + 65 + 2O
Itotal = 3Estar + K
fixed formatter requests <= 640K
dynamic core requests <= 640Itotal
```

Each normal scalar conversion or single-character temporary has a distinct
prospective text-event slot. This assignment is made before the conversion,
so an interruption before enqueueing does not erase its request. A 192-byte
allowance per slot covers the largest selected scalar route: `%g` allocates
a 48-byte closure in `convert_float`, a 24-byte internal-format Buffer record,
32-byte Buffer16 backing, 16-byte precision `"6"` string, 16-byte `"%.6g"`
string, and at most 32-byte result: 168 bytes. Its buffer never grows. Integers
need at most 32; `pp_print_char` needs 16; Boolean/literal strings may be static.
Format argument/continuation blocks belong exclusively to the accepted
`128C+192*(27C)` accumulator subtotal, and annotation parser/substring blocks
to `208O`. These two accepted subtotals are imported without replaying their
checker. No caller-selected width, precision, padding or runtime format AST
is admitted here. C numeric scratch buffers and native call frames belong to
the separate stack/service interfaces, not to heap allocation.

Caller-local native allocation groups are separately charged as follows:

| Caller | Per invocation | Invocations per save |
| --- | ---: | ---: |
| `save` | 184 | 1 |
| `save_prover` | 72 | A |
| `save_result` | 72 | Axml |
| `save_file_path` | 32 | `F+Axml` |
| `save_proof_attempt` | 224 | Axml |
| `save_goal` | 288 | G |
| `save_trans` | 224 | T |
| `save_theory` | 112 | Th |
| `save_file` | 160 | F |
| `string_of_shape` printer closures | 104 | G |

These are the sums of native constant reservation sites in each body, including
optional paths conservatively. Other printer helpers in the retained region
allocate no own local blocks. Generated printer closures tail-call the selected
printer bodies; the selected list/HTML loops allocate no per-item closure.
The typed application path and `%a` curry bridge are already covered by the
accepted accumulator argument. No extra dynamic-format closure owner is hidden
in the event total. The separately retained `save_session` body's two 40-byte
closures belong to its preliminary traversal owner and are excluded here.

## Buffers, files and channels

Each annotation Buffer16 owns one 40-byte record and one 32-byte backing,
giving `72O`. `compute_tag` calls `Buffer.sub` directly for the selected
descriptions, so there is no extra raw `Buffer.contents` copy. Its description
copy and parser substrings are already in `208O`.

For each Buffer512 `asprintf`, let `c=512*2^k` be the least such capacity at
least its output bound W (use 64 for the header). The complete direct request
charge is

```text
40 + sum(i=0..k, S(512*2^i)) + S(W).
```

The initial buffer and final current buffer may both be reachable through
`initial_buffer`/`buffer`; they are distinct after a resize and are both counted.
The sum even includes capacities skipped by a large append. A successful resize
strictly increases capacity, so each capacity is allocated at most once within
one fresh Buffer lifetime; an abandoned resize cannot resume and allocate it
again under the private-frame premise. The native `resize` keeps its source
`new_len` reference in a register/stack slot, not a heap reference. Its normal
route allocates only the new backing. `contents` allocates one result copy and
`reset` merely restores the initial backing. Both abandoned and successful
backings remain in this cumulative sum.

The imported file packet owns at most `9r*S(Ddir+20)` OCaml pathname block
bytes, `19r*(Ddir+21)` C pathname-copy bytes (including channel names), and
`2r*65616` C channel-record bytes (including each 65536-byte I/O buffer).
Two additional direct objects per new channel close its representation ledger:

* The channel custom wrapper has a custom-operations pointer and channel pointer:
  two payload words, hence **24 OCaml bytes**. `alloc_custom_gen` computes
  `wosize=1+ceil(8/8)=2`. The 65616 argument is GC resource accounting, not another
  payload allocation.
* `caml_io_mutex_lock` requests **40 C bytes** lazily when `mutex=NULL`, initializes
  the mutex and publishes it. Under normal locking and private-channel behavior
  this is at most once per channel; the bound also covers the route where no
  hook is installed. Native size `0x28` is checked. Failed initialization exits
  through its error service; no normal retry loop on the same channel is assumed.

Libpthread's own implementation/TLS representations, custom-table and remembered
set growth, GC copying/promotion/metadata, allocator rounding/reservations and
errors retain runtime-service ownership. The direct objects passed to those
services and their valid sizes are explicit here. Ordinary runtime correctness
and sufficient external resources remain existing trust assumptions; this
packet neither proves collector invariants nor adds a requirement to prove
the whole allocator, libc or kernel. Source-owned failure catches, pending
actions, global channel wrappers/refcounts and native stack capacity are still
separate obligations. No finite EINTR count or positive-write service attachment
is inferred from the allocation total.

## Machine guards, lifetime interpretation and results

The checker evaluates each stream's sentinel/container guards independently.
All per-object strings/backings fit `Sys.max_string_length=(2^57)-9`; payload
words fit the 54-bit header size field. Buffer position+append and capacity
doubling stay below `2^62-1`, with byte rounding below unsigned 64-bit limits.
Private Buffer induction preserves `0<=position<=length` and valid blit ranges;
all output slices inherit the accepted core/client bounds. Fixed object layouts
and the channel/mutex C request sizes have no variable-size arithmetic.
The largest new string/backing is 131072 bytes in the first two cases and
116162 bytes in the others (the conservative restored identifier extent).

Multiplying the per-save disjoint totals by global r=3 bounds every attempted
prefix, including interrupted constructors before publication. This deliberately
forgoes lifetime reuse: the bytes of all distinct caller objects ever requested
also bound the bytes of those objects simultaneously retained. It does **not**
count duplicate representations held during copying GC, collector metadata,
runtime reservation granularity, stacks, or objects belonging to other owners.
Thus it is a conservative caller-object live envelope, not an OS memory estimate.

| Case | All direct requested bytes across interval | OCaml block bytes | C object bytes |
| --- | ---: | ---: | ---: |
| Put_Line | 95,095,382,112 | 95,094,985,896 | 396,216 |
| Put | 72,677,794,467 | 72,677,398,536 | 395,931 |
| First_Or_Default | 28,512,934,719 | 28,512,537,648 | 397,071 |
| Is_Message | 3,753,840,753 | 3,753,444,024 | 396,729 |
| Input_Is_Valid | 4,515,574,341 | 4,515,177,384 | 396,957 |

The coarse per-event option/reset charge explains the large totals; they are
valid cumulative envelopes rather than measured heap demand. The packet now
has a complete scoped direct-request accounting argument, not another inventory
of missing formatter objects. No physical runtime demand/sufficiency measurement
is exported; this is not a new obligation to prove the trusted collector
implementation. The whole native stack, source-owned failed-service
continuations and complete save/pipeline joins remain open, with their
corresponding flags false/null.

Selected author model: GPT-6 Astra / Extra High; live runtime settings and
individual token/cost telemetry unavailable. Base: `79301d13cfac0dafccf9e53b5da17345266d4eca`.
The packet records focused check timing and review freeze separately. No target
execution/capture/disassembler, proof run, predecessor checker replay, Oracle,
source/pin or production change was performed. CLI memory was not updated.
