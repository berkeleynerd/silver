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

**First priority: Lean Critical Path**, followed by closure of the existing
language features. On 2026-10-12 the owner requested placing all recommended
performance work at the beginning of the roadmap. These are proposed bounded
investigations and integration tasks; this planning instruction does not start
experiments, migrate proofs or change the supported language.

### Lean Critical Path

The [latest completed desktop checkpoint](docs/copy-values.md#physical-linux-checkpoint)
spent 6,010 of 6,234 seconds in `OutputBodyCertificate`; ten unrelated
certificates stayed cached and the fresh axiom audit took 1.36 seconds. These
are retained physical-host measurements, not timings for the current sandbox
or its unfinished proof edit. The generated reconstruction is the first target;
module visibility can separately reduce unnecessary rebuilds after proof edits.

| Order | Work item | Bounded result |
| --- | --- | --- |
| 1 | Baseline and declaration-level profiling | Freeze representative inputs and record the actual host, tool versions, settings and cache state. Measure no-change, proof-only-edit and representative feature-edit feedback separately. Profile the dominant certificate's leaf checks, reconstruction joins, final source equality and token flattening; distinguish elaboration, kernel work and build overhead where the profiler permits. Rank time and memory costs. |
| 2 | Source reconstruction and equality proofs | Test a monitored retry of the existing structural/authoritative-decoding candidate, using an explicit memory budget and host-headroom cutoff. Compare targeted conversion equalities, reusable lemmas and shared reconstruction data against the unchanged baseline. Preserve exact authoritative bytes, including line endings and final newline. Splitting generated files is useful only if final composition also becomes cheaper. |
| 3 | Module-system and dependency pilot | Migrate a small compatible dependency closure to Lean's opt-in module system. Measure downstream reuse after private/proof-only edits and necessary invalidation after public/source-byte edits. Choose imports and public interfaces deliberately; expose computational bodies where correspondence proofs require reduction. Retain the legacy audit initially or prove equivalent full private/transitive coverage with `import all`. Adopt only demonstrated improvements before considering wider migration. |
| 4 | Selective proof-authoring improvements | At measured hotspots, use named intermediate equalities, tight theorem interfaces and restricted successful `simp`/`grind` scripts; add auxiliary lemmas only where they reduce duplicated work. Separately measure repeated AI/editor elaboration and pilot persistent editor/REPL proof-state reuse if it is material. Integrate successful proofs into ordinary source files and validate them normally. |
| 5 | Integration and measurement | Compare successful uninstrumented runs on identical inputs and the same host; separate cached iteration, changed-source checking and any cold-build measurement. Check source-edit invalidation and axiom/module coverage, then complete one stable local checkpoint for adopted changes. Record gains, memory costs and failed candidates; conclude the bounded investigation and continue feature consolidation. |

The [earlier reconstruction trials](docs/certificate-performance.md) remain
failed/interrupted experiments, not speedup evidence. Their memory constraints
justify a measured retry, not automatic adoption. The 2026-10-12 isolated module
probe on pinned Lean 4.34.1 confirmed proof-only invalidation savings, but also
showed that ordinary module imports can hide unused private declarations from
the audit; `import all` restored detection. The existing legacy audit rejected
the private-axiom control. Retain that coverage during any migration.

**10× faster feature feedback is a stretch target.** It is not a promised gain
or a requirement to reject smaller useful improvements. With other costs held
fixed, the retained timings imply roughly 15× faster certificate checking for
10× faster Lean checkpoints; whole-development turnaround needs its own
measurement. Keep theorem statements, accepted axioms, source correspondence
and complete obligation discharge unchanged during performance comparisons.

Lean 4.34.1, cached project artifacts, per-source dependencies, focused checks,
parallel workers and optional separate replay are already in use; preserve them.
Broad `SymM`/`vcgen` migration is deferred until a measured symbolic-execution
hotspot warrants it. `native_decide` and ordinary `bv_decide` do not preserve the
current axiom boundary. Blanket opacity or lower heartbeat limits are not
general speedups. Keep GitHub Actions disabled and validation local; macOS
proof work remains outside this sequence.

### Existing-feature consolidation

**Next: close the existing features under composition.** On 2026-10-12
the owner asked to revisit the implemented capabilities, maximize their useful
scope within the Oracle's automatic Bronze/Silver guarantee, and put this work
ahead of further isolated feature increments. The
[current assessment](docs/language-generalization.md) records the inventory,
restrictions and implementation implications.

Here, **closed** means that a feature works throughout an explicitly specified
fragment of the existing constructs, wherever the shared binding, initialization,
length, control-flow and effect rules permit it. It does not mean support for all
Ada/SPARK or a claim to recognize every program that an external prover might
prove. A completed narrow milestone is not evidence of that broader closure.
The existing language retains its assurance; the extensions below are targets,
not newly admitted syntax.

| Order | Work item | Required result before calling the area closed |
| --- | --- | --- |
| 1 | Restrictions and capacity audit | Account for every existing construct and restriction. Distinguish semantic requirements, library contracts, resource limits and staging choices. Resolve catalogue inconsistencies; measure dense source, proof-report and translation cases needed by the broader fragment. |
| 2 | Declarations, names and copies | Shared binding rules for finite declaration lists, initialized constants and mutable objects, and copies from earlier initialized values. Track case-insensitive uniqueness, mutability, value snapshots and fixed bounds; remove the incidental one-variable/two-constant slot restrictions. |
| 3 | String expressions | One expression judgment for literals, names, concatenation and parentheses in initialization, assignment, comparison and output. Count repeated static and dynamic occurrences and prove every intermediate bound. Resolve the sixteen-operand limit through explicit capacity evidence, not an unexplained replacement threshold. |
| 4 | Statement sequencing and assignment | Finite sequences of the admitted null, assignment, output and conditional statements. Compatible expression assignments, multiple initialized objects and self-copy work wherever state rules permit; preserve initialized reads and each target's fixed bounds. Classify harmless diagnostics precisely without suppressing safety obligations. |
| 5 | Equality, guards and branches | Specify the supported String-equality and validity/length predicate grammar and its Boolean compositions. Admit finite nested conditionals under shared rules; propagate path facts and establish initialization and bounds at joins instead of enumerating whole-program arrangements. |
| 6 | Output effects | Compose output in those sequences and branches, including repeated calls and output interleaved with assignments. Prove the cumulative trace and continued attempts after returning failures, with sticky failure status. Derive size bounds from the actual sequence and per-call contract; no separate four-call limit. |
| 7 | Existing argument operations | Compose the existing initialization, validity and rejection operations with those declarations, expressions and statements. Make required validity facts and rejection effects explicit; preserve actual returning-call semantics and the specified argument domain. New positional-argument APIs are a separate capability. |

These are dependency priorities, not seven isolated implementations. Shared
declaration, expression and statement rules should replace the need to enumerate
another complete-program template for every combination. Develop coupled rows
together where their interactions require it. Build reusable binding,
expression, statement and effect theorem interfaces as these foundations are
implemented; measure their reduction in proof duplication and feature-edit work.
This carries the shared-rule performance recommendation into the language work
without a separate core-language or proof-framework redesign. Literals,
escaping, comments, whitespace and case-insensitive names already vary throughout their declared
lexical domain; preserve that coverage in the generalized grammar.

### Completion criteria

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

After the bounded performance investigation, the first consolidation work is to
make the shared fragment and restriction inventory concrete, investigate its
tool/report capacity, and implement the
necessary binding and expression foundations. The earlier **Repeated Output**
instruction is incorporated into sequencing and effect composition; its partial
unvalidated implementation is not a completed capability. The proposed four-call
cap was rejected. Ordinary returning calls continue execution, and a detected
output failure leaves exit status failed even if later output succeeds.

Loops, additional library APIs, resizable strings and unrelated language
constructs are outside this consolidation. The Oracle remains unchanged.

### Completed increments and validation cadence

[Input-dependent branching](docs/input-branching.md),
[Compose String Results](docs/string-results.md) and
[Copy String Values](docs/copy-values.md) passed their complete Linux checkpoints.
Their supported scopes remain those in [language.md](language.md); the historical
milestones below do not imply full closure of their underlying features.

The [source compartmentalization](docs/lean-compartmentalization.md) and
[focused Lean runner](docs/lean-iteration.md) are complete. Use focused checks
during development and batch complete source-correspondence checks at stable
checkpoints, preserving caches and running inputs. Optional independent replay
and further certificate infrastructure are not prerequisites for this work.

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

The output target covers admitted literals and bounded command-line
messages; the text `Hello, world!` receives no special treatment. String literals do not imply support for
additional string-variable forms, arbitrary concatenation, indexing, general arrays, access types, or file
handles. Each additional form needs explicit admission and composition rules.

## Input-dependent branching

**Supported**, following owner authorization on 2026-10-10.
The [capability record](docs/input-branching.md) records the obligation experiment,
implementation, source correspondence and completed full Linux validation:

```ada
with Silver_IO;
with Silver_Arguments;

procedure Main is
   pragma SPARK_Mode (On);

   Mode : constant String :=
     Silver_Arguments.First_Or_Default ("brief");
begin
   if Silver_Arguments.Input_Is_Valid then
      if Mode = "verbose" then
         Silver_IO.Put_Line ("Silver is ready. Input validation succeeded.");
      else
         Silver_IO.Put_Line ("Ready.");
      end if;
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

Admit one immutable command-line String using the existing missing/default,
empty-input, printable-byte and size rules. Inside the mandatory validity
guard, compare the bound name to an admitted literal with predefined String
`=` and select exactly one of two literal-output branches. Comparison is
case-sensitive byte equality; identifier binding remains case-insensitive.
The default, comparison literal and output literals vary over the existing
domain, rather than assigning special meaning to `brief` or `verbose`.
Unequal-length operands simply compare false. Invalid input still reaches the
terminal rejection branch, and each successful path makes one terminal output
call with the existing failure semantics.

This added runtime choice without a new library API. Branch assignments are now
supported by the separate composed-result shell above. General Boolean expressions,
additional decision nesting, multiple outputs and arbitrary statement sequences
remain outside the language. A focused native obligation
experiment covered empty strings, unequal lengths, case differences and
maximum-size sources and confirmed the strict empty-Main report policy. Exact
membership, branch meaning, binding, complete obligation handling and actual
source correspondence passed the full Linux checkpoint. Existing caches and
evidence were preserved; hosted CI remains disabled and macOS proofs are a
non-goal for this work.

## Generalizing the existing features

The original 2026-10-10 assessment led to bounded output expressions, tighter
capacity guards, branch-selected results and compatible constant copies. Those
increments are supported within their documented scopes. The
[assessment record](docs/language-generalization.md) preserves that history and
now begins with the 2026-10-12 review of the remaining composition gaps.

The [consolidation priority](#existing-feature-consolidation) supersedes the earlier
recommendation to keep repeated assignments, more bindings and repeated dynamic
references as separate later candidates. Consolidate them through shared rules
for the existing fragment. The older staging choices are not evidence that
their restrictions are required by the assurance target.

## Next goals after the greeting review

Originally recorded on 2026-10-09 while external review of `a73f85e` was pending.
That review is now assessed in the
[greeting record](docs/greeting.md#external-review-and-native-macos-validation),
with no blocking finding. The owner authorized the combined remit on 2026-10-09,
and both implementation units are complete. Address independently confirmed
correctness or assurance defects before further language expansion. Review
suggestions do not automatically require new infrastructure or approval gates.

The completed order was a bounded source-certificate performance pass, then
the guarded command-line greeting with report-policy functional refinement.
Neither performance candidate established an improvement; the original
representation remains. The feature passed complete native validation and
independent review without an Oracle amendment. Further work needs its own
owner-authorized scope. The fifth-form implementation baseline is `a73f85e`; the reviewed
documentation handoff is `fee3afe`.

### Bounded source-certificate performance

**Completed investigation:** neither of the two candidates established a
validated improvement. Retain the existing representation; no third approach is
authorized. The [performance record](docs/certificate-performance.md) distinguishes
failed and interrupted trials from successful validation. The investigation
raised the CI Lean allowance to 120 minutes without measuring hosted capacity.
The retained workflow is now dormant at the owner's direction; validation runs
locally.

The owner separately authorized [Lean scheduling and concurrency tuning](docs/lean-concurrency.md)
on 2026-10-10. That work uses the existing proofs and certificate representation;
it does not reopen the two-candidate representation investigation or authorize
another language capability.

The following records the bounded investigation scope.

The [greeting evidence](docs/greeting.md) identifies a substantial cost in the
enlarged recognizer certificate. Its timings overlapped other probes, so they
motivate investigation without constituting a controlled benchmark. Caching
already works; this task concerns rebuilding changed source certificates.
The external review also identifies a capacity risk in the configured CI Lean
job's former 60-minute timeout. Hosted CI had not run at that planning checkpoint,
so a timeout was not established.
That assessment included job-budget headroom before the first hosted run;
a larger timeout alone would not improve proof feedback.

- Establish a comparable baseline on fixed current source bytes and pinned
  tools on Linux ARM64. Record certificate and full-replay phase times, peak
  memory, artifact size and warm-cache behavior. Keep measurements in the
  evidence record, not as machine-dependent language acceptance thresholds.
- Limit implementation candidates to reconstruction lemmas, proof terms and
  their generator. The current reconstruction tree is already balanced. Large
  character-list conversions are a candidate bottleneck; the earlier raw-byte
  experiment was unsuccessful and is not a ready solution.
- Run heavy experiments separately in native-host workspaces with explicit
  time and memory budgets based on the baseline and available resources.
  Preserve normal caches and other hosts' state; use parallel work where the
  memory budget permits it. Trial budgets do not change proof acceptance policy.
- Preserve exact authoritative bytes, checked lexing and source correspondence,
  source-change cache invalidation, the fresh axiom audit and independent kernel
  recheck. Adopt only a successfully checked improvement that exceeds ordinary
  measurement variation without a material memory regression. No new trusted
  shortcut, source/runtime/language change or general certificate framework.

Completion means a measured decision after at most two candidate approaches.
A successful candidate must pass focused generation, mutation and cache tests,
full Lean validation and ordinary semantic review before a local commit. If
neither improves matters, retain the implementation and record the findings;
stop that investigation rather than extending it into an open-ended redesign.
The authorized language implementation follows that bounded decision.

### Guarded command-line greeting

**Supported**, after authorization on 2026-10-09 and the bounded performance
decision. The sixth complete production combines command-line initialization
with an explicit capacity guard and one prefix/name/suffix concatenation:

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := Silver_Arguments.First_Or_Default ("world");
begin
   if Silver_Arguments.Input_Is_Valid
     and then Name'Length <= 4088
   then
      Silver_IO.Put_Line ("Hello, " & Name & "!");
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

The capacity must equal 4096 minus the decoded prefix and suffix lengths; the
example therefore reserves 4088 bytes for `Name`. Only this use of `'Length`,
`<=`, canonical decimal and `and then` is admitted. Both references bind to the
same constant. Missing input selects the default; empty input prints the
decorations; invalid, extra, oversized or over-capacity input returns status 1
without output. The [language specification](language.md#guarded-command-line-initialization)
contains the exact rules.

The obligation experiment exposed a String lower-bound requirement for empty
prefixes. The owned SPARK initializer now constructs one-based results and
proves that bound while preserving bytes. Lean checks admission, typed Main
meaning, source correspondence, output bounds and a finite range-obligation
decision procedure. Concrete GNAT obligation generation and pinned prover
completion remain explicit external-tool premises. Every emitted application
and selected-library check is audited. SPARK proves executable report acceptance
equivalent to independent ghost policies.

The [capability record](docs/command-line-greeting.md) records complete Linux
validation, review, resource-option repair and preserved tool failures. The
[external review disposition](docs/command-line-greeting.md#external-review-disposition)
assesses the feature review with no surviving blocking, high- or medium-severity
finding and records five documentation clarifications. Its reported native macOS
results remain optional external evidence; obtaining or corroborating their raw
logs is not a pending requirement. Additional routing assertions, layout tests
and an exact-sample theorem are deferred without a demonstrated correctness gap.
Subsequent host validation, evidence recovery and the owner's decision to
validate locally with hosted CI disabled are recorded in
[host readiness](docs/host-readiness.md).
Reassignment, mutable strings, repeated references, general expressions/conditionals
and a new output API remain outside that completed increment. The owner
subsequently authorized the fixed-length assignment increment recorded above.

## Output design and next increments

Hello World admits its context clause, literal, and call as one coherent
capability. A context-only null program would add no behavior and is not admitted;
there is no artificial `runtime_context.adb` step. The API is
`Silver_IO.Put_Line`, implemented in verified SPARK over the existing libc
`putchar` and `fflush` symbols plus GNAT
`__gnat_set_exit_status`. The [review repairs](docs/hello-review-repairs.md)
replace abrupt exit with ordinary status assignment and return. The focused
[runtime experiment](docs/hello-runtime-experiment.md) established the actual
obligation classes before the report checker was extended.

The [language specification](language.md) defines printable ASCII literals,
quote escaping, empty strings, the source bound, exact LF output, detected
failure, and the current permitted compositions. The
[trusted boundary](docs/trusted-boundary.md#literal-output-boundary) defines
external effects and progress. Repeated calls, additional variable forms, arbitrary concatenation and
broader library admission remain excluded.

The owner authorized the command-line message task below on 2026-10-09.
The review repairs are complete in `251dd85`; named strings are committed in
`2f76b20`. The command-line scope and assurance are recorded below. A general proof
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

## Hello World with a command-line message

Recorded on 2026-10-08 and **authorized for implementation on 2026-10-09**.
The preceding review repairs are complete in `251dd85`. Named strings are
supported in `2f76b20` with [complete Linux evidence](docs/named-strings.md).
Guarded command-line input is also supported; its
[capability record](docs/command-line.md) records the completed compiler audit,
tests, Lean replay and independent kernel recheck, with actual platform scope.

The two increments are:

1. A named `constant String` initialized from a string literal, then passed
   to `Silver_IO.Put_Line`, with case-insensitive whole-name binding.
2. Initialization by `Silver_Arguments.First_Or_Default`, followed by the fixed
   `Input_Is_Valid` guard. The true branch prints the constant; the false branch
   calls `Reject` and returns with status 1 and no application output.

The command-line sample contains:

```ada
Message : constant String :=
  Silver_Arguments.First_Or_Default ("Hello, world!");
```

and the complete body:

```ada
if Silver_Arguments.Input_Is_Valid then
   Silver_IO.Put_Line (Message);
else
   Silver_Arguments.Reject;
end if;
```

A missing argument uses the default. One printable ASCII argument of at most
4096 bytes is preserved, including an explicitly empty argument. Extra arguments,
unsupported bytes and oversized input are unsuccessful without truncation.
The pure initializer returns an internal empty value for invalid input; the
required false branch never prints it. Both queries observe the same immutable
argument vector. The focused experiment selected this design because SPARK
rejects a side-effecting function in a constant initializer. Only this complete
guard composition is admitted.

Runtime initialization fixes the object's length from its initial value.
Reassignment, concatenation, mutable strings, general arrays, access types,
arbitrary conditionals and general command-line package access remain outside
that completed task. Literal-backed greeting is now supported below;
guarded command-line concatenation is now supported above.
The owner authorized the first statically compatible assignment composition on
2026-10-10: exactly one literal-initialized variable, one literal assignment of
equal decoded length, then output by the same name. The
[capability record](docs/string-assignment.md) tracks its implementation and
assurance. Further assignment forms remain later work.

The implementation reuses the approved GNAT argument imports beneath a verified
SPARK wrapper. Application reports remain empty; selected owned libraries have
complete nonempty reports. The source bridge covers the recognizer and argument
wrapper, with immutable argv and runtime ABI semantics documented as trusted
premises. The sample manifest records default, empty, valid and rejected input
cases. Execute the compiled application directly to pass arguments; forwarding
through `silver run` remains a separate convenience. No Oracle amendment.

## Literal-backed greeting

Completed in `a73f85e`, following authorization on 2026-10-09 and repair commit
`54844c5`. The motivating application declares a literal-backed `Name` constant
and calls `Silver_IO.Put_Line ("Hello, " & Name & "!")`.

The capability admits arbitrary existing-domain literals for the initializer,
prefix and suffix, with exactly one reference to the constant. The sum of their
decoded lengths is bounded by their consumption of the complete source. The
completed work includes a genuine GNATprove obligation experiment, SPARK
recognition, Lean admission/composition/source correspondence, catalogue/specification
and sample updates, boundary and rejection tests, and full native validation.
The [capability record](docs/greeting.md) retains the evidence and replay costs.
Literal contents receive no special treatment.

Repeated references, literal-only or arbitrary concatenation expressions,
additional declarations and assignment remain excluded. The completed
[command-line greeting](#guarded-command-line-greeting) adds an explicit capacity
guard before constructing its output; the earlier argument-validity guard alone
does not reserve space for a prefix and suffix.

## Completed report-policy follow-up

The guarded-greeting increment closes the identified functional-refinement gap
in `Silver_Library_Reports`. Independent Static ghost byte traversal and complete
report policies specify coverage, dependencies and discharge; SPARK proves exact
acceptance equivalence for selected runtime and dynamic Main reports. Shared
elementary predicates do not replace the independent traversal and policy.
See [the assurance scope](docs/assurance.md#selected-library-sources-and-evidence)
and [completed evidence](docs/command-line-greeting.md).

Faithful complete GNAT obligation generation and pinned prover completion on the
concrete arithmetic fragment remain explicit external-tool premises. The new
Lean decision procedure proves universal validity of the admitted range schemas;
it does not verify the bundled solver implementations or their 10000-step bound.
No additional solver, certificate framework or adversarial report authentication
was introduced. Additional tools still need an identified coverage gap.

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

For each active milestone, record its capability identifiers, dependencies,
exact scope, remaining decisions, and links to implementation and evidence.
When a language capability becomes supported, update this file, `language.md`,
the catalogue, and the sample manifest together. Completed validation and
remaining tool/platform limits are recorded per capability in the
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
