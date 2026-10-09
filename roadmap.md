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
| Named string constant | Authorized; follows repair baseline | A literal-initialized `constant String`, name binding and output through its identifier. First increment of the next task below. | Planned `samples/string_constant.adb` |
| Command-line message | Authorized; follows named strings | Initialize the named constant through a narrowly admitted, verified argument wrapper; depends on the named-string increment. | Planned `samples/command_line.adb` |

The target is a class of programs that can print admitted literals, not special
treatment of the text `Hello, world!`. String literals do not imply support for
string variables, concatenation, indexing, general arrays, access types, or file
handles. Each additional form needs explicit admission and composition rules.

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
failure, and the two permitted compositions. The
[trusted boundary](docs/trusted-boundary.md#literal-output-boundary) defines
external effects and progress. Repeated calls, variables, concatenation and
broader library admission remain excluded.

The owner authorized the command-line message task below on 2026-10-09.
Finish the current review-repair validation and commit before language changes. Specify
interactions and generated obligations before implementation. A general proof
engine, catalogue framework, or additional output API is not a prerequisite.

The source bridge checks both recognizers and the selected output library.
Source-certificate replay remains a development cost to measure as these grow.
Preserve caching and independent module scheduling; improve representation when
measurements justify it without weakening source correspondence or kernel checks.

## Next task: Hello World with a command-line message

Recorded on 2026-10-08 and **authorized for implementation on 2026-10-09**.
Complete the preceding review-repair baseline first. The two milestones are
authorized work, not yet supported language; their sample files and final API
will be admitted only with complete assurance and validation.

1. Add a named `constant String` initialized from a string literal, then passed
   to `Silver_IO.Put_Line`. Establish declaration, initialization, name lookup
   and identifier-expression rules and their permitted compositions.
2. Allow initialization through a narrow verified command-line wrapper, with
   the proposed spelling `Silver_Arguments.First_Or_Default`. A missing argument
   uses the supplied default; an explicitly empty argument remains empty. Start
   with printable ASCII and an explicit length bound compatible with output.
   Oversized input, unsupported bytes and extra arguments have defined
   unsuccessful outcomes, without truncation. Finalize the API, exact bound and
   failure details during authorized implementation.

The motivating proposed declaration is:

```ada
Message : constant String :=
  Silver_Arguments.First_Or_Default ("Hello, world!");
```

The focused Linux experiment selected a pure initializer and an explicit
validity guard. SPARK rejects a side-effecting function in this declaration;
therefore the proposed complete body for the argument form is:

```ada
if Silver_Arguments.Input_Is_Valid then
   Silver_IO.Put_Line (Message);
else
   Silver_Arguments.Reject;
end if;
```

The pure initializer returns an internal empty value for invalid input; the
required false branch never prints it and sets process status 1. Both checks use
the same immutable argument vector. This admits one fixed guard composition,
not arbitrary conditionals or general command-line access. No oversized sentinel
or abrupt process-exit import is needed. The initial literal-constant increment
still uses a sole unguarded output call. These experiment results do not yet
admit either new production.

Runtime initialization fixes the object's
length from its initial value. This task does not introduce reassignment: Ada
string objects do not resize, so arbitrary assignment to an existing string
requires a separate length-safety rule. Concatenation, mutable strings, general
arrays, access types and general command-line package access remain outside the
task. A later increment could add bounded concatenation for a personalized
greeting, or statically compatible assignments.

Begin with a focused GNATprove obligation experiment. Reuse the
existing trusted GNAT argument bindings beneath a verified SPARK wrapper whose
calls impose no application-author preconditions. Extend actual-source Lean
correspondence, semantics and composition assurance for the resulting language.
The application-report checker currently expects empty obligation lists; extend
it if the new forms generate checks, preserving complete coverage and discharge.
Update the specification, catalogue and manifest only as each capability becomes
supported. Extend sample cases with arguments and expected success/failure
outcomes; initially invoke the compiled executable directly. Argument forwarding
through `silver run` is a separate convenience, not a prerequisite. No Oracle
amendment is proposed.

## Deferred until needed

Binary attestations, full per-program dependency provenance, additional defenses
for adversarial build environments, and compatibility machinery are deferred.
Revisit them when distributing independently consumed binaries, working in
untrusted/shared environments, or preparing a stable release makes them useful.
They are not prerequisites for Hello World. Existing validation remains in
place; accurate evidence and current language guarantees are still required.

## Recording progress

For each active milestone, record its capability identifiers, dependencies,
exact scope, remaining decisions, and links to implementation and evidence.
When a language capability becomes supported, update this file, `language.md`,
the catalogue, and the sample manifest together. The sample collection and output capability are supported; their completed
validation and remaining tool/platform limits are recorded in the
[capability record](docs/hello-world.md).
Keep proof claims and assumptions in
[docs/assurance.md](docs/assurance.md) and
[docs/trusted-boundary.md](docs/trusted-boundary.md), linking to them here.

Linux is the primary implementation and validation platform. macOS validation
is independent and secondary under the Oracle. Record actual evidence per host;
a configured CI workflow is not a completed CI run. Work remains local until
the owner creates the remote repository and authorizes publication.
