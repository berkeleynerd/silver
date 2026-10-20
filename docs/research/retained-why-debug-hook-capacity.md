# Selected Debug Stats hook: output, allocations and caller stack

2026-10-20 UTC, #119 / #153; retained Linux x86_64 inputs. Selected
GPT-6 Astra / Extra High; runtime confirmation and token/cost attribution are
unavailable. Author base `f79a5736e42c7cac9b414d929b2c64783a1e7b83` plus
first-use provider `7ead79763d239bbd81ed734b2aaa1ef01d8cc747` (local cherry-pick
`5d0c000255`). The parent reported acceptance of that exact provider in review
`ec08dd19e5ee5efc85885c4b1746672723908a22`; this work imports its bytes without
replaying its checker.

Under the named source/runtime and service premises, the selected once-only
Debug Stats hook offers at most **26,619 bytes** to its Buffer, requests at most
**684,672 bytes** of new caller-owned OCaml blocks, and adds at most **16,272
bytes** of caller stack to explicit service frontiers. These are conservative
source bounds for normal execution and abandoned prefixes. They are not observed
totals, physical capacity, or a completed exit/save result.

The [packet](../evidence/retained-why-debug-hook-capacity-20261020/README.md)
checks exact successful component inputs and new retained instruction witnesses.
It does not execute gnatwhy3, fetch sources, disassemble, run a solver or replay
a predecessor checker. Passing arithmetic and byte checks do not prove the
semantic argument below. The existing [selected source/native behavior
relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
and valid runtime representations remain explicit premises; historical source
identity is not newly claimed.

## Entry, attempts and preserved ownership

The accepted [first-use result](retained-why-debug-formatter-control.md) identifies
the Debug formatter with `Gnat_main.escape_formatter`, with Buffer capacity 42,
position 0, default fresh formatter settings, one unknown system-box token in
the queue, and system-entry-plus-sentinel scan stack. Its output is Buffer
`add_substring`; its flush is ignore; spaces/indent use `display_blanks`. Newline
passes through exactly one Debug wrapper, which invokes the captured default
newline and then the captured ignore flush. No earlier enabled print mutates
this formatter, and these callback identities/settings remain preserved.

The accepted [growth result](retained-why-exit-timing-growth.md) supplies at most
26 callback entries over the whole remaining suffix, 1,051 distinct key bytes,
maximum key length 59, a fixed 64-slot backing, no resize, and uniform counters
195/162/99/12/6 in case order put_line/put/first_or_default/is_message/input_is_valid.
This remains a whole-suffix bound when signal callbacks suspend ordinary work.
It is not 26 multiplied by each save or each exit dispatch.

`registered_stats` is empty, although `print` still allocates the closure for
its unused List iterator. The installed once gate clears **before** entering
the hook. A nested exit cannot enter the same hook, whether the first hook is
still suspended or has failed. `Hashtbl.iter` only restores its traversal marker
and reraises; it does not restart a row or catch a failure and continue printing.
There is no rollback or same-hook retry after partial Buffer/core mutation.
Global budgets **r<=3 and e<=2** remain unchanged and are never reset here.

Faithful runtime callbacks may suspend and resume one current source operation;
they do not replay a completed allocation prefix or manufacture a formatter alias.
A callback that escapes abandons the current hook. A resumed interrupted
operation is counted once. The first-entry constructor theorem is not asserted
again after any partial Stats work. Other active saves have their own formatter
objects and their own already-budgeted charges.

Services must return according to their retained normal contracts or escape to
their existing failure continuation. The `%f` normal contract covers every
binary64 value, including nonfinite values, under the retained GNU conversion
and effective-locale premises. This does not establish those future service
premises, or the resource usage of a failing allocator, formatter, GC, libc or
signal service. A malformed out-of-contract return is not silently treated as
a valid source prefix.

## Core operations, output and representations

The exact template is `<stats>@[%s: %f, %d@]@.`. Its nine main accumulator nodes
are six text nodes (three literals, name, float, integer), an open box, a close
box and a newline flush. Each contributes one direct core operation. The box
annotation is the empty accumulator, whose helper does no text operation and
one `pp_print_flush`. After iteration, the hook calls one more main flush.
Thus, including attempted operations before abandonment:

```text
C = 26 rows
B = 1051 + 26*348 = 10099 text bytes
E_main = 9*C + 1 = 235
E_annotation = 1, B_annotation = 0, at most C separate helpers
I_main = 3*E_main + 1 = 706
I_annotations = C*(3*1 + 1) = 104
I_total = 810
```

The per-row 348 bound is imported from the accepted
[format extension](retained-why-exit-timing-format.md); it includes the full 317-byte normal `%f`
bound and a conservative tagged-integer decimal bound. Actual timing counters
need at most three digits. Variable names remain data strings, never formats.
No tags, tabs, custom formats, Magic_size, `%a`, `%t`, setting changes or further
box-annotation recursion enter these streams.

Apply the accepted [core induction](retained-why-save-formatter-core.md) with
`L=B+E_main=10334`, `P=1000000010`, `N=4*(E_main+1)=944`. Its guards are
`L+79=10413<=P` and `N+2=946<=2^62-1`. Totals, stored unknown sizes, depths,
queue/stack lengths and intermediate indentation calculations therefore satisfy
that transfer. Depth is below max_boxes; annotation helpers satisfy the same
guards with B=0/E=1. Flush adds pending closes and reset system boxes within I;
it assigns P, drains, and resets, rather than adding P to the old total.

For a deliberately conservative output bound, retain the core theorem's
`B+70*(E_main+1)=26619`. This includes possible automatic newlines and up to 68
indentation bytes at each relevant operation, in addition to the 26 explicit
row newline requests. It therefore does not equate the raw data-plus-newlines
subtotal with all Buffer output. There are at most `4*(E_main+1)=944` direct
core output/flush callback calls. Each selected output/string/newline/spaces/
indent path performs at most one Buffer append: `display_blanks` receives at
most68, below its 80-byte recursive threshold. The Debug newline wrapper adds
an ignore-flush call and no byte or allocation. The 944 count is for calls from
the core, not all transitively invoked closures.

Empty annotation helpers drain only their zero-length system token and flush
without a newline. They emit **zero bytes**. Buffer 16 never resizes;
`compute_tag` takes its len<2 `Buffer.contents` branch, and the empty box
description immediately returns `(0,Pp_box)`. No annotation scanners, numeric
parser or parser closures run. The final main flush has no additional explicit
newline and no `Buffer.contents` call.

The main Buffer can grow through powers of two from 42 through 43,008. All
append indices are nonnegative, `position+length<=26619`, and the doubling
arithmetic is far below max_int. Capacity 43,008 is below the retained
`Sys.max_string_length=2^57-9`; its block needs 5,377 payload words, below the
54-bit header limit. The largest newly requested OCaml block is43,024 bytes.
Fixed closures/records, annotation strings and317-byte float results also fit.
Hashtbl's traversal marker only changes the existing +/-64 field; its loop
index is 0..63 and the backing remains64. Counts remain within their accepted
small bounds. These are object/operation guards, not a single allocation of the
cumulative charge.

## New allocations and retained objects

Use the accepted [allocation transfer](retained-why-save-format-allocation.md)
`640I` only after supplying the preceding selected-token and E bounds. Its
queue/token/cell, scan/format-stack, Some wrappers, reset sentinel and empty
tag-iterator closure partition also covers prefixes of a failed operation.
Its initial main dummy-box allowance is an overcount of new work, because
those constructor objects already exist. Keeping that allowance is safe; it
does not assert they are newly allocated.

| New caller-owned block-request charge | Bytes |
| --- | ---: |
| Main and annotation dynamic core, `640*810` | 518,400 |
| 26 annotation formatter fixed allocations, `640*26` | 16,640 |
| Main accumulator/argument/format continuations, `26*(128+192*9)` | 48,256 |
| Float conversion objects, `26*464` | 12,064 |
| Integer converted strings, `26*32` | 832 |
| Annotation Buffer records and backing strings, `26*(40+32)` | 1,872 |
| Empty annotation contents, safe16-byte allowance each | 416 |
| Debug print closures32+40, Hashtbl bucket-loop closure32 | 104 |
| Main Buffer backing growth | 86,088 |
| **Total** | **684,672** |

The [accumulator transfer](retained-why-save-format-accumulator.md) supplies
128 per attempted format expression and 192 per main node. No annotation node
is added: the empty annotation has only an immediate terminator. These charges
cover the float 64-byte argument closure and 24-byte accumulator node separately
from its 464-byte conversion subtotal. The latter includes the eager unused
hexadecimal closure, internal formatting Buffer/record, precision/format strings
and 328-byte result. The old 192 scalar-event allowance is **not** used for `%f`.
No literal in this template is a single-character node; there is no additional
`pp_print_char` allocation. The empty box result needs no parser charge; the 16
contents allowance is safe even if the runtime shares its empty string.

For string length n use `S(n)=8*(1+floor((n+8)/8))`, including the header.
The main Buffer growth charge sums S over84,168,336,672,1344,2688,5376,10752,
21504,43008. A resize may skip capacities, which only lowers this sum. Every
successful resize strictly increases the stored capacity. If a resize has
allocated a new backing but exits before publishing it, that abandoned final
request is already one of the larger powers in this same sum; no subsequent
same-hook retry can allocate that capacity again. The source `ref new_len` is
optimized into registers/stack in the retained Buffer resize body, as established
by the imported allocation witness. There is no extra heap ref charge.

The preexisting owned formatter/Buffer graph has a separate safe 1,456-byte
charge: fixed formatter 640, constructor dynamic allowance 640, Buffer record 40
plus initial 42-byte backing block 56, and captured output-functions record 48
plus Debug wrapper 32. Adding this to every new request without reclamation gives
**686,128 bytes** for those owned initial objects plus newly created objects.
That is a logical object-storage envelope; it excludes preexisting timing
table/key/input objects, global roots, other live saves and ambient heap.
The Buffer can keep its initial backing and current backing reachable together;
the cumulative envelope already allows both and every abandoned backing.
It also overcounts dead accumulator/formatter objects, deliberately requiring
no reclamation to justify the source subtotal.

The normal C float path's at-most 21-byte saved-format malloc request can occur
at most 26 times, giving a separate 546-byte requested subtotal in R. It is not an
OCaml block and does not include libc/allocator metadata or internal requests.
Neither that subtotal nor the caller envelope bounds GC relocation, heap-region
reserve, allocator rounding, failed service work or physical availability.

## Native callers and the formatter component

The selected native chain is Debug hook `fun_3069` -> `print_1651` -> generic
`Hashtbl.iter_730` -> `do_bucket_734` -> `apply2` -> timing row `fun_3056`.
The allocated row closure has arity two and a raw `fun_3056` entry, so apply2
uses that exact-arity entry; the stored curry2 entry is not invoked here. The
row calls `fprintf` and tail-transfers to apply4 with the static format, name,
float and counter. Its unary Format wrapper then returns the finite string,
float and integer argument closures. The tuple and boxed time already exist;
the row body allocates no fresh pair or boxed float.

The 64-slot array loop and bucket traversal are native backward jumps. No frame
is retained per table slot or timing cell. Hashtbl's exception handler has 16
trap bytes, restores the old traversal sign when required, and reraises to R.
The valid fixed backing excludes its array-bound-error branch. The registered
List iteration sees nil, so its allocated callback body and `%t` are excluded.

| Additional owned body/context | Own bytes including return |
| --- | ---: |
| Debug hook | 16 |
| Debug print | 16 |
| Debug timing row | 48 |
| Hashtbl.iter including exception trap | 80 |
| Hashtbl.do_bucket | 32 |
| Hashtbl.ongoing_traversal | 8 |
| Stats empty List.iter instance | 32 |
| Debug newline wrapper | 16 |
| Caller-side apply2 and apply4 | 16+32 |
| **Conservative sum** | **296** |

Each additional body has at most one simultaneous instance in this hook.
Summing them overcounts mutually exclusive and tail-replaced contexts safely.
Caller apply2/apply4 and the Stats List iterator are charged here by invocation
context, outside the Format component's internal adapter/tag-iteration instances.
The captured default newline and ignore flush bodies are already in F; only
the 16-byte Debug wrapper is added.

Reuse the accepted [formatter closure](retained-why-save-binder-formatter-stack.md)
with its accepted Float_f/empty-annotation extension. There is one main formatted
invocation, at most one active annotation helper, and one terminal/helper
allowance. Thus **H=3** safely bounds each other ordinary owned body. Core,
Buffer and format-construction loops are tail loops; callbacks only append to
Buffer and cannot reenter a formatter. Unlike the save's `%a` environment, this
hook has no synchronous nested main formatted invocation.

Use **J=48**, three levels times the inherited 16-layer allowance for each
selected arity-at-most-four apply/curry body. This includes internal construction,
factory, output and annotation adapters; repeated rows or text bytes do not add
levels. The separate caller adapters above cover the Hashtbl-to-row and
row-to-format boundary. The fixed 9-node main accumulator contributes at most 10
`output_acc` frames including its terminator; the empty annotation contributes
one, so **O=11**. These justified values give:

```text
F_hook = 2392*3 + 176*48 + 32*11 = 15976
Hook caller stack to explicit services <= F_hook + 296 = 16272 bytes
```

F's exact own-frame sums include many unused name/constant/channel bodies,
which is safe overcounting. They do not make the hook's callback environment
arbitrary: the timing template excludes every serializer `%a`/`%t` import,
name/constant root and channel callback. The packet records the finite selected
new edges and narrowed callback environment. Exception/GC frontiers remain
explicit. Runtime polling can invoke already-budgeted callbacks, whose active
save/exit frames are composed separately rather than restarting this theorem.

The 512-byte long-float C wrapper shell belongs to **R**, as does the OCaml-C
bridge, GC/allocator/libc services, signal machinery and failure handling. The
16,272-byte caller term does not absorb any of these or ambient **A_pre**. The
once-gate wrapper and outer exit dispatcher are owned by the existing exit
component outside this root. At most one Stats hook term may be active; it is
added once alongside other active components, never multiplied by r or e.

Complete exit stack/capacity and complete save capacity remain false. Ordinary
standard/error formatter phases, R, ambient storage/stack and physical capacity
still need their own joins. Oracle, admission, production code and tool pins
are unchanged. Root integration owns issue and durable-memory updates; no CLI
memory was updated by this subthread. Check/round timing is in the packet.
