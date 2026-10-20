# Independent review: channel and server attachment

2026-10-20 UTC, authorized research #119 / #153.

**All three frozen packets are accepted at their stated conditional scopes.**
They provide controlled-cut channel state, a failure-aware server-record bound,
and an exact native copy-service bridge. They do not establish the full
source/configuration-decidable capacity rule or complete #119/#153. The precise
remaining joins below are the reviewed stop; no required author rework remains.

## Exact targets and review scope

The standard-channel author freeze is
`b982214962c132247e60870def4eb944502dfdaa`, based on
`eb4e10cc32caaae49994f3166f78fbd993307ddf`. Review covered the
[research argument](../research/retained-why-standard-channel-attachment.md)
and all eleven files of its
[evidence packet](../evidence/retained-why-standard-channel-attachment-20261020/README.md),
including the checker, source/launcher/native witnesses, coverage query record,
manifest, result and validation/round records.

The server author freeze is `e44e86583a896498c71adfdf406e52f670eac787`,
on the same author base. Review covered its
[research argument](../research/retained-why-server-record-capacity.md) and all
seven files of the
[packet](../evidence/retained-why-server-record-capacity-20261020/README.md),
including the new checker, every retained source/configuration attachment,
the three scoped countermodels and the arithmetic/result/round records.

The separately authorized native bridge freeze is
`4f7d6b82d94b7e8efb5ac9264e66c0a1cb990b27`, based on `a6d848598c`.
Review covered its
[research argument](../research/retained-why-server-buffer-copy.md) and all
eighteen files of the
[packet](../evidence/retained-why-server-buffer-copy-20261020/README.md),
including the complete retained native bodies, symbols/relocations, query
provenance, normalization, checker, exact inputs and conditional result.

Reviewer `/root/channel_server_attachment_review` was selected as **GPT-6 Astra /
Extra High**. Runtime confirmation and token/cost telemetry are unavailable.
The reviewer owns only this report in
`tmp/review-channel-server-attachment-20261020`, branch
`review-channel-server-attachment-20261020`, created at `a6d848598c`.
The live child harness goal returned null. The actual host is Linux 7.0.14
x86_64; `scripts/dev.py paths` confirmed the platform and workspace paths.

Read AGENTS.md, the Oracle, relevant assurance/trusted-boundary and review
bookkeeping guidance, the accepted standard-channel, standard-initial-state,
diagnostic-expansion and standard-JSON arguments and their independent reviews.
Their source/ownership and callback premises are reused at their stated scopes;
their checkers and captures were not replayed. Direct source review used the
retained Why3 and OCaml source trees and exact frozen witnesses.

Before either freeze, the lead supplied the distinction between actual captured
state, source-derived controlled-prefix state, prospective pipe attachment and
universal prefix coverage. The lead also supplied the server framing concern
discovered in the author lane. The reviewer independently raised the server
`have_taken` overlap-precondition question before the server freeze. These
contributions and author repairs are disclosed; the reviewer did not author
either source argument or evidence packet.
The later native-bridge author investigated the overlap question at the lead's
request; this reviewer checked the frozen result rather than authoring its
selector-equivalence argument.

## Standard-channel disposition

**Accepted at the stated conditional scope; no required repair.** The additional
direct-channel partition supports P0=0 and O0=q at all five named controlled
cuts, where q is the constructor's cached `lseek` return. This is useful new
source information despite the absent historical pointer/fd observations.

The extra `Gnat_checks.Logging.outc` alias matters: it initially points to
Stdlib.stdout, and logging uses a private Format wrapper plus direct newline
and flush operations. The immutable logging selection is false in the retained
argv, so both initialization and use are excluded. Arg's Bad/Help output exits
or unwinds initialization; it does not restore a cut continuation. The selected
fresh-session relation excludes old-session backtrace output. The active
`update_goal_node` exception pattern protects only `get_proof_parent`; its
table lookup converts ordinary Not_found to BadID, while the retained controlled
prefix excludes signal-origin exception injection. The additional Thread.create
reporter is outside the one-worker selected client relation. Fatal/uncaught
printing cannot restart the unwound initialization or scheduling continuation.

Together with the accepted standard Format, Debug, loader, private-channel,
exit-gate and native-owner partition, this excludes the first standard-channel
byte offer or record mutation before each cut. It does not infer an empty
channel from a fresh formatter queue. Raw descriptor/C-stdio effects can change
the underlying destination without changing these OCaml cached fields; they
remain different owners. The ordinary no-signal result applies only to the
named debugger-controlled prefixes that actually reach the cuts.

The retained Stdlib initializer stores the descriptor-1 and descriptor-2
wrappers in distinct globals at offsets 0x130 and 0x138. The source/native
constructor relation supplies separate rooted output records, curr=buff,
max=NULL and in-object buffers of 65,536 bytes. Rooted ownership excludes
finalization of those wrappers under the accepted relation. It does not prove
descriptor liveness: an invalid inherited fd can still yield a constructed
record with q=-1, and a private open/close can later reuse that fd number without
mutating the standard C record. The final packet keeps this distinction explicit.

The historical launchers give **GDB** a merged stdout pipe. Their bytes are not
a measurement or proof of the inferior's fd inheritance. The historical query
records no complete eight-byte read of either standard-channel global slot
among 5,918,792 retained read rows. Review inspected its containment predicate
and bound inputs but did not rerun that large query. The packet correctly says
that partial-read stitching was not checked; it does not strengthen this into
absence of every overlapping byte. Actual pointers, q, descriptor kind,
liveness, aliases and binding/service attachment remain null.

For the prospective direct-pipe profile, live endpoints installed before the
constructors give q=-1 under the named ordinary pipe service contract. With
no offset reset, debt conservation gives

```text
F_pre + P0 <= X_pre
O0 = -1 + F_pre
O0 + P0 + X_suffix <= -1 + X_pre + X_suffix.
```

The mathematical guard `X_pre+X_suffix<=2^63` therefore excludes the first
unsafe signed-64-bit cached addition from construction onward. This does not
assume prefix arithmetic safety circularly. Separate per-channel guards work
even when both fds share an open-file description; cached offset is not claimed
equal to the kernel position. The positive-write premise remains explicit,
including errors, interruption, raising and nonreturn as separate outcomes.
A pipe label or eventual progress alone does not remove the zero-write Putch
counterexample. Delivery, termination and service storage are not inferred.

The prospective launcher is not implemented. Universal pre-admission use still
needs a source/configuration-bound descriptor-lifetime profile, a prefix bound
covering failed or terminating paths and uncontrolled signal/save output,
whole-suffix B/E and diagnostic strings, and the named service/caller premises.
A frozen-cut certificate is diagnostic evidence for a process, not language
membership. No new OS trust or proof of GDB/libc internals is required or claimed.

## Server-record and solver-output disposition

**Accepted as conditional components and a precise stop; no further required
repair to the frozen packet.** The response-constructor bound, failure-aware
header argument and weighted-output arithmetic are useful. Their remaining
preservation, environment and solver-production joins are correctly explicit.

The source allocates I+4 for Started and I+outfile_bytes+31 for Finished.
With outfile_bytes=C+11, a queued Finished record has at most I+C+41 wire
bytes, including LF, or I+C+40 excluding LF. The source's misleading float-size
comment is not the proof: `used>=len` prevents queuing a truncated response.
Under the selected ABI and the downstream signed-int length guard, a negative
snprintf return also takes that unsigned comparison's shutdown branch. The
actual wire size I+outfile_bytes+d+t+8 requires d+t<=22 to queue successfully.
A conditional size theorem therefore does not promise that every result is
reported or that a solver completes. Ordinary represented arguments and
allocation/formatting services remain premises.

The original intact-framing C+60 shortcut is insufficient. A committed prefix
`run;1` followed by a later request beginning `run;2;...` yields raw ID `1run`.
The server copies that field without validating decimal syntax. The client's
idle handler can catch a failed send and continue another owner on the same
socket. Reliable ordered writes do not make the multi-call send atomic.

The repaired I<=20+8N proof does account for this path. For a parsed run command,
the ID can contain one initial decimal-ID prefix. Subsequent abandoned sends
can add only prefixes of `run` or `runstdin` before the next semicolon ends the
ID; a later operand cannot cross its own preceding header delimiter. Each of
the globally counted N messages contributes at most eight such stem bytes.
The selected source excludes additional interrupt/parallel send roots. The
Driver sanitizer, fixed filename templates, six-digit temporary suffix and
retained delimiter-free TMPDIR establish the needed LF-free message operands;
no logical goal-name length bound is smuggled into this alphabet argument.
The accepted call-owner budget counts failed/abandoned attempts and is not
renewed per message. Generic I<=Q remains available if the whole offered-byte
stream and substring-preservation premise are supplied instead.

Under preserved server requests, this gives M=C+60+8N. The client needs a
separate concatenation bound M+1024, not merely a 1024-byte record bound.
Its selected receive/parser errors do not locally restart receiving after
dropping a chunk: the main loop's only local handler is Exit, which enters
ending, while other errors unwind to reporting. Save callbacks do not reenter
recv_buf. The InvalidAnswer branch adds 23 direct private text bytes; wrapper
layout, adapter copies and JSON escaping remain separate owners. Complete
receive allocation/list/stack and cumulative request/reply costs are not claimed.

Independent arithmetic reproduces all five conditional M values
1684/1415/924/222/205. Substituting the launch-directory spellings requires the
separate C=C_launch relation: getcwd can canonicalize the supplied path, and
the historical returned value was not captured. A current namespace inspection
would not establish the historical value.

The reviewer independently challenged server request-buffer compaction.
`have_taken` calls memcpy on `[0,len-size)` and `[size,len)`; the ordinary
nonoverlap precondition fails when 0<size<len-size. The author's 285-byte
protocol-shape example has 142 consumed and 143 retained bytes and overlaps
by one byte. It uses selected command tokens and an allowed sanitized filename,
not an observed request sequence. This is the incoming **request** buffer,
not the outgoing S/F reply queue. Neither a 1024-byte read nor server parallel=1
establishes the missing invariant: the selected synchronous idle scheduler can
emit multiple requests before response collection. No actual historical
overlap, libc misbehavior or installed crash is asserted. The frozen server
packet correctly leaves this caller-validity/native-preservation join open.

Protocol responses contain filenames, not solver-output bytes. The separate
file reader appends until EOF, and current zero limits and selected solver flags
give no prospective byte cap. This does not prove the pinned solvers unbounded.
Likewise, the retained bare solver names with server PATH=/usr/bin:/bin are not
an attachment to packaged solver identities. No solver ran before the retained
cuts, so this missing later resolver join does not invalidate those prefixes.

For a proved uniform per-file q, multiplicities give O_A<=Aq and O_P<=Nq;
O=max(A,N)q is conservative without assuming unique output ownership. Recomputed
optimistic O ceilings are 240635/240681/240771/240893/240899, and their q ceilings
are 1156/1391/2229/20074/26766. The other unknown contributions are nonnegative
and were set to zero only for this probe. All three imported core guards pass
at each O ceiling; adding one byte violates the first guard. Exceeding one of
these sufficient-envelope ceilings does not establish actual overflow or
authorize rejection of a valid program.

The `unknown\n` repetition witness concerns the unconstrained receiving
interface, not source reachability in a pinned solver. It establishes that
chunk size and answer grammar alone do not supply q. Actual O, whole JSON B/E,
other diagnostics/private formatters, native stack, physical resources and
automatic discharge remain unproved. Runtime output truncation or a new cutoff
cannot silently replace the required source/configuration theorem.

## Exact native-copy bridge disposition

**Accepted under the named binary, binding, resolver-state and valid-range
premises.** The bridge addresses one native copy step without treating generic
C memcpy overlap as valid or claiming historical server attachment.

The exact 96,904-byte server identity matches retained server metadata, not just
a pathname. Its 82-byte `have_taken` body checks size<=len, computes destination
data, source data+size and count len-size, and calls the memcpy PLT at 0x2590
from 0x2ffe. After return it subtracts size from len. The PLT reaches GOT 0x7f00,
whose relocation names memcpy@GLIBC_2.14. This is a real memcpy call; there was
no compiler substitution with memmove. The separate assertion branch aborts
before copying an invalid size.

The identified libc bytes match the retained native-effect provider, but that
provider observed the Why process, not the historical server. In these bytes,
memcpy's default GLIBC_2.14 IFUNC is at 0xb8c80 and memmove's default GLIBC_2.2.5
IFUNC at 0xb9600, each 257 bytes. Independent review decoded the ELF symbol
version requirements/definitions directly to confirm these bindings and to
distinguish the older nondefault memcpy@GLIBC_2.2.5 function at 0xc22f0.

Review inspected every instruction in both resolvers. The initial RIP-relative
load addresses the same 0x211eb8 loader-global slot. Each of the thirteen LEAs
has the same absolute target after applying its signed displacement. Every
other instruction's bytes and relative position match, including all conditional
branches, masks, register writes, conditional moves and returns. Branch targets
stay on matching instruction boundaries. There are no hidden call or indirect
branch paths in these bodies. Thus this is control/data equivalence for the
same stable resolver state, not just equality of unordered candidate addresses.
Every returned RAX value comes from the listed address candidates.

With ordinary noninterposed resolution to that exact image and the same stable
loader feature/tuning state, the memcpy symbol therefore selects the same
implementation as the trusted memmove entry. Existing memmove semantics can
supply overlap-safe copying for valid readable/writable ranges. With the
separate live-allocation, ownership and representation premises, the two ranges
fit data[0:len], the copied prefix equals the original suffix, and the native
subtraction establishes the required new length. The copy bodies and loader
implementation need not be re-proved to use this existing service boundary.

This does not prove all server C arithmetic, parser/container invariants,
reallocation, socket lifecycle or resource sufficiency. It also does not erase
source-level undefined behavior or establish arbitrary source-to-binary
refinement. Historical server libc maps, resolved GOT and selected target
remain null. A prospective fixed deployment can bind the exact profile; absent
that join, the server packet's request-stream preservation stays conditional.

## Validation record

One comparison of the new channel packet passed in **3.331884393 seconds**:
22 input identities, six retained archive identities, 21 source slices, five
case joins, 13 guard tests and nine debt-transfer boundary cases. It used
neither `--write` nor `--audit-coverage` and left Git status clean. The finite
integer cases and source transcriptions corroborate the argument; asserted
conclusion fields are not machine proofs of source control or services.

One new server-packet comparison passed in **2.762463561 seconds wall time**.
It checked retained identities, source/configuration joins, all five conditional
interfaces, the scoped countermodels and guard arithmetic. Independent Python
integer calculations reproduced M and both O/q ceilings directly, without
importing the packet checker. The only worktree difference after comparison
was this reviewer-owned report.

One native-bridge comparison passed in **0.653592343 seconds**, checking
612 native instruction bytes, both 58-instruction resolvers and 13 candidates.
It read the installed ELF files and retained outputs; it did not execute a
resolver or rerun objdump/readelf. The independent ELF version decoding was
likewise a byte read, not target execution. All three comparisons were justified
by newly frozen packets; no identical-success expensive rerun was performed.

Review began at **17:25:03 UTC**. Channel review, comparison and substantive
conclusion were complete by **17:31:52 UTC**; that interval also includes
server prerequisite analysis and waiting for freezes. All substantive source,
arithmetic and native-bridge review finished at **17:38:43 UTC**, an elapsed
**820 seconds** from the first recorded time, including worktree setup and
freeze waits. Report completion and commit follow that interval. Intended
result: challenge actual/universal attachment and every new capacity join.
Achieved result: conditional acceptance, with the abandoned-request repair and
independently raised copy-precondition issue preserved and the isolated native
copy obligation given a conditional bridge. No target, debugger,
capture, disassembler, solver/proof suite, predecessor checker or source fetch
ran in this reviewer lane. No GitHub, shared-memory or CLI-memory write was
made. The lead owns integration and publication.

The universal stop remains the production launcher/prefix attachment,
whole-suffix channel and diagnostic inputs, exact server binding/canonical
directory and remaining caller invariants, and source-derived weighted solver
output for the resolved solver configuration. Other allocation, native-stack,
physical-resource and complete-discharge owners also remain. The global two
save-entering callbacks, three saves and e<=2 budgets are unchanged. Oracle,
tools, pins and admission are unchanged; production #88–#94 is unstarted and
PR #121 remains draft/unmerged. No issue or goal is completed by this review.
