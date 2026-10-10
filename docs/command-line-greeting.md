# Guarded command-line greeting

This capability is **supported** after complete native Linux validation. It
introduced the sixth production; [language.md](../language.md) defines the
current admitted language.
The [roadmap](../roadmap.md#guarded-command-line-greeting) records its authorization
and completion conditions. The Oracle is unchanged.

## Scope and design

The sixth production combines the existing command-line initializer with one
literal-prefix, bound-name, literal-suffix concatenation. Its fixed condition is
`Silver_Arguments.Input_Is_Valid and then Name'Length <= capacity`. Both name
references bind to the declared constant, ignoring ASCII case. Membership requires
`capacity + decoded_prefix_length + decoded_suffix_length = 4096`.

The capacity is canonical decimal: `0` or a nonzero digit followed by decimal
digits. Signs, leading zeroes, underscores, exponents, based literals and source
arithmetic are excluded. Only this use of `'Length`, `<=` and `and then` is
introduced. The guard precedes both concatenations and the false branch calls
`Silver_Arguments.Reject`. No general expression or conditional is admitted.

Successful input produces the exact decorations and selected value followed by
LF. An explicitly empty argument produces the decorations; missing input selects
the default. Invalid input, extra arguments or a value exceeding the remaining
capacity produce no application output and status 1. Existing output failure
semantics and external assumptions remain.

## Obligation investigation

Native Linux ARM64 experiments use copied source and the pinned GNAT/GNATprove
configuration under `.silver/linux-aarch64/guarded-greeting-experiment/`. They
preserve the application source and record proof reports, builds and execution
results separately. These exploratory results are distinct from the completed integrated
validation recorded below.

The ordinary sample generates genuine Main range checks. The original runtime
contract proves printable bytes and length at most 4096 but does not constrain
String's lower bound. With an empty prefix, GNATprove cannot discharge an upper
bound check from that contract. Runtime success alone does not resolve this
proof failure.

The integrated runtime repair uses extended returns of `String (1 .. Item'Length)` and
proves `First_Or_Default'Result'First = 1`. The returned bytes and existing failure
semantics are preserved. This establishes the needed fact in Silver-owned SPARK
code; it adds no external assumption about GNAT's returned bounds. The focused
empty-prefix proof, including the strengthened owned contract, passes.

The final argument covers the full admitted literal/identifier/layout
class, both concatenation results, argument lengths and the effect-domain bound.
The application report policy audits every actual check without demanding a
fixed historical count: optimization can eliminate checks for empty operands.
The existing strict empty-report route remains for the earlier five productions.

## Development evidence

The normalized runtime experiment completed 15 native proof/build projects and
150 execution checks, with retained immutable inputs in the experiment directory.
Three additional projects confirmed GNAT preserves Main's source spelling in
report entity names. The application policy therefore accepts exactly the four
ASCII letters of Main without case distinctions; selected library entity names
remain exact. Generated Main range-check counts vary with optimization.

The draft recognizer's focused native SPARK run proved all 909 checks. Its only
subsequent source change at that checkpoint was a comment clarification; final
integrated validation still had to cover the actual final bytes. The seven core
Guarded Lean modules and Current integration checked individually. At that stage
these were development checks; the full source-correspondence/axiom/kernel replay
was still pending.

An independent subthread reviewed the draft driver, runtime normalization,
catalogue, specification and tests without finding a blocker. It also checked
the independent report-policy specification and exercised the native checker on
90 genuine reports and 45 mutations of actual Main records. The report package
completed its focused proof: all 856 checks passed, as did its 22 native tests.
Independent review of recognition found no disagreements across 4,731 generated
cases, and all 82 admitted native Ada legality probes compiled. These probes
do not establish universal source or producer completeness.

The exact eight recognizer/runtime source-shape pins were independently compared
with the selected source and reviewed alongside their semantic changes. The new
recursive-equation interpretation has a concrete consistency witness. Its typed
Main model renders exactly to the admitted token sequence and consumes the
parser events in source order; the checked guard and output cannot silently
exchange their references, operands or branches. Full authoritative certificate
replay was still required at that stage; its completed results follow below.

## Assurance and integrated validation

The report checker now has independent Static ghost byte-traversal and report
policies. SPARK proves exact equality between executable acceptance and the
runtime/application specifications, covering both sound acceptance and rejection
relative to those bounded policies. The specifications share elementary scalar
predicates and vocabulary with the implementation; their traversal, field,
record, dependency and coverage definitions do not call the executable checker.
This establishes functional refinement, not report authenticity or a proof of
GNATprove's obligation producer.

Lean proves the guarded language's membership, meaning, bounds and outcome
properties. Every generated mathematical range schema refines one of two uniform
bounded schemas, and a terminating decision procedure proves their validity.
The external-tool contract still assumes complete faithful GNATprove generation
and completion of the pinned solvers on the concrete arithmetic fragment. Lean
does not prove CVC5, Z3 or Alt-Ergo complete within their configured 10,000 steps.
Actual compilation requires every emitted check to be proved and all required
coverage and library reports to pass. See the exact
[assurance argument](assurance.md#guarded-command-line-concatenation) and
[trusted boundary](trusted-boundary.md).

The bounded performance investigation ended with no adopted candidate in
`5668806`; see [its record](certificate-performance.md). Feature integration uses
the original certificate representation and generator. Bootstrap refreshed the
selected runtime-source binding before compiler validation.

Completed native Linux validation is retained under
`.silver/linux-aarch64/guarded-greeting-validation/`. This contains the compiler
input identities, phase logs and timings. The first Lean attempt was explicitly
stopped after discovering that Lake's cached configuration ignored a newly
requested memory threshold. Its partial artifacts and interruption record are
retained; it is not successful validation. The repaired runner re-elaborates
Lake configuration while retaining unchanged proof objects. Twenty focused Lean
evidence/source tests pass, including a real-Lake resource regression; removing
the fix makes its negative control fail. That restarted full replay requested one
thread and a 6144-MiB internally checked resident-memory threshold per Lean
build/audit process. Lean's `-M` threshold is neither cumulative allocations nor
a hard OS limit or aggregate limit across processes. The separate pinned
`leanchecker` has no memory-limit CLI option. This was the production validation
setting, separate from the performance trials' 4096-MiB budget; subsequent
[concurrency tuning](lean-concurrency.md) changed the runner's thread defaults.

The first full compiler audit encountered the previously recorded external
`value expected (got DOC_END)` failure while processing unchanged
`silver_reports.adb`. Its reports and logs are retained under
`initial-gnat-json-reader-failure/`; it supplies no successful audit. A manually
selected cold audit uses separate proof/session/cache state under
`compiler/obj/cold-wcapt8_3/gnatprove/`. Its producer proved 2616 checks, but
the strict auditor rejected eight arithmetic-reassociation warnings in the new
report specification. Explicit parentheses preserve the existing association
and remove those diagnostics; the auditor admits no new warning exemptions.
That failed audit and the pre-repair source are retained under
`cold-warning-audit-failure/`.

A manually selected full audit with copied sessions and the ordinary solver
cache then hit `DOC_END` in three units. Its distinct failure is retained under
`reused-final-gnat-json-reader-failure/`. Final validation therefore uses a fresh
cold workspace on the repaired source. These comparisons do not establish the
crash's root cause or repair warm state. The final cold audit passed all 2616 checks (383 flow and 2233 proof),
with complete provenance and coverage for 16 units and 203 entities. It took
480.657 seconds, using four workers and wholly fresh session/cache state. The
manifest is `compiler/obj/cold-tline0db/gnatprove/proof-provenance.json` under the
Linux host directory. The build passed in 1.013 seconds.

The first complete suite reached all 139 tests but failed in the platform
fixture's old expected Lake command: it lacked `--reconfigure`. Eleven failures
(including nested fixture repetitions) share that one expectation. The fixture
now explicitly requires both `--rehash` and `--reconfigure`; the original log is
retained under `platform-fixture-reconfiguration-failure/`. The corrected full
suite passed **139 of 139 tests** in 211.389 seconds, including every manifest
sample, the guarded boundary/failure cases, real resource-option/cache checks,
report mutations and all platform fixtures. All 2389 completed compiler-audit
input hashes still match after the tests.

`native-validation-summary.json` and `native-validation.json` retain the exact
phase commands, results and identities alongside `prove-cold-final.log`,
`build.log` and `test-final.log`. Lean's final source-correspondence, axiom and
fresh-kernel outcomes are recorded below.

The source build completed all 79 Lake jobs, including every actual-source
bridge. The enlarged output-body certificate took 2720 seconds; the freshly
executed axiom audit accepted 19993 declarations using only `propext`,
`Classical.choice` and `Quot.sound`. Because the report-source parentheses changed
after that invocation captured all source hashes, its orchestration was stopped
after building and auditing, at the start of the kernel phase. Its complete
module objects are ordinary valid cache entries. Logs and the explicit stop
record are retained under `superseded-input-*`. A new full invocation captures
all final bytes and reuses those modules before its fresh kernel recheck; the
superseded invocation is not claimed as completed full evidence.

At this local validation checkpoint, native macOS validation of this increment
was pending, independent and nonblocking. Earlier macOS evidence validates the
five-form baseline only. This record includes no hosted CI, x86-64 or GNAT Pro
run. See the [session memory](session-memory.md) and [handoff](../RESUME.md) for
subsequent publication and CI status. The Oracle is unchanged.

## Completed Lean evidence and handoff

The final full invocation passed on the final source snapshot in 491.574 seconds.
It reused the completed module objects, executed the axiom audit afresh and
passed `leanchecker --fresh Silver.Audit`. This is cached full validation, not a
clean rebuild. The environment contains 68 project modules and 19993 audited
project declarations, using only the approved standard foundations. The evidence
records 93 source/script inputs, 70 workspace inputs, 136 compiled proof artifacts
and three pinned tool identities. All ten regenerated certificates match the
checked-in candidates byte for byte.

The retained `lean-final-evidence.json` SHA256 is
`2bad3e9652576f9fdf55e0315391450dc2293afe2a14cb52ce2c0e07e0ea1f5a`.
The completed compiler provenance SHA256 is
`badd800964e10c44779f6c9298d9f4e37d58b102434d39e646bb256664cd60a1`.
Matching logs, native phase results, failed/interrupted attempts, review records
and final hash comparisons are in the host-local validation directory. These
identify local evidence; they do not attest a distributed compiler binary.

Independent review covered the recognizer and source pins, arbitrary-callee
bridge and typed Main meaning, runtime normalization, report-policy refinement,
metadata/sample/test consistency, external-tool premises, and the resource-option
repair. It found no remaining blocking issue. Root review also compared every
final report-parenthesis and platform-fixture change with its preserved failing
input. `reviewed-current-code.json` and `review-summary.json` retain scope and
identities. Their pending-validation notes describe the earlier review checkpoint;
`final-artifact-verification.json` confirms all reviewed-code, compiler and Lean
identities against the completed final evidence, with no discrepancies.

The bounded performance unit is committed separately as `5668806`. The feature
implementation and external-review target is the commit adding the supported
`samples/command_line_greeting.adb` and this completed record. All implementation,
proof, catalogue, sample, test and documentation changes belong to that unit.
No further language expansion is authorized by completion of this goal.

## External review disposition

The external review covered `da0a76e..b8b263d`, with `b8b263d` identifying the
original reviewed endpoint before migration-archive history cleanup. The feature
implementation and review target remains `96b4e3a`. Independent assessment of
the supplied findings and current source found no surviving blocking, high- or
medium-severity defect. This documentation follow-up changes no guarantee,
language rule, implementation or proof.

Five wording clarifications were accepted:

1. Current Lean runner defaults use available CPUs for both Lake workers and
   per-process threads. The earlier one-thread setting and lack of concurrency
   measurements describe historical checkpoints; the
   [concurrency record](lean-concurrency.md) supplies the later measurements.
2. Lean's `-M` option is an internally checked per-process resident-memory
   threshold in MiB, not a cumulative allocation budget, hard OS limit or bound
   on the combined memory of concurrent processes.
3. Direct Lake invocations can retain the last cached configuration. The
   one-thread fallback applies only to fresh configuration elaboration without
   an override; the supported runner reconfigures Lake on each invocation.
4. The guarded form concatenates a runtime argument value. Its predefined Ada
   String concatenation and index semantics remain frontend premises; references
   to static evaluation concern the separate literal-backed form.
5. The consolidated [trusted-boundary table](trusted-boundary.md#trusted-computing-base)
   now makes faithful, complete obligation generation and bounded-fragment
   solver completion explicit. These premises already appear in the detailed
   assurance argument and `Current.ToolContract`; this is a visibility correction,
   not a newly introduced assumption or a claim of arbitrary-SPARK completeness.

The reviewer reported source-size variation probes reaching up to 988 of the
configured 10,000 solver steps at the 4096-byte source bound. Those are externally
reported sample measurements, not a universal completion bound. Lean proves the
mathematical range schemas and finite checker, while completion of the concrete
pinned solvers remains an explicit external-tool premise. The review's raw
temporary logs are unavailable in this checkout, so these measurements have not
been independently corroborated here.

The reviewer also reported optional native macOS validation: 2616 compiler
checks, 144 tests and 19993 Lean declarations, with fresh axiom auditing and
kernel checking, about 11.2 GB memory use and no swap. These are attributed
external results, distinct from the retained Linux evidence above. Their raw
logs are unavailable here. Obtaining or corroborating those macOS logs is
optional and is not a pending requirement for this Linux work.

Additional routing assertions, layout regression cases and an exact-sample
meaning theorem are deferred because the assessment found no demonstrated
correctness gap requiring them. Existing generic `member_has_meaning` and
`meaning_unique` proofs already cover every admitted source; connecting the
checked-in sample to one explicit program would add regression coverage, not a
new universal guarantee. The reported 29-minute example-proof cost does not
justify adding it now. No stack rewrite, certificate redesign, additional prover
or language expansion follows from this review. No next feature is selected.
