# Retained adapter outcome interface and publication gate

2026-10-20 UTC; authorized #119 / #153 research; prospective #88 design.
Author base `43f0e9871bb78374dc75af5ed411eea52558dcdf`.

A proxy on the existing external Why3 server connection can prevent a truncated
canonical `unsat` from becoming a proof result: publish a canonical filename
only after a complete adapter decision **and** the stock server's successful
adapter completion, and only after writing and closing the entire canonical
file. The request ID already binds that response to its Why3 proof attempt.
This is a conditional source-level protocol argument, not an implemented SPARK
adapter/proxy or a completed capacity rule. In particular, the unchanged stock
report does not expose the request-to-report-leaf join required for complete
#88 unsuccessful-attempt attribution. The concrete missing observation is
specified below, after checking the available filenames, session and debug
interfaces. **The full q remains open.**

The [packet](../evidence/retained-adapter-outcome-interface-20261020/README.md)
pins 42 source slices, the #88 requirements, and the previously reviewed R51
31-row canonical table. R51's finite recognizer and Re behavior premise are
inputs, not rerun proofs. The accepted quiet/timeless configuration remains a
separate conditional input: all configured/sent/parser resource limits are zero
and time regexps are absent. Then the stock completion time is the adapter's
actual server-observed user CPU time, not established solver CPU or wall time.
No installed tool, pin, admission rule, Oracle text or production #88–#94 code
changes. No solver/native/proof/capture run was used. The global allowance of
two save-entering callbacks / three saves / e <= 2 is unchanged and never resets
per attempt. Captured serial results do not become prospective parallel evidence.

## Existing request and completion authority

The retained Why3 revision is `9390baf120ef260547dfa14f08e11c890b203d9c`.
`call_provers.ml:460–464,507–532` increments an OCaml integer request ID,
saves the VC filename, parser and limits under that ID, and sends it unchanged.
At `478–493`, Finished retrieves/removes precisely that entry and parses the
named output. `Driver.prove_task` returns `ServerCall id` (`driver.ml:456–474`).
`controller_itp.ml:430–438,454–474` binds the call to `spa_id` and its callback,
then delivers Done to that task. This closes **transport result → actual Why3
attempt** conditional on ID uniqueness/no wrap and faithful stock runtime.
It does not establish an externally observable report-leaf map.

The proxy uses one backend connection per fixed Why3 client domain D. Its key
is `(D, original request ID I)`, not an fd, child PID, filename suffix, wall time,
new nonce or new counter. A domain connection is created once for a fresh
private run and never reconnected under that context. The original request ID
remains the backend ID. Reused/duplicate IDs cannot be merged. An original-ID
high-water mark can reject reuse even after live slots are reclaimed; gaps are
allowed because `actualcommand` may fail after `gen_id`. The existing no-wrap
capacity obligation still needs discharge; this design introduces no attempt cap.

`server-unix.c:505–533` creates the raw output file, forks, records the original
ID/client/PID/path and sends S. At `462–499`, `wait3` supplies the actual adapter
termination: WIFSIGNALED supplies a signal number and the wire field named
`timeout`; WIFEXITED supplies an exit code. The `timeout` field does **not** prove
a timeout. The F time is `ru_utime`, formatted with six fractional digits.
`536–543` also emits `F;id;0;0;0;` for queued cancellation, with **no launched
process and an empty filename**. Thus ordinary-looking zero F alone cannot
validate a decision. Require S and the launched nonempty-file F as well.

This authority assumes the retained server process table and private local
channels operate correctly; it is not cryptographic process attestation.
The child PID in the decision is an observed native fact, not a substitute
for the request binding or a proof of resource cause.

## Request wrapping, process lifecycle and channel

After receiving the unchanged Why3 request, the proxy wraps its backend argv:

```
adapter --control B --domain D --request I --prover P -- solver original_args
```

D ranges over the fixed five retained domains and P over the three selected
provers. B can be a fixed seven-byte relative Unix listener name `.slv-a0` in
the original stock server working directory. Listeners are created exclusively
in the already private fresh working directory before requests; the server
cwd is preserved. This avoids a new long control socket pathname. The
solver's argv, cwd, environment, inherited stdin, and merged stdout/stderr
must be preserved. For `runstdin`, its final filename remains the final wire
field so stock server stdin setup still applies to the adapter and its child.
The wrapper adds ten argv entries compared with the original executable/args.
For byte lengths of requests including final LF:

```
L_backend = L_original + len(adapter_exec) + 46
                         + len(B) + digits(D) + digits(I) + digits(P)
```

For seven-byte B, one-digit D/P and a positive 63-bit OCaml integer I, the
increase is at most `len(adapter_exec)+74`. The checker verifies the formula
on actual serialization, including runstdin. `prove_client.ml:161–184` provides
no semicolon/newline escaping; the original and added fields must satisfy the
existing wire grammar. Native argc/length arithmetic, ID range and aggregate
queue/storage capacity remain obligations, not new accepted-input cutoffs.

The adapter creates one solver process and a shared stdout/stderr pipe. Its
finite R51 recognizer drains all solver bytes; it joins **pipe EOF and decoded
waitpid for that exact child**, in either order, before finalizing an answer.
Waiting alone is insufficient: a descendant may still hold the pipe. EOF alone
is insufficient: the child may still be running. No deadline is added. Progress
requires eventual child/descendant descriptor closure and native scheduling;
this safety argument is not a termination proof. All control/listener fds are
closed in the fork child before exec (and CLOEXEC); only the adapter owns its
control write end. Launch errno, where required, uses a separate bounded
close-on-exec child-error pipe rather than guessing from exit 127.

The adapter and solver remain in the stock server-created process group;
`proc.c:23–29` kills `-pid` with SIGKILL. They must not detach. The proxy forwards
runs and interrupts promptly in per-client request order, without waiting for
a decision. It forwards the shared server's parallel setting without inventing
a private worker cap. An offered interrupt and an observed signal are separate
facts: the kill result is not established by this source and neither SIGKILL,
shell 137 nor an aggregate OOM counter proves attributable resource exhaustion.
An interrupt that races after ordinary adapter completion does not revoke a
valid completed result. Native timing and the winning alternative may change.

## Fixed decision schema

All integers are unsigned big-endian fixed-width fields. The first and last
magic values are `SLVADP01` and `SLVEND01`. This schema is a design choice; no
wire implementation is claimed.

| Bytes | Meaning |
| --- | --- |
| 0–7 | initial magic |
| 8 / 9 | D / P (cvc5=0, z3=1, altergo=2) |
| 10 / 11 | answer kind ASCII V/U/S/T/M/H / warning bit 0 or 1 |
| 12 | flags: bit 0 solver pipe EOF, bit 1 exact child wait decoded |
| 13 | child termination: 0 absent, 1 exited, 2 signaled |
| 14 | observation: 0 complete, 1 launch failure, 2 read failure, 3 wait failure |
| 15 | reserved zero; no claimed resource-cause discriminator |
| 16–23 | original request ID |
| 24–31 | observed child PID; zero only if absent |
| 32–35 / 36–39 | decoded exit/signal value / captured errno (zero if none) |
| 40–47 | recognized answer-rule facts, driver-local bit mask |
| 48–55 | failure-site facts: pipe, fork, child setup, child exec, read, wait |
| 56–63 | terminal magic |

The answer-rule indices are the retained loaded directives in order, excluding
time measurements: 13 CVC5, 5 Z3, 6 Alt-Ergo, each below 64. A bit is a fact
about the specified source rule, **not** a claim of physical resource cause.
The producer must state whether its fact is a selected delimiter/grep witness
or a separate raw diagnostic observation; those are not interchangeable.
R51 establishes the answer/warning quotient, not a complete independent-defect
scanner. This packet permits a zero mask and makes no completeness claim for
raw diagnostics. Any nonzero mask requires its own recognition refinement;
extra evidence accumulators belong in `S_adapter` below, not silently inside
R51's fixed storage constant. Previously established independent defects remain
in the supervisor regardless of whether this mask observes them.

A complete observation requires both flags, a launched child, a decoded native
exit/signal status in the selected ABI's range, no failure-site bits, errno zero,
and a legal R51 canonical-table row for (P, kind, warning). Noncomplete
observations must be H/no warning and have appropriate failure-site evidence;
they never prove a goal. EOF/wait flags are certified by the future adapter's
source proof, not trusted simply because two bits arrived. Directly decoded
child nonzero exit or signal does **not** by itself erase a complete source
answer V: the retained analyser preserves V despite terminal signal H. Keep
both facts and apply independent-defect policy separately.

The receiver retains at most 65 bytes per control connection. It accepts
exactly 64 bytes **followed by EOF**, and checks identity, enum/range, masks,
reserved values and canonical row. Byte 65 is enough to reject extra bytes,
a duplicate frame or a conflict in the same stream. Closing the accepted stream
before publication excludes a later append on that stream. A different complete
connection for the same key is a duplicate-protocol defect, including when late;
unknown/mismatched keys cannot attach to an existing slot. The private workspace
and verified adapter are the authority for D/I/P, not hostile arbitrary clients.
The adapter closes the control connection, then exits ordinarily with code zero
only after completing its protocol. A complete V record before abnormal adapter
death is provisional and cannot open the publication gate.

## State transitions and complete-file publication

Per key retain the admitted request binding, S, one backend F, the control
record/EOF state, cancellation facts and publication state. The event loop
services all channels and cancellations while a particular gate waits.
Cross-channel record and F delivery have no order guarantee; either may arrive
first. All client-facing S/F messages are enqueued in backend order per connection;
a blocked F also holds later S/F messages to retain that order. This can add head-of-line
delay, but must not stop reading control channels or forwarding interrupts.
Across domains there is no asserted global event order.

The only semantic publish transition is:

1. A single consistent decision has reached exact 64-byte EOF and passed checks.
2. The request has S and one nonempty-file stock F with signaled=false, exit=0.
3. The proxy selects the R51 row, creates a new canonical file exclusively,
   writes **all** row bytes, and successfully closes it. Any user-space flush
   must succeed before close. The stable private workspace premise excludes
   replacement or mutation after release; crash-durable fsync is not asserted.
4. Only then may it queue a complete replacement F using the canonical pathname.
   Once released that pathname is never rewritten/reused; Why3 reads/deletes it.

Use a domain-specific fresh directory and the original ID's fixed 16-hex-digit
name, e.g. `R/d0/0000000000000001.out`. If `R` has r bytes without a trailing
slash, the path has r+24 bytes. There is no fresh filename counter. Duplicate
creation fails closed. The canonical file contains at most 76 bytes, fully
present before any forwarded F can name it. The proxy never forwards the raw
stock output path as semantic solver output, including startup/failure paths.
Their storage still needs a bound: semantic quarantine is not a raw-file size
bound. The separate launch-output work owns that source accounting.

Inductive safety invariant: a released semantic pathname names a fully closed,
immutable table row, selected from a complete decision for the same admitted
(D,I,P) and a successful launched adapter F. Initially no pathname is released.
Receive/S/F/cancel events only accumulate facts; malformed data cannot select a
row. Create/write actions keep the pathname private. Close changes it to ready
only after the exact intended byte length; send is enabled only from ready.
Every transition therefore preserves the invariant. In particular `unsat`,
although already a Valid-matching EOF prefix, is never a published partial file.
This is the protocol argument; the checker exercises finite adverse schedules
and byte prefixes rather than proving an unbounded implementation.

Queued cancellation (empty F, no S) uses the existing empty-path semantics,
`Failure "interrupted"` (`call_provers.ml:392–399`), and can never publish V.
For a completed failed adapter, the proxy may return a fresh closed `!\n` H file
while retaining the exact adapter/record/cancellation facts. A successful
adapter with malformed/missing complete protocol is a protocol defect.
Truncation accompanying established interruption/resource failure is not by
itself an independent defect; do not reject every aborted losing attempt.
A duplicate/conflicting full decision or mismatched identity, when actually
established, is independent evidence and retains precedence even after V.

If creation/write/close fails, the proxy exposes no canonical filename. It
reports the precise native operation/cause to the outer supervisor and aborts
confirmation; it may cancel remaining work. It must not invent a resource cause
or disguise this as ordinary solver interruption. If a partial F write, proxy
failure, client read failure or later report omission prevents complete delivery,
the outer normal-completion/report audit still fails to confirm. This is not
repaired by a valid file remaining on disk. Forwarded F time/termination fields
remain adapter observations; child status is the separate decision field.

## #88 goal/check classification and warning correction

First retain independently established identity, configuration, protocol,
required-representation, unexpected-cap and report defects. Those retain
precedence. Within an otherwise coherent proof forest, any accepted Valid
alternative proves **that goal**. A transformation proves its parent only if
all its required child goals are proved (including a justified empty-child
transformation). A check requires all root goals. Unknown/crash/resource/
interruption in alternatives below an already proved goal does not poison it.
The source has these AND/OR distinctions (`gnat_checks.ml:1110–1127`), and
cancels competing provers after a valid result (`1060–1079`). A generic “any V
proves the check” rule is wrong when roots/subgoals differ.

On the remaining unproved relevant obligations, Unknown/Invalid/unexplained
failure is a defect candidate; resource-inconclusive requires **all relevant
unsuccessful attempts** to have attributable resource outcomes. A selected
resource-looking canonical S/T/M string is not an observation and cannot supply
attribution. Retain per-attempt facts and histories, rather than classify solely
from compressed `unproved_status`. Explicit interruption/resource can explain
missing evidence without that absence independently establishing a defect;
an already established competing defect survives. Normally completed missing
coverage, malformed required reports or inconsistent identity still fails the
strict audit. Confirmed requires every required check proved, coherent identity
and coverage, and normal completion of the selected run with full successful
report audit. “Normal” is not “exit zero” because of `--checks-as-errors`.

**Correction to R51's strict-warning implication:** `Loc.warning` reaches
`Gnat_report.add_warning` and the top-level `warnings` list
(`gnat_report.ml:34–46,211–214`). SPARK
`gnat2why-error_messages.adb:1301–1311` prints these strings via
`Ada.Text_IO.Put_Line`. It does not insert them into `.spark` `warn_error` on
this path. Therefore the final strict `warn_error` predicate does not establish
automatic rejection of these consecutive-answer warnings. Preserve the warning
bit and canonical warning behavior; warning bit alone is not a newly invented
defect policy. Any new warning-rejection rule needs an explicit consumer policy
and its source argument. The frozen R51 packet is preserved as history.

## LeafMap investigation and the minimum missing observation

The decision key must eventually join to the report check, goal/tree occurrence,
prover and attempt history/current selection. Existing candidates were checked:

- Ordinary solver paths encode sanitized source basename and goal `id_string`
  (`driver.ml:294–308,415–454`). The unique tempfile prefix distinguishes files,
  but final JSON does not contain that prefix. SMT2 `;; Goal`/`;; File` comments
  (`smtv2.ml:819–822`) contain textual goal/location, not session proofNodeID;
  shared names/location or repeated/split tasks are not excluded by this source.
- `check_tree` has proof_attempts and transformations. Per prover it contains
  time, steps and result, without goal ID, request ID or task path
  (`gnat_checks.ml:940–979`). Top-level check ID/kind exists, while `vc_file`
  is only emitted for manual proof info (`gnat_report.ml:127–133,185–198`).
- Session XML stores goal names and tree structure plus final per-prover result;
  it can include proof_script paths (`session_itp.ml:2084–2147`). The ordinary
  automatic path has no assigned proof_script. `--debug-save-vcs` assigns unique
  files but adds a per-check counter and uses location/kind, not check ID
  (`gnat_checks.ml:863–897`, `gnat_expl.ml:575–580`). Check equality uses numeric
  ID/kind, not location (`gnat_expl.ml:178–186`), so a unique filename is not a
  proved injective report key. More decisively, `controller_itp.ml:641` calls
  `graft_proof_attempt` **without `~file`**; the debug path is only `spa_pr_scr`
  at 647. `session_itp.ml:662–675` therefore leaves a fresh automatic
  proof_script=None. The debug filename is **not** added to automatic session
  XML. Debug-save-vcs also changes keep_vcs. Neither final XML nor JSON is a
  complete retry/supersession history. XML sorts
  transformations by name; JSON traversal order is not thereby identical.
- Existing `.why3log` records actual proofNodeID, prover, status and time
  (`gnat_checks.ml:101–111`) but no request ID or check/tree map. Its inspected
  call is in the parallel branch (`1064`), not a complete serial request trace.
  `scheduler` debug prints the optional script filename; `call_prover` debug
  prints command/limits, neither the required joint IDs.

A narrower existing payload channel does survive: `print_prover_answer`
(`call_provers.ml:150–158`) includes Unknown/Failure/HighFailure payload in the
`check_tree.result` string. For U alone, a candidate
`(:reason-unknown 010000000000000007)\n` carries one hex digit each for D/P and
16 for I. Its 18-character hex payload is in R51 class O; it is neither empty,
resourceout, timeout nor `(not unknown!)`. It yields U without warning in 37
bytes, or U with warning in 75 bytes after the existing 38-byte S prefix.
`grep` substitutes the captured payload (`205–215`), and `print_prover_answer`
preserves it. This is a bounded candidate only: the canonical table used in the
protocol/checker remains unchanged and no new producer configuration is adopted.

It does not solve the relevant failure cases. M/S/T/V are payload-free
constructors. For H, arbitrary unrecognized output becomes the constant
`unrecognized prover answer` (`327`); the other constructors here use
`default answer` (`262`), `signaled` (`351`), or the grep fallback constant
(`206`). `grep` explicitly rejects a HighFailure regexp (`214`), and the loaded
drivers have no Failure rule. Appending a tag to H's raw unrecognized text
therefore cannot carry it through unchanged as H. Changing H/M/S/T to Unknown
to gain a ticket would change answer kind and policy, so that is not selected.

Thus these concrete stock outputs do not supply a proved injective LeafMap.
No switch is silently enabled, no synthetic ID is encoded into time/steps,
and scheduling/coverage is not serialized to make a join appear unambiguous.

A category-wide invariant can close some attribution cases without an exact
LeafMap. For example, if every delivered H record in a fixed (D,P) cohort has
complete directly attributable resource evidence, and coverage proves each
reported H comes from that cohort, every such H leaf is resource-attributable.
This requires the actual resource predicate and producer/consumer coverage;
the label H alone supplies neither. Likewise an M cohort cannot be presumed
resource-only: CVC5 maps segfault text to M and Z3 includes configured-allocation
caps. No canonical answer kind, timing or steps is changed to encode identity.

Mixed cohorts expose the remaining ambiguity. A proved root with an H loser
and an unproved root with H can have the same categorical report and the same
unassociated records {resource H, unexplained H} with opposite placements.
Only one placement makes the unproved root resource-attributable. A decoder
that guessed from label/count alone would misclassify one placement. Uniform
cohorts are a sufficient case, not a universal solution to this ambiguity.

Within this fresh current-source scope, “relevant” includes earlier unsuccessful
attempts at a still-unproved required goal, even when the per-prover current
slot overwrote them. #88 supplies no rule that an overwritten Unknown vanishes.
A later Valid at that goal or a proved ancestor makes those failed alternatives
losers. Merely replacing an Unknown by a resource answer does not establish
that *all* relevant failures were resource-attributable. Historical attempts
from other sources/replayed sessions are outside this scope; no historical
compatibility machinery is proposed.

The following minimum missing information identifies an observation boundary;
**source hooks are unavailable under the unchanged GNAT/GNATprove/Why3
constraint and are not selected as the solution.** It reuses existing IDs:

1. At `controller_itp.ml:430–438`, expose `(D, I, spa_id, prover)` immediately
   after `ServerCall I` is obtained. The scheduled callback already captures the
   existing proofAttemptID (`592–652`); retain it in the observation too, rather
   than inventing another attempt number. Each retry already receives a new I.
2. At the actual Done update (`602–605`), expose which I supplies the current
   `(goal, prover, proofAttemptID)` result. Preserve prior I records as history,
   including interrupted/removed/obsolete state. Supersession cannot erase an
   earlier relevant independent defect. The final tree omits obsolete results;
   the observer must account for that omission explicitly.
3. At `check_to_json/goal_to_json` traversal (`940–979`), expose the existing
   check ID/kind, root membership, goal ID, transformation ID and ordered child
   edges, plus current per-prover proofAttemptID/I association. A stream of
   fixed-tag, fixed-integer edge records avoids unbounded path strings and a new
   occurrence counter; edge multiplicity/order must match the same traversal.
   Record an explicit complete end marker and normal producer completion.

For example, fixed 64-byte records suffice for these tags with one-byte D/P,
8-byte original native IDs and relation operands, leaving reserved bytes.
With A attempts, E tree relations and U state-update events, observation bytes
are at most `64*(A+E+U+1)` for a single final traversal; every repeated traversal
must be counted separately. Existing counters' no-wrap, completeness and bounded
A/E/U still require source/capacity proofs. No buffer needs the whole path, but
an eventual forest classifier still needs its explicit node/edge storage bound.

This is a precise information/refinement boundary, not an available stock flag
or authorization to modify Why3. A justified unchanged-stock acquisition path
or stronger source-proved class invariant is still required before the external
leaf classifier is complete. The stock proxy alone closes result delivery and
publication safety; it cannot truthfully close all per-leaf #88 attribution.

## Symbolic storage and remaining obligations

Let C=5 fixed clients, J maximum concurrently active adapters under the existing
server setting, K maximum outstanding requests (queued, running or awaiting
forwarding), A total attempts, H simultaneous control connections, P maximum
canonical pathname bytes, L maximum wrapped request bytes, and B_F maximum
backend completion-line bytes. K and H are **not** bounded merely by J: the
server queue grows, and completed/connecting adapters can wait for handling.
With one control connection per adapter and no hostile clients, H <= A; a
sharper simultaneous bound needs event-loop/lifetime reasoning. Do not install
an arbitrary K/H cap and report cap exhaustion as physical resource failure.

```
M_proxy <= S_global + C*(S_channel+B_socket)
           + K*(S_slot+L+B_F+P) + H*(S_control+65) + B_serializer
M_adapters <= J*(1,417,216 + S_adapter + B_argv + B_pipe)
retained decision payload <= 64*A
canonical file payload <= 76*A
canonical path length = len(R)+24
```

S terms include implementation object layouts, indexes, alignment and native
bookkeeping. Every sum/product needs native representability as well as logical
count bounds. The immutable path file metadata and retained failure records,
LeafMap stream/classifier, raw stock files and buffers are separately charged;
`64*A` does not purport to cover the whole audit history. No concrete verified
SPARK layout exists yet. Canonical F wire length is
`8+digits(I)+len(exit)+len(time)+len(path)` including LF (one-byte signal flag).
The stock source assumes short exit/time text and aborts when snprintf exceeds
its allocation (`server-unix.c:434–458`); a bound on that runtime formatting or
its explained failure remains necessary. Synthetic duration bytes are forbidden.

The future owned SPARK implementation must refine these transition guards,
record/framing/native-lifecycle predicates, canonical table and file publication;
complete Bronze/Silver checks and Lean semantic/source correspondence; and
integrate report coverage, actual resource evidence and LeafMap. R51 recognizer
proof and quiet/timeless configuration are separate inputs. This packet supplies
the protocol and a concrete missing observation boundary, not a substitute for
those proofs or an authorization to start #88. Parent-owned launch-output and
metadata packets are not assumed to contain unfrozen results.
