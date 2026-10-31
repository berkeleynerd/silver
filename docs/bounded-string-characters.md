# Bounded String indexing and character operations

Status: owner-authorized on 2026-10-31; design and implementation pending.
[Milestone 16](https://github.com/berkeleynerd/silver/milestone/16) contains one
work package, [#296](https://github.com/berkeleynerd/silver/issues/296).
The [authorization](session-memory.md#2026-10-31--bounded-string-indexing-and-character-operations-authorized)
covers the complete implementation, assurance, review and feature PR delivery.
This proposal does not admit syntax or claim completed support.

## Initial scope

The motivating Rosetta candidates are Reverse a string, Palindrome detection
and character replacement. Confirm their complete task requirements and choose
faithful bounded programs during design. Record demonstrated task mappings
separately from program counts; no broad String construct is promoted merely
because one rewritten task works.

- Indexed reads and element writes on fixed-bound Strings, using bounded
  Integer index expressions.
- Character literals and initialized scalar constants or variables, including
  copies, assignment and comparisons, under the current printable-ASCII policy.
- Bounded slice expressions with decidable bounds and length rules, usable with
  existing String expressions and length-compatible assignment.
- Composition with finite loops, guards, Boolean conditions, initialization,
  snapshots and output under the existing declaration and name-hiding rules.

Preserve the current 4,096-byte source, 63-operator and 64-leaf budgets; state
the applicable counting rules for new expressions explicitly. General
dynamic-length indexing, resizing, Unicode processing, general String/Character
libraries and capacity-limit changes are excluded. Boolean arrays and functions
remain separate queued features.

## Design and assurance obligations

Settle syntax and inherited meaning before fixing the admission rules. In
particular, check Character literal spelling against existing apostrophe
attributes, predefined-name visibility, actual String lower bounds, null slices,
concatenation and assignment sliding, and evaluation before mutation. Use the
pinned frontend to distinguish genuine Ada/SPARK restrictions from Silver's
selected scope. Document the purpose of every added restriction.

Derive every index, slice and destination-length obligation from declarations
and executable control flow. Cover unreachable arms and empty loops where the
pinned frontend still rejects invalid source. Preserve fixed bounds and exact
runtime byte semantics through element writes, copies and slices. Existing
length and Boolean facts must retain only the information justified by their
current rules; mutation must not create stale byte-equality assumptions.

Extend the native implementation and Lean admission, semantics, composition,
automatic-discharge and actual-source arguments together. Review source-tree
precedence and helper domains against their Ada definitions. New source
certificates and every proof module must enter the complete source/module/axiom
checkpoint. Keep endpoint guarantees, native contracts and required obligations;
no suppression, source replacement or Oracle amendment is permitted.

Discover the native diagnostics produced by representative admitted shapes
before changing report handling. Account for any relevant report-storage or
recognizer-stack effect within current limits. Use focused managed checks during
development and one stable complete checkpoint; retain applicable successful
work and diagnose a repeated failure before another attempt. A new framework,
performance project or assurance mode is not part of this feature.

## Design checkpoint — 2026-10-31

Implementation is in progress; these decisions do not claim supported syntax.
The integration branch starts at authorization commit
`1500b902a91c25f88cbb7aed1c832bbfb90d2959`. The initial independent semantics
review used GPT-6 Astra / Extra High; the native architecture and discovery
thread selected GPT-6.1 Sol / Extra High. Runtime model confirmation and token
or cost measurements are unavailable.

Character constants and variables share the internal initialized byte store
with Strings, represented as single printable bytes. Explicit kind checks must
keep their Ada types distinct in declarations, expressions, comparisons,
assignment, output, attributes and name hiding. In particular, a one-byte String
is not a Character, and the existing String output operations do not accept a
Character directly. Character concatenation and slice assignment targets are
outside this selected increment; Character values support indexed replacement,
copies and comparisons, while slices extend the existing String expressions.

Index and slice prefixes name existing Strings whose actual bounds are known
at declaration elaboration. Input-dependent-length Strings retain their current
whole-String operations; proving an input length in a guard does not add general
dynamic-length indexing. Actual bounds are independent of length: slices and
copies preserve both bounds, including arbitrary inverted null ranges;
concatenation preserves a nonnull left operand's lower bound and returns the
right operand when the left is null. Whole-String assignment slides equal-length
values onto the target's unchanged bounds. Element assignment preserves those
bounds and reads its target index and RHS from the incoming store.

Indexed reads and writes require a nonempty inferred Integer interval contained
in the prefix's actual bounds, including unreachable arms and empty loops.
Slice endpoints retain their ordinary scalar arithmetic checks. For independent
nonempty endpoint intervals `[a,b]` and `[c,d]` and prefix bounds `B .. E`,
the planned rule accepts either `a > d` (every slice is null), or
`a >= B` and `d <= E` (every potentially nonnull slice is within the prefix).
Its length interval is `max(0,c-b+1) .. max(0,d-a+1)`, computed in wide
arithmetic. Endpoint and concatenation-bound proof integration remains pending.

Each Character literal or name is one expression leaf. An indexed read costs
one prefix leaf plus its subscript's scalar leaves; a slice costs one prefix
plus both endpoint expressions' leaves. Indexed targets and assignment RHSs
have independent 64-leaf checks. Image keeps its existing separate scalar
argument budget. All source bytes still count toward 4096, and all arithmetic
inside indexes/endpoints counts toward the shared 63 operators. Complete
Character literals, including operator characters and quotation marks, are
skipped by the operator and xor scanners; their contents add no operators.

The first pinned frontend/prover discovery run
`20261031T162539-96d0ba9159be` confirms all 95 printable Character literals,
noncanonical String bounds, null slices `0 .. -1`, `-2 .. -3` and
`2147483647 .. 2147483646`, and assignment between differently bounded null
Strings. Literal-only Character comparisons are ambiguous and therefore need
a typed Character name or indexed String operand. A declaration named
`Character` hides its own type mark. Invalid static indexes can still fail in
dead code. These focused experiments establish producer behavior for their
inputs, not universal assurance or completed feature validation. Discovery
inputs and logs are retained in the native lane's
`.silver/linux-x86_64/string-discovery/`; the final evidence packet will identify
its complete outcome and applicable inputs.

## Completion

Complete native Bronze/Silver proof and coverage/provenance audit, a matching
build, complete Lean/source/module/axiom assurance, and the required final
regression and sample coverage. Use the existing reviewed-reuse provision only
where every final test remains accounted for. Review the critical arguments and
final evidence independently, retaining exact targets and prior failed results.

Synchronize language.md, the catalogue, samples, roadmap capability status and
Rosetta records under the [planning workflow](planning.md#rosetta-progression).
Publish a completed feature PR and leave it open for owner review. No supported
status is claimed before that validation and review pass.

## Work rounds

| Date | Selected settings and intended result | Result and remaining work |
| --- | --- | --- |
| 2026-10-31 | Integration/design subthread selected GPT-6 Astra / Extra High; record scope and inspect the existing architecture. Lead runtime settings and token/cost totals are unavailable. | Authorization and initial proposal prepared; no implementation or validation result yet. Exact String/Character rules, native feasibility and the corresponding proof design are next. |
