# Post-registration scalar terminal diagnostic bytes

2026-10-23 UTC, #119 / #153, Linux x86_64; author base
`7d507503b9`. This closes a **conditional scalar terminal byte interface** for
the combined quiet/timeless/logging J12 registration cut. It does not cover a
failed startup/connect, arbitrary Why diagnostics, or actual production use of
the proposed proxy. Oracle, admission, tools and pins are unchanged.
The [packet](../evidence/retained-why-terminal-diagnostic-bytes-20261023/README.md)
retains source witnesses, exact input identities and the new arithmetic check.

## Scalar family and concrete operands

Use the [R63 callback-demand result](retained-why-callback-demand.md), including
the broad protected Driver preparation and the parallel callback which logs
`InternalFailure` without its payload and drops it. A failure in that callback,
logging, saving or terminal reporting is a new scalar failure. It does not
recover the dropped term/type/declaration exception. The saved forests have
no patterns/Tcase and only variable-valued substitutions. The serial `2A`
exception-report term is absent. The one global `e<=2`, two save-entering
callbacks and three saves is unchanged; nothing below renews it.

The remaining recursive constructors have **at most one `Loc.Located` and
one `Fun.Finally_raised`: d<=2**. This sharpens the initial conservative d<=3
freeze `6be9a29ea4`; it adds no execution premise. The accepted
[wrapper creation argument](retained-why-diagnostic-expansion.md) gives the
single Finally bound. Its TransFailure/BadI_rs_type creation routes and the
two noncoalescing clone handlers (`typing.ml:1715–1737`) lie in preparation.

The second-Located exclusion needs the control boundary, not just coalescing:

1. `Loc.try1`–`try7` and `with_location` preserve an already outer Located.
   `Loc.errorm` creates a fresh Message; it does not wrap the current exception.
   Explicit selected leaf constructors likewise use fresh leaf errors.
   The clone handlers can add a second Located to an existing error, but all
   their post-cut execution is inside the complete Driver preparation trap.
2. `controller_itp.ml:518–540` catches **all** escaping preparation exceptions,
   including scalar failures and signal-save failures wrapped while unwinding
   a parser guard. The session wrapper at 591–619 then invokes the fixed
   parallel callback at `gnat_checks.ml:1060–1077`, which drops InternalFailure
   without rethrowing its payload. No parser/location guard below that catch
   remains resumable. A failure in this handler is a secondary exception.
3. Callback status/logging, independent result handling, save/ending, hooks
   and terminal reporting have the R63 scalar root closure. They do not call
   a Why source parser/clone or enclose these secondary failures in `Loc.try*`,
   `with_location` or a noncoalescing Located handler. The selected parent-status
   `Loc.errorm` constructs a new constant Message. The session-file read
   wrapper constructs a fresh Located(Message) and belongs to the excluded
   read/merge route; it cannot wrap an existing Located.
4. Coalescing alone would **not** exclude
   `Located(Finally_raised(Located(e)))`. The selected finally bodies update
   timing scalars (`debug.ml:158–173`) or flush/close a private file formatter
   (`sysutil.ml:69–90`); they neither add a location guard nor run a Why source parser.
   Fun.protect wraps the **cleanup** failure and replaces a body failure;
   successful cleanup reraises the body failure unchanged. A save interrupt
   has the same closed scalar save roots. If such a failure is in preparation,
   item 2 drops it; outside preparation there is no enclosing location guard
   to add a further Located. Thus this interleaving cannot supply a second
   Located on a terminal chain.
5. The Located exception-printer branch only renders the existing wrapper.
   It creates no Located. Registry failure retains the original argument;
   failures escaping the main/custom reporters are new scalar/service/save
   errors, with no location-wrapping continuation. Repeated reports therefore
   cannot deepen either the original value or a secondary error.

Zero or one Located remains a conservative envelope; no stronger zero-Located
claim is needed. The different source origin of a failure, its timing during a
callback, or the global interruption budget does not renew these bounds.

Supply these computable path/configuration operands:

* `R`: actual canonical result-directory byte length; `Pc=R+24` under the
  [prospective protocol](retained-adapter-protocol-storage.md).
* `P`: maximum byte length of any path argument or location filename selected
  by the post-cut clients. Take the maximum of `Pc`, actual request temporary
  paths, save/backup paths, the unchanged configured input/log/profiling paths,
  and selected `Loc.FileTags` filename payloads. This is a maximum over those
  source/configuration providers, not a limit imposed on executions.
* `M=Pc+48` bounds each complete frontend response line, conservatively including
  its LF: positive OCaml IDs need at most 19 decimal bytes, S needs 22, and F
  needs at most `Pc+19+29`. This uses intact validated original requests and
  the proxy's canonical S/F stream. It does not transfer the old serial
  abandoned-ID grammar to J12, or bound a malformed/untrusted stream.

The shared-server relation keeps frontend endpoints, cwd, TMPDIR and input
roles unchanged. Endpoint lengths are 50/89/56/96/56. The accepted request
filename construction gives maxima 80/119/93/133/93 in domain order
Put_Line/Put/First/Is_Message/Input for the retained TMPDIR spellings. Reuse
those numbers only through that preservation relation. Save paths are the
actual session directory plus at most 20 bytes, including backup suffixes.
An alternative deployment must evaluate its actual providers. A selected
FileTags value is not established merely by the source argument spelling;
retain its pathname operand when its payload has not been attached. The
116,162-byte *qualified logical path* theorem is not a filesystem bound.
P is a single-argument maximum: selected `Sys.rename` reports `NO_ARG` on a
rename failure, and `Unix.rename` reports its first path; the preliminary
path-validity checks also name only one input. Neither builds a two-path error
string (`sys.c:299–319`, `otherlibs/unix/rename.c:23–40`).

The leaf origin table is the required string attachment:

| Reached origin | Byte source and bound |
| --- | --- |
| `Sys_error` from runtime filesystem/channel services | `runtime/sys.c:76–93` copies either `strerror(errno)` or `path ^ ": " ^ strerror(errno)`: at most `P+51`. The client LC_ALL=C comes from the preserved logging-prefix environment; the selected libc identity/ordinary noninterposed C-locale service relation is the [49-byte result](retained-adapter-launch-output.md). Server locale alone would not suffice. |
| `Unix.Unix_error` | `unixsupport.c:288–310` supplies error code, fixed function name and path/empty argument. The ML printer uses the symbolic code, **not strerror**, and quotes both strings. `EUNKNOWNERR` includes a native integer. |
| Primitive numeric, string, array, map/queue/stack, Buffer, Format, runtime and linked Re failures | Payload-free or fixed ASCII message; static strings belong to the selected linked implementation. Integer/float conversions do not copy their rejected input. The only reached dynamically formatted annotation failure is at most 46 bytes (R67). No dynamic format-program parser or geometry setter is entered. |
| Re parsing/matching | The retained `emacs` parser raises payload-free `Parse_error`/`Not_supported`; Str's explicit errors are fixed messages. AST/bit-vector/cset errors use fixed operation names. Matching/group operations and callbacks manipulate scalar data. Their failures do not embed solver output. This is under the already explicit selected Re service relation, not a new identification/refinement claim for an arbitrary library. |
| `Prove_client.InvalidAnswer s` | The whole response line has length at most M; its matched Why branch offers `M+23`. The 1024-byte read chunk is not a line-length bound. `ConnectionError` is confined to pre-cut connection creation and no reconnect occurs. Other selected Prove_client errors are constant. |
| `Sysutil.file_contents_{buf,fmt}` failure | If reached, replaces the error with `"(cannot open " ^ path ^ ")"`, at most `P+14`; it does not copy file contents. |
| Session/task/selection sentinels | Payload-free, or immediate/opaque scalar data. Task Goal/Lemma branches and Session NoProgress have fixed messages. Metadata/logical-error branches are excluded by R63. |
| `Loc.Message` | The selected fatal parent-status message is constant; its private `@[...@.]` construction has at most 256 returned bytes. Old-session XML/shape loading, merge, archive and replay messages are absent. `Loc.user_position`'s numeric failures, if retained conservatively, are fixed prefix/suffix plus one at-most-20-byte integer, below 256. |
| Assert/Match/Undefined_recursive_module | Static source filename and compiler position tuple; no logical traversal. The filename bound below applies to the exact linked fixed source paths. Every displayed native integer has at most 20 bytes, including the endpoint computed by OCaml's char+5/6 expression. This byte argument adds no source-position accuracy claim. |

For fixed ASCII messages, constructor names, native operation names and compiler
source filenames **proven to reside in the selected Why ELF**, use `H=467`.
The focused byte check verifies the exact ELF identity and finds the maximum
contiguous run over TAB/LF/CR/ASCII 32..126 across that file. Every such resident
literal is a substring of one run; no zero-termination or symbol-boundary
inference is needed. Source origin, ASCII encoding and residency remain part
of the existing fixed-code correspondence relation. This cap is not applied
to dynamically composed messages, a newly loaded plugin, libc/libgmp storage,
arbitrary foreign exceptions or a source filename with a different encoding.
The selected OCaml runtime and Unix/Re/Why stubs are linked in this ELF;
external strerror is charged separately. The native service contract does not
permit an arbitrary foreign OCaml exception/string constructor. Adding one
requires a new leaf row. No new disassembly or general binary refinement is
claimed.

Set

```
S = max(467, P+51, M+23, 256)
K = 467 + 12*S + 256.
```

K bounds each nonrecursive leaf rendering and every wrapper's own prefix.
The default Printexc interface `C+4*sum_strings+68*k+2` has `C<=467`,
`k<=3`, each direct string<=S. Other fields become `_`; they are not traversed.
Special location exceptions need at most `467+160`. Unix's symbolic error
needs at most 32 bytes, quotes at most two strings, and fixed delimiters fit
within 64; `64+8*S<=K`. Loc's own prefix is at most `P+128`; Finally's is at
most 20. Constant/message/server branches also fit K. Sexplib's ordinary
defaults are disabled for automatic Printexc; enabled S-expression parse/
conversion constructors and Dynlink errors have no post-cut creation route.

## Dirty private formatters and returned strings

The Why registry opens each candidate through `"@[%a@]"`, catches a failed
candidate, and continues with the original exception on the **same** formatter.
A failure may leave open boxes or interrupt a core operation. Fresh creation
does not justify reusing R66's completed request-private drain proof.

Instead instantiate the [interrupted-core transfer](retained-why-standard-formatter-core.md)
at fresh constructor state for every diagnostic formatter. Scalar matched
branches use only 0/1 indentation, 0/1 breaks with offset zero, raw text,
closes/newlines/flushes; tags/tabs/magic-size/settings changes are absent.
The 55 rejecting candidate shells count even if their printer emits no text.
Annotation helper formatters are separate owners. Their fixed descriptions
are tiny; annotation failure is already in the scalar leaf table.

The standard-core proof's queue/stack/partial-reset argument depends on core
mutation order, not on a channel destination. Here callbacks are
`Buffer.add_substring` and an ignored flush. These do not recover and return
to a stale core frame. Signal saving uses other private formatters and the
already charged standard roots; it cannot access this local diagnostic buffer.
Any escaping signal exception abandons the suspended core frame before a
registry catch starts new work. The existing faithful service/unwinding and
no-unmodeled-shared-owner mutation relation remains required.

Buffer reuse needs a separate invariant: `0<=position<=length<=physical_length`.
`resize` allocates and copies before storing the new backing, then stores its
larger advertised length. A prefix between those stores weakens equality but
preserves this invariant. Later growth safely uses the advertised length.
`add_substring` validates its slice, grows if necessary, blits and publishes
position last. A prefix before publication contributes no new published bytes;
after publication the whole prospective append was already charged. No callback
can mutate this buffer and return into stale local append variables. Final
`contents`/reset belongs to finishing the private helper; a failure there
abandons that helper rather than returning to its registry loop. This proves
an upper bound under caught failures, not rollback or guaranteed text delivery.

With B prospective text bytes and E core events at an owner, dirty-core output
is at most `B+70*(E+2)`. Per-owner finite queue/scan work and arithmetic use the
same theorem. Loss of pending text can reduce this upper bound; no generic
fresh-large-stream drain claim is used.

## Expansion, copies and exported terminal interface

One dispatch package contains at most two Why passes and one Printexc call;
there are at most two calls on its strict inner exception. The Why Printexc
adapter runs only the registered pass, so it cannot create a same-value cycle.
At depth d, `N=2^(d+1)-1`. At d=2 this is 7 packages, 14 Why passes,
770 candidate attempts, 7 Printexc calls and 35 Printexc callback attempts.

A conservative package allowance is 320 direct core events: 220 shell
open/close events, two 32-event matching prefixes, anomaly text and helper
finishing events. There is at most one newly created adapter owner per package;
allow two entry-owner charges. Its nonrecursive output is bounded by
`2*K+70*(320+4)`. A returned adapter string may be copied once into an anomaly;
a Finally string similarly copies its child. Charge both construction and
use, including every failed prefix. A convenient simultaneous majorant for
prospective text and offered output over all principal diagnostic owners, and
any returned string in one expanded dispatch, is

```
T[-1] = 0
T[d] = 4*T[d-1] + 8*K + 65536
Y = T[2] = 21*(8*K+65536)
E_dispatch = 320*7 = 2240
x_abort = Y + 1024
X = 2*x_abort  # sum of the at most two abort-message payloads
E_private = 2256.
```

To see the factor four, charge each of the two child subtrees once for its
work and once more if its rendered result is copied by the enclosing adapter/
anomaly/Finally path. A single package never retries a child after that child
throws: its enclosing candidate is abandoned. The 8K term pays the two own
matched prefixes, possible default/Unix string construction and copies; twice
the 22,680 layout allowance and the remaining fixed strings fit 65,536.
Counting copied substrings more than once is intentional. Owner-entry charges
are made at their creating package, including owners that never finish.
The actual outer main/custom formats add at most four events: at most two
literal/string text insertions, the explicit `@.` and the helper's final flush.
Their text is at most 29+59=88 bytes; even giving that outer context its own
entry allowance costs at most `88+70*(4+2)=508` bytes. Thus 1,024 is conservative;
16 is merely a looser event ceiling. This is an upper-bound induction, not an
equality or observed output.

Check the following **per private owner**, using the aggregate majorants as
conservative inputs. Put `L=x_abort+2256`, `I=3*2256+2`, `Pinf=1000000010`,
`Tcore=Pinf+L+1`:

```
L+79 <= Pinf
(3*2256+1)*Tcore + L+79 <= 2^62-1
4*I+2 <= 2^62-1.
```

These also keep append sums/doublings, Buffer payloads and OCaml string rounding
inside the [R67 representation interface](retained-why-format-accumulator.md).
The source wrappers are finite; these guards are necessary to invoke the
selected dirty-core arithmetic result, not a physical allocation limit.
For orientation only, P<=416 and M<=444 give S=467, K=6327,
Y=2,439,192, x_abort=2,440,216 and X=4,880,432, satisfying all guards. This is
a conditional configuration range, not a measurement or an attachment of an
unknown pathname.

There is at most one main Why report (`gnat_main.ml:356–360`), at most one
configured uncaught Why report, and at most two direct fallback Printexc
conversions (`printexc.ml:324–358`). The main handler is outside its own trap;
the uncaught fallback does not restart the configured handler. OOM may skip
the main report. Failures during JSON produce a secondary scalar error, not an
exception wrapping the rendered JSON. Consequently, per process:

* Each abort error-string payload is at most **x_abort**; their sum is at
  most **X=2*x_abort**. There are at most two abort JSON attempts and at most one normal JSON attempt.
* Direct terminal fallback stderr offers at most **`2*Y+253` bytes**: two
  converted strings, 24/54-byte fixed lines, at most two 59-byte raw-backtrace
  prints and the possible 57-byte OOM-handler line. These are channel writes,
  not standard-Format core events. Partial earlier writes remain charged.
* Principal private diagnostic work is at most four expanded outer packages;
  use `4*x_abort` prospective text/output and `4*2256` events if summing
  distinct owners.
  Never apply a combined guard across unrelated formatter states as though
  they share a right-total field.

The two raw-backtrace prints associated with missing-parent warning failures
belong to the separate warning owner and the one global e budget. The embedded
backtrace is already inside each x_abort, hence inside the summed X. The R66
`64E` text / `8E` standard-stderr syntax diagnostic is also separate and must be added once by the shared-root join.
Neither is silently renewed here. JSON escaping/layout and shared standard-root
B/E are supplied by their owners; this note exports the summed error-string
input X. The fixed annotation and CamlinternalFormat helper owners retain
R67's separate capacity charges; they
are not mislabeled as standard-root events or included in E_private.

The exported function remains conditional until P/M and every named
correspondence/service/proxy premise are attached. Failed startup/connect,
malformed-stream handling and any newly introduced foreign error family remain
outside this theorem. Physical memory, stack, I/O sufficiency, native services
and complete #119 admission are not proved. No allocator/kernel proof or new
aggregate admission gate is introduced. Selected author setting: GPT-6 Astra /
Extra High; runtime confirmation and token/cost telemetry are unavailable.
