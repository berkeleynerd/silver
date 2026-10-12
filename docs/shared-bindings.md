# Declarations, names and copies

Status: supported. The owner authorized this roadmap unit on 2026-10-12, based
on `640d5cce9d`. Its complete Linux native/Lean checkpoint and independent review
passed. The implementation/review target is the commit introducing
[samples/shared_bindings.adb](../samples/shared_bindings.adb).

## Scope

Replace fixed declaration slots with a finite ordered environment of initialized
String constants and mutable objects. Initializers are literals or earlier
initialized names; a copy captures its value immediately. Names remain unique
ignoring ASCII case. Assignment preserves mutability and the object's fixed
bounds, including copies of the sole dynamic argument-length value. Self-copy
is legal. An assignment target need not appear in the output.

Existing terminal-output/control-flow arrangements remain: direct output, one
assignment then output, guarded argument output, equality-selected output, and
one branch-selected assignment target then common output. Existing flat output
expressions retain 16 operands and at most one dynamic occurrence, counting
aliases. One immutable First_Or_Default binding remains first and unique.
General sequencing, repeated output, expression initializers, parentheses,
broader branching, context ordering/grouping and new APIs are deferred.

Binding storage is derived from the complete 4096-byte source bound: the
shortest copied declaration `A:String:=B;` consumes 12 bytes. The native array
holds `4096 / 12` entries; this is not an independently imposed declaration cap.

## Working evidence

`tmp/shared-bindings-active.json` identifies the task directory, starting commit,
latest validated cache seed and isolated model workspace. The task directory is
`.silver/linux-x86_64/shared-bindings-20261012T181220Z/`. Its `preserved-before/`
retains the former canonical Lean cache, prior native state and the exact
unfinished repeated-output source/patch. The active cache was seeded from the
checked restrictions-audit snapshot. No evidence or cache was discarded.

Focused native discovery lives separately under
`.silver/linux-x86_64/shared-bindings-probes/20261012T181220Z/`. The report policy
admits proved range/length checks and exact initializer advisories; only
assignment-bearing forms permit `unused assignment`. General warning acceptance
and repeated-output ghost advisories remain excluded. Probe results do not
establish the required universal argument.

## Assurance and verification

`Bindings` gives declarations independent bounds and value stores. Initializers
see earlier bindings; copies capture bytes immediately. Assignments preserve the
target's bound and every other cell. `ComposeDeclarations` and `ComposeGrammar`
derive those declarations and resolved references from admitted source;
`ComposeDecode` proves the resulting program valid. `ComposeExecution` renders
the same eight source shells and interprets their ordered initialization,
assignment, guard, branch and terminal-output behavior.

`ComposeExpressions` supplies typed interpretations of the actual recognizer
bodies, with checked scope and precedence. Source facts in `ComposeSourceChecks`
check the authoritative tokens, declarations, helper refinements and finite
catalogue. The bounded native array corresponds to a one-based active prefix:
lookup reads only initialized entries, and extension appends exactly one entry.
`ComposeEquations` proves helper meanings; `ComposeRecognitionEquations` assembles
complete recognition and both report selectors. `ComposeSourceBridge` connects
these results to Main execution and `Current`'s conditional completion theorem.

The obligation stream includes both concatenation range schemas and exact
fixed/symbolic length schemas for initialization and assignment. Precise report
policies accept proved range/length checks, classify initializer advisories for
all output forms, and allow the exact unused-assignment advisory only for
assignment-bearing forms. Required library evidence is unchanged. Faithful,
complete obligation generation and pinned solver completion remain explicit
tool premises; native success does not establish a universal solver-step bound.

Validation runs on Linux x86-64, with 12 available CPUs and about 31 GiB RAM.
The owner's available physical RAM is distinct from the sandbox allocation.
The complete compiler audit passed: 2,521 checks, comprising 435 flow and 2,086
proof checks across 17 units and 229 entities, with 53 classified limitation
notes and 14 imports. The reduced count follows replacement of slot-specific
recognition with shared binding rules. The current input/report provenance was
rechecked successfully after proof integration; these are complete warm-cache
results, not a cold-run measurement.

Native build and catalogue equality passed. The full suite exercised 240 test
methods in 1,247.541 seconds. Four failing subcases were confined to two methods:
two obsolete rejection expectations and two stale source-certificate fixtures.
After updating those expectations and regenerated fixtures, both affected methods
passed focused reruns in 0.948 seconds. Thus every method passed across the full
run plus focused repairs; the initial full invocation itself was not clean.
The original failure log and repair evidence are preserved. Nine new binding
tests and 67 focused report/evidence tests also passed.

Native discovery proved 20 cases, built 14 programs and checked 58 exact
executions. Three discovery-only guarded assignments were outside the retained
Silver body shapes and informed report classes only. Permanent tests exercise
the admitted selected-result forms, including emitted length checks. A dense
4096-byte source produced 268 initializer advisories and a 102,797-byte Main
report; this observation is not a universal report-size bound.

The two changed source certificates passed; the body took 1,011 seconds and
the specification 154 seconds, scheduled concurrently. Focused semantic,
obligation, recognizer-equation and example checks passed with standard axioms.
The complete integrated Lean build and fresh whole-project coverage/axiom audit
passed for all 114 modules and 32,329 declarations, using only `propext`,
`Classical.choice` and `Quot.sound`. The final integrated cached invocation took
775.811 seconds, including 764 seconds for the new source facts and 3.229 seconds
for the fresh audit; earlier certificate/model work was reused. This is not a
cold-build timing. Optional independent replay and macOS validation were not requested.

## Review and evidence

Independent reviews found no material semantic, report-policy or actual-source
mismatch. They checked snapshot separation, case-insensitive resolution,
mutability, dynamic aliases, source/name correspondence, active-prefix array
reads, exact helper contracts, report routing and the external tool premises.
Review prompted explicit name-resolution facts for assignment targets and guards.
Documentation module attributions and historical solver-margin wording were
corrected. The source-check conjunctions were split into individual checked
facts, reusing the checked scope/precedence theorems; their propositions are
unchanged. The complete integration check and final evidence review passed.

The task directory preserves `native-full-proof.log`, `native-evidence-recheck.log`,
source-certificate and complete Lean logs, semantic/equation evidence, independent
review reports and input hashes. The separate probe directory preserves the
native cases, reports, exact-output results and full/focused test logs.
The original memory-heavy source-check attempt and all completed objects remain
available; the completed canonical cache at `.silver/linux-x86_64/proof/`
merges successful artifacts with all sidecars and Lake metadata. The exact
complete-run input digest is `23fbc9fc69a61eeede9046750849589efb4410248ff3506103483472e4f36393`;
`lean-complete-evidence.json`, `native-proof-provenance.json` and
`final-inputs.json` retain detailed input attribution. No old evidence, toolchain or scratch was deleted.

## Remaining scope

The next proposed unit is the common String-expression judgment across
initialization, assignment, comparison and output, with intermediate bounds and
justified capacity. Context/name visibility closure remains paired with the
existing argument-operation work. Sequencing and repeated output remain later
items; the preserved unfinished draft is not current support.
