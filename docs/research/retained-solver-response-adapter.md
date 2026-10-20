# Bounded solver-response adapter: constructive design and remaining joins

2026-10-20 UTC; #119 / #153 research, prospective #88 implementation.
Author base `ca1daafc23ff683c1aa718982984e6281df8a1e1`.

**A finite answer interface exists for all three selected drivers.** It has
31 canonical rows, at most 76 bytes per completed adapter response, and preserves
the final answer kind and whether the answer analyser emitted a warning.
The byte recognizer below has a concrete fixed-storage construction; it does not
store a complete line, arbitrary Unknown payload, or cumulative byte offset.
Its conservative data reservation is 1,417,216 bytes, below 2 MiB per adapter.

This is a source-level design argument under the stated Re.Str behavior, not
implemented/verified SPARK or a replacement bound for today's solver files.
The endpoint selector and answer reducer have separate finite checks. The full
byte-stream implementation, its refinement proof and native process joins do
not yet exist. In particular, **the current full-file q remains unresolved**;
this packet does not close #119, implement #88, or change installed tools,
admission or the Oracle. Conditional implementation pseudocode is not a
completed capacity rule.

The [evidence packet](../evidence/retained-solver-response-adapter-20261020/README.md)
pins the selected 14-file driver closure, Why3 source, issue #88, report-policy
source and the public Re API source used below. The author selected GPT-6 Astra
/ Extra High; runtime confirmation and token/cost telemetry are unavailable.

## Exact observable quotient

The scope is the retained CE-off task relation (`get_model=None`), fresh
noninteractive, non-replay attempts, and the exact three driver closures in
`loaded-response-directives.json`. Driver imports are expanded in place by
`driver_lexer.mll:117–144`; `driver_parser.mly:45–53` retains source order;
`driver.ml:119–148,264–271` restores that order after list construction.
There are no exitcode, Invalid, Failure or **steps measurement** directives.
There are direct StepLimitExceeded answer directives in CVC5 and Alt-Ergo;
these must not be confused with absent steps measurements.

`call_provers.ml:233–338` first splits the raw bytes, then runs `grep` afresh on
each isolated Delim in loaded rule order. A delimiter's creating union branch
need not be its `grep` answer. Text exactly equal to one LF is discarded;
every other nonempty Text is a Model separator. No models are parsed here.
The quotient preserves:

- V = Valid; M = OutOfMemory; S = StepLimitExceeded; T = Timeout;
  U = Unknown; H = HighFailure.
- Five pending Unknown classes: E = empty, R = `resourceout`, T = `timeout`,
  N = `(not unknown!)`, O = every other payload.
- Whether a consecutive-answer warning happened **before** the Valid sink.
  It does not preserve warning multiplicity or arbitrary diagnostic text.
- Separate attributable process/evidence fields described below. Parser labels
  do not replace them.

The saved result needs only `none,H,U,S,T,M`; it never re-enters an adjacent
answer chain. The pending answer needs `none,S,T,M,UE,UR,UT,UN,UO`. A Valid
sink and warning bit give `2*(6*9+1)=110` states; 106 are reachable in the
included transition exploration. On a new answer, combine a pending answer
using the following ordered rules, or start a new pending answer:

| Pending / incoming | Replacement | Warning |
| --- | --- | --- |
| S or any U / UR | S | no |
| T or any U / UT | T | no |
| any U / UE, or any answer / UN | pending | no |
| UE / any U | incoming | no |
| other U / other U | UO | no |
| every remaining pair | incoming | yes |

The order is essential. Joining two nonempty payloads inserts ` + `, which
cannot occur in any of E/R/T/N; hence the concatenation branch is always O.
A Model commits the pending answer, if any; otherwise it preserves an existing
saved result or supplies H. A committed non-H result replaces saved H; a later
H cannot erase it. V ends analysis immediately, including warning evolution.
Appending terminal H for a signal therefore changes no quotient result: it
only supplies H when no better answer was present. Empty filename cancellation
is a separate Why3 path, `Failure "interrupted"`, not an adapter-emitted row.

These branch facts establish the token-level quotient by induction on the
source's recursive analyser. The checker also compares a direct, concrete
payload evaluator with the finite machine on 354,312 cases (all token words of
length at most five, both signal flags). That finite comparison checks the
implementation of the table; it is not the universal induction proof.

## Canonical bytes and warnings

Every row below uses the existing answer regexps, including Alt-Ergo's imported
SMT-LIB `^unsat$` rule. LF means byte 10, not platform newline translation.

| Kind | Canonical bytes | Drivers |
| --- | --- | --- |
| V | `unsat\n` | all three |
| U | `unknown\n` | all three |
| S | `unknown\n(:reason-unknown resourceout)\n` | all three |
| T | `unknown\n(:reason-unknown timeout)\n` | all three |
| M | `Cannot allocate memory\n` | CVC5, Z3 |
| H | `!\n` | all three |

When the original warning bit is true, prepend the S row to the desired row.
The prefix itself creates S without warning; S followed by the desired row's
first answer creates exactly one warning, then reduces to the desired kind.
H with a warning is unreachable: a warning requires two non-H answers, and
later Model/signal H cannot erase every such answer. Alt-Ergo has no M row
because no selected output or exit rule can create M. This gives 11+11+9=31
rows and maximum 76 bytes, including the warning prefix.

`Loc.warning` reaches `Gnat_report.add_warning` and its warnings list. Thus the
adapter must retain this bit; deleting warnings merely because V eventually
wins can alter the report. The future producer/report join must show that one
generic consecutive-answer warning preserves the strict policy's rejection of
the original nonempty set, including the warning before V case. The fixed
warning text/payload and count are intentionally different; no claim of
byte-identical reports is made. #88 must keep the existing successful audit,
coverage checks and independent-defect precedence, and consume the bounded
warning/evidence record as additional evidence. It must not reinterpret a
synthetic canonical resource label as a new resource observation.

## Byte recognizer construction

The relevant runtime premise is byte matching with the public Re.Str behavior
retained from ocaml-re 1.12.0, commit
`f09672608781dc05172ad980a6e9a483c3b9d534`: `str.ml` defines full_split and
search/replace; `emacs.ml` maps dot to not-LF, `^`/`$` to line boundaries,
negated classes to complement, and escaped parentheses/vertical bar to
grouping/alternation. `core.mli:600–632` specifies first-alternative and greedy
repetition priority. No selected regexp has a backreference. This identifies
the required behavior, **not the installed library's historical version**.
Faithfulness to this interface is part of the existing relevant-runtime
premise; the desired finite-machine equivalence is argued separately here.

Full_split searches leftmost, chooses the preferred branch at equal starts,
returns the whole chosen match, and resumes at its end. Every selected match
has positive length, so its empty-match progress special case is unreachable.
The following construction implements those decisions rather than independently
classifying lines or searching for an `unsat` substring.

**Persistent gap state.** Add a three-valued pending Text summary to the
110-state reducer: empty, exactly LF, other. Unmatched bytes update this state;
only a subsequent Delim or EOF flushes it. In particular, two LFs are one
Model, not two discarded Texts. There are at most 330 combined states. A chunk
summary is a function on these 330 states, represented by 330 two-byte entries.
Composition preserves arbitrary chunk boundaries and incoming reducer state.

**Line-local CVC5/Z3 wildcard branches.** Apart from reason-unknown, all
unbounded matches stay on one LF-delimited line. The only unanchored wildcard
branches are literal `P .* S`:

| Driver | P | S | Equal-start priority |
| --- | --- | --- | --- |
| CVC5 | `(error "` | `out of memory")` | only branch |
| Z3 | `(error "` | `out of memory")` | first |
| Z3 | `Maximal allocation counts ` | ` have been exceeded` | second of these three |
| Z3 | `(error "` | `number of configured allocations exceeded")` | third |

The intervening Z3 `Cannot allocate memory` alternative has a distinct start
prefix. All other unanchored answer patterns are fixed literals. Their full
lists, prefix-free check, containment checks and cutpoint-overlap checks are in
the evidence. No fixed literal starts before a wildcard P and crosses its
start, and no fixed literal starts inside a chosen S and crosses its end.
Consequently simple-literal lexing of the gaps can be finalized at these cuts
without losing a match. Long delimiters always re-grep to M: they contain no
LF; none equals an earlier anchored U/N/V pattern; any earlier CVC5 memory
literal also yields M.

Let K be the number of wildcard branches, at most three. For each j retain its
last complete S start/end on the current line. A candidate P beginning at p
is valid precisely when that suffix starts at or after P's end. Its greedy
match then ends at the retained end `e[j]`. At each anchor in
`{line start,e[1],...,e[K]}`, retain the first P of each branch beginning at or
after the anchor and the finite gap-transform up to that P. Also retain the
simple-literal tail transform from each anchor to the current byte.

At LF/EOF, choose the earliest valid candidate after the current anchor;
break equal-start ties in loaded branch order. Emit its preceding gap summary,
then M, and move to its `e[j]` anchor. If none exists, emit that anchor's tail
summary. There are at most K selections: a selected branch consumes its final
suffix on the line, so it can never match again after that end. Later starts
of a branch cannot rescue an invalid first start, because there is no later
suffix available to them either. This proves the endpoint algorithm by
induction on the remaining matches. The finite checker independently compares
the endpoint rule with documented greedy/priority matching on repeated,
nested, competing-suffix and literal-gap examples; it does not execute Re.Str.

The registers are maintained online. Detecting a literal P at its final byte
uses a bounded lookback snapshot from before P; detecting a new final S resets
that branch's anchor, first-start row and tail summary. Snapshot finalization
includes the simple lexer's delayed bytes, not merely committed answers.
Implement the fixed-literal lexer with a sparse prefix/failure automaton.
Its pending prefix is a finite state, not a copied byte string in every
snapshot. When a gap snapshot is finalized, any nonempty pending prefix is
unmatched non-LF text and updates the gap to other. Store that finite lexer
state and pending flag alongside each snapshot; the crossing checks ensure
that no completed simple token was withheld across the cut.
No full line is retained. The source constants and crossing checks justify
using a 128-byte delayed window and 129 snapshot positions per anchor.

**Anchored line alternatives and Alt-Ergo.** Common `unknown/sat/Fail/unsat`
and CVC5's special N error require an exact line; bounded literal-prefix
recognizers suffice. They cannot overlap the wildcard/literal matches above
when they succeed. Alt-Ergo's additional patterns are all anchored at BOL:
the fixed fatal-steps prefix, or `; File "` followed by a greedy filename and
the finite-state suffix `", line digits+, characters digits+-digits+: ?`
followed by Valid or `I don't know`. Keep the last completed suffix of each
kind and a bit saying whether bytes followed it. Prefer any Valid suffix to
the Unknown suffix, as the loaded rules do. A successful suffix has no quote
after its initial quote, so later successful filename-closing quotes also
have later ends. Thus the last-end register realizes greedy filename choice.
The trailing bytes on that same line have no BOL and cannot create another
Alt-Ergo answer. Digit runs require states, never an accumulated integer.

**Multiline reason-unknown.** The remaining pattern is
`^(:reason-unknown \([^)]*\))$`. At the earliest eligible BOL prefix, freeze
the incoming transform and start one fallback line parser on the same bytes,
with reason recognition disabled until this candidate is decided. Also retain
the capture class and the earlier-rule flags needed for isolated-Delim grep.

The first `)` after the prefix is decisive. LF/EOF immediately after it accepts
the whole candidate. Any other next byte rejects it. Every nested reason
prefix before this first `)` is rejected in the latter case too: it meets the
same forbidden first close followed by a non-boundary. Therefore the single
fallback summary loses no nested successful delimiter. If EOF arrives without
a closing `)`, the same fallback is selected. Upon rejection, resume its full
line-parser state; upon acceptance, discard its internal answers, emit the
whole reason delimiter's answer and continue after its end. The following LF
belongs to the gap, not the delimiter.

For isolated-Delim grep, common unknown/sat/Fail lines are earlier than the
reason rule; any such line makes its class O. CVC5 has still earlier rules:
its exact N error and two cvc5 memory literals. Track these finite flags in
their loaded order, then common unknown, then the reason capture E/R/T/O.
The N error can itself contain the candidate's first closing parenthesis.
For example, an inner N error on the last line overrides the outer reason
capture. Other CVC5 memory rules and Valid occur later and cannot override it.
The fallback is a transform on all 330 incoming states, not a raw byte buffer
or a prematurely committed inner Valid.

This explains both decisive adversarial cases:

```text
(:reason-unknown <LF>unsat<LF>)<LF>   -> U
(:reason-unknown <LF>unsat<LF>        -> V at EOF
unknown<LF><LF>(:reason-unknown resourceout)<LF> -> U, not S
```

All recognition is on bytes. NUL, high octets and CR are ordinary bytes;
there is no Unicode decoding or CRLF normalization. `unsat\r\n` is H.

**Storage and indices.** Each endpoint is a reference to its relative order,
not an input offset. Retain a ring of the last 129 positions plus the live
start/end references above. Insert the newest position at the end of that
order; retire unreferenced positions and renumber the remaining bounded set.
Every comparison used by the algorithm is order/equality or an endpoint
selected from that fixed ring; there is no cumulative byte arithmetic.

A deliberately loose reservation is 2,048 transform rows, each 330 unsigned
16-bit entries: 1,351,680 bytes. The line matrix needs at most
`(K+1)*(129+K+4) <= 544` rows including delayed snapshots, first-start snapshots,
tail/current rows and work rows. A second such bank permits composing/copying.
Reason mode suspends the normal parser and **reuses** its line-parser bank for
the fallback; it does not allocate a third bank. Reserve 64 further rows for
the frozen incoming/reason summaries, Alt-Ergo/anchored summaries and whole
stream composition scratch. Thus `2*544+64=1,152 <= 2,048` rows suffice.
Reserve another 65,536 bytes: 8,192 for 4,096 two-byte rank references,
24,576 for three rank-renumbering work arrays, 8,192 for four-byte snapshot
metadata, 8,192 for sparse literal/digit recognizers and their constant
tables, and 16,384 for rings, state tags and bounded loop scratch. No dense
256-way table or per-snapshot 128-byte buffer is part of this layout.
Total: **1,417,216 < 2,097,152 bytes**. State codes
are at most 329; row indices at most 2,047; rank indices at most 4,095; literal
lookback at most 128. The implementation must use these bounded ranges and
nonrecursive loops, with the large record outside the call stack.

This is a usable storage layout for the described algorithm, not measured
memory usage of an existing executable. A future implementation must prove
the register/snapshot invariants above and its refinement to the source byte
relation. The finite endpoint tests do not by themselves discharge the
multiline fallback, Alt-Ergo or rank-renumbering refinement obligations.

## Chosen timing route

The concrete proposed route uses private response configuration with **time
measurement regexps removed**, no steps measurement directives, and all
answer regexps/task printing/transforms unchanged. Why3's existing server
CPU-time fallback remains in the normal time field. This is an explicit new
measurement source: it describes the process the server reaps, the adapter,
with the platform's resource-accounting behavior. It is not relabelled as the
old solver-only CPU time or as the discarded arbitrary `why3cpulimit` text.

`grep_time` normally tries the first match of each time regexp and catches
conversion failures; it does not search later same-regexp matches after a
failed conversion. With the proposed empty time-regexp list it always falls
back. `pr_steps` remains -1 for completed output-file attempts, with the
existing separate queued-interruption steps=0 case. No decimal-to-binary64
streaming conversion or finite/nonfinite raw timing-text claim is needed.

With actual time and step limits zero, `parse_prover_run:363–377` cannot turn
U/H into a resource answer using these fields. `gnat_checks:769–826` uses time
to choose the fastest **already Valid** proof and report statistics; that
selection cannot create or remove a proved goal. `check_tree` retains its
normal time/steps fields. Session saving uses answer kind and optional steps.
Fresh, non-replay ownership excludes the generic replay/bisection consumers;
the normal parallel scheduler at 1049–1084 dispatches and cancels by answer,
not reported time. The strict report policy sources have no time/steps
success predicate. Source inspection therefore supports this measurement
change on that selected zero-limit route, without deleting required fields.

There is an exact caveat: `gnat_config.ml:27,567–575` defaults warning-attempt
timeout to **1 second**, independently of `--timeout=0`. This packet does not
silently change that existing route. Applying the all-zero timing argument to
warning attempts requires the prospective launcher/producer configuration to
set its warning timeout to zero, or a source proof excluding those attempts.
That configuration join is still open. Likewise, changing private driver
time directives and command paths needs its own source/configuration/prefix
transfer; the accepted quiet-command prefix transfer is not reused unchanged.

## Process completion, cancellation and evidence

The adapter invokes the pinned solver with the same argv and one shared pipe
for child stdout/stderr. It must drain incrementally, wait for complete child
termination and EOF, and finalize the finite result. Optional raw logging may
not block this work. No extra deadline or size cap is introduced. Fixed adapter
storage does not justify child argv sizes, launch arithmetic, lifetimes, stack
or solver internal representations; their existing obligations remain.

`server-unix.c:348–355` creates a process group whose id is the launched adapter
PID; `proc.c:23–29` sends SIGKILL to that whole group. The solver and descendants
must inherit that group and not detach. This reuses existing cancellation;
the adapter must not attempt to forward SIGKILL from a handler. Offered kill
is not successful kill, and SIGKILL does not establish an OOM cause.

Before writing **any** canonical bytes, the adapter must publish a complete,
attempt-bound decision record to the #88 supervisor containing the final
quotient, warning/evidence mask and directly decoded child wait status. Failure
to complete this record cannot produce a Valid response. Only then emit the
chosen bounded row. A partial `unsat` already matches `^unsat$` at EOF, and
Why3 prefers it even when the adapter is signaled. Therefore response-prefix
boundedness alone is insufficient: #88 must reconcile a Valid with the
completed decision record and separately observed adapter completion or
interruption. The record precedes emission so even this prefix cannot claim a
child result that had not been fully determined. Missing, contradictory or
malformed records cannot establish confirmation.

Final-only output does not reproduce every raw-prefix cancellation answer.
It may lose a raw-prefix V before the child/adapter completes. That difference
is explicit: normal losing-attempt cancellation follows another accepted V;
explicit interruption is unconfirmed; other premature termination requires
its own attributable-resource or defect classification. Already established
independent defect evidence is retained by the supervisor and has precedence.
The adapter must not emit an early provisional V: completing the multiline
reason example can change a current-prefix V into U.

The bounded evidence record distinguishes at least launch/pipe/read/write/wait
failure and captured errno; child exited versus child signaled with the actual
numeric value; adapter failure versus child result; explicit cancellation;
ordinary answer kind; warning presence; and recognized diagnostic-rule facts.
Its discriminator set and fixed-width native status fields are finite.
There is no attempt to preserve an unlimited arbitrary diagnostic string.
Classifier significance must be justified per fact: CVC5's M rules include
segfault text; Z3's include configured-allocation caps. Those are not physical
OOM evidence. A competing U or unexplained failure on an unproved check stays
a defect candidate, while a resource/interrupted loser cannot poison a check
already proved by another attempt. Raw signal numbers and shell statuses must
not be guessed from the canonical text.

The 76-byte bound applies to bytes emitted by a successfully entered adapter
protocol. Server failures before exec can print argv[0]/strerror directly to
the capture file; adapter runtime startup/fatal paths also need bounded
source-defined output or a separately controlled diagnostic descriptor.
Consequently the full prospective per-file bound must include those paths,
for example `max(76, B_server_launch, B_adapter_startup)`, with actual controlled
path lengths and runtime error-text bounds. A protocol claim does not erase
these pre-entry producers.

## Required completion of the design

#119 owns the remaining **design** joins before this proposal can satisfy its
prerequisite: full source-level byte/construction soundness and review under
the explicit Re behavior relation; the warning-timeout and changed-prefix
configuration; strict-warning/cost and completion-record policy joins; and
pre-entry server/adapter-startup bounds. This packet supplies the concrete byte
construction and source argument for review, while leaving the listed
configuration/process/pre-entry joins open. They cannot be assigned to an
unstarted #88 implementation as a reason to declare #119 complete.

After that design is justified, the #88 implementation/correspondence package
has concrete inputs: the exact
driver manifest, 110/330-state tables, the endpoint matrix and rank layout,
reason fallback/isolated-grep flags, 31 canonical rows, the chosen time-source
configuration, and the process record-before-emission protocol. It must prove
the full byte refinement and storage/index invariants in Silver-owned SPARK,
complete Bronze/Silver checks and Lean semantic/source correspondence, and
attach launch/cancellation/record/report behavior under #88. Focused fixtures
must include the retained overlap, two-LF, CRLF, NUL, warning, signal and
truncated-`unsat` cases. They supplement, rather than replace, those proofs.

No native, solver, proof, capture, observer or broad predecessor replay was
performed. The single global two-callback/three-save, e<=2 allowance is
unchanged. Preparation identity/counters, compiler/producer grammar, retained
prefix composition and the full #119 rule remain separate obligations.
