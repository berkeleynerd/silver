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
| Faster proof feedback | Supported | Native GNATprove/Lake reuse, configurable workers and explicit full/cold/clean checks; [native platform evidence and remaining costs](docs/proof-workflow.md). No language change; CI has not run. | Developer workflow |
| Sample collection | Supported | Original null source moved byte-for-byte, with a small [manifest](samples/manifest.json) driving admission/proof/build/run checks. No language change. | [samples/null.adb](samples/null.adb) |
| Literal output / Hello World | Supported | `runtime_context`, `literal_output`, and `string_literal` together: one qualified call, printable ASCII literal, verified wrapper and complete report handling. Final validation is recorded in the [capability record](docs/hello-world.md). | [samples/hello_world.adb](samples/hello_world.adb) |
| Named string constant | Supported | A literal-initialized `constant String`, name binding and output through its identifier. Completed [validation](docs/named-strings.md). | [samples/string_constant.adb](samples/string_constant.adb) |
| Command-line message | Supported | Initialize the constant through `Silver_Arguments.First_Or_Default`, with a mandatory validity guard and rejection branch. Completed [Linux validation](docs/command-line.md). | [samples/command_line.adb](samples/command_line.adb) |
| Literal-backed greeting | Supported | Literal prefix, one reference to a literal-initialized String constant, and literal suffix joined by Ada `&`; combined bounds and completed [validation](docs/greeting.md). | [samples/greeting.adb](samples/greeting.adb) |
| Source-certificate performance | Proposed | Recommended next: a [bounded performance pass](#bounded-source-certificate-performance) on exact-source reconstruction, retaining all current assurance. | Developer workflow; no language change |
| Guarded command-line greeting | Proposed | Next language increment: [dynamic concatenation behind an explicit capacity guard](#guarded-command-line-greeting). | Planned `samples/command_line_greeting.adb` |

The output target covers admitted literals and bounded command-line
messages; the text `Hello, world!` receives no special treatment. String literals do not imply support for
string variables, arbitrary concatenation, indexing, general arrays, access types, or file
handles. Each additional form needs explicit admission and composition rules.

## Next goals after the greeting review

Recorded on 2026-10-09 while external review of `a73f85e` is pending. This is
planning only; neither proposed goal has started or been activated in the
harness. Independently verify the incoming findings and address actual
correctness or assurance defects before further language expansion. Review
suggestions do not automatically require new infrastructure or approval gates.

The recommended order is a bounded source-certificate performance pass, then
the guarded command-line greeting. This protects the development loop while
keeping the next language target concrete. Both await the owner's go-ahead;
no Oracle amendment is currently indicated.

### Bounded source-certificate performance

**Proposed goal:** evaluate at most two local approaches to reducing exact-source
certificate checking cost; integrate a validated improvement, or record a
negative result and retain the current representation.

The [greeting evidence](docs/greeting.md) identifies a substantial cost in the
enlarged recognizer certificate. Its timings overlapped other probes, so they
motivate investigation without constituting a controlled benchmark. Caching
already works; this task concerns rebuilding changed source certificates.

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
The language goal can then proceed once authorized.

### Guarded command-line greeting

**Proposed language goal:** support a sixth complete production combining the
existing argument initializer and greeting expression, with an executable
capacity guard before either concatenation is evaluated. The motivating sample
is ordinary Ada/SPARK, but is **not currently admitted Silver**:

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

The prefix and suffix consume eight bytes, leaving 4088 for `Name`. The proposed
class permits arbitrary existing-domain default, prefix and suffix literals.
Membership checks that the decimal capacity literal equals 4096 minus the
decoded prefix and suffix lengths; it does not add source arithmetic. Introduce
only this use of `'Length`, `<=`, `and then` and the capacity literal. The guard
and output must reference the same declared constant, with exactly one reference
in the concatenation and the existing command-line name restrictions.

Missing input prints the decorated default; an explicitly empty argument prints
the decorations. Valid input fitting the remaining capacity prints its exact
bytes with the prefix, suffix and LF. Invalid input, extra arguments, and input
exceeding the remaining capacity return status 1 without application output or
truncation. Existing detected-output-failure behavior and external assumptions
remain. The default and decorations fit by their combined source-consumption
bound; a runtime argument needs the new guard.

Once authorized, begin with an isolated GNATprove/GNAT obligation experiment.
Dynamic concatenation may introduce nonempty application reports. Check both
intermediate results, String index/lower bounds and empty prefixes; the current
initializer contract guarantees length and printable bytes, not a particular
lower bound. Establish any needed contract strengthening through verified owned
code or an independently justified existing interface premise. Do not assume a
length guard alone settles these obligations or silently exclude failed cases.
Extend report handling for the obligations actually generated, with complete
coverage and discharge. Keep the capacity condition visible in application
source rather than introducing a wrapper solely to conceal it.

Completion requires the recognizer, specification, catalogue, proposed sample
and manifest; universal assurance and checked source correspondence for all six
forms; native GNAT/GNATprove boundary and failure tests; full Linux validation;
independent review and a local commit. Include exact capacity and one-byte-over
cases, empty input/default/prefix/suffix, escaped literals, mismatched or weakened
guards, invalid arguments and output failure. Ordinary proof failures are work
to resolve. A necessary Oracle amendment or broader architectural change is a
reason to report the concrete issue and reconsider scope, not to suppress checks.
macOS validation remains independent and nonblocking.

Reassignment, mutable strings, repeated output references, arbitrary expressions
or conditionals, a general parser and a new output API remain later work.

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
external effects and progress. Repeated calls, variables, arbitrary concatenation and
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
guarded command-line concatenation is the proposed next language increment.
Statically compatible assignments remain later work.

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
additional declarations, assignment and command-line concatenation remain
excluded. The [proposed command-line greeting](#guarded-command-line-greeting)
adds an explicit capacity guard before constructing its output; the existing
argument-validity guard alone does not reserve space for a prefix and suffix.
That follow-on is not authorized by the completed greeting goal.

## Proof coverage follow-up

The 2026-10-09 review of additional prover options identified one existing
mechanization gap worth a focused follow-up: `Silver_Library_Reports` has verified
safety, but its report-policy meaning is reviewed and tested rather than linked
to an independent functional specification. See the
[current assurance scope](docs/assurance.md#selected-library-sources-and-evidence)
and [report boundary](docs/trusted-boundary.md#source-identity-and-program-proof-evidence).
This is not a discovered incorrect acceptance or a need for another prover.

Proposed work, naturally paired with future report changes, is to prove that
acceptance establishes the required coverage and discharge policy, and that
genuinely complete successful reports in the supported format are accepted.
Keep report/parser bounds sufficient for every admitted program. Use existing
SPARK/Lean tools and the pinned producer's format; completeness of GNATprove's
emitted obligations remains its documented premise. No general JSON framework
or adversarial report authentication is proposed. This entry does not start
implementation or reorder the already proposed next goals.

The guarded command-line goal separately requires extending the language-wide
automatic-discharge argument to its actual generated obligations. The current
empty-application proof does not establish that extension, and additional
solvers or certificates alone would not establish it either.

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
is independent and secondary under the Oracle. Record actual evidence per host;
a configured CI workflow is not a completed CI run. Work remains local until
the owner creates the remote repository and authorizes publication.
