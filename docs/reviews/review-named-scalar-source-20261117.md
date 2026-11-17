# Final source-correspondence review — named scalar arguments #392

Reviewed on 2026-11-17 on Linux aarch64. Selected reviewer setting: GPT-6
Astra, Max, as specified by the lead and project policy. Independent live
model/effort confirmation, total review elapsed time, token use and cost are
unavailable.

## Target and disposition

**No static source-correspondence or domain-weakening finding in the reviewed
slice.** The complete pin agrees with the final native source, and its new
source checks connect to the reviewed semantic equations. Final candidate
checking and complete integrated assurance remain separate pending evidence;
this report does not certify their completion or close #392.

The review target is the frozen 24-file source-owned inventory in
`tmp/named-source-392/tmp/source-candidates-392/owned-final-files.json`, SHA256
`d128cad943d673284ac569ce6a3e351840e4a00cb0bfa249026784d56c47813f`.
All 24 listed file hashes matched at entry and were unchanged when rechecked.
This pending source increment builds on `a5e7c3fd7` and
`d3399feb4468750f77e8dcdcd0f3e54259cfbc85`. Their 16 core proof files match the
integration checkout. All **1,010** other non-owned files under `proof/Silver`
also match the integration checkout byte for byte, including the borrowed
semantic work. The native target is `f4ed7cd513047df7c8a24c04b3fd107ee704db1c`,
output-profile SHA256
`de017ca035a5ffd358d5fa98646d017dfe4ef54bd822fafc40743a9a8ae66f53`.

The 24-file slice comprises the association source checker and eight component
certificates plus their wrapper; function source/ghost checkers, three new
component certificates and their wrapper; procedure source/ghost checkers,
four new component certificates and their wrapper; and the complete reviewed
output-source pin. The review included the supporting source interpretation,
domain, normalization and library-link modules from the two core commits and
the already reviewed integrated native/semantic chain.

The owner-authorized scope and Oracle requirements are unchanged: existing
scalar functions/procedures, fully named/reordered/mixed calls, each formal once,
same incoming state, unchanged conservative alias rules and source limits,
and exact original-source compilation. The review was read-only apart from this
scratch report. No Lean, compiler, generator, test or cache-mutating command was
run, and the active source-candidate job was left untouched.

## Source and semantic checks

- **Finite marker storage and complete domain.**
  `PredicateAssociationEquations.lean:14` models every native seen-set cell
  using `Fin maxFormals`. `read_mark` at `:32` connects its one-cell update
  with the semantic function for every index in the native 1..585 subtype.
  Outside-index reads are only a total mathematical extension. The arbitrary
  stored set, including an already-true selected bit, remains unrestricted.
  `PredicateAssociationHelpers.lean:17` gives `MarkDomain` exactly that subtype
  bound, with no added precondition. The typed delta tree, its renderer and
  `PredicateAssociationSource.lean:43` connect this storage interpretation to
  the sole native delta expression and the full pointwise postcondition.
- **Resolvers and arbitrary imported helpers.**
  The source trees call the existing case-insensitive `Equal_Name` on the
  selected formal slice, preserve zero/invalid query cases and retain
  deterministic first-match resolution. Their complete native domains include
  arbitrary valid metadata; no uniqueness-of-spelling premise was added.
  `DefinitionEquations` and the normalizations in
  `PredicateAssociationHelpers.lean:98` onward derive arbitrary domain-bounded
  helper meanings from their source bodies and imported meanings. The library
  links retain the actual lexical/resolver/marker callee identities. The concrete
  model inhabitants establish consistency; they are not substituted for the
  arbitrary-callee argument.
- **Function recurrence and exact ghost call.**
  `PredicateFunctionCallGhostSource.lean:49` fixes the call's typed arguments and
  scope. Its full recurrence theorem at `:64` retains arbitrary seen/named state,
  the selected association, payload result, bounds and comma guard. The exact
  Static declaration and null body are checked at `:114`; erasure is limited to
  that named ghost call. `PredicateFunctionCallSource.lean:79` keeps the complete
  executable loop and places the typed call before cursor/seen/named mutations.
  Its source-check record includes the complete helper contract, tail expression,
  model wrapper and loop. The function-tail normalization preserves the fixed
  signature slice, selected formal and same incoming facts across every written
  actual and all rejection branches.
- **Procedure admission, payload aliases and updates.**
  `PredicateProcedureCallHelpers.lean:49`, `:114` and `:184` normalize the
  association traversal, payload-only alias replay and output update chain.
  The typed trees match the native selected-formal arguments, source endpoints,
  named flag and seen-set update. Replay supplies payload spans to the established
  name scanner and exempts only the writable payload's exact own endpoints;
  selector labels are never substituted for payload reads. The update trees
  retain original incoming facts while carrying the current output scan.
  Recursion decreases the written-actual ordinal, independently of the selected
  formal. The wrapper and loop source checks preserve the native full-domain
  refinement postconditions.
- **Domains and raw ghost equality.**
  The added domains mirror complete native preconditions and component subtypes,
  rather than success-only states. Zero cursors, empty typed bounds, arbitrary
  valid metadata and arbitrary seen flags remain covered where the native
  declarations permit them. The payload target-name domain agrees with native
  `Target_First > 0` plus `Valid_Name_State`; it adds no hidden success premise.
  `Procedure_Update_Step` accounts for its new metadata/slice arguments without
  restricting its independent formal parameter. The procedure ghost equality
  model retains all raw path fields and constrained vector cells, including
  Count=0 and dormant bounds; projection is used only in the valid forward
  direction. Its Static call retains both complete model applications.

## Pin, certificate composition and validation evidence

I independently lexed the complete final Ada output-profile source according
to the fixed source lexer's token rules and compared every token with
`ReviewedOutputShape.outputImplementation`: **76,980 tokens, exact equality**.
The pin file SHA256 is
`7d034eaaa79d6f3175ebd957eda8a493b6e2290d1904e654bac8469cd1616383`.
This direct comparison supplements review; it is not a substitute for Lean's
authoritative-source certificate.

The new component certificate statements compare complete extracted headers,
expressions, types or loop bodies with the reviewed typed renderings using
`decide +kernel`. Their wrappers cover every field in the enlarged checked-source
records. `FunctionSourceChecks.checked_source` and
`PredicateProcedureCallSourceChecks.checked_source` transport those records
through `Output.SourceBridge.actual_complete_shape` to `Source.outputBodyTokens`.
`PredicateSourceChecks.actualSource` includes both routes. The existing
`PredicateSourceBridge` keeps the interpreted equations, callee wiring and
native executable refinements explicit; the new pin is not itself asserted to
prove scanner semantics. No unfinished proof, added axiom or kernel bypass was
found in the frozen owned files.

I also inspected the retained marker helper/source-definition evidence and
independently rehashed every archived repository input:

- `20261117T030746-bf872a6a0f4d`: **1,141/1,141** archive inputs match. The retained
  focused helper/library result reports 338 imported modules, 49,919 declarations
  and a passed standard-foundation axiom audit.
- `20261117T031315-44bc724a3e70`: **1,142/1,142** archive inputs match. The retained
  focused source-definition result reports 123 imported modules, 18,902
  declarations and a passed standard-foundation axiom audit. Its captured proof
  inputs match 23 of the 24 frozen files; the later complete pin is different.

These runs use caches and are focused checks, without independent kernel replay.
The 031315 result supports the checked helper definitions, not final
actual-source correspondence.
The second run records native source SHA256
`9ede490b6cf72b352a39072cd37f4ef39774409c6024135487cf076567b59b9c`,
not the final `de017ca…` source. Consequently neither the matching proof-file
subset nor the earlier helper success is described here as final authoritative
source validation. The active candidate batch and final combined audit must
establish that result on the integrated bytes.

The complete native helper-contract review is recorded separately in
`tmp/named-final-native-review-392.md`; it found no focused native applicability
gap. Full integrated native/Lean obligation coverage, source provenance and the
final regression inventory remain the lead's validation scope. The documented
restricted Ada/frontend interpretation, native call-legality, external-tool and
local-cache premises are retained. No new exception to the Oracle was inferred.
