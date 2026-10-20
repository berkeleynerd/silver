# Independent review: selected suffix diagnostic occurrences

2026-10-20 UTC, #119 / #153. **Accepted under the named selected
source/native/runtime and metadata-preservation relation; no material repair
required.** This closes outer occurrence counts and the direct backtrace
subtotal. Recursive registry expansion and diagnostic payload capacity remain
unproved by this packet.

## Inputs, method and measurements

The exact author freeze is `63a701e032bd054331613716c7a8ba56fc9c58a3`:
the [research note](../research/retained-why-diagnostic-occurrences.md) and all
nine files in the [packet](../evidence/retained-why-diagnostic-occurrences-20261020/README.md).
Its [manifest](../evidence/retained-why-diagnostic-occurrences-20261020/inputs.json)
pins 29 reused records/archives. I read the control argument, checker, retained
source witnesses, client dispositions and result/round records. Relevant
accepted preparation, attempt preservation, standard-output control,
channel-exit and disabled-backtrace arguments were reused without replay.

The lead performed this review independently of the author, in
`/tmp/silver-review-diagnostic-occurrences-20261020`, branch
`review/diagnostic-occurrences-20261020`, at that freeze. Live lead model/effort
and per-review token/cost telemetry are unavailable; no change of lead setting
is claimed. The author's selected setting was GPT-6 Astra / Extra High.
The timed portion began at 16:49:58 UTC, after initial reading; complete
review elapsed time is unavailable. The single new packet comparison passed
in **0.394667435 seconds wall time** (0.356340742 seconds internal), checking
40 source excerpts, 12 inherited raw-client rows, four libraries and five
cases. All packet file digests were identical before/after. No target,
debugger, disassembly, source fetch, solver, proof or predecessor replay ran.
Additional read-only inspection checked the selected GNAT/controller source
roots and transform exception-printer references against the accepted dispatch
closure; lexical searches alone were not treated as reachability evidence.

## Findings

**The two owner-local reports need whole-suffix weighting.**
`build_prover_call` removes no new scheduling key and invokes its failure
callback once from the Sys_error handler. `idle_handler` pops once before
building, and its separate handler can report a failure of that first report.
Neither handler catches its own body. The accepted distinct-pair/consumed-escape
proof bounds scheduling owners, including failures before preparation: each
repeated owner needs the prior nonvalid Done and a new consumed false tried-query
result. A lost publication supplies no retry credit. Thus A=3G+2 is valid for
the five cases, without resetting the global exception allowance per report.

**Outer roots and nested printers are separated correctly.** GNAT's main
handler lies outside the protected main expression. The installed uncaught
handler is called once; its OCaml fallback performs at most two to_string
conversions, and the final wrapper suppresses further failures. Therefore
Exn outer <=2A+2 and Printexc outer <=2. The timeout InternalFailure arm has
no selected producer: Call_provers constructs only Started/Finished updates.
Its caller removes finished calls before Done dispatch. Prefix configuration,
file/reload and connection reporters, nonselected interactive transforms,
CE/RAC/model parsing and eager module initializers add no suffix outer root
under the inherited dispatch/configuration relation. The exact later-library
bytes exclude Lexlib's position-directive reporter. This exclusion relies on
the accepted four-file closure, not merely on searching those four files.

**Output failures can reach later roots.** One ordinary single-line JSON call
can partially execute before either abort route. Each of the main and custom
uncaught handlers has one abort call, so one normal plus two abort invocations
is a valid prefix bound. Counting only one final successful JSON would not be.
Printer.int_of_string's broad handler really can emit stderr on a conversion
failure. On the selected Smtv2 route its assertion or failed output escapes the
print; the nearby Unsupported catches rethrow, and the range-literal Exit catch
has no callback here and raises Failure. The bookkeeping catches do not surround
syntax output. Hence at most A such reports, without assuming conversion success.

**The missing-parent raw print consumes a global escape.** OCaml exception
patterns in `match get_proof_parent ... with` protect the scrutinee, not the
recursive parent-update branch. Its ordinary table miss is translated to BadID
inside get_proofNode. A signal-origin Not_found outside that inner trap may
reach the outer handler; this consumes one of the existing e<=2 exceptions.
The handler cannot retry itself or produce a fresh signal credit. Old-session
merge is excluded and the two other alleged raw-print sites are comments.
Together with the custom-handler fallback this proves n<=1 and m<=e+2<=4.

**The raw component's stack multiplier is one.** A covered conversion/print
does not invoke another covered conversion/print. Selected pending save/exit
clients and hooks do not introduce these raw callers. A failed raw operation
unwinds before higher reporting; the uncaught wrapper prevents recursive fatal
reporting. Suspended save/caller/service frames retain their own owners. Thus
d<=1 is valid for this component, not a whole-process stack bound. Reusing
the accepted per-call costs yields <=1,432 object-request bytes, <=236 offered
channel bytes in <=4 calls, returned string length <=59, and <=5,016 covered
active native bytes per process. These are prospective requests, not live-heap
or physical sufficiency claims.

## Acceptance boundary

All five result rows keep inner printer counts, wrapper depth, diagnostic
payload bytes and actual standard-core B/E null. Complete diagnostic,
save/exit, process-stack and physical-capacity flags remain false. That is
necessary: the earlier first-inline depth-two/eight-attempt allowance does
not cover later Loc/Trans/Pretty/Fun wrappers. The separate expansion and
JSON/payload work must supply those inputs before composition.

Oracle/tools/admission remain unchanged. #119/#153 remain incomplete,
production #88–#94 unstarted and PR #121 draft/unmerged. This review owns only
this report; it changes no GitHub record or goal state.
