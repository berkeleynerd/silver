# Solver output: the required capture bound and a smaller JSON interface

2026-10-20 UTC, Linux x86_64, #119 / #153. Author base:
`421486c4e33271c02fc59f54d71182cc98c9558c`.

**Why3 needs a bound on each complete captured solver file before it can deliver
that attempt's result. It does not need to copy all those bytes into the final
JSON.** The selected implementation does not establish an observation-only
exemption for raw warnings, statistics or terminal text. However, the existing
quiet/no-statistics configuration direction removes specific output producers,
and an exact ordinary-response language eliminates their unnecessary charge to
the JSON answer/warning interface. These are two distinct reductions.

The [offline packet](../evidence/retained-solver-output-relevance-20261020/README.md)
pins Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`, CVC5
`86cecd83b685f59e884094693b9a4c5c90a62e03`, installed driver bytes and the
existing #88 dependency criterion. This is authorized continuation after the
owner rejected treating the earlier research stop as completion. It selects no
stop alternative, changes no production configuration, and leaves the whole
capacity rule open. Oracle, tools, pins and admission remain unchanged.

## Capture and discharge are coupled

The relevant path is source-explicit:

| Owner | Actual operation and dependency |
| --- | --- |
| `server-unix.c:505–533,389–396` | Create one temporary output file; duplicate its descriptor onto both fd 1 and fd 2; `execvp` the solver. Direct stderr and ordinary stdout reach the same file. Failed exec text also reaches it. |
| `server-unix.c:434–459,462–499` | After child termination, send the filename, status and CPU time. The server reply does **not** contain the output bytes. Consequently its reply-length bound needs the filename, not q. |
| `call_provers.ml:168–173,392–402`; `sysutil.ml:29–38` | Read the whole file through 1,024-byte chunks into a growing Buffer, then copy `Buffer.contents` into a string. Delete the file only after this read. Chunked I/O does not make retained storage bounded independently of q. |
| `call_provers.ml:233–247` | Run `Re.Str.full_split` on the complete string, then eagerly `List.fold_right` over every resulting segment, constructing Answer/Model entries. The later priority for Valid at 263–265 does not bypass this work. |
| `call_provers.ml:342–390` | Analyse answers, then search the entire output for time and step fields; retain the raw string in `pr_output`. CE-off avoids model parsing at 328–336, not the initial split or string storage. |
| `call_provers.ml:478–499,543–560`; `controller_itp.ml:448–491,592–617` | `List.map handle_answer` parses the received batch before `ProverFinished` publication; the controller subsequently updates the proof attempt/goal and invokes Done callbacks. A parse failure can prevent delivery of another result in the same batch. |
| `gnat_checks.ml:1055–1079` | A delivered Valid result cancels competing attempts. A losing attempt's file can be parsed before that callback, so “another solver will prove it” does not eliminate its capture/parser obligations. |

Thus the necessary early interface is a prospective per-file bound q, together
with the parser's segment/allocation/stack bounds and their aggregate lifetime
composition. Its inputs are the source/configuration-derived task family and
launch relation. It is not a bound on the server's protocol record and not an
arbitrary aggregate-RAM assumption. Buffer position/growth arithmetic, string
length, regexp offsets, the eager list construction and recursive traversal
remain caller representations. A byte bound is an input to their checks, not
a proof that those checks pass.

Cancellation has two different paths. Removing an unstarted queued request
sends an empty filename (`server-unix.c:536–544`); Why3 returns the fixed
`Failure "interrupted"` without reading/parsing a file. Its raw-file charge is
zero. Killing a running request retains its file and ordinary child-completion
message; that prefix is still read. The selected server's SIGKILL adds no CVC5
signal-handler text, but does not remove preceding bytes or prove their bound.
External soft cleanup is a separate route. No terminal/signal allowance is
borrowed from Why3's global callback budget.

## The concrete option and consumer distinctions

**Statistics.** The private no-StepRegexp driver has no step extractor. The
remaining inherited time regexp is `why3cpulimit time : %s s`, not a CVC5
statistic. `parse_prover_run` uses server CPU time if it does not match, and
uses -1 when no step regexp matches. GNAT's report statistics are constructed
from `pr_time`, `pr_steps` and a count (`gnat_checks.ml:805–826`); they are not a
parse of CVC5's registry dump. This supports removing `--stats-internal` under
the existing no-step configuration proposal without deleting required outcome
or obligation fields. It does not remove time-domain or report-count bounds.

With a joined `stats=false` invariant, CVC5's ordinary and safe statistics
functions return without obtaining/traversing the registries
(`command_executor.cpp:81–115`). The ordinary registry/string/histogram byte
terms and safe-printer signed-negation/double-conversion/histogram-traversal
obligations are then absent **from these selected print paths**. This is a real
reduction, not an observation-only exception to an overflow. The option-query
gate itself still needs a valid receiver. Statistics objects/counters updated
elsewhere are not thereby absent; the configuration lane must also account for
the internal `statisticsInternal` consumers, including proof-finalization work.
No claim of identical instruction traces or disabled proof checking follows.

**Warnings.** The accepted [parser/options account](retained-cvc5-parser-options.md)
shows that `--quiet` routes WarningChannel and `Env::warning()` to null streams.
It therefore removes the recurrent arithmetic-warning **byte** term
`81*K_ar+L_ar+D_ar` from the captured-file interface once that routing is joined.
It does not establish that term/rational operands are unevaluated or their
printing terminates; their reached caller representations retain their own
scope. Without routing or a proved content exclusion, diagnostic text can also
match answer regexps, including unanchored resource-error patterns. It cannot
be declared semantically irrelevant just from its human-readable purpose.

**Error-channel routing.** The stock `--err`/`--diagnostic-output-channel` option
exists (`base_options.toml:4–13`). `ManagedErr` can use a file such as `/dev/null`;
this changes that managed stream, not the process's fd 2. Direct `std::cerr`,
raw terminal writes and failed-exec text still reach Why3's merged capture.
SMT command failure/recoverable-failure responses remain ordinary output.
Opening the selected channel introduces its own service/error route. Redirecting
this channel is consequently a partial producer reduction, not a completed q
bound or permission to discard needed failure attribution. Its full option and
status-preservation join belongs to the configuration lane.

**Terminal/error text.** The selected driver has out-of-memory and timeout
patterns; signal status is also interpreted. These paths can affect an attempt's
outcome and are still eagerly captured even when another attempt ultimately
proves the goal. Under `stats=false`, the separate safe-statistics dump is
absent, but direct handler text, error payloads and any saved runtime handler
remain distinct. Arbitrary corrupted states are not added to the normal-service
scope. Nor does an unexplained crash become successful discharge or an
attributable resource result. Ambient interruption and detected physical
failure retain #88's separately specified incomplete-confirmation outcomes.

## A strict smaller language for the downstream JSON input

Define a **clean ordinary CVC5 file** to contain exactly one complete ordinary
check-sat/reason-query response pair, with the selected SMT2 formatting and
driver interpretation: sat, unsat or unknown followed by its specified reason
response, with ordinary nonsignaled process termination. This does not require
exit status zero; native status is preserved independently. This is a predicate
to establish prospectively from the producer
relation, not permission to classify membership by examining solver output.
It asserts neither that the answer is Valid nor that the driver alone guarantees
this file language. No warnings, statistics, exceptions or terminal bytes are
silently included in it.

The accepted [CVC5 component](retained-cvc5-output-capacity.md) bounds that file
by 84 bytes (sat 82, unsat 84, unknown 47). More precisely its Why3 parsing gives:

| Pair | Parsed answer behavior |
| --- | --- |
| unsat plus expected get-info error | Valid has immediate priority in `analyse`; formatted answer `Valid` has five bytes. |
| sat plus expected get-info error | The error matches the fixed `Unknown "(not unknown!)"` rule; the 294–296 reduction retains `Unknown "sat"`. |
| unknown plus finite reason | The two Unknown answers either reduce to Timeout/StepLimitExceeded, discard an empty reason, or join using `" + "` at 299–300. They never take the incompatible-consecutive-answer warning branch. |

For the unknown pair, the two captured payloads together are no longer than
the 47-byte file. One three-byte joining separator and the ten-byte
`Unknown (...)` wrapper give at most 60 bytes; fixed outcome names are shorter.
Hence a clean ordinary answer needs **at most 64 bytes and zero consecutive-
answer warnings**, including the sat/unsat reason-query error. This does not
infer proof success from expected-looking text; it describes the existing
driver's parser on the exact language under its usual trusted interpretation.

The queued-cancellation branch is also a fixed answer of fewer than 64 bytes,
with no parser warnings and no raw file. A running cancellation, malformed
response or terminal/error file stays in the exceptional class below unless a
separate prospective prefix-language proof refines it. Do not reclassify a
finished-but-unsuccessful attempt as an interruption. Other solvers stay in
the exceptional class unless their own exact response-language result applies.

Let A count **all** reported answer occurrences as before. Let `O_Ax` sum raw
file lengths only over exceptional reported answer occurrences, `O_Px` over
exceptional parser invocations, and `N_x` count those invocations. Multiplicity
and abandoned prefixes are preserved. Put `O_x >= max(O_Ax,O_Px)`. The accepted
general answer/warning argument then sharpens to:

```text
L_A <= 64*A + 4*O_Ax
W_c <= O_Px + N_x
L_c <= 514*O_Px + 512*N_x.
```

No clean raw-file bytes enter these three expressions. Their early Buffer,
regexp and retained `pr_output` owners still pay for the complete file.
Debug-prover-errors must remain off to exclude its separate raw-output warning
copy (`gnat_main.ml:103–108`); other warnings remain `W_o/L_o`. `check_tree`
formats `pr_answer`, time and steps, not `pr_output`
(`gnat_checks.ml:961–971`). CE-off and the accepted model ownership relation
remain in force. This uses the actual producer, not a new output adapter.

Substitution in the accepted [standard JSON interface](retained-why-standard-json-inputs.md)
gives the following **normal-JSON** contribution, with its unchanged timing,
schema, occurrence and formatting premises:

```text
B_n <= 14864 + 3732R + 189G + 873A + 3075N_x
       + 3111O_x + 3W_o + 6L_o + 3D + 6H
E_n <=  2313 +  753R +  73G + 194A + 1027N_x
       + 1039O_x + 3W_o + 2L_o + 3D + 2H.
```

Thus a proved clean subset removes its contribution to the old `3111O` and
`3075N` terms without removing its attempts, fields, timing or result identity.
Abort JSON still adds `84+6X` bytes and `106+2X` events over two calls; the global
debug-copy allowance stays `D<=1,H<=26619`. Other standard writers, construction,
native stack and core guards remain separately charged. If no clean producer
join is established, use the old general formula: this packet assigns no actual
attempts to the smaller class and exports no complete q/O.

## The smallest useful remaining joins

For the proposed quiet/no-statistics invocation, the next useful source theorem
is the **selected task-to-response relation**, not another warning recurrence
census: each selected, correctly generated task in the covered normal-service
domain executes the fixed command envelope without a parser/API hard failure,
and its only captured bytes are the ordinary pair. This supplies q<=84 and the
smaller JSON interface for that domain. Other charged execution outcomes need
their explicit byte/prefix relation or a source-justified scope exclusion; an
unproved relation is not zero. A bound on each file handed to `handle_answer`
is sufficient; an inventory of every output path in arbitrary API clients,
unselected portfolios or malformed external SMT files is unnecessary.

The existing fixed typed forests make a bounded attachment plausible, but do
not themselves discharge it. The [task-language packet](retained-solver-task-language.md)
deliberately permits symbol/tag aliases to select a wrong or empty syntax
template, and includes two malformed Float80 templates in its overapproximation.
To exclude them using the fixed no-float domain, join (a) correct nonaliasing
symbol-to-syntax correspondence through the selected transforms, and (b) the
inductive absence of Float80 template use and of removal-as-term/type syntax.
Then the existing trusted Why3 translation and solver-input semantics can apply
to the correctly printed typed task family. This is not a request to prove an
arbitrary SMT parser or solver implementation correct, and a textual no-Float80
census alone is insufficient. The intended larger grammar needs its own join.

The [accepted relevant-behavior boundary](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
applies throughout. No historical build-record or new binary-attestation gate is
introduced. Ordinary correct allocation, stream/container operations, integer
conversion services and OS behavior on valid requests remain trusted. The
source-derived sizes, operand domains, caller arithmetic and reached stack
remain justified separately. A runtime output interface may be stated against
the selected dependency's relevant behavior rather than proving its entire
internals; “every accepted task fits/proves” would be circular. Disabling an
unneeded print traversal removes that traversal's obligations, not all solver
counter or arithmetic obligations.

Final JSON/report/audit operations cannot retroactively change a completed local
proof, but their failure can still stop outstanding required work in other
children. The accepted [producer tail](retained-producer-tail.md#reporting-phase-separation)
shows result collection is not an all-children barrier. Its later `spark_report`
summary arithmetic is a separate possible observation-only boundary requiring
reliable detection; that does not exempt these earlier consumers. Successful
confirmation continues to require every strict report and identity/coverage
check. No named earlier boundary is reclassified as observation-only here.

One global Why3 allowance remains **two save-entering callbacks, three saves,
e<=2**, never renewed for solvers, output classes or reports. Selected author:
GPT-6 Astra / Extra High, confirmed as the parent's spawn selection; runtime
model/effort and token/cost telemetry are unavailable. The packet records exact
checks, freeze and elapsed time. No native/solver/proof/capture run, GitHub write
or harness change occurred; independent review is left to integration.
