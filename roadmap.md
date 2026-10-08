# Silver roadmap

Silver grows through small capabilities motivated by runnable examples. The
[Oracle](oracle.md) governs the guarantees; [language.md](language.md) and the
[catalogue](catalogue/silver-null-0.json) specify what is supported today.
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
  agree; the example and its expected behavior are recorded. Once the proposed
  sample collection exists, each supported example must have a manifest entry.
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
| Null baseline | Supported | `main_procedure`, `spark_mode_on`, and `null_statement` in the sole `silver-null-0` composition. | [samples/null.adb](samples/null.adb) |
| Faster proof feedback | Supported | Native GNATprove/Lake reuse, configurable workers and explicit full/cold/clean checks; [native platform evidence and remaining costs](docs/proof-workflow.md). No language change; CI has not run. | Developer workflow |
| Sample collection | Supported | Original null source moved byte-for-byte, with a small [manifest](samples/manifest.json) driving admission/proof/build/run checks. No language change. | [samples/null.adb](samples/null.adb) |
| Approved runtime context | Proposed | A context clause for a specifically selected runtime package; selected specifications and bodies, dependencies, elaboration, and initialization must be covered. | Future `runtime_context.adb` |
| First text output | In progress | Isolated wrapper and obligation experiment, followed by one qualified call and a specified class of string-literal arguments; admission requires the approved runtime context and its verified implementation. | Future `hello_world.adb` |
| Hello World | In progress | Complete output behavior and automatic assurance for the chosen operation and literal class; see the [implementation checkpoint](docs/hello-world.md). | Future `hello_world.adb` |

A parameterless newline operation could be a separate step before text output
if it is a desired part of the runtime API. It is not required merely to split
the work into more samples. Hello World may be the representative sample for
the first text-output capability if no further capability is needed.

The target is a class of programs that can print admitted literals, not special
treatment of the text `Hello, world!`. String literals do not imply support for
string variables, concatenation, indexing, general arrays, access types, or file
handles. Each additional form needs explicit admission and composition rules.

## Decisions before output admission

1. **API and implementation boundary.** Prefer a small Silver-owned SPARK
   wrapper with verified contracts. Choose its package name and individual
   admitted operations after examining actual GNATprove/runtime contracts.
   `Silver_IO.Put_Line` is a candidate name, not an approved API. Select the
   trusted external interface explicitly; neither all of `Ada.Text_IO` nor any
   other package is admitted by association.
2. **Literal domain.** Define permitted characters, encoding, literal syntax
   (including quotes), length bounds, and empty-string behavior. Establish
   automatic assurance for the entire declared domain without author contracts.
3. **Observable output.** Specify bytes or characters written, newline
   conventions, buffering/flushing, and the point at which output is considered
   complete. Record any deliberate platform differences.
4. **Failure and progress.** Decide how failed or partial writes, closed output,
   resource exhaustion, and environmental progress are represented. A defined
   nonzero application exit is a candidate initial policy; status-returning APIs
   remain an alternative. Neither policy is selected yet. State assumptions
   explicitly and ensure failure is not reported as successful output.
5. **Initialization and composition.** Cover package elaboration and the entire
   call chain, including required state and external assumptions. Decide the
   exact permitted combinations of calls and statements; supporting one call
   does not automatically admit arbitrary repetition.
6. **Proof and evidence.** Extend the semantics with output effects and specified
   outcomes, and prove safety and complete automatic discharge for the resulting
   language. Establish correspondence with the selected library source and its
   contracts. Identify the actual obligations of the candidate operation before
   choosing report-handling changes: the current checker requires empty lists,
   and any newly generated obligations require complete checked handling.

These are foundations of the output capability. When richer syntax requires a
shared typed representation for admission and catalogue rules, introduce it with
that capability and maintain agreement with the specification. The current
expression-function bridge will need extension or supplementation for effectful
procedures; merely updating its source pin is insufficient. Assess replay cost
as the proof grows without abandoning source correspondence or kernel checking.

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
the catalogue, and the sample manifest together. The sample collection is
implemented; the output capability remains in progress and is not yet admitted.
Keep proof claims and assumptions in
[docs/assurance.md](docs/assurance.md) and
[docs/trusted-boundary.md](docs/trusted-boundary.md), linking to them here.

Linux is the primary implementation and validation platform. macOS validation
is independent and secondary under the Oracle. Record actual evidence per host;
a configured CI workflow is not a completed CI run. Work remains local until
the owner creates the remote repository and authorizes publication.
