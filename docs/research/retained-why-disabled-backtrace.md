# Disabled exception backtraces in the selected continuation

2026-10-20 UTC, Linux x86_64, owner-authorized research #119 / #153. Base
`c80fe75816cff369030b2c6e5ffaa0fcd165ad52`. Selected author setting: GPT-6 Astra /
Extra High; runtime model/effort confirmation and token/cost telemetry unavailable.

Under the existing selected source/native/runtime/loader relation,
**exception-backtrace recording is inactive at all five retained cuts and remains
inactive through their selected suffix**. The diagnostic raw backtraces supplied
by the standard uncaught-handler machinery are empty. This gives the following
conditional **per-invocation** interface, including unsuccessful prefixes:

| Operation on that empty raw input | Direct object requests, including headers | Result / direct channel request |
| --- | ---: | --- |
| Raw getter, including `try_get_raw_backtrace` | 0 bytes | Empty raw array |
| `raw_backtrace_to_string` | At most 1,112 bytes | Returns either 0 or 59 bytes, or propagates/terminates |
| `print_raw_backtrace` | At most 80 bytes | At most one 59-byte channel request, or propagates/terminates |

Both printing interfaces have a **912-byte conservative projection of selected
own native frames**. Adding the already owned direct C/GC bridge allowance gives
**5,016 bytes per active invocation**, before external service interiors and
pending-client contributions. This is a sum of inspected frames, not a measured
high-water mark or complete process-stack requirement. The getter and optional
convenience-wrapper frames are deliberately included in that sum.

The nonempty result is significant: **inactive recording does not imply that
the string is always empty**. A pending signal's `Failure` can be caught by the
conversion wrapper and select its fixed 59-byte fallback. This result closes
this backtrace component; it neither bounds all exception diagnostics nor
supplies a whole-suffix reporting count, complete R or capacity.

The [evidence packet](../evidence/retained-why-disabled-backtrace-20261020/README.md)
retains source excerpts and inventories, exact five-process attachment, selected
native bodies and frames, and the fallback's ELF data layout. Its checker checks
those inputs and arithmetic. It does not prove the semantic control argument.

## Selected process and authority boundary

The cases are Put_Line / 17310, Put / 17514, First_Or_Default / 17631,
Is_Message / 17704 and Input_Is_Valid / 17869. The first four cuts are the
registration entry to `Gnat_checks.iter`; the fifth is the first cvc5
`Driver.apply` for `inline_trivial`. All have the same executable SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
Why3 source is revision `9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml is
`8eb41f72ded84df884c3671734c947f612091f84` (4.14.2).

The checker joins the accepted [Debug input attachment](retained-why-debug-formatter-control.md)
to the [five-process prefix attachment](retained-why-path-initial-state.md#exact-input-and-initialization-attachment).
Those records already attach actual argv/environment, the same seven images,
one initial OCaml worker and no new worker, fixed `gnat_json` / `ada_terms`
plugins, and the selected typed/native owners. This packet does not replay
their captures or checkers. In particular, an image-map match alone would not
exclude an application callback.

The reused capability relation excludes generic native/module reflection,
application finalizer/alarm registration and Memprof start. It includes the
classified collector, Thread, channel, custom-destructor and pending-signal
owners. Thread SIGVTALRM and GNAT's SIGINT save/exit are the selected OCaml signal
clients. The continuation remains Per_Check, CE off, non-replay, built-in
`cvc5,z3,altergo`, external-server, without a new interactive/configuration/plugin
route. Earlier signals are not assumed absent by this argument.

Source transfer still requires the named
[behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
and valid representations. Matching bytes and local source owners do not prove
universal binary refinement. The Oracle's complete-call-chain and all-path
requirements remain unchanged. The ordinary external allocator/GC/OS contract
applies to valid represented requests; it does not discharge caller arithmetic,
frame demand or the remaining phase joins.

## Why recording stays inactive

The induction tracks only `Caml_state->backtrace_active = 0`. It does not require
`backtrace_pos` or `backtrace_buffer` to stay zero.

1. Native startup initializes the domain before parsing runtime parameters
   (`startup_nat.c:106–124`). Domain initialization sets active/position to zero,
   buffer to NULL and last exception to unit (`domain.c:75–78`). The installed
   initializer's vector store at `0x9e36bd` zeros active and position, with
   active at offset `0xe8`. This is an executed startup-prefix fact under the
   accepted relation, not an inference from zero-filled ELF storage.
2. The actual `OCAMLRUNPARAM` is `s=256M,h=16M,M=1000`. The parser's only
   recording call is option `b` (`startup_aux.c:103–125`), absent from these
   bytes. Its `CAMLRUNPARAM` fallback is taken only if `OCAMLRUNPARAM` is absent.
   The native executable does not select bytecode startup's separate `-b` route.
3. The complete 603-source Why projection has four recording-call occurrences.
   Two are GNAT argument closures: `--debug-why3 stack_trace` and
   `--debug-stack-trace` (`gnat_config.ml:224–238`). All five argv omit those
   options. The `Debug.Args` setter (`debug.ml:143`) belongs to the initialization
   route already excluded by the accepted Debug control proof: GNAT parses its
   own options and reads config directly, without invoking the Whyconf/Debug
   argument initializer. `trywhy3/why3_worker.ml:50` belongs to the unselected
   browser-worker frontend. No selected suffix enters any of these entry routes.
4. There is no hidden unqualified setter client: the inventory retains every
   `record_backtrace` occurrence and every Printexc open/include/module alias or
   local open in that projection. Why's local opens invoke callstack/restore
   functions, not recording. The Stdlib alias is a re-export, not an initializer
   call. The retained OCaml runtime/stdlib/otherlibs/utils and Sexplib, Sexplib0 and
   Parsexp projections add no selected application enablement. The runtime's
   actual active-field writers are domain initialization, the recording setter,
   and the default C fatal handler's save/disable/restore sequence. The latter
   restores its saved **zero**; even conservatively allowing it does not break
   the invariant. No successful diagnostic or successful exit-hook execution is
   needed for that preservation.
5. Native symbol references corroborate precisely the two GNAT closures,
   Debug's selected-flags body, the exported Printexc wrapper, and the runtime
   parameter parser. The exported wrapper is a capability, not evidence of a
   selected call; its clients are resolved by the typed source census and fixed
   loading relation above. The ordinary native owner contracts preserve this
   private runtime field. Thread context save/restore writes position, buffer
   and last exception, **not active**. `restore_raw_backtrace` likewise does not
   activate recording. Raises, handler catches and signal unwinds do not invent
   a recording setter or obtain a new reflective capability.

This is source/client induction with a native attachment. Grep results alone
would neither close exported-function aliases nor exclude arbitrary native
stores. The accepted owner/loader relation supplies that boundary. Inactivity
persists after partial Stats work as well: Stats and formatting do not enter
configuration setters. The first-use freshness limit of the earlier Debug
formatter result is not incorrectly transferred to this separate flag invariant.

## Empty raw provenance and the two outcomes

`caml_get_exception_raw_backtrace` tests active before buffer/position and calls
`caml_alloc(0,0)` whenever recording is inactive (`backtrace.c:164–181`). Native
`0x9dd7af -> 0x9dd7c7` selects that zero-size call. `caml_alloc(0,0)` returns the
preexisting atom; it allocates no new array. This remains true even if a restore
or thread operation changed the other backtrace fields.

The standard uncaught route obtains its raw input through `try_get_raw_backtrace`
or uses its static empty array. The fallback after a failing custom handler does
the same for the secondary exception (`printexc.ml:319–346`). GNAT's installed
handler passes that argument directly to `raw_backtrace_to_string`
(`gnat_util.ml:11–24`). Convenience `get_backtrace` / `print_backtrace` use the
same raw getter. The only Why `get_callstack 100` client is Pinterp's location
inspection; it does not supply these diagnostic arguments. The unselected
Thread-create reporting closure also uses the raw getter. This result does not
cover an arbitrary caller-supplied raw array: `get_callstack` can return a
nonempty array independently of exception-recording status.

For the empty raw array, native `caml_debug_info_available` returns 1. Both
conversion loops have length zero; no debug-location extraction, filename,
defname, slot formatter or nested inline-frame expansion is reached. Conversion
returns `caml_alloc(0,0)`, again the atom. The OCaml wrapper then constructs
`Some empty` (`printexc.ml:132–134`), with a 16-byte request in native
`0x97de28`.

That wrapper's trap remains active through the `Some` allocation. Its slow
allocation path invokes the selected GC/pending interface. A `Failure` delivered
there, including one escaping a SIGINT save, selects `None`; native
`0x97de4c–0x97de68` tests the Failure constructor. The native constant
`debug_info_available = 1` therefore excludes the ordinary missing-debug-info
failure but **does not exclude this asynchronous fallback**. Other exceptions
propagate or terminate; no recursive backtrace conversion is performed by this
catch. A failure later in Buffer construction/copy or Printf/channel output is
outside this conversion trap and cannot restart it.

For `Some empty`, both OCaml slot loops execute zero times. The string operation
still constructs `Buffer.create 1024`, then obtains its zero-length contents.
The Buffer is private, position zero, with no callback receiving an alias.
For `None`, string conversion returns the static literal
`(Program not linked with -g, cannot print stack backtrace)\n` (59 bytes).
The print operation uses `Printf.fprintf` on exactly that literal.

The ELF object at `0xf80c30` contains a format node at `0xf80c48`, a
`String_literal` of tag 11 followed by `End_of_format`, and the same 59-byte
string at `0xf80c60` used by string conversion. Its string storage is 64 bytes,
plus its preexisting header. The checked switch-table entries select
`make_printf` at `0x96f7c8` and `output_acc` at `0x972ec8`. Thus the fallback
allocates one literal accumulator, invokes the captured output continuation,
recurses once to `End_of_acc`, calls `output_string` once, and invokes the fixed
ignore continuation. There is no `%a`, `%t`, dynamic format parse, formatting
queue or user-supplied printer on this path.

## Direct requests and native frames

Object requests below count the eight-byte header and represented payload.
For an n-byte string, the selected C allocation arithmetic is
`8 + 8*floor((n+8)/8)`. Both `n=1024` and `n=0` are representable, satisfy the
Bytes allocation bound and select the small-string branch (129 and one payload
words). The native Buffer constructor reserves 40 bytes; it retains the same
backing bytes in both buffer fields. `Bytes.sub` validates `(offset,length)=(0,0)`
against length 1024 and copies zero bytes. No resize or loop-dependent arithmetic
is selected.

| Direct request | Bytes |
| --- | ---: |
| Conversion `Some` | 16 |
| Buffer backing string, length 1024 | 1,040 |
| Buffer record | 40 |
| Empty copied contents | 16 |
| **Successful string subtotal / upper bound for any its prefix** | **1,112** |
| Printf captured continuation for fallback | 40 |
| Literal accumulator node for fallback | 24 |

The print bound is `16 + 40 + 24 = 80`, conservatively including an attempted
`Some` request before the exception selects `None`. The string fallback itself
adds no object request. The empty getter requests zero objects, and neither
conversion loop creates a slot. Direct new private live objects are bounded by
the corresponding cumulative subtotal, but these numbers are **not physical
heap/RSS bounds**, allocator retry totals or collector workspace bounds. The
static literal/format objects already belong to the loaded image. Returned
strings retained by callers must be counted by those callers. For n string and
m print invocations, direct cumulative object demand is at most
`1112*n + 80*m`; this packet supplies no whole-suffix n or m.

The one fallback `output_string` request is `(offset,length)=(0,59)` for that
same 59-byte string. The channel service may flush previously buffered bytes,
partially write, raise or terminate. The 59-byte figure bounds this call's
payload request, not all OS traffic or a guarantee of successful output. Its
channel/runtime costs and any exception construction remain explicit service
or enclosing-phase obligations.

The native frame projection uses the following inspected own frames, including
incoming return slots and local traps. Every listed body is charged once except
the one-node `output_acc` traversal, charged twice. Several alternatives and tail
transfers are intentionally overcharged; no recursion or reentry multiplicity
is inferred solely from symbol presence.

| Bodies / selected context | Own bytes charged |
| --- | ---: |
| OCaml conversion wrapper, including its two-word trap | 32 |
| `print_exception_backtrace`, `backtrace_to_string` | 48 each |
| `print_raw_backtrace`, `print_backtrace`, `raw_backtrace_to_string`, `get_backtrace` | 16 each |
| `try_get_raw_backtrace`, including trap | 32 |
| C raw getter; C empty converter | 128; 224 |
| `caml_debug_info_available`; zero-size `caml_alloc` | 8; 48 |
| Buffer.create; Bytes.sub | 16; 32 |
| `caml_create_bytes`; `caml_alloc_string`; `caml_blit_bytes` | 8; 32; 16 |
| Printf.fprintf; kfprintf; captured continuation; ignore | 8; 16; 16; 8 |
| `make_printf`; `output_acc`; `output_string` | 48; 2*32; 16 |
| **Conservative selected own-frame sum** | **912** |

Empty conversion only calls the constant debug-availability body and zero-size
allocator. Its other native extraction/conversion calls are in skipped loops.
`Some empty` selects Buffer.create, Bytes.sub and its zero-length blit; no
slot-formatting, bprintf or Buffer-add descendant is called. The fallback selects
exactly the constant Printf path established above. Literal processing in
`make_printf` loops in place, and its end continuation is a tail transfer;
`output_acc` reaches only its literal node and
empty predecessor. Their indirect successors are the captured Printf continuation
and fixed ignore closure. No general-purpose Format or exception-printer body
is hidden in the 912-byte sum.

The existing [bridge owner](retained-why-save-stack-helper-closure.md#signal-dispatch-and-transient-bridge-demand)
supplies 4,104 bytes for a direct `caml_c_call` / `caml_call_gc` crossing,
including the transient 4 KiB touch. This packet **reuses that projection**,
with the same ownership convention as the [save join](retained-why-save-owned-stack-join.md).
Its C helper frames above are separate; they are not hidden inside the bridge.
Charge that bridge once per active invocation, not once per sequential call.
Service-owned nested crossings remain service demand. This gives the useful
component expression

```text
covered diagnostic native projection <= d * (912 + 4104) = d * 5016,
```

where d counts simultaneously active covered diagnostic invocations, including
any reentry; it is not silently set to one for a whole process. A separately
counted invocation need not add its getter a second time. Ambient caller stack
`A_pre`, other diagnostic/report/exit callers, and the external service term R
remain separate. Direct service frontiers are GC/small-allocation dispatch,
raising/failure handling, `caml_ml_output`, and the zero-length `memmove@plt`
call. Pending clients at those frontiers retain their own source-owned work and
global signal/save budget; their bodies are not reassigned to an opaque R.

## Composition limits and disposition

The whole-post-cut budgets remain **at most two signal opportunities and three
saves, with e <= 2**, shared by the entire continuation. A raw getter, failed
conversion, fallback or new report does not reset them. Interruption can retain
this component's local frames while another charged owner runs; escaping failure
unwinds rather than restarting the same conversion catch. Composing concurrent
components must use actual invocation contexts, not a union of function names.

The historical six-report / 25,920-registration allowance in
[save/exit charge](retained-why-save-exit-charge.md) stops at the first-inline
interval. It is not a whole-suffix report bound and is not used to multiply the
numbers here. Remaining work includes that enclosing report topology and all
non-backtrace exception text, global formatter/channel state, complete R,
physical-memory conversion and total process stack. An empty backtrace does not
make the exception message or surrounding JSON output empty.

No Oracle, tool, pin or admission change is made; production #88–#94 remains
unstarted and PR #121 draft/unmerged. No target run, capture, source fetch,
disassembler, solver, Lean/full-suite run or predecessor-checker replay occurred.
The measured author/validation record is in `round.json`. Independent review is
parent-arranged on the exact freeze; the parent owns integration, GitHub status
and durable session memory. No CLI memory was updated.
