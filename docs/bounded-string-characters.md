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
