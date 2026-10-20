# Independent review: CVC5 output closure and #119 decision

2026-10-20 UTC, authorized research #119 / #153.

**The three component packets and the precise whole-#119 research-stop report
are accepted at the scopes below.** They do not establish a complete per-attempt
q or the whole-#119 capacity rule. The stop is the permitted research deliverable
now ready for matching integration and publication. The missing diagnostic and
terminal premises are supported by source, and the remaining parent obligations
survive even if a narrower configuration removes one output family. This review
changes no harness/issue state, Oracle, admission or tool configuration.
Incomplete proof here establishes neither impossibility nor an actual failure
on the selected tasks.

## Exact inputs and review setting

The isolated review worktree is `tmp/cvc5-output-closure-review`, branch
`review/cvc5-output-closure-20261020`, based at
`d19f73cb3f3c2d8c32d88c1dda9b3c058090ce07`.
The frozen inputs and verification results are recorded in the
[review packet](../evidence/retained-cvc5-output-closure-review-20261020/README.md).
Combined reviewed worktree target: `186bc00db2`; author files match these exact
freezes byte-for-byte:

| Component | Final author freeze | Review-worktree import |
| --- | --- | --- |
| Parser/options | `8460aa16ed76101fd011ed0b3fe0744c00c51704` | `59d60dafc4` |
| Diagnostics | `acc4d04c4bd0278e0168e33805b32ea00a0975ab` | `185b1a7d3b` |
| Terminal control, including citation repair | `572e03d7edf19f4b6eff9f06dda2d9bf3d9e6028`, atop `b79598ef2ad682973942eb57ff041ae2058bc9c1` | `c946ce84d6`, atop `3068cca866` |
| Whole-#119 stop, including reporting repair | `651fa8e1a7c7c88dd27828ad8e2219f69b4f9f50`, atop `a980e7d4de823739dd0e97e079a2afaa59d10265` | `186bc00db2`, atop `4bb286ae05` |

Reviewed the new parser/options, diagnostic and terminal notes and their
packets, plus the exact whole-goal research-stop report. Read the governing
AGENTS.md, Oracle, the capacity contract's required
conclusion, current opening status and complete-grammar/completion sections,
Round 46 ledger/review and the current external-review disposition. Reused the
accepted task-language, registry, enum and parallel-launch scopes; did not
re-review the selected 475-condition native derivation or replay old captures.

Reviewer `/root/cvc5_output_closure_review` was selected as **GPT-6 Astra /
Extra High** by the parent. Runtime model/effort confirmation and token/cost
telemetry are unavailable. The child `get_goal` returned null; the parent
reports the active goal permits either a complete source/configuration-decidable
whole-#119 rule or a precise independently reviewed research stop identifying
unresolved obligations and alternatives, without unlocking expansion. The latter
is an authorized outcome, not an inferred request to pause. Actual host is Linux
7.0.14 x86_64; `scripts/dev.py paths` confirmed isolated worktree routing.
The reviewer authored none of the three components and spawned no other agent.

## Component review

### Parser and automatic options

**The parser/option argument is accepted for the selected construction and
stock-main relation.** The noninteractive `.smt2` route invokes one continuous
file loop with portfolio disabled. The generated-name template supplies that
suffix, but Why3 can reuse an old proof-script pathname; the actual launch must
attach the generated-name branch or an equivalent `.smt2` pathname. No such
attachment follows from the template alone. Successful command parsing consumes the
enclosing delimiters; nested term/sort parsing does not reenter the command
parser. Lexical string/comment/symbol containment therefore survives parser
execution. Parser exceptions mark the parser done and escape the loop; no
recovery interprets a malformed template suffix as a new command stream.
The two Float80 templates remain a semantic-acceptance gap, without breaking
this conditional command containment.

Distinct returned commands consume at least three distinct lexical tokens,
giving `C<=floor(T/3)<=floor(N/3)`. N must still be derived prospectively.
Hard failure stops the loop; the included SetInfo/GetInfo recoverable statuses
have the stated two-event envelope. These outer counts do not bound internal
warnings, and the reason-query error already included in the accepted 84-byte
pair must not be charged twice.

The setter generator performs the addressed field assignment after its declared
handlers/predicates; holder copies copy values into separate allocations.
Inspection of defaults, direct writes, automatic setters, driver mode selection
and subsolver/portfolio gates supports the named projection, rather than a
blanket assertion that all defaults persist. In particular stats-all,
stats-every-query, pivot and ITE histogram collection stay false, output getters
and portfolio remain disabled, and MINISAT/verbosity zero/zero tlimit are
preserved. No synthesized find-synth command or external plugin client is
introduced. This attaches R=0 and inactive uint32 histograms to the accepted
ordinary registry/enum join: `Q_stats<=1,103,886+F`, under its other original
object/stream/native premises.

The parser warning charge is source-local: each unsupported attribute can be
charged to its physical keyword occurrence, and each fresh-binder warning to
one parsed binder entry. The binder-context caller reads that list once.
Their fixed bytes and location widths support
`N(max(F+99,173)+1)`. The direct-error interface separately preserves the
rendered-operand input H and caught payload E_caught in
`68+F+max(256+2N+3H,E_caught)`; it does not substitute raw task size for expanded
terms/types or arbitrary exception messages.

The prospective single `--quiet` has a verified candidate-source effect:
negative verbosity routes both global WarningChannel and `Env::warning` to the
null stream. CheckSat and nonempty GetInfo results, and non-ok command statuses,
print without that verbosity gate. This preserves the named normal response
text while excluding those warning bytes. It is useful alternative evidence,
not an adopted invocation, complete q or rendering-safety result.

### Returning arithmetic diagnostics

**Accepted as a specific unclosed output obligation.** Source review followed
the MINISAT `search` loop through CHECK_FINAL, TheoryProxy, TheoryEngine and
`Theory::postCheck` to the arithmetic full-effort check. That check clears and
repopulates its model caches. The producer explicitly stores a nonintegral
Rational for an integer term in the ill-typed map. Its consumer prints the
warning, offers a branch-and-bound lemma and returns normally if a new lemma
was added. MiniSat's `recheck` continuation can return to a later full check.
Neither the warning site nor this continuation requires a second input command.
The always-assert path is only the bad-assignment/no-new-lemma branch; treating
the entire warning family as fatal would be incorrect.

At verbosity zero, `EnvObj::warning()` selects `verbose(0)` and the nonmuzzled
environment selects the error stream. The fixed warning text is 72 bytes.
The nonintegral SMT2 rational adds at most nine bytes around its numerator and
denominator digits, giving the conditional family allowance
`81*K_ar(N) + L_ar(N) + D_ar(N)`. The source uses GMP arbitrary-precision
Rationals, so the statistics int64 decimal-width bound cannot supply those
digits. Counting input variables, one live map or one query does not bound
cumulative warning entries after resets. Local restart budgets and zero global
resource/time limits supply no whole-attempt count.

This is a control-path and missing-premise argument. It does not establish that
any retained task reaches, repeats or diverges through this path. A theorem
excluding the path for the exact task/helper relation is an admissible alternative
to bounding the cumulative count and payloads. No such theorem is present.

The independent define-fun calculation also checks: 55 fixed API payload bytes
become `121 + 2*(R(term)+R(sort)+R(actual-sort))` under the accepted command
wrapper. Internal API translation copies `getMessage()`; it does not invoke the
additional decoration in `TypeCheckingExceptionPrivate::toStream`. Generated
operand rendering and raw runtime `what()` strings remain distinct obligations.
The note correctly disclaims an exhaustive diagnostic census.

### Terminal activation count and payload

**Accepted at its explicitly conditional scope, after a citation repair.**
The five installed signal kinds use an empty additional mask without
SA_NODEFER. Under the stated single-thread POSIX, disposition/reset, no
unblocking/reinstallation/nonlocal-recovery and terminal-action premises,
distinct handlers can nest but each signal kind enters at most once. The saved
termination handler is restored before the CVC5 callback prints; with its
standard nonreturning contract and no reinstallation, the CVC5 callback adds at
most one activation. Thus six attempted safe dumps and `8688+24P0` direct-text
bytes are valid conditional upper bounds. They are not process-wide theorems
derived from the command line alone.

Zero `tlimit` excludes CVC5's own timer installation/thread route, conditional
on parser/options attachment. It does not identify every linked backend thread
or native signal behavior. The note preserves escaping-handler unwinding as a
missing condition rather than inferring its absence from a lexical search.

Safe histogram output traverses positive vector buckets directly; ordinary
map-collapsed enum spellings cannot supply its bucket multiplicity. Separate
vector/offset updates also make an ordinary completed-operation invariant
insufficient for every signal instruction boundary. The int64 negation and
double-to-int64 cast require their stated arithmetic domains; average statistics
do not establish them by type alone. The exact statically linked saved C++
handler and its exception/type/message operands remain unidentified for this
byte account. The host's current shared runtime would not supply that relation.

The original double-conversion citation/excerpt omitted the central cast at
`safe_print.cpp:116`. The lead repaired the note and widened the retained excerpt
to lines 109–139 in `572e03d7ed`, atop `b79598ef2a`. The complete source hash was
already correct. This was an evidence-precision repair, not a defect in the
conditional count or the identified numeric obligation.

## What is missing from a complete q

For the selected command, the ordinary command envelope and registry/enum
components are retained progress. They do not provide the required theorem:

> For every selected source/configuration-derived task, every charged execution
> prefix emits at most a computable pre-run q, while all intermediate producer,
> printer, counter and output representations stay in their justified domains.

At minimum this needs a source-derived cumulative arithmetic-warning/rendering
bound or a valid exclusion, complete remaining diagnostic/error producers,
terminal entry/payload/native relations, and their composition over the same
actual attempt. A default option, finite counter type, observed successful run,
single-query count or finite handler count cannot replace these inputs. Nor
does an overly large conservative envelope prove that a useful bound is
impossible. Complete q and weighted O remain null.

A quiet configuration is a legitimate same-tool research alternative. Its
required-answer behavior, exact parser/executor settings, all remaining error
and terminal families and downstream accounting must be established before it
can close q. Suppressing emitted warning bytes does not by itself suppress C++
operand evaluation or prove internal rendering/search representation bounds.
No such configuration is adopted by this review.

## Whole-#119 completion assessment

The CVC5 gap alone prevents the current complete output join. It is not the
only reason the whole rule remains unfinished. The following matrix preserves
the parent's full completion contract without reopening accepted source audits.

| Obligation | Reused established evidence | Still required for a complete rule |
| --- | --- | --- |
| Compiler/native route | #145's reviewed selected literal-output four-job graph, 475-condition conjunction, twelve stage summaries and 51 GGC owners; accepted #131 reconciliation and #150 dispositions | Generalize or soundly reduce every required grammar/composition family; preserve actual invocation/search/input contracts. Production #89 must later adopt that route with implementation correspondence or rederive an alternative. The native result itself is not reopened. |
| Producer and fixed-library proof | Accepted producer-prefix/first-inline intervals, fixed source-to-task joins, five fixed-process typed domains and scoped registration/save controls | Complete required producer/Why3/task-driver paths, formula/context and later representation sizes, actual-input attachment and automatic-discharge argument. Straight-line literal Main having no backend task does not eliminate its fixed-library verification. |
| Consumers, saving and exit | Accepted JSON/output interfaces, server/launch relations, serial state components and this round's output subcomponents | Actual q for all required CVC5/Z3/Alt-Ergo attempts and weighted O; complete formatter/report/server/library joins, caller arithmetic/ownership and native/ambient/service relations, and complete save/exit composition. Prospective parallel counts do not transfer captured serial state. |
| Essential versus reporting-only limits | Existing #88 dependency-test criterion and named confirmation limits | Classify each remaining Image/report-writer dependency by whether it can affect complete obligation generation/discharge. Calling confirmation optional cannot waive an essential representation or incomplete strict report audit. |
| Current grammar and composition | Source/value/parser/helper/native/producer component transfers in the capacity contract | Cover declarations, references/concatenation, integer expressions, assignments, comparisons/branches, nested loops, Image and their permitted compositions, with all generated support. The accepted declaration-free literal family is not the whole admitted language. |
| Correspondence and trusted inputs | Exact retained archives/pins, solver identity inventory, installed-producer observations and explicit source/tool premises | Attach relevant source/configuration behavior for each actual executable/launch, plus Silver-owned model/source/implementation correspondence. The exact historical installed SPARK revision is still unattached; missing owner records are not a mandate for full binary attestation. A precise reviewed relevant-behavior premise may fit the existing trust boundary, but cannot silently waive transfers or discharge. |
| Decidable whole-rule accounting | Checked local evaluators and selected native conjunction | One terminating rule over authoritative source, dependencies and configuration, with proved checked/saturating accounting and sound peak/lifetime composition for every required path. It must decide membership without running compiler/prover success tests or measuring materialized enormous constants. |
| Useful domain and final review | Retained shape-dependent region and component boundary examples; source-sensitive/uniform comparison requirement | Compare sound candidates on the same configuration, describe useful acceptance and current-shape losses, select explicit predicates, state #93 rederivation triggers for the completed rule and obtain its independent final review. A component boundary or subjective 82% estimate is not this result. |

The [current disposition](../review-a3af180047-disposition.md) already resolves
#131's reconciliation and all seven #150 checkbox items. They should be reused,
not relisted as undischarged historical findings. Its #89 production obligation
is a later dependency; this review does not turn #119 into implementation of
production #88–#94. Likewise the old chronological sections of the capacity note
do not override its later accepted native and fixed-session results.

## Recommended next decision

**Integrate and publish the goal's permitted precise research-stop report now.**
This round has converted the previous generic request for a complete CVC5 output
account into named missing control, payload and native-interface obligations.
The evidence supports that result without another broad solver audit. It does
not support promising that one more bounded argument will close the whole rule.
The recommendation follows the unresolved dependency structure, not sunk token
cost, the number of rounds or a claim that higher reasoning effort cannot help.

The [frozen stop report](../research/retained-tool-capacity-stop.md) preserves
the accepted results above, names the unresolved theorems/inputs, retains
complete q/O as unestablished and distinguishes current configuration from
prospective alternatives. Its full requirement audit includes compiler,
producer, fixed-dependency, all-consumer, grammar, correspondence, decidability,
composition, comparison, rederivation and final-review requirements. It correctly
requires matching integration/publication after this review and explicitly
limits any later #119 completion to the stop deliverable. #153's technical
composition stays unfinished; no production prerequisite is satisfied by the
stop. No substantive repair is required to that disposition.

One reporting repair was requested: distinguish delegated authors'/reviewer's
selected Astra settings from unavailable runtime confirmation and lead settings.
The exact repaired freeze is listed above. This does not change any theorem or
the recommendation. The lead owns integration, harness/issue-state handling
and publication.

Continuing with a narrowly specified recurrence/exclusion theorem, quiet/output
configuration analysis, launcher relation or relevant-behavior attachment is
already-authorized research if the lead elects to pursue it. Each would need an
explicit success criterion and retain the other residuals; none is silently a
whole-goal completion. Forking/replacing the retained toolchain, changing the
Oracle or assurance guarantee, narrowing owner-approved task scope, using proof
success as membership, or waiving essential obligations would require a separate
owner decision or remain forbidden by the unchanged contract. Routine research
option choices do not need an invented approval ceremony.

## Verification and handoff

Focused offline checks, exact commands, output and elapsed times are recorded
in [checks.json](../evidence/retained-cvc5-output-closure-review-20261020/checks.json).
Each new component checker ran once; terminal and diagnostic checks ran
concurrently, then parser after its freeze arrived.

| Check | Result | Measured subprocess seconds |
| --- | --- | ---: |
| Terminal | Pass: seven source members and conditional arithmetic | 0.500683 |
| Diagnostics | Pass: 30 source files, 49 ranges and payload arithmetic | 0.873351 |
| Parser/options | Pass: 51 source files, four foreign sources, 43 witnesses, 31 options and 177 lexical parser sites | 1.416894 |

They validate identities, excerpts,
lexical supports and local arithmetic; source review assesses the conditional
arguments. Neither establishes native refinement, selected-input reachability
or universal automatic discharge.

The reviewer's identity/link check passed **24 frozen files, 14 historical
inputs, four components and 38 local links** in **0.094176 seconds**, without
replaying the component checks. Its result is retained in
[result.json](../evidence/retained-cvc5-output-closure-review-20261020/result.json).

Review began **18:40:03 UTC**; source/report checks finished **18:50:37 UTC**,
**634 seconds** later, including freeze waits and report preparation. Final
record edits and commit follow that interval. The three component subprocess
times total **2.790928 seconds**; the first two overlapped. Intended result:
challenge complete-output claims and decide the next whole-goal disposition.
Achieved: conditional component acceptance and acceptance of the exact stop,
with one terminal citation/excerpt repair and one selected/runtime reporting
repair, neither a new semantic theorem. Token and monetary cost measurements
are unavailable. The review did not run
a native target, solver, compiler, capture, proof suite, network operation or
broad predecessor replay. No GitHub or CLI-memory write occurred.

The global two save-entering callbacks, three saves and e<=2 remain one budget,
never renewed by a solver, warning, registry, dump or channel. Oracle, installed
tools/pins and admission are unchanged. #119/#153 are not declared finished or
paused; production #88–#94 is unstarted and PR #121 remains draft/unmerged.
Only this review and its evidence packet are reviewer-owned edits.
