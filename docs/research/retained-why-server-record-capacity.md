# Server records and the separate solver-output capacity obligation

2026-10-20 UTC, Linux x86_64, #119 / #153; author base
`eb4e10cc32caaae49994f3166f78fbd993307ddf`.

**The selected server's response constructor bounds a queued protocol record,
but it does not bound the solver-output file.** With a preserved request stream,
the selected global request count also bounds malformed IDs caused by abandoned
client writes. A server receive-buffer `memcpy` with potentially overlapping
ranges prevents exporting that preservation as an ordinary C-source theorem.
The current solver-output bound O remains null: neither the retained flags nor
the receiving code supplies its missing source-derived payload bound.

This is a precise conditional component and stop condition, not complete server,
reporting, R/U or automatic-discharge assurance. The
[packet](../evidence/retained-why-server-record-capacity-20261020/README.md)
pins actual selected source/configuration bytes, five current process identities,
source excerpts, arithmetic and three deliberately scoped interface witnesses.
The existing relevant-source/native/runtime relation remains conditional;
matching bytes do not prove historical binary refinement. No new transport or
arbitrary-protocol trust is inferred from the accepted save-file service contract.

## Actual selected producer and two output channels

The retained `capture-common.tar.gz` plans and `run.py` launch a separate
`why3server --socket server.sock --single-client -j 1`. Each per-case
`capture/server.json` records its actual argv, environment and binary identity.
The server environment is exactly `PATH=/usr/bin:/bin`, `LC_ALL=C`.
The five client PIDs are 17310/17514/17631/17704/17869, with the accepted
R=22/18/9/1/1, G=64/53/32/3/1 and scheduling-owner N=194/161/98/11/5.
The first four cuts precede scheduling; the fifth precedes its first inline
transformation. The observer never submitted solver work after these cuts.

`server-unix.c:132–142,517–524` creates an output filename consisting of
`current_dir`, `/why3` and the six replaced `mkstemp` characters. It redirects
the child's stdout and stderr to that file (`389–396`). Protocol replies contain
the filename, status, time and request ID; they contain **no solver-output bytes**.
`Call_provers.read_and_delete_file` instead opens the named file and calls
`Sysutil.channel_contents`. Its 1024-byte input loop appends until EOF and returns
the whole Buffer (`call_provers.ml:168–173,392–402`, `sysutil.ml:29–39`). There is
no file-size test or cumulative byte cap on this path.

The source gets `current_dir` using `getcwd(NULL,0)` before its temporary socket
directory change (`server-unix.c:88–90,234–245`). The launch plans pass the
following directory spellings to `Popen(cwd=...)`:

| Case | Launch directory bytes C_launch | N |
| --- | ---: | ---: |
| Put_Line | 72 | 194 |
| Put | 67 | 161 |
| First_Or_Default | 80 | 98 |
| Is_Message | 74 | 11 |
| Input_Is_Valid | 105 | 5 |

These spellings and selected TMPDIR values contain no NUL, LF or semicolon.
The server's returned `getcwd` string was not captured. Numerical substitution
of C_launch for C=the actual `current_dir` byte length therefore requires the
canonical directory-value relation. A proposed launcher can establish a fixed,
canonical namespace and its byte/character conditions before admitting work;
the present filesystem's spelling is not historical evidence of that value.
This relation concerns the selected directory input, not a proof of libc getcwd.

## A response-constructor bound that does not trust the float-size comment

Let I be the actual raw request-ID string length and C the actual directory
length. A normal output filename has C+11 bytes; the queue-removal response
uses the empty filename and is covered by the same bound. Under represented
valid arguments, returning normal formatting/allocation and sufficient resources:

```text
Started allocation = I+4; wire bytes including LF = I+3.
Finished allocation = I+outfile_bytes+31 <= I+C+42.
Queued Finished wire bytes including LF <= I+C+41.
Complete reply line excluding LF <= I+C+40.
```

The allocation follows the actual `+3`, `+27`, `+1` statements, not the
inaccurate comment above them (`server-unix.c:414–459`). `snprintf`'s `used`
must be less than `len` before the buffer is queued. On this ABI `len` is
unsigned size_t; a negative int result converts to a large unsigned value and
also takes the shutdown branch. Require the allocation and transmitted length
to fit the downstream signed int fields (`writebuf.c:27–47,62–68`); all displayed
conditional instantiations are far below INT_MAX. A represented request and a
normal result remain caller/service premises, rather than a claim that C
undefined behavior is constrained by this branch.

This is a safety bound on a **queued** response. Let d be the printed exit-code
length and t the `%.6f` CPU-time length. The actual formatted wire size is
I+outfile_bytes+d+t+8. Successful queuing therefore needs `d+t<=22`.
A larger value shuts down the server rather than generating an oversized
queued line. No successful-report, finite-time, solver-termination or required
discharge result follows. The comment's supposed 13-byte allowances do not
prove this guard, and a zero timeout does not imply it.

`writebuf` sends one message's remaining prefix at a time before selecting the
next queued message. A zero write leaves the pointer unchanged; an error does
not advance it. Thus the usual ordered, nonduplicating socket-prefix semantics
are enough for the corresponding byte-stream argument, without promising
positive writes, a finite retry count or eventual delivery. That argument still
needs valid producer objects and preservation of the server's receive buffer,
as discussed below. It does not extend the positive-write premise for private
XML/shape files to sockets.

## Abandoned requests invalidate the simple decimal-ID argument

An intact `Prove_client.send_request` emits a signed63 decimal ID of at most
20 bytes. This would give a line bound C+60. It is insufficient for all admitted
failure paths. `send_request_string` can successfully write a prefix and then
raise on a later operation (`prove_client.ml:64–73`). The enclosing build/idle
handlers can report InternalFailure and continue another owner. They do not
reset the socket's pending server request bytes before the later send.

For example, the concatenation of abandoned prefix `run;1` and the next request
`run;2;0;0;solver;input.smt2\n` has raw ID `1run`. `parse_request` copies that
field as text; it does not validate it as an integer (`request.c:42–56,99–125`).
A response echoing it can reach `InvalidAnswer`. This source-shape witness
does not assert an observed target execution or a selected solver result.

A more robust length argument uses the **global** message count and header
alphabet, without assuming the message has valid numeric fields:

1. The selected post-cut client has at most N scheduling owners. Each enters
   `send_request` at most once. No partial send retries the owner inside that
   function. The accepted ownership relation already pays repeated owners.
2. Client argv has no `-j`; `gnat_config.ml:37,673` selects parallel=1. The
   GNAT parallel cancellation arm is excluded (`gnat_checks.ml:1049–1083`).
   The selected roots exclude strategy/editor/replay entry points. No pending
   save, printer or exit callback independently sends protocol requests, and
   the external connection is not restarted. Thus there are no additional
   selected `interrupt` or `parallel` messages in this suffix.
3. Each offered message is a prefix of a string beginning `run;` or `runstdin;`,
   followed by its decimal ID and further semicolon-separated fields. The
   selected command templates all use `%f`, so the actual branch is `run`, but
   using the eight-byte `runstdin` stem conservatively covers both.
4. No operand contains LF: fixed command/scalar tokens do not; the selected
   filename templates are `%f-%t-%g.smt2` or `.psmt2`; `Driver.get_filename`
   applies `Ident.char_to_alnumus` to every substitution. That sanitizer returns
   only ASCII alphanumerics/underscore. `Filename.open_temp_file` adds a fixed
   `why_` prefix, six hex digits and the selected delimiter-free TMPDIR. The
   selected root family has no setter changing that directory. Fresh nonmanual
   attempts have no old proof-script filename. These facts establish a token
   alphabet without needing a bound on the goal-name length.
5. For a parsed command that is `run`/`runstdin`, the next field starts with
   at most one original decimal-ID prefix. If that message was abandoned, the
   rest of its raw ID can contain only prefixes of later message headers until
   the first subsequent semicolon. A later message's operand cannot enter the
   field: its own header semicolon ends the field first. Each of at most N
   messages contributes at most eight such header bytes. Consequently
   `I<=20+8N` is conservative even when the resulting ID is not decimal.

This argument requires preservation of the received byte stream by the server's
parser/buffer implementation. Under that explicit condition,

```text
line M <= C+60+8N;
F allocation <= C+62+8N;
Prove_client's pending-prefix plus next-read concatenation <= M+1024;
InvalidAnswer matching branch direct text <= M+23.
```

The last constant is the literal `Invalid server answer: `. It has no format
break or nested logical printer. The prior
[diagnostic expansion](retained-why-diagnostic-expansion.md) can multiply it by
the imported particular-terminal-branch attempt count, including partial
printing. The packet retains those products. They are private **direct text**
contributions; enclosing wrappers, layout, copied adapter results, abort JSON
escaping and standard B/E are not thereby bounded.

| Case | Conditional M, allowing abandoned request prefixes | Pending prefix plus read | Direct InvalidAnswer text |
| --- | ---: | ---: | ---: |
| Put_Line | 1684 | 2708 | 1707 |
| Put | 1415 | 2439 | 1438 |
| First_Or_Default | 924 | 1948 | 947 |
| Is_Message | 222 | 1246 | 245 |
| Input_Is_Valid | 205 | 1229 | 228 |

Each row additionally assumes C=C_launch. The intact-framing M values would
be 132/127/140/134/165, but are not substituted for the failure-aware values.
More generally, if Q bounds all offered request bytes and the decoded request
is preserved as a substring of that stream, `I<=Q` gives `M<=Q+C+40`, without
the selected header lemma. Neither argument needs a solver-output-file bound.

On the client side, `read_lines` appends only the current line prefix and
splits at LF, so a successful continuation preserves the pending-prefix bound.
The selected scheduler does not catch a failed receive/parser and restart
receiving: its only local main-loop handler is Exit, which enters ending;
other errors leave for main reporting. Save callbacks do not reenter this
buffer. Abandoning a receive therefore cannot create a later receive retry
with an uncharged stale prefix. A 1024-byte read may contain many complete
records; the line bound is not a total allocation/list/stack bound or a bound
on the number of reads. Those owners and complete request/reply lifecycle
capacity remain separate.

## Concrete server preservation obstruction

`handle_msg` processes all complete LF-terminated requests, then calls
`have_taken(readbuf, old)` for their consumed prefix (`server-unix.c:547–590`).
`readbuf.c:45–48` implements this as:

```c
memcpy(b->data, b->data+size, b->len-size);
b->len -= size;
```

The ranges overlap whenever `0<size<b->len-size`. Ordered socket delivery and
the 1024-byte read size do not exclude a short complete frame followed by a
longer incomplete frame. The packet constructs that shape using the selected
Z3/CVC5 command tokens and a permitted sanitized filename: 142 consumed bytes
and 143 retained bytes in one 285-byte read. The ranges overlap by one byte.
This is a checkable violation of the ordinary memcpy precondition for that
shape; it is **not** a captured execution or a claim that the installed libc
misbehaves. The exact reached request sizes/order are not captured at the cuts.

Therefore ordinary C memcpy semantics does not establish the substring and
header-preservation premise above. A usable native attachment must establish
the actual call's overlap-safe behavior for the selected compiler/libc route,
or prove a no-overlap invariant for every selected receive schedule. Assuming
that the socket is reliable cannot discharge this caller precondition. No
such attachment is supplied here, and all protocol products stay conditional.
The same unresolved server arithmetic/container/ownership conditions must be
retained; this packet is not a whole C-server verification.

## Why the actual weighted solver-output input remains open

The current client explicitly selects `--steps 0 --timeout 0`, has no
`--memlimit`, and reads a config with `memlimit=0`. `set_steps` accepts only
positive values; `limit_time`, `limit_mem` and the no-steps branch therefore
supply zero on the ordinary selected proof path. `adapt_limits` preserves a
zero time. The selected non-step command templates are:

```text
cvc5 --prenex-quant=none --stats-internal %f
z3 -smt2 -st smt.arith.solver=6 %f
alt-ergo --max-split 5 --disable-weaks %f
```

There is no `RLIMIT_FSIZE` in the selected server. CPU/address-space limits,
even if nonzero in another configuration, would not by themselves prove a
byte count for diagnostics or statistics. An OCaml maximum String length is
not a sufficient prospective bound on successful buffering and formatting.
The existing selected solver-statistics source excerpts remain in
`retained-producer-response-20261018/sources.tar.gz`; a new solver analysis must
close their output families and error paths, not infer a cap from flag names.

There is also an exact executable-resolution join: these commands use bare
names, while the retained server PATH contains only `/usr/bin:/bin`.
`Whyconf.get_complete_command` appends options to the configured command;
`Gnat_util.get_gnatprove_config` resolves driver files, not solver executables;
the server calls `execvp`. No retained result attaches the packaged solver
identities to this later PATH resolution. This does not invalidate the earlier
prefix, which never executed a solver, and does not prove that those historical
directories lacked a solver. A proposed launcher can use explicit packaged
solver paths and a fixed config, then attach the corresponding source/argument
behavior. That is not implemented or adopted here.

Let q be a **proved prospective** upper bound on each originating solver-output
file for every selected attempt, obtained from admitted source metrics and a
fixed configuration before running the tool. The accepted JSON interface uses
reported answer occurrences A and parser invocations N separately. Without any
one-owner/no-duplication assumption:

```text
O_A <= A*q; O_P <= N*q; choose O = max(A,N)*q.
```

A per-attempt family of bounds can instead be summed with the actual proven
answer/parser multiplicities. Abandoned parsing prefixes remain charged.
The selected R/G/A/N and one normal/two abort budgets are unchanged; none of
this renews the global e<=2, two save callbacks or three saves.

For the imported sufficient standard-JSON envelope, let B0/E0 be its case
constants and let nonnegative Y_B/Y_E contain all other unknown contributions.
A source/configuration guard must establish, before admission,

```text
B = B0 + 3111*max(A,N)*q + Y_B
E = E0 + 1039*max(A,N)*q + Y_E
B+E+79 <= 1000000010
(3E+1)*(1000000010+B+E+1)+B+E+79 <= 2^62-1
4*(3E+2)+2 <= 2^62-1.
```

Setting the other unknowns to zero gives these **optimistic guard ceilings**:

| Case | O ceiling | Uniform q ceiling using max(A,N) |
| --- | ---: | ---: |
| Put_Line | 240635 | 1156 |
| Put | 240681 | 1391 |
| First_Or_Default | 240771 | 2229 |
| Is_Message | 240893 | 20074 |
| Input_Is_Valid | 240899 | 26766 |

All three arithmetic guards pass at the displayed O ceiling; O+1 violates the
first. Exceeding a ceiling means this conservative envelope cannot certify the
input, not that the actual formatter necessarily overflows or a valid program
may be rejected. Other diagnostic/channel owners reduce the available budget.
These calculations cannot instantiate q: source-to-solver-task sizes, solver
output/statistics/error production and executable resolution are still missing.

The receiver-interface family `("unknown\n")^k` makes the missing inference
concrete. For k=30080 it has 240640 bytes, all readable in chunks of at most
1024, exceeding even Put_Line's optimistic O ceiling with one parser occurrence.
The selected consecutive-Unknown reduction has payload length 10k-3. This
shows that the receiver and answer grammar alone impose no useful small total
bound. It does **not** show a pinned solver can emit the family for one of the
five tasks, or that a real standard-core guard fails.

A runtime file stat, output truncation, output cap, observed successful run,
or a new timeout would not supply the missing pre-admission theorem. Such a
cutoff can abandon a required proof, so it cannot be silently adopted as
language membership or successful discharge. Actual O and whole JSON B/E stay
null until source-derived q (or a sharper weighted family) and the independent
remaining owners are established.

## Verification and handoff

The one focused checker reads retained bytes and verifies hashes, excerpts,
five input/launch/config joins, packet countermodels and the displayed arithmetic.
It does not prove OCaml/C control closure, solver output semantics, a native
memcpy contract or service liveness. Three initial excerpt endpoints exceeded
their file by one to three lines; correcting those bounds required no semantic
change. Later materialization includes the independently raised overlap
obstruction and the author's abandoned-request correction.

Selected author setting: GPT-6 Astra / Extra High, confirmed as the parent's
spawn selection; runtime setting, tokens and cost are unavailable. The packet
round record supplies elapsed time and the exact validation command. No target,
solver, debugger, proof, source fetch or predecessor checker ran. Oracle,
toolchain pins and admission are unchanged; production #88–#94 is unstarted,
#119/#153 remain incomplete, and PR #121 remains draft and unmerged.
