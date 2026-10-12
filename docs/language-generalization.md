# Generalizing Silver's current features

## 2026-10-12: current consolidation assessment

The owner asked to review the existing capabilities, put their generalization
at the beginning of the roadmap, and drive them to closure. The
[consolidation sequence](../roadmap.md#existing-feature-consolidation) takes
priority over accumulating more special-case program shapes. The owner later
placed the bounded [Lean Critical Path work](../roadmap.md#lean-critical-path)
ahead of it. Shared binding, expression, statement and effect theorem interfaces
remain part of consolidation and its expected reduction in duplicated proof
work; they are not a separately proposed language architecture. This assessment
uses the supported Copy String Values baseline `e9d18f1996`; the partial
Repeated Output edit is unfinished and does not expand current support.
The [language specification](../language.md), [assurance claims](assurance.md)
and [Oracle](../oracle.md) remain authoritative.

The subsequent [restrictions and capacity audit](restrictions-capacity.md) is
complete. It classifies the supported rules by origin, records dense native
experiments and their limits, and repairs the catalogue metadata without changing
membership. Shared declaration, name and copy rules are next proposed, followed
by common String expressions. The audit specifies their binding/value foundation;
the broader closure targets below remain unimplemented.

### What is supported, and what is being counted

The existing language has a universal assurance argument for every admitted
source in its specified narrow grammars, subject to the documented tool and
external-runtime premises. It is not limited to the sample texts. That guarantee
does not imply that each admitted construct can be repeated or combined in
arbitrary Ada contexts.

| Count | Meaning |
| --- | --- |
| 10 completed language milestones | Null baseline; literal output; named String constant; command-line message; literal-backed greeting; guarded command-line greeting; fixed-length String assignment; input-dependent branching; Compose String Results; Copy String Values. Workflow and proof-performance projects are excluded. |
| 7 current grammar families | Six output shells plus the separate null shell. |
| 16 concrete program forms | Fifteen output variants, plus null. Capacity guards and optional constant declarations account for variants within the six output shells. |
| 23 catalogue construct identifiers | Includes Main/pragma/context scaffolding and overlapping descriptions of output and expression syntax. These are not 23 independent, fully generalized language features. |

These counts answer different questions. None measures unrestricted support for
full SPARK String operations, assignment, conditionals or I/O. The present
[composition rules](../language.md#shared-composition-rules) explicitly describe
complete program grammars, not independently repeatable capabilities.

### Closure target

Close a deliberately specified fragment built from the existing String values,
literals, names, declarations, copies, assignments, concatenation, predicates,
conditionals, null statements, output and admitted argv APIs. An admitted
component should compose wherever its explicit typing, initialization, length,
control-flow and effect conditions hold. Its position in one of the old whole
program templates should not be an additional requirement.

The target uses finite source expressions and statement trees, including finite
sequencing and nested conditionals. It preserves inherited Ada/SPARK meaning:
String assignment does not resize the target, copying captures the source value
at that point, and a returning output failure does not skip subsequent source
statements. It does not implicitly admit loops, recursion, application-defined
subprograms, arbitrary library calls, indexing, slicing, conversions or other
String/array operations. Those require their own explicit rules and assurance.

Use shared rules rather than one new template for every combination. A finite
binding environment should record names, mutability, initialization and object
bounds; one expression judgment should supply value and length facts in every
admitted context; statement judgments should preserve those facts through
sequencing and branch joins; an effect model should compose the observable
calls and process status.

This is a closure objective within an explicit fragment, not a promise of a
uniquely maximal decidable subset of all automatically provable SPARK programs.
Membership must remain independent of whether a particular prover run happens
to succeed. Safety proofs, complete obligation discharge and source
correspondence remain necessary for the entire admitted fragment.

### Restriction inventory and closure criteria

| Area | Supported restriction | Closure target and required argument |
| --- | --- | --- |
| Literals, names and trivia | General printable-ASCII literals, empty Strings, escaped quotes, comments and case-insensitive binding under the source bound | Preserve this existing generality. Reuse lexical rules throughout the grammar; retain documented character and identifier policies rather than inventing restrictions for particular examples. |
| Declarations and bindings | One static binding, or one mutable result with at most two additional literal-backed constants; declarations occupy fixed positions | Finite declarations throughout the selected declaration region, limited by justified resource policies. Enforce scope, case-insensitive uniqueness, declaration order, mutability and initialization using a shared environment. No independent one-variable or two-constant limit without a stated need. |
| Initialization and copies | Result initialization/RHS accepts a literal or preceding literal-backed constant; constant aliases, mutable sources and expression initializers are excluded | Use the common expression and binding rules for initialization and copies. Preserve exact values, snapshot semantics and fixed object bounds. Admit initialized sources wherever compatibility is established; do not substitute a mutable name's later value for an earlier copy. |
| String expressions | Flat chains of 1–16 operands, at most one dynamic reference, used only in output | Use one expression grammar in every admitted value position, including compatible initializers/RHS values and comparisons. Support parentheses, nested concatenation and repeated dynamic references under multiplicity-aware length accounting and bounds on every intermediate result. Remove the independent operand/reference limits once the corresponding arithmetic, solver and report-capacity arguments are established. |
| Assignments and null | One assignment per executed path, one mutable target, compulsory result use and no self-assignment; null is a separate whole program | Close finite statement sequencing over the admitted operations. Check initialization, target mutability and equal lengths at every assignment. Harmless self-assignment, unused values and overwritten stores should not be excluded merely to retain a template; classify any resulting native diagnostics precisely. Null acts as a no-op within the admitted statement grammar. |
| Predicates, guards and branches | Two exact outer guards and one input-name/literal equality in fixed branch shapes | Define a decidable predicate/fact language for the existing validity, length and String-equality operations. Compose finite conditional trees with path facts and sound joins for initialization, bounds and state. Do not extend this claim to arbitrary Boolean computations or function calls. |
| Output effects | One terminal `Put_Line` per executed path | Compose finite calls with no separate four-call limit. Check each argument independently; preserve call order, accepted-byte observations, individual flush results and sticky failure status while continuing after returning failures. Total output depends on the selected call list and is not limited to one line. |
| Existing argv APIs | One immutable input binding under a fixed validity/capacity/rejection shell | Allow the admitted API operations to compose with the shared declarations, expressions and statements while preserving the immutable argument snapshot, defined invalid/default behavior and required guard facts. Multiple positional inputs or new interpretations require a separate API extension, not an implied relaxation. |

For the current single dynamic value, repeated references can use a bound of
`W + k * C <= 4096`, where `W` includes every fixed-length occurrence and `k`
counts dynamic occurrences. More independent values require corresponding
combined bounds. This describes compiler reasoning; it neither admits new
application arithmetic nor licenses an overflowing intermediate computation.
Compatible assignment requires equality with the target's fixed length under
the established facts, not merely fitting the output limit.

### Resource limits, tooling and the completion test

The current 4096-byte source bound, 4096-byte per-call output domain,
16-operand limit and proof-report capacities are explicit Silver implementation
or resource policies, not SPARK Silver-level rules. Review every retained bound:
state its purpose, distinguish semantic requirements from implementation
capacity, verify its enforcement and prove that downstream tooling can handle
every admitted case. Derive finite call/declaration counts from source size
where possible instead of imposing another unrelated template count.

Removing a grammar limit alone does not close a feature. More expressions,
assignments and branches can increase generated obligations, diagnostics and
report bytes. The compiler currently has a 262,144-byte report domain. The
[native audit](restrictions-capacity.md#native-measurements-and-integration)
records the actual dense-program experiments. Its 77-call, sixteen-operand
probe was stopped at an external 300-second experiment budget without producing
a Main report. The earlier extrapolation of 1,155 checks and 2.2 MB therefore
remains unverified; it is neither a measured result nor a worst-case bound.
Smaller probes and their actual report/translation outcomes are recorded in the
audit. This exploratory stop is distinct from the application's configured solver
step limit and does not change current membership. A justified capacity and
complete-obligation argument remains necessary before extending the grammar;
silently truncating reports, suppressing obligations or accepting all warnings
would not satisfy it.

Closure is complete only when the specification and catalogue describe the
shared rules, the compiler admits precisely that fragment, the same author
source is proved and compiled, and universal binding/state/effect semantics,
source correspondence and complete automatic discharge cover all permitted
compositions. Boundary and interaction tests supplement those arguments.
Follow the existing [validation workflow](../development.md#proof-loop-and-validation)
and preserve successful caches; this assessment does not add an approval
ceremony or require optional independent kernel replay.

A catalogue consistency repair is complete and tested in the
[audit](restrictions-capacity.md): the
`selected_result_output.initializers` metadata in
[catalogue/silver.json](../catalogue/silver.json) and its
[SPARK exporter](../src/silver_catalogue.adb) now includes
`preceding_literal_constant_identifier`, matching already supported result
initialization and neighboring operand metadata. Native export consistency and
the focused catalogue tests cover the repair. The admitted language is unchanged.

## 2026-10-10: historical assessment, partly superseded

The following assessment was written against the seven-production
implementation `d630229`. Its references to “current” scope and future work
refer to that baseline. Bounded output expressions, tighter capacity guards and
branch-selected results have since shipped, and Copy String Values partially
addresses its declaration/copy proposal. Repeated assignments/output and
additional argv operations remain unfinished. Preserve the analysis below as
history; use the current assessment above and
[language.md](../language.md) for present status.

### Recommendation

Several restrictions can usefully become composition rules. After the selected
input-dependent branching increment, prioritize **bounded String expressions in
existing output positions**, then **a fixed-length result selected by a branch
and printed once**. These make existing features work together without first
admitting arbitrary Ada statements, a general parser or a new string library.

Literals already admit arbitrary printable ASCII contents, empty strings and
doubled quotes. Names, case-insensitive binding, comments and whitespace already
vary under explicit rules. The checked-in sample texts are not special cases.
The main opportunity is broader composition, not more literal or naming examples.

The completed branching item follows the existing typed conditional approach
with its own interpreter in [BranchingMain](../proof/Silver/BranchingMain.lean).
It adds String equality, its grammar and an input-dependent meaning in
[Current](../proof/Silver/Current.lean), connected to the actual source. It did
not require implementing the expression generalization first.

| Area | Useful generalization | Cost or reason to limit it | Recommendation |
| --- | --- | --- | --- |
| String output expressions | Literals, an existing bound name and flat `&` chains; include variables after assignment and repeated statically sized names | Explicit length accounting, intermediate Ada bounds and expanded source correspondence; new Main checks may appear | Best first follow-up to branching |
| Capacity guards | Permit an application-selected capacity no greater than the safe residual capacity | A smaller bound deliberately rejects more input, including possibly a long default; specified behavior must reflect it | Assess alongside dynamic expression rules |
| Conditional branches | Reuse the same admitted output expressions in either branch | Every path must retain its required validity/length facts and terminal effect | Compose once both capabilities are established |
| Fixed-length assignment | Assign equal-length values in either branch, then print the result once | Requires immutable input plus a distinct initialized result, binding and branch-join proofs | Best later behavior-oriented increment |
| More declarations and copies | Several initialized bindings; copies whose lengths match the target | Case-insensitive uniqueness, declaration order, mutability and per-object length tracking | Add when a concrete data-flow program needs them |
| Repeated assignments | A finite sequence preserving one object's fixed length | Repeated literal overwrites are unobservable before one final print; more dead-store diagnostics | Feasible but low priority alone |
| Repeated output | Multiple lines with a documented complete-program effect | Calls continue after a returning failure; per-call observations do not describe cumulative output | Separate later capability |
| More argv operations | Multiple positional inputs or other interpretations | New API domains, indexing, validity/failure rules and runtime correspondence | Defer until an application needs them |

### First follow-up: bounded output expressions

A small proposed grammar is:

```text
expression := operand { "&" operand }
operand    := string_literal | bound_string_name
```

Use it in the output positions of supported compositions, including conditional
leaves. Initially retain their existing declaration
and statement order. A nonempty operand sequence follows Ada's left association;
arbitrary parentheses, calls, indexing and conversions need not arrive with it.
For example, output following the current equal-length assignment could use:

```ada
Silver_IO.Put_Line ("Hello, " & Message & "!");
Silver_IO.Put_Line (Message & ": " & Message);
```

These are two **alternative proposed output statements**, not an admitted
two-call sequence. One expression rule covers absent decorations, literal-only
concatenation, variable output and repeated statically sized names. It avoids
adding an independently named whole-program template for every combination.

Infer each literal's decoded length and each literal-backed object's fixed
length, then sum operand lengths **with multiplicity**. Require the result to
fit the 4096-byte output domain and prove all intermediate operations safe.
Repeated names invalidate the existing shortcut that distinct source literal
spans bound the whole result. A short source referencing a 3000-byte value twice
can request more than 4096 output bytes. Do not rely on the output wrapper's
failure guard to make such a statically oversized expression a successful
admitted-output case.

For dynamic argv input, begin with one dynamic reference per expression and the
existing executable validity/capacity guards. Let `L` be the total length of its
literal decorations; a permitted capacity `C` must satisfy `C + L <= 4096`.
The current rule requires equality. Allowing smaller `C` would support a useful
limit such as 80 characters while preserving safety; the program's explicit
guard, including its rejection of an over-capacity default, determines behavior.
Use each branch's actual decorations when establishing its required capacity.
Check each terminal branch independently; one execution selects one output, so
its bound need not include the lengths of unexecuted branches. The current
[default-fits-capacity theorem](../proof/Silver/GuardedSemantics.lean) depends on
exact residual capacity. A tighter guard therefore needs the changed default
behavior above, or a separate admission condition requiring the default to fit.

Repeated dynamic references are a later extension. For `k` occurrences of the
same argument, the relevant bound is `k * length + L <= 4096`; a source-checked
constant guard could use `floor((4096 - L) / k)` when `k > 0` and `L <= 4096`.
This arithmetic describes a possible admission rule, not newly admitted Ada
arithmetic or a reason to evaluate an overflowing product before checking it.
Retain the verified one-based argument result and account for empty operands
and every intermediate String result. Multiple independent dynamic values need
a different combined bound.

There is useful existing theory in
[ConcatSemantics](../proof/Silver/ConcatSemantics.lean),
[AssignmentSemantics](../proof/Silver/AssignmentSemantics.lean) and
[GuardedObligations](../proof/Silver/GuardedObligations.lean). Their current
grammars, event shapes, source renderings and complete-program theorems still
target particular productions; a general-looking expression datatype alone
does not prove the broader language. This is a capability increment with real
proof work, not a recognizer-only relaxation.

### Later: compute a fixed-length result, then render it

The existing assignment rule can generalize from one literal replacement to
compatible expressions and control flow. A useful motivating body is:

```ada
-- Proposed: Command is immutable argv input; Result is an initialized
-- seven-character String variable. Neither declaration pattern nor this
-- composition is currently admitted.
if Silver_Arguments.Input_Is_Valid then
   if Command = "start" then
      Result := "started";
   else
      Result := "unknown";
   end if;
   Silver_IO.Put_Line ("State: " & Result);
else
   Silver_Arguments.Reject;
end if;
```

Both assignments preserve the result's fixed length. The join before output
must establish its initialization, length and selected bytes on either path.
This combines one immutable dynamic input with fixed mutable storage; changing
the length of an argv-initialized String is not a substitute. Ordinary Ada fixes
that object's bounds at initialization too.

General assignment compatibility can use the same length judgment as output:
the right-hand expression must equal the target's fixed length. But adding
arbitrary assignment chains before any observable use provides little benefit.
With only one variable, length-preserving self-concatenation is also very
restricted. Add extra bindings or statement sequencing to serve actual data
flow, with explicit name resolution and state semantics, rather than bundling
all variations into the first expression increment.

### Repeated I/O has a distinct effect contract

The actual [Put_Line body](../src/silver_io.adb) sets exit status 1 and returns
on a detected failure. A later successful call **does not reset that status**.
There is no established bug in the current terminal-call behavior.

Allowing a following call would nevertheless attempt more output. The wrapper's
Static byte transcript and success flag reset at each invocation, while
[OutputRuntime.completeMain](../proof/Silver/OutputRuntime.lean) currently
interprets one terminal call. Multiple calls need a cumulative trace and process
status argument, plus an explicit choice between continuing attempts and
stopping after the first failure. Successful later bytes after a failed earlier
line need not be a prefix of the complete intended output. Per-call bounds also
do not bound the total output when values can be reused. The
[trusted boundary](trusted-boundary.md#literal-output-boundary) already identifies
this composition obligation. Repeated I/O is useful but should have its own
multiline application and complete effect specification.

### Proof and implementation scope

Keep membership decidable from the actual source, independently of prover
success. Begin each authorized capability with native obligation experiments,
then establish universal semantics, automatic-discharge arguments and actual
source correspondence. Exercise maximum permitted expression/statement sizes;
finite source size alone does not establish external solver completion or that
the complete proof report fits the compiler's report buffer.

The current [assignment report policy](../src/silver_library_reports.adb)
requires empty safety-proof lists and at most one precisely classified
initializer advisory in its warning-bearing form. Mutable concatenation or
additional stores may generate different checks or diagnostics. Inspect and
model them explicitly; neither reusing a previous report policy blindly nor
accepting all warnings is justified. The existing compiler routes those modes
separately in [silver.adb](../src/silver.adb).

No new trusted dependency or Oracle amendment is indicated by these candidates.
Parser replacement and certificate redesign are not prerequisites. The owner
subsequently prioritized end-of-day checking and assessment of source/dependency
compartmentalization before another language increment; this addresses measured
development cost, rather than a missing language foundation. Reuse small
proof/recognizer components where the authorized
capability needs them, keeping specification and implementation arguments
independent. Retain the [proportionate validation cadence](../development.md#proof-loop-and-validation),
including complete local assurance at a capability checkpoint.

This assessment used source/document inspection and three focused reviews of
native behavior, proof reuse and development priorities. No native probes,
proof replay or benchmark was run, and no broader admission rule was installed.
