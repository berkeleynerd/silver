# Silver roadmap

Silver grows through small capabilities motivated by runnable examples. The
[Oracle](oracle.md) governs the guarantees; [language.md](language.md) and the
[catalogue](catalogue/silver.json) specify what is supported today.
This roadmap records intended work and unresolved decisions. It does not admit
new syntax or authorize weakening an existing guarantee.

Before 1.0, maintain one current language. Git records revisions; separate
profile maintenance and compatibility infrastructure are unnecessary. Intentional
changes to earlier rules and examples must be explicit and consistent. The
[development policy](development.md) prioritizes foundations needed for the
next capability while retaining full assurance for the current language.

## Current development sequence

### Unbounded programs

**Retained-tool direction adopted; capacity design resumed.** The owner
[selected](docs/session-memory.md#2026-10-17--retained-tool-capacity-direction-adopted)
keeping the existing GNAT/GNATprove toolchain, accepting explicit tool-imposed
representation boundaries and removing unnecessary Silver limits within a
justified domain. [Decision #117](https://github.com/berkeleynerd/silver/issues/117)
records this disposition. External paired support, compiler forks and replacement
frontends cease to be prerequisites. The [scope](docs/unbounded-programs.md)
and [milestone 5](https://github.com/berkeleynerd/silver/milestone/5) retain the
unchanged Oracle and current supported language.

The reviewed research [#107/#108](docs/research/unbounded-feasibility-result.md)
and [#113](docs/research/frontend-representation-result.md) establishes a
source-derived obstruction to the original full String composition domain.
Two distinct length-2^30 Strings require at least 2^31 shared character entries;
the inspected GNATprove literal producer has a separate finite Why-node space.
These are conditional source facts, not native near-limit failures or safe
admission thresholds. PR #109 and PR #116 preserve the completed research and
reviews. Their external-support recommendation is superseded, not their evidence.

The capacity research package is
[#119 Derive capacity rules for unchanged tools](https://github.com/berkeleynerd/silver/issues/119),
a design subpackage of #91 shared with #93. The
[design contract](docs/research/retained-tool-capacity.md) requires a sound,
decidable rule accounting for retained and temporary values, generated data,
dependencies, phase-specific expansion, representation arithmetic and growth.
Prefer program-structure accounting and justify any conservative envelope.
`Integer'Last` is an inherited ceiling; a per-value bound alone does not justify
all compositions. No numerical aggregate cap or larger admission domain is selected.

The selected literal-output native-build increment
[#145](https://github.com/berkeleynerd/silver/issues/145) is technically complete
and In review through [draft PR #121](https://github.com/berkeleynerd/silver/pull/121).
**#119 is In progress; #153 and #178 are technically complete and In review**,
following the owner's continuation recorded
on main through [PR #160](https://github.com/berkeleynerd/silver/pull/160).
This supersedes the night pause; the complete capacity-rule objective is unchanged.
The [R61 checkpoint](docs/evidence/retained-printer-pause-round61-20261023/README.md)
retains reviewed preparation through printer entry and its shared-demand baseline.
The harness still reports
paused pending its separate UI/system control; project work is authorized.
The reviewed [R63 join](docs/evidence/retained-six-owner-round63-20261023/README.md)
completes the six-owner input set and all five conditional operand calculations
fit. The [R64 name-table result](docs/evidence/retained-printer-names-round64-20261023/README.md)
adds private suffix/integer/array bounds. The accepted
[R65 checkpoint](docs/evidence/retained-name-attribute-round65-20261023/checkpoint.md)
now supplies Hsattr lifetime demand/state, the seven-owner join and complete
raw-name origins for R64's string guards. All five applications fit; review
repaired the combined-prefix attachment without changing the owner bounds.
The accepted [R66 checkpoint](docs/evidence/retained-printer-output-round66-20261023/README.md)
supplies selected per-request output and fresh Format/Buffer operands under the
actual Driver box/flush lifecycle. All fifteen case/driver applications fit.
The accepted [R67 checkpoint](docs/evidence/retained-printer-private-round67-20261023/README.md)
adds the remaining private printer-container and formatting accumulator/layout/
finite-progress interfaces. All five private-owner and fifteen layout applications
fit; review repaired two draft source arguments before acceptance. The
[R68 reporting checkpoint](docs/evidence/retained-reporting-round68-20261023/README.md)
now joins current J12 canonical-response counts, initial/continuing warnings,
terminal scalar diagnostics and the shared standard-root writer sum. All five
conditional calculations fit at the explicitly hypothetical path orientation;
actual path attachment remained open at that checkpoint. The
[R69 checkpoint](docs/evidence/retained-reporting-round69-20261023/README.md)
now supplies source/configuration path functions and selected private report
construction, including an explicit alias-robust warning-byte correction.
The combined reporting guards yield a common sufficient result-directory
length region of R<=2264; actual configuration R remains unset and this is
not an adopted admission cap. The accepted
[R70 checkpoint](docs/evidence/retained-path-logging-round70-20261023/README.md)
adds complete raw library-probe path/local storage and logging formatter/channel
interfaces; all five logging offset applications fit. The accepted
[R71 checkpoint](docs/evidence/retained-filetags-parser-round71-20261023/README.md)
closes FileTags representation and canonical reader/direct caller bounds under
their explicit premises, and attaches current registration to the retained
459-entry protocol envelope. The accepted
[R72 checkpoint](docs/evidence/retained-re-native-round72-20261023/README.md)
closes the selected installed-Re numerical correspondence, including its extra
packed table, interrupted-update recovery and private search-array lifetime.
It retains the existing matching-semantics and sufficient-resource premises.
The accepted [R73 design](docs/evidence/retained-backend-output-round73-20261023/README.md)
now bounds raw backend output on the prospective pipe/canonical route by
`max(2*A+72,A+E+1296)`, with explicit configuration arithmetic and lifecycle
conditions. The actual adapter must discharge the recorded #88 refinement;
no adapter is implemented. The accepted
[R74 checkpoint](docs/evidence/retained-controller-main-round74-20261023/README.md)
adds the selected controller ownership/container join and five Main API typed
contract profiles. The Main U/H transfer remains conditional on the unfinished
source traversal; #178 is not complete. The accepted
[R75 checkpoint](docs/evidence/retained-fixed-main-round75-20261023/README.md)
adds private preparation-container bounds, a composed fixed-library Why
continuation predicate after successful controlled startup, and Main's primitive
contracts/restricted conversion interface. Pre-registration failure capacity,
full Main source construction and whole-rule coverage/composition were open
at that checkpoint; R77/R78 close the scoped interfaces below.
The accepted [R76 diagnostic checkpoint](docs/evidence/retained-fixed-diagnostics-round76-20261023/README.md)
now supplies conditional pre-cut scalar/marker and complete fixed `.sexp`/`.mlw`
interfaces. Review repaired escaped-string and FileTags-alias bounds. Full
composition additionally requires the driver-resolution repair: unique private
names must avoid installed-name ambiguity and uncontrolled fallback after a
failed stat. The earlier first-local-import claim is insufficient; the narrow
configuration/prefix repair is now independently accepted in
[R78](docs/evidence/retained-fixed-process-round78-20261023/README.md).
This closes #153's technical fixed-process success/failure capacity interface
and repairs #181; both are In review pending delivery. The symbolic diagnostic
cwd guard preserves the separate successful-prefix allocation relation. Actual
#88 launcher/adapter refinement and #119's later consumers remain separate.
The accepted
[R77 Main interface](docs/evidence/retained-main-interface-round77-20261023/README.md)
now completes #178's source-to-typed-body/contract scope, including full caller
and implicit-clause traversal and source-derived U/H. Review repaired anonymous
sequence keys, independent scalar check layers and String inequality lowering;
#178 and findings #182–#184 are In review pending delivery. The next Main join,
[#185](https://github.com/berkeleynerd/silver/issues/185), composes structured
kode and initial VC formulas, then per-VC imported marked definitions/aliases
and terminal goals. This follows #178 and feeds the complete #119 rule
alongside the accepted fixed-process #153/#181 result.
The independent required-consumer increment
[#186](https://github.com/berkeleynerd/silver/issues/186) attaches the bounded
Why response schema to GNATCOLL reader/token/string/container/reference guards.
It ends at parsed-response return; later result/assumption construction and
final `.spark` serialization remain with #119. It is In progress in a separate
author workspace, while #185 proceeds with early independent review.
Whole-process headroom and #119 are unfinished.
The Round 47 [stop report](docs/research/retained-tool-capacity-stop.md) and
[independent review](docs/reviews/review-cvc5-output-closure-20261020.md) preserve
accepted results, the original requirement matrix and precise missing bounds
as interim evidence. Their earlier completion disposition was premature.
#153 is technically complete at R78; the complete #119 production prerequisite
remains unsatisfied. PR #121 stays draft and merging it is not authorized.
The reviewed [Round 48 reduction](docs/evidence/retained-quiet-output-round48-20261020/README.md)
establishes a supported controlled quiet/no-statistics CVC5 route and conditional
ordinary-response accounting. It leaves complete output and task/prefix joins
unfinished and changes no production invocation or admission.
The reviewed [Round 49 transfer](docs/evidence/retained-quiet-prefix-round49-20261020/README.md)
bounds the command perturbation and excludes malformed Float80 template origins
for the fixed tasks. Continuing identifier and memo-counter bounds, exact task
correspondence and complete solver output remain unfinished.
The reviewed [Round 50 calculation](docs/evidence/retained-goal-inline-round50-20261020/README.md)
supplies goal-revalidation charges, including repeated preparation, and attaches
the fresh first-inline graph to its earlier local bound. Other preparations,
callbacks and counters remain separately charged.
The reviewed [Round 51 checkpoint](docs/evidence/retained-preinline-adapter-round51-20261020/README.md)
adds the retained serial pre-inline family/charge and a bounded solver-response
recognizer design. Review identified an unresolved parallel first-fill gap:
failed CVC5 preparation can let Z3 insert declarations before Alt-Ergo's first
CE fill. The serial result does not discharge that obligation. The adapter's
76-byte canonical responses and proposed fixed storage do not yet close full
output q; configuration, outcome-policy and startup-output joins remain.
The reviewed [Round 52 checkpoint](docs/evidence/retained-config-parallel-round52-20261020/README.md)
closes selected warning-attempt exclusion and the zero-limit/time-parser
configuration transfer, including composition with the quiet command, for the
retained serial domains. It reduces the parallel first-fill remainder to 13
keys in four formula families; the complete parallel attachment remains open.
No adapter, parallel configuration transfer or full q bound is adopted.
The [Round 53 checkpoint](docs/evidence/retained-metadata-outcome-round53-20261020/README.md)
retains all five J12 metadata/raw-domain attachments, a conditional result
publication protocol with a final audit seal, and the direct stock-server
child-diagnostic terms. Missing data is now available for the thirteen-key
producer argument; its stage-selected transfer and full parallel mutable-state
attachment remain open. The protocol's native refinement and stock report-leaf
association, loader/adapter startup and complete q are still required.
The reviewed [Round 54 checkpoint](docs/evidence/retained-parallel-attribution-round54-20261020/README.md)
closes all thirteen residual producer keys under the fixed-input/cache/freshness
premises, derives the 118-root/47-check map and a conditional F-to-Done log
association, and bounds stock completion formatting under the selected
Linux/libc/compilation interfaces. Parallel mutable-state and changed logging
startup transfer, aggregate response/history storage and full q remain open.
No production adapter or changed invocation is adopted.
The reviewed [Round 55 checkpoint](docs/evidence/retained-parallel-state-round55-20261020/README.md)
adds the guarded arbitrary-order producer-state induction, transfers the root
map to exact R53 J12-plus-logging startup, and bounds protocol owners and ring
storage. It selects the prospective Why-only SIGINT mask route; #88 still owes
actual spawn, default/unblocked termination, PID/group race fallback and reaping.
That checkpoint left the quiet/timeless/J12/logging combination separate.
The reviewed [Round 56 checkpoint](docs/evidence/retained-request-inline-round56-20261020/README.md)
now joins that configuration for the exact R53 successful-prefix roles,
attaches filesystem filenames/argv/request bytes, and bounds first inlining
over all 118 registered roots. Parser allocation is computable from adapter
and TMPDIR lengths; direct first-inline Ident registrations are at most
792,911 across the five processes under their existing global allowances.
That checkpoint left returned old hidden-map/type/validator envelopes,
stock-server owners and shared-server launch attachment open alongside later
preparation/printing/counters, complete storage/output and the full #119 rule.
The reviewed [Round 57 checkpoint](docs/evidence/retained-returned-server-round57-20261020/README.md)
now closes returned context storage/types at the first-inline interface,
direct stock-server requested-object families and exact-path successful
connection transfer to the shared-server design. Later validators and
collision/primitive costs remain separate. Physical-memory exclusions retain
the established sufficient-resource trust boundary; this adds no aggregate
RAM gate or allocator-internals proof requirement.
The reviewed [Round 58 checkpoint](docs/evidence/retained-postinline-libc-round58-20261020/README.md)
bounds the next three preparation stages, including repeated task validation,
and adds the three named libc allocation terms to the shared-server equation.
These remain conditional source/representation interfaces; later generated
formula families, printing, counter totals and complete output remain open.
The [Round 60 checkpoint](docs/evidence/retained-preparation-demand-round60-20261023/README.md)
adds reviewed right-only split bounds and a partial six-owner demand join.
The [Round 61 checkpoint](docs/evidence/retained-printer-pause-round61-20261023/README.md)
adds the accepted remaining preparation through printer entry and supplies its
vector to that join. Known operand guards fit. Library lookup constructors,
printer execution and other callbacks/shutdown remain explicit missing inputs;
actual whole-process headroom stays false. Unreviewed library-constructor work
is committed locally for resumption.
The [review disposition](docs/review-a3af180047-disposition.md) enumerates the
remaining #119 obligations, shape-dependent accepted region, configuration
premises and deferred findings. The historical planning estimate supplies no
remaining-time prediction or evidence of complete rule coverage.

The result covers a selected direct four-job graph with extra compiler options,
direct GNATBIND and a fixed two-unit Silver object/ALI bundle. Production still
runs GPRbuild over a seven-unit project and is outside that researched invocation.
**#89 must adopt the exact researched graph, options, materialization, environment
and fixed-input contracts with Bronze/Silver and Lean source correspondence,
coordinated with #88, or rederive capacity for the alternative graph.** This is
a future production obligation; the stop does not discharge it. Continuation
requires producer/Why3 and fixed-dependency coverage, current-grammar coverage,
decidable checked accounting, whole-rule source correspondence/composition,
useful-domain comparison and final independent review, reusing accepted native
evidence. Relevant #150 review follow-ups have been reconciled at bounded checkpoints.

The next technical checkpoint repairs controlled driver/import resolution and
composes the reviewed R76 failure interfaces with the fixed-domain continuation.
The accepted lookup/library,
printer/callback and installed-Re results remain inputs to that composition.
In parallel, the separate source-sensitive
[#178 Main typed-profile increment](https://github.com/berkeleynerd/silver/issues/178)
attaches ordinary Main source and selected API contracts to the existing
typing/kode/SP-WP input bounds. Its five selected API profiles, primitive
contracts and restricted array-conversion interface are accepted; the full
constructor-preserving source traversal and implicit clauses remain in progress.
This is an In progress child of #119; #153's
fixed-library scope cannot supply that variable-Main input. It ends at the
typed-body/contract interface, before the remaining downstream terminal-goal,
native GCC and whole-rule joins. Then finish the full current-grammar capacity rule.
Subsequent #88 owns executable SPARK/Lean refinement. No adapter is adopted;
checked accounting, source correspondence, whole-rule composition, useful-domain
comparison and final review remain required before production starts.

The unfinished research increment is
[#153 Bound fixed Why3 session domains and ordinary ending](https://github.com/berkeleynerd/silver/issues/153):
the five retained logical domains, fresh backing states, scheduling/save-domain
preservation and ordinary-ending/SIGINT control are reviewed. The
[Round 46 checkpoint](docs/evidence/retained-tool-rounds.md#round-46--generated-solver-domains-and-parallel-launch)
retains the accepted 206 structural table applications, five attempt-counter
bounds and private formatter/scalar lifetime. It closes initial resumable
path-table state and selected library/writer origins, yielding a 116,162-byte
path bound under the named source/runtime and normal-service relation. The
[path/input composition](docs/research/retained-why-save-path-input-join.md)
attaches actual U at that conditional scope to the existing Format core and
attempted String.concat construction; all five arithmetic guards pass. This
does not establish service success or complete formatter/save capacity.
Round 34 retains local restored-path lookup and composes the selected direct
formatter allocation requests into a disjoint cumulative envelope. It derives
469 preparation episodes across the five interrupted continuations, and removes
successful initial lseek from offset representation requirements. Round 36's
[service attachment](docs/research/retained-why-save-service-contract.md) supplies
conditional buffer/offset capacity under an explicit positive-write premise
for the selected private blocking regular files. This is assumed external
behavior, not a proved OS guarantee or complete delivery/termination claim.
Whole-interval native/frame behavior remains an explicit premise.
[#155 selected preparation and Theory publications](https://github.com/berkeleynerd/silver/issues/155)
is technically complete and In review pending draft PR #121. Its
[composition](docs/research/retained-why-publication-composition.md) bounds actual
publications in all five continuations and passes every writer scalar-size
guard. It attaches initial registration counts and prepared tuple families,
and counts expanded library reads/clones with global cache-loss allowances.
Request counts and recursive-own-frame interfaces are evaluated; complete
writer allocation and whole-stack capacity remain open. Round 37 supplies
[direct allocation bounds for all six shape-builder families](docs/research/retained-why-save-shape-builder-allocation.md)
left by the structural subtotal; cumulative requests do not establish live
memory or physical sufficiency. The
[variable-only binder argument](docs/research/retained-why-save-stack-composition.md)
and [five helper closures](docs/research/retained-why-save-stack-helper-closure.md)
now join the reviewed binder/private-formatter and serializer components in the
[selected save caller-stack composition](docs/research/retained-why-save-owned-stack-join.md).
This replaces the incomplete save-entry projections with explicit S/T/G/F
components and preserves the global three-save/two-callback budget. The
[private-printer control](docs/research/retained-why-save-printer-control.md)
and [signal-setter projection](docs/research/retained-why-save-signal-setter-capacity.md)
are separately reviewed. Ambient preparation, service interiors and non-save
phases remain outside the composed caller projection. The
[channel/exit attachment](docs/research/retained-why-channel-exit-bound.md)
bounds six global flush roots, later output-channel creation and per-channel
refcounts, including abandoned allocation prefixes. It adds no global positive-write
premise. The [initial exit values](docs/research/retained-why-exit-initial-values.md)
attach actual timing entries and Debug formatter scalars from the retained logs.
The reviewed [timing growth](docs/research/retained-why-exit-timing-growth.md)
now bounds actual cells and whole-suffix timing callbacks by 26, preserves the
64-slot backing and supplies finite update/key/counter bounds. The reviewed
[timing format](docs/research/retained-why-exit-timing-format.md) extends the
private formatter environment to the exact `%f` template. Their limited join
gives 10,099 template data bytes and at most 26 newline requests under the
normal numeric-service premises. Round 40's reviewed
[first-use/control argument](docs/research/retained-why-debug-formatter-control.md)
now attaches the Debug escape formatter's constructor queue, stacks, Buffer and
callbacks up to its first Stats hook. The reviewed
[hook composition](docs/research/retained-why-debug-hook-capacity.md) includes
indentation, callbacks and abandoned prefixes: at most 26,619 output bytes,
684,672 new OCaml requested object bytes and 16,272 caller stack bytes, under
the named source/runtime and normal-service premises. The hook cannot restart;
this does not grant stdout/stderr fresh state or renew any signal/save budget.
Round 41's reviewed [standard control](docs/research/retained-why-standard-formatter-control.md)
fixes stdout/stderr callbacks and settings, including one stderr newline wrapper;
that packet left initial queues/stacks and interrupted arithmetic unattached.
The reviewed
[JSON byte escape](docs/research/retained-why-json-byte-escape.md) supplies fixed
padding and conditional per-string bounds for all 256 byte values. Neither
component establishes the actual global stream or complete output capacity.
Round 42's reviewed [initial-state composition](docs/research/retained-why-standard-initial-state.md)
now supplies both constructor states at the five retained controlled cuts. It
matches the entry premise of the reviewed
[interrupted-core bound](docs/research/retained-why-standard-formatter-core.md),
which accounts for partial flush/enqueue state and later reuse. Actual cumulative
text/event budgets remain unjoined. The reviewed
[disabled-backtrace interface](docs/research/retained-why-disabled-backtrace.md)
includes the asynchronous fixed fallback and conditional per-call request/stack
bounds. The [model-meta attachment](docs/research/retained-why-model-meta-control.md)
reuses the accepted Round 32 proof to exclude that selected diagnostic path.
The reviewed [diagnostic occurrence bounds](docs/research/retained-why-diagnostic-occurrences.md)
now cover whole-suffix attempted reports, one normal/two abort JSON calls and
raw-backtrace n/m/d at most 1/4/1 per process. They join the per-call backtrace
interface without claiming complete diagnostic bytes or global stream capacity.
The reviewed [JSON input formulas](docs/research/retained-why-standard-json-inputs.md)
cover successful and unsuccessful selected results, with actual input identities
and interrupted binding multiplicities. Payload lengths remain symbolic. The
reviewed [exception expansion](docs/research/retained-why-diagnostic-expansion.md)
bounds wrapper depth and failed registry dispatch separately from private layout
and returned strings. Complete server records, logical diagnostic payloads,
private formatter/identifier costs and their standard-output transfer remain.
The reviewed [standard-channel interface](docs/research/retained-why-standard-channel-capacity.md)
bounds offered output and cached-offset arithmetic conditionally. Its initial
checkpoint left channel entry values, descriptor behavior and payload totals
unattached; private save-file assumptions do not cover inherited standard streams.
The [channel-entry attachment](docs/research/retained-why-standard-channel-attachment.md)
now derives P0=0/O0=q at the controlled cuts. A proposed pipe-launcher guard
still requires universal prefix/signal coverage and suffix byte bounds. The
[server-record bound](docs/research/retained-why-server-record-capacity.md)
accounts for abandoned request headers, while actual solver-output sizes and
executable resolution remain open. The
[native buffer-copy bridge](docs/research/retained-why-server-buffer-copy.md)
supplies conditional overlap-safe behavior under exact server/libc binding;
it does not attach the historical server's actual loaded image or complete
its stream-preservation argument.
The [solver inventory](docs/research/retained-solver-identity.md) identifies the
packaged files, commands and driver closures; actual executable/source and
intended concurrent-launch attachment remain open. Candidate-source output
components now cover the [CVC5 response/statistics families](docs/research/retained-cvc5-output-capacity.md),
[Z3 statistics](docs/research/retained-z3-output-capacity.md) and
[Alt-Ergo status data](docs/research/retained-altergo-output-capacity.md).
The [generated-task interface](docs/research/retained-solver-task-language.md)
now bounds selected queries and excludes task option/synthesis commands for the
fixed five-input family. It preserves raw location-filename conditions and two
malformed Float80 templates; it does not establish semantic solver acceptance
or automatic option preservation. The [registry](docs/research/retained-cvc5-registry-domain.md)
and [enum](docs/research/retained-cvc5-enum-output.md) domains compose to a
conditional ordinary CVC5 statistics allowance. Safe bucket counts and complete
warning/error/terminal output remain separate. The
[parallel launcher interface](docs/research/retained-solver-launch-profile.md)
derives fresh-client scheduling/cancellation counts and failure-aware message
bounds, while preserving historical serial evidence and unresolved lookup,
soft-cleanup and parallel-state joins. Complete per-file q and weighted O stay
null. These supporting results do not complete the capacity rule. Round 47 adds
selected CVC5 parser/option preservation and a precise missing repeated-warning
bound, with explicit parser-payload and terminal-state/runtime residuals. The
reviewed interim stop preserves these findings and a prospective, unadopted
quiet-option route now under assessment; it makes no impossibility claim. The
detailed earlier checkpoints above retain their original conditional scopes.
Global output/offsets, diagnostic payload bounds, exposed counters,
ambient/service resources and complete-save integration remain with #153.
Trusted allocator/GC/OS correctness for valid requests remains at the
existing boundary; it does not
replace those caller obligations. At that checkpoint #153 remained In progress;
R78 above closes its scoped interface. Later driver
transforms/printers, solver/server/report transfers and current-grammar
generalization remain separate #119 obligations. All seven #150 follow-ups
have documented resolutions and remain In review pending PR #121's merge.

Capacity restrictions must be established before admission. An admitted program
hitting a build or proof-essential representation limit remains a defect,
distinct from physical resource exhaustion. Optional confirmation cannot waive
automatic discharge. A reporting-only boundary needs an explicit independence
argument before it may be treated as inconclusive confirmation. These rules
replace the former blanket confirmation-only producer-limit classification.

The milestone's work packages retain their production order, with #119's design
before any expanded membership:

1. **Scope and design [#87](https://github.com/berkeleynerd/silver/issues/87):**
   completed historical proposal and corrections; #117 selects the revised route.
2. **Proof confirmation and resource outcomes [#88](https://github.com/berkeleynerd/silver/issues/88):**
   separate build and confirmation, preserve complete success auditing and input
   identity, and classify resource, representation and other failures accurately.
3. **Compiler storage and complexity [#89](https://github.com/berkeleynerd/silver/issues/89):**
   input-sized storage, growable process/file/path interfaces, explicit stack work
   and producer/consumer representation accounting. Adopt the researched native
   invocation with source correspondence, or rederive capacity for the selected
   alternative, as recorded above. Admission stays unchanged.
4. **Parameterized Lean assurance [#90](https://github.com/berkeleynerd/silver/issues/90):**
   exact length ranges and the selected capacity predicate, native correspondence,
   composition and automatic discharge. Admission stays unchanged.
5. **Pinned-tool capacity rules [#91](https://github.com/berkeleynerd/silver/issues/91):**
   complete #119's justified whole-program design, then implement its native/Lean
   rules after #89/#90. A partial component or researched stop does not satisfy
   the adoption dependency.
6. **Remove unnecessary source, operator and expression caps [#92](https://github.com/berkeleynerd/silver/issues/92):**
   admit larger programs after #88–#91, retaining necessary capacity accounting.
7. **String and argument capacity within pinned-tool limits [#93](https://github.com/berkeleynerd/silver/issues/93):**
   generalize values/runtime contracts within the justified #119/#91 domain;
   re-derive dependency/producer bounds after runtime changes. May overlap #92
   only after their shared capacity and assurance prerequisites hold.
8. **Validation, review and delivery [#94](https://github.com/berkeleynerd/silver/issues/94):**
   complete stable native/Lean assurance, outcome/capacity validation, independent
   review and synchronized capability records before claiming support.

#119 resumes the complete capacity-rule derivation. The owner has also authorized
production #88–#94 once the capacity rule is justified. Those packages remain unstarted,
with their dependencies recorded; no further implementation go-ahead is needed.
No external-tool change, Oracle amendment or arbitrary lower cap is selected.
If complete sound capacity coverage cannot be established, report the exact
missing obligation before removing the existing caps; optional confirmation
cannot fill that gap. #89/#90 coordinate source certificates with one proof
workspace writer. New constructs/Rosetta stages are separate, and native macOS
validation remains independent and nonblocking. The milestone remains open.

### Bounded mutable integers

**Complete after review remediation on Linux x86_64, 2026-10-17.**
[PR #86](https://github.com/berkeleynerd/silver/pull/86) delivers the owner's
[authorized repairs](docs/session-memory.md#2026-10-17--bounded-mutable-integers-review-repairs-authorized)
to [review-b79b986403](docs/reviews/review-b79b986403.md). B1 [#77](https://github.com/berkeleynerd/silver/issues/77)
explicitly rejects empty Integer-assignment RHS intervals; M1 [#78](https://github.com/berkeleynerd/silver/issues/78)
connects independent endpoint readings to declared-range semantics. D1–D6
#79–#84 and minor record corrections are complete. The [repair record](docs/review-b79b986403-repairs.md)
separates source/proof/test input commit `78cf419452`, bidirectional source
reviews and the passing native, full-suite and complete cached Lean/source
checkpoint. The original PR #76 delivery and its retained failures below remain
historical evidence. Optional implementation improvements remain deferred;
no next construct is authorized.

The [capability record](docs/bounded-mutable-integers.md) defines the selected narrow
increment under [stage #11](https://github.com/berkeleynerd/silver/issues/11),
driven by [Find square difference](rosetta/f/find-square-difference/silver.md).
An initialized mutable Integer result can receive a loop index and be printed
with Integer Image. Optional object-local static ranges constrain initialization
and assignments; named subtype/type declarations and conversions remain outside
this increment.

The implementation separates exact declaration snapshots from Ada-staticness. Every
executable-body read of a mutable scalar uses its full declared range; neither
assignments nor guards narrow that range. RHS interval inclusion preserves the
target range, loop bounds are captured at entry, and Image lengths use the
current expression interval. Scalar and String writes persist across iterations
and after a loop; only its scoped index is removed. The universal and source arguments passed the repair checkpoint. Image
applicability retains the source-route, fixed-template and native evidence
classes under the documented producer/consumer assumptions.

[Milestone 4](https://github.com/berkeleynerd/silver/milestone/4) contains all
four work packages, recorded together when scoping began:

1. **Scope and automatic-proof design [#67](https://github.com/berkeleynerd/silver/issues/67):**
   complete through the scope proposal, including the driver, exact rules,
   composition, exclusions, assurance boundaries and future evidence plan.
2. **Native admission and regressions [#68](https://github.com/berkeleynerd/silver/issues/68):**
   Complete: selected SPARK rules, language/catalogue agreement, the driver
   sample and boundary/composition regressions. The complete native audit and
   full-suite execution with the focused snapshot repair are finished.
3. **Universal and actual-source assurance [#69](https://github.com/berkeleynerd/silver/issues/69):**
   Complete: mutable-store semantics, membership, finite execution,
   safety/discharge and source correspondence, including the later M1 repair.
   Image applicability retains the evidence classes and producer premises in
   the capability record. The
   [mutable report envelope](docs/bounded-mutable-report-capacity.md) extends the
   source/producer derivation; the old constant-only bound is retained as history.
   Complete native validation and the complete cached Lean build with fresh
   whole-project auditing passed.
4. **Validation, review and delivery [#70](https://github.com/berkeleynerd/silver/issues/70):**
   Complete: independent source review, both low finding repairs, native and
   Lean validation, and full-suite execution supplemented by the focused snapshot
   repair. The capability record distinguishes actual inputs, source-review
   targets, retained failures, the passing affected recheck and cache/workspace
   provenance. Language, catalogue, samples and support records are synchronized.

The owner's [implementation instruction](docs/session-memory.md#2026-10-17--bounded-mutable-integers-implementation-authorized)
selects packages #68–#70 through complete validation, review and delivery;
completion of #67 alone does not complete this milestone. The board carries live
status and coordinated workspace claims. The
[review](docs/reviews/review-bounded-mutable-integers.md) distinguishes the
implementation target, source review and validation evidence. No new Oracle
policy decision is identified.

The delivered Rosetta mapping uses the narrow identifier
`bounded-mutable-integers`: Find square difference is stage 1, position 15, among
35 baseline tasks. The ten remaining stage-2 tasks retain the broad
`integers`, `ranged-subtypes`, `for-loops` and `scalar-image` identifiers under
#11. General mutable arithmetic/refinement, named types/subtypes, conversions,
other loop forms and other scalar images remain outside this increment. Existing
Rosetta sample work #9 is separate, and procedures and arrays remain future
direction. No new harness goal was requested; the earlier goal remains complete.

### Review of For loops and integers

**Implementation and validation complete on Linux x86_64, 2026-10-17**.
[PR #66](https://github.com/berkeleynerd/silver/pull/66) tracks publication. The owner authorized
the recommended remediation of [review-b8f1d0b9a8](docs/reviews/review-b8f1d0b9a8.md)
on 2026-10-16, after the completed milestone below.
[Milestone 3](https://github.com/berkeleynerd/silver/milestone/3) uses the
finding issues as its increments. The [repair record](docs/review-b8f1d0b9a8-repairs.md)
identifies implementation, exact native/Lean/test inputs, cache reuse and
retained failures separately. The completed increments followed this order:

1. **Recognizer and capacity premise:** L1 [#51](https://github.com/berkeleynerd/silver/issues/51),
   native token-boundary counting with its Lean mirror, source correspondence
   and 63/64-boundary regressions. This is prerequisite to further constructs.
2. **Batched evidence and boundary corrections:** L2–L7 #52–#57, L8 under
   existing #31, L9 #58 and L13 #62. Preserve historical evidence, disclose
   actual input/cache scope, correct handoff status and document producer and
   invocation premises. This documentation stream ran alongside L1.
3. **Adapter operations:** L10 #59 and L12 #61, explicit workspace lifetime
   and retention plus useful fail-closed diagnostics, with affected assurance.
4. **Regression coverage:** L14 #63, selected admission/composition cases and
   two native regressions, integrated with the preceding changes.
5. **Separate proof follow-ups:** L11 #60 (internal template spelling/meaning
   determinism and stronger endpoints) and L15 #64 (representative
   kernel-checked recognizer witnesses), with separate focused proof evidence.
6. **Integration:** independent review, complete cached native and Lean audits,
   and focused regressions for the combined changes. The original failed
   full suite and its focused repair remain separate history; no repeated
   complete suite, clean build or independent kernel replay is claimed.

No owner policy decision remains open for this scope. There is no new language
construct, Oracle amendment, mandatory clean/replay run or generic provenance
framework. The previous milestone and its harness completion are not reversed.
Existing open Rosetta/planning suggestions remain separate; procedures receive
a stage issue when selected as a near-term capability. Future review effort
uses candidate consolidation, extra independent checking for blocker claims
or disagreements, and a whole-team cost checkpoint.

### Proof iteration controls

**Complete on 2026-10-16.** The owner's “Make it so” instruction selected one
cohesive tooling milestone before further feature work. Its
[single work package #39](https://github.com/berkeleynerd/silver/issues/39) in
[milestone 2](https://github.com/berkeleynerd/silver/milestone/2) delivers a durable
run ledger, resolved-workspace locks and worker coordination, cheap provenance
preflight, rationale for identical-success expensive reruns, recurring-obligation
diagnostic checkpoints, and resume/handoff readout. The
[record](docs/proof-iteration.md) defines scope and completion criteria.

The common runner controls, native/Lean integration, focused regressions and
independent review are complete. The record identifies the final Linux evidence
and repaired review findings. These are parts of one work package, with no
remaining owner policy decision. Required assurance stays
unchanged; no language construct or Oracle amendment is included. The owner has
now separately resumed the existing For loops and integers goal below.

### For loops and integers

**Complete on Linux x86_64, 2026-10-16.** The
[capability record](docs/for-loops-integers.md) admits immutable signed-32-bit
Integer constants, fully grouped `+`, `-` and `*`, comparisons, scoped
forward/reverse loops and standard Integer `'Image`, including Ada's leading
space. These compose with the existing String, input, path and output rules.
The [delivery evidence](docs/for-loops-integers.md#stable-delivery-evidence)
records the complete cached native audit and build, the retained full-suite
failure with its focused snapshot repair/recheck, and the complete cached Lean
build with a fresh audit. It distinguishes actual input scopes and independent
review; the regression evidence is not one clean passing full-suite run.

The owner resumed this same unfinished goal on 2026-10-16 after the selected
[review repairs](docs/review-343c2f8-repairs.md) and
[proof-iteration controls](docs/proof-iteration.md). The dated
[session memory](docs/session-memory.md) preserves that authorization and its
historical harness-status distinction. The settled [Image decision #34](https://github.com/berkeleynerd/silver/issues/34)
required exact Image-length composition, including valid fixed-length
assignments; the delivered producer/scanner/consumer refinement supplies that
connection without author annotations or source replacement.

[Milestone 1](https://github.com/berkeleynerd/silver/milestone/1) and
[stage #10](https://github.com/berkeleynerd/silver/issues/10) followed this order:

1. [Report capacity and placement #17](https://github.com/berkeleynerd/silver/issues/17):
   the prerequisite source/producer envelope, streaming projection,
   reader/policy correspondence and library-level storage. The
   [scalar/loop/Image extension](docs/report-capacity.md#for-loops-and-integers-extension)
   derives the new retained-report envelope within the existing allocation.
2. [Scope and automatic-proof boundary #13](https://github.com/berkeleynerd/silver/issues/13):
   exact scalar/loop/Image rules, resource bounds, complete composition and
   discharge schemas, producer assumptions and motivating programs.
3. [Native admission and regressions #14](https://github.com/berkeleynerd/silver/issues/14):
   verified SPARK admission/report changes with boundary, failure-path and
   interaction regressions.
4. [Universal and actual-source assurance #15](https://github.com/berkeleynerd/silver/issues/15):
   decidable membership, finite execution/termination, safety/discharge and
   correspondence to authoritative source. Forward producer acceptance and
   exact native refinement/consumer meaning are separate checked connections.
5. [Validation, review and delivery #16](https://github.com/berkeleynerd/silver/issues/16):
   stable native Linux and whole-project Lean evidence, independent review and
   synchronized language/catalogue/samples/Rosetta/capability records.

The motivating programs are the nested triangle, computed step sequence and
reverse countdown. The step example multiplies the index by a constant; it
adds no stride clause. Colour bars/Display remains future file output, based
on its faithful image-file assessment. At that milestone, mutable integers,
custom subtypes, conversions, division and other scalar images were excluded.
The [bounded mutable extension](#bounded-mutable-integers) above now covers the
selected initialized-object and assignment forms; the other exclusions remain.

The coordinated Rosetta delivery supports only `integer-for-loops`,
`immutable-integers` and `integer-image`. Their three reviewed drivers are
baseline stage 1. Broad `for-loops`, `integers` and `scalar-image` remain
unsupported. Remaining scalar/loop forms and ranged subtypes are stage 2 on
[#11](https://github.com/berkeleynerd/silver/issues/11), procedures stage 3 and
arrays stage 4 on [#12](https://github.com/berkeleynerd/silver/issues/12).
The stage fields and issue bodies follow this mapping. Procedures receive a
stage issue when selected as a near-term target. This delivery and stage
movement authorize no later capability.

### Partial Output

**Complete**, authorized and validated on 2026-10-15. `Silver_IO.Put (Item)` joins
`Put_Line`: the same bounded String expressions, name visibility and named actuals,
exact bytes without LF, and a flush on every call including empty output. Detected
failure returns with sticky status 1; later statements continue. Invalid-input
paths still reject without any output call.

This is one milestone with three ordered work packages:

1. **Complete:** SPARK runtime and admission, including matching parser/name
   cases and unchanged Put_Line behavior.
2. **Complete:** universal Lean semantics, discharge and actual-source
   correspondence, exact native report policy, focused regressions and a
   [greeting sample](samples/partial_output.adb). The dense 571-call specimen
   proved, built and ran within existing report capacity.
3. **Complete:** independent source/semantic review, stable Linux native
   proof/build/full tests and complete cached Lean validation. Specification,
   catalogue and evidence are synchronized for the published delivery.

The [delivery record](docs/partial-output.md) gives exact evidence and limits,
including preparatory versus final Lean timings. Source/value limits and
accepted axioms are unchanged. No next capability or replacement harness goal
is automatically authorized.

### Run Arguments

**Complete**, authorized and validated on 2026-10-15. Existing input-dependent
programs now run with `silver run SOURCE -- [arguments...]`, preserving empty
values, spaces, quotes and exact argument boundaries through GNAT's direct
process interface. The no-argument form remains supported. Ordinary application
statuses propagate unchanged; neutral diagnostics reflect that status 1 can
mean Reject, output failure or failed launch.

All three work packages are complete: the process/resource boundary, verified
SPARK copying/cleanup with focused regressions, and Linux validation, review and
delivery. The [delivery record](docs/run-arguments.md) distinguishes the frozen
full-suite pass from the final equivalent-formatter repair and affected recheck,
and records final native/Lean evidence and real application executions.

Language membership, application APIs, source/value limits, report acceptance
and all seventeen Lean source bindings are unchanged. Existing source/proof/build
publication guards remain. No new capability or harness goal is automatically
authorized; preserve caches and unrelated Rosetta/scratch work.

<a id="larger-expressions--proposed-next-unit"></a>
### Larger Expressions

**Complete**, authorized and validated on 2026-10-15. The bounded String-expression
fragment now supports **64 leaves per expression and 63 concatenations per source**
across initialization, assignment, comparison and output. The source-wide budget
is the smallest that accommodates one maximal expression, with the same total
available across expression positions; it was not scaled mechanically from thirty.

All three work packages are complete: composition/capacity selection, matching
native/Lean implementation and regressions, and a stable Linux checkpoint and
delivery. Nine current-runtime probes cover grouping, repeated static/dynamic
references, path guards and dense sequences. The historical argument-shell
specimen proved and fit the buffer with 1.5% measured headroom. The review's
denser static construction left only 0.28–0.29%; timing-dependent prover credits
can exceed that margin. These measurements do not establish universal capacity;
see the [capacity correction](docs/review-343c2f8-repairs.md#report-capacity-correction).
The
[delivery record](docs/larger-expressions.md) gives the measured costs and limits.

Universal membership/composition/discharge and actual-source proofs passed at the
expanded constants. Native proof/build, complete cached Lean validation, all test
methods through the full run plus one test-only repair/recheck, and full GNAT code
generation for the focused differential corpus are complete. The specification,
catalogue and [release-report sample](samples/release_report.adb) agree. The
4096-byte source/value bounds, assignment/literal repairs, report policies and
external-tool premises remain. No new API, Oracle amendment or proof framework
was introduced; no next capability is automatically authorized.

### Known outstanding work

Reconciled on 2026-10-15 against the completed Partial Output, Run Arguments and
Larger Expressions deliveries, earlier handoffs and review dispositions.
Conditional follow-ups are tracked as
[`type: follow-up` issues](https://github.com/berkeleynerd/silver/issues?q=is%3Aissue+is%3Aopen+label%3A%22type%3A+follow-up%22)
on the Silver board; the seven that this table held were filed on 2026-10-15. The
linked records retain detailed findings, reasons and historical scope. Closed or
rejected review suggestions are not new tasks.

New language/API capabilities and release tooling remain direction rather than
follow-ups. Additional argument APIs, broader API placement and resizable
strings need their own motivating scope and assurance. For loops and integers
and the bounded mutable extension are recorded above; further capabilities
remain unselected.
Distribution/provenance and extra provers remain
[deferred until needed](#deferred-until-needed). Hosted CI stays disabled; its
dormant wording is revisited only if reactivation is authorized. macOS validation
remains independent and nonblocking.

Argument forwarding and neutral application-status diagnostics are complete in
[Run Arguments](#run-arguments). The prior kernel-bypass repair, default-runner drift tests, real axiom-audit
regression and branch correspondence guards are complete. The theorem-name
registry was deliberately rejected, historical-language retention is not required
before 1.0, and the Python provenance check is intentionally retained. These are
dispositions, not unfinished milestones.

## Language surface direction

Decided on 2026-10-15. The [Rosetta progression](rosetta/progression.md) is the
short-term plan for filling out Silver's natural surface under the Oracle. It
orders the Rosetta Code candidates whose proofs are likely or plausible to
discharge automatically into stages, each adding the constructs its samples
need, the most widely needed first. Each stage states the admission question for
every construct it adds; a stage that adds an input construct is driven by a
sample that uses that input and names the failure paths to test. A stage is a
candidate for a milestone, not an authorization: each still needs its own scope,
the owner's authorization and the complete assurance in
[development.md](development.md).

The assessments are model judgments, not proofs, and the corpus underrepresents
input handling, failure outcomes, modularity and library design. Once the natural
surface is filled out, reassess networking, parallelism (whose required profile
pragma the Oracle does not permit in program source) and other demanding samples,
and add real-world target programs where Rosetta is thin. The
[Rosetta README](rosetta/README.md) describes the assessments, the inclusion
policy and the supported-construct list.

## Planning and tracking

From 2026-10-15, work items and their status are tracked as GitHub issues on the
Silver board, as described in [planning](docs/planning.md). This roadmap keeps
direction: the milestone sequence, deferrals and the reasons for them. Owner
decisions and authorizations stay dated in the
[session memory](docs/session-memory.md). The
[board](https://github.com/users/berkeleynerd/projects/6) holds the conditional
follow-ups and the near-term progression stages.

## Completion criteria

For each area, enumerate its admitted forms, legal positions and interactions
with the other existing features. Each remaining exclusion must have a concrete
semantic, assurance or resource reason. An unimplemented interaction stays open;
it must not disappear into an unspecified later increment while the area is
called closed. Resource policies, including the current source and output size
bounds, are explicit project choices, not requirements of SPARK's Silver level.
They remain in force until any change is implemented and justified. A proof or
tool failure for already-admitted source remains a defect, not a new exclusion.

Establish decidable admission and universal composition, automatic-discharge and
actual-source correspondence arguments for the resulting fragment. Keep the
specification, catalogue, SPARK implementation, proofs and samples aligned.
Exercise boundaries and feature interactions, including failure paths, then
complete the existing [validation workflow](development.md#proof-loop-and-validation)
before marking an extension supported. This adds no separate approval or release
gate and does not substitute examples for the universal argument.

When a formerly rejected composition becomes supported, replace its rejection
expectation with admission, exact output/exit-status and genuine-report checks.
Retain negative tests for justified exclusions and incomplete verification.

The shared binding, declaration, copy and common-expression foundations are
complete. The authorized sequencing checkpoint incorporates repeated output and
retains the audit's diagnostic, report-capacity and translation constraints.
Declaration-time expressions cannot rely on facts established only by a later
body guard. The earlier unfinished **Repeated Output** draft remains preserved as
history; its proposed four-call cap was rejected. Ordinary returning calls
continue execution, and a detected output failure leaves exit status failed even
if later output succeeds. Predicate/path facts are complete in item 5. Call
associations and context/name closure are complete in Names and Calls.

Loops, additional library APIs, resizable strings and unrelated language
constructs are outside this consolidation. The existing assurance guarantees
remain in force.

## Status and admission

Milestones move through **proposed → in progress → supported**:

- **Proposed:** scope, dependencies, and open decisions are recorded. Example
  source may be shown here, but it is not a supported sample.
- **In progress:** implementation and assurance work has begun. Its new forms
  remain excluded from the supported language until admission is complete.
- **Supported:** the specification, catalogue, compiler, proofs, and validation
  agree; the example and its expected behavior are recorded. Each supported example must have a manifest entry.
  Regression checks pass, and any intentional changes to earlier rules or
  samples are documented as part of the change.

The admission criteria and review steps are in
[development.md](development.md). Each increment should introduce one small,
coherent capability. Closely coupled syntax may arrive together. The dependency
relationships below matter more than forcing every feature into a rigid linear
sequence.

## Milestones

| Milestone | Status | Capability and dependencies | Sample |
| --- | --- | --- | --- |
| Null baseline | Supported | `main_procedure`, `spark_mode_on`, and `null_statement` in the null composition. | [samples/null.adb](samples/null.adb) |
| Faster proof feedback | Supported | Native GNATprove/Lake reuse, configurable workers and explicit full/cold/clean checks; [native platform evidence and remaining costs](docs/proof-workflow.md), with subsequent [Lean concurrency measurements](docs/lean-concurrency.md). No language change; [host readiness](docs/host-readiness.md) records local validation and the owner's decision to disable hosted CI. | Developer workflow |
| Sample collection | Supported | Original null source moved byte-for-byte, with a small [manifest](samples/manifest.json) driving admission/proof/build/run checks. No language change. | [samples/null.adb](samples/null.adb) |
| Literal output / Hello World | Supported | `runtime_context`, `literal_output`, and `string_literal` together: one qualified call, printable ASCII literal, verified wrapper and complete report handling. Final validation is recorded in the [capability record](docs/hello-world.md). | [samples/hello_world.adb](samples/hello_world.adb) |
| Named string constant | Supported | A literal-initialized `constant String`, name binding and output through its identifier. Completed [validation](docs/named-strings.md). | [samples/string_constant.adb](samples/string_constant.adb) |
| Command-line message | Supported | Initialize the constant through `Silver_Arguments.First_Or_Default`, with a mandatory validity guard and rejection branch. Completed [Linux validation](docs/command-line.md). | [samples/command_line.adb](samples/command_line.adb) |
| Literal-backed greeting | Supported | Literal prefix, one reference to a literal-initialized String constant, and literal suffix joined by Ada `&`; combined bounds and completed [validation](docs/greeting.md). | [samples/greeting.adb](samples/greeting.adb) |
| Source-certificate performance | Completed investigation | Both candidates failed to establish a validated improvement; retain the existing representation. [Negative result and evidence](docs/certificate-performance.md). | Developer workflow; no language change |
| Lean source compartmentalization | Supported | Per-file binary dependencies and a verified lexical-helper boundary; [measured cache reuse and full validation](docs/lean-compartmentalization.md). Certificate representation unchanged. | Developer workflow; no language change |
| Focused Lean checks | Supported | Synchronized module targets and scoped fresh auditing; complete routine checks retain caching and source correspondence, with optional replay/provenance. [Validation and limits](docs/lean-iteration.md). | Developer workflow; no language change |
| Guarded command-line greeting | Supported | Dynamic concatenation behind the fixed validity/capacity guard; verified normalization, complete application reports and independent report-policy refinement. [Completed validation](docs/command-line-greeting.md). | [samples/command_line_greeting.adb](samples/command_line_greeting.adb) |
| Fixed-length string assignment | Supported | One literal-initialized variable, one equal-decoded-length literal assignment, then output by the bound name. Completed [Linux validation](docs/string-assignment.md), including full Lean audit and fresh kernel replay. | [samples/string_assignment.adb](samples/string_assignment.adb) |
| Input-dependent branching | Supported | One equality comparison between validated command-line input and a literal, choosing between two terminal literal outputs. [Completed Linux validation](docs/input-branching.md). | [samples/input_branching.adb](samples/input_branching.adb) |
| Compose String Results | Supported | Shared bounded output expressions, repeated static references, tighter safe capacities and one branch-selected fixed-length result; [completed Linux validation](docs/string-results.md). | [samples/composed_result.adb](samples/composed_result.adb) |
| Copy String Values | Supported | Up to two literal-backed constants in mutable shells, named initialization and equal-length copies, with bounded constant output references; [completed Linux validation](docs/copy-values.md). | [samples/copied_result.adb](samples/copied_result.adb) |
| Shared declarations, names and copies | Supported | Ordered initialized bindings, literal/name snapshots, mutability and fixed static/dynamic bounds across the then-existing bodies; [scope and completed validation](docs/shared-bindings.md). Sequencing and context rules are supported below; broader API placement remains separate. | [Shared-binding sample](samples/shared_bindings.adb), native tests and universal/source proofs passed |
| Common String expressions | Supported | Shared bounded expressions in every expression position; [completed validation](docs/common-expressions.md). | [samples/common_expressions.adb](samples/common_expressions.adb) |
| Statement sequencing and assignment | Supported | Nonempty finite sequences, fixed-bound assignments, one-level choices and returning output effects; [validation record and resource follow-up](docs/statement-sequencing.md). | [samples/statement_sequence.adb](samples/statement_sequence.adb) |
| Equality, guards and branches | Supported | Nested conditionals, `elsif`, optional `else`, bounded predicates/integer literals and path-sensitive assignments, output and rejection; [completed 5a–5c validation](docs/branches.md). | [samples/conditional_statements.adb](samples/conditional_statements.adb), [samples/path_guards.adb](samples/path_guards.adb) |
| Names and Calls | Supported | Reordered/grouped/repeated contexts, use-visible calls with local-name hiding, and named `Item`/`Default` actuals for existing operations; [completed validation](docs/names-and-calls.md). | [samples/names_calls.adb](samples/names_calls.adb) |
| For loops and integers | Supported | Immutable signed-32-bit Integer constants, scoped forward/reverse loops, grouped arithmetic, comparisons and standard Integer Image, composed with existing String/path/output rules; [complete delivery evidence](docs/for-loops-integers.md#stable-delivery-evidence). | [Triangle](samples/for_loop_triangle.adb), [computed step](samples/for_loop_step.adb), [countdown](samples/for_loop_countdown.adb) in the coordinated delivery |
| Bounded mutable integers | Supported | Initialized Integer objects with optional object-local static ranges, range-preserving assignments, exact declaration snapshots and captured loop bounds; [completed Linux validation](docs/bounded-mutable-integers.md). | [Find square difference](samples/find_square_difference.adb) |

The output target covers admitted literals and bounded command-line
messages; the text `Hello, world!` receives no special treatment. String literals do not imply support for
additional string-variable forms, arbitrary concatenation, indexing, general arrays, access types, or file
handles. Each additional form needs explicit admission and composition rules.

## Output design and next increments

Hello World originally admitted its context clause, literal, and call as one
coherent capability, without an artificial `runtime_context.adb` step. Sequencing
now also admits an output-capable context whose body contains only null or
assignment statements. The original API is
`Silver_IO.Put_Line`; [Partial Output](#partial-output) adds `Silver_IO.Put`. Both
are implemented in verified SPARK over the existing libc
`putchar` and `fflush` symbols plus GNAT
`__gnat_set_exit_status`. The [review repairs](docs/hello-review-repairs.md)
replace abrupt exit with ordinary status assignment and return. The focused
[runtime experiment](docs/hello-runtime-experiment.md) established the actual
obligation classes before the report checker was extended.

The [language specification](language.md) defines printable ASCII literals,
quote escaping, empty strings, the source bound, exact LF output, detected
failure, and the current permitted compositions. The
[trusted boundary](docs/trusted-boundary.md#literal-output-boundary) defines
external effects and progress. Repeated calls, initialized variables and bounded
common String expressions are now supported. Broader library admission remains
excluded.

The owner authorized the command-line message task below on 2026-10-09.
The review repairs are complete in `251dd85`; named strings are committed in
`2f76b20`. The command-line scope and assurance are recorded in the
[history](docs/roadmap-history.md#hello-world-with-a-command-line-message). A general proof
engine, catalogue framework, or additional output API is not a prerequisite.

The source bridge checks both recognizers and the selected runtime libraries.
Source-certificate replay remains a development cost to measure as these grow.
Preserve caching and independent module scheduling; improve representation when
measurements justify it without weakening source correspondence or kernel checks.
The [greeting record](docs/greeting.md) retains the enlarged certificate's
resource-limit repair and observed replay cost for that follow-up.
The completed [command-line review follow-up](docs/command-line-review-repairs.md)
strengthens the existing Main composition and expression-precedence checks,
regressions and evidence documentation. It adds no admitted forms and does not
authorize another language increment.

## Deferred until needed

Binary attestations, full per-program dependency provenance, additional defenses
for adversarial build environments, and compatibility machinery are deferred.
Revisit them when distributing independently consumed binaries, working in
untrusted/shared environments, or preparing a stable release makes them useful.
They are not prerequisites for Hello World. Existing validation remains in
place; accurate evidence and current language guarantees are still required.

Additional solver cross-checks, alternative kernels such as lean4lean, duplicate
proof developments in Rocq/Isabelle and solver-certificate infrastructure are
deferred. Revisit additional proof tooling only for a demonstrated coverage or
automatic-discharge gap, or when practical use warrants redundancy. No new
prover dependency or Oracle amendment is indicated by the current assessment.

## Recording progress

Each active milestone has a GitHub milestone whose issues carry its work
packages' scope, completion criteria, status and evidence links, as described in
[planning](docs/planning.md). This roadmap records the milestone's purpose,
dependencies, remaining decisions and status changes. When a language capability
becomes supported, update this file, `language.md`, the catalogue and the sample
manifest together, add any construct it completes to the `supported` list in
[rosetta/coverage.json](rosetta/coverage.json), and close its issues. Completed
validation and remaining tool/platform limits are recorded per capability in the
[README's evidence index](README.md#proofs-and-platform-evidence).
Keep proof claims and assumptions in
[docs/assurance.md](docs/assurance.md) and
[docs/trusted-boundary.md](docs/trusted-boundary.md), linking to them here.

Linux is the primary implementation and validation platform. macOS validation
is independent and secondary under the Oracle. Record actual evidence per host.
The owner has disabled GitHub Actions repository-wide and directed local
validation; the retained workflow is dormant and hosted results are not a
required follow-up. On 2026-10-09 the owner added
the [remote repository](https://github.com/berkeleynerd/silver) and authorized
committing outstanding work and pushing the completed history. This publication
does not authorize another language increment.

## History

Completed milestone narratives moved to [docs/roadmap-history.md](docs/roadmap-history.md)
on 2026-10-15. Earlier links to their sections land here:

- <a id="production-solver-allowance--complete"></a>[Production solver allowance — complete](docs/roadmap-history.md#production-solver-allowance--complete)
- <a id="expression-headroom--solver-budget-experiment-complete"></a>[Expression Headroom — solver-budget experiment complete](docs/roadmap-history.md#expression-headroom--solver-budget-experiment-complete)
- <a id="admission-repairs--complete"></a>[Admission Repairs — complete](docs/roadmap-history.md#admission-repairs--complete)
- <a id="focused-source-checks--complete"></a>[Focused Source Checks — complete](docs/roadmap-history.md#focused-source-checks--complete)
- <a id="names-and-calls--complete"></a>[Names and Calls — complete](docs/roadmap-history.md#names-and-calls--complete)
- <a id="branch-review-repair--complete"></a>[Branch review repair — complete](docs/roadmap-history.md#branch-review-repair--complete)
- <a id="completed-foundation-work"></a>[Completed foundation work](docs/roadmap-history.md#completed-foundation-work)
- <a id="lean-critical-path"></a>[Lean Critical Path](docs/roadmap-history.md#lean-critical-path)
- <a id="existing-feature-consolidation"></a>[Existing-feature consolidation](docs/roadmap-history.md#existing-feature-consolidation)
- <a id="equality-guards-and-branches-increments"></a>[Equality, guards and branches increments](docs/roadmap-history.md#equality-guards-and-branches-increments)
- <a id="audit-follow-ups"></a>[Audit follow-ups](docs/roadmap-history.md#audit-follow-ups)
- <a id="completed-increments-and-validation-cadence"></a>[Completed increments and validation cadence](docs/roadmap-history.md#completed-increments-and-validation-cadence)
- <a id="input-dependent-branching"></a>[Input-dependent branching](docs/roadmap-history.md#input-dependent-branching)
- <a id="generalizing-the-existing-features"></a>[Generalizing the existing features](docs/roadmap-history.md#generalizing-the-existing-features)
- <a id="next-goals-after-the-greeting-review"></a>[Next goals after the greeting review](docs/roadmap-history.md#next-goals-after-the-greeting-review)
- <a id="bounded-source-certificate-performance"></a>[Bounded source-certificate performance](docs/roadmap-history.md#bounded-source-certificate-performance)
- <a id="guarded-command-line-greeting"></a>[Guarded command-line greeting](docs/roadmap-history.md#guarded-command-line-greeting)
- <a id="hello-world-with-a-command-line-message"></a>[Hello World with a command-line message](docs/roadmap-history.md#hello-world-with-a-command-line-message)
- <a id="literal-backed-greeting"></a>[Literal-backed greeting](docs/roadmap-history.md#literal-backed-greeting)
- <a id="completed-report-policy-follow-up"></a>[Completed report-policy follow-up](docs/roadmap-history.md#completed-report-policy-follow-up)
