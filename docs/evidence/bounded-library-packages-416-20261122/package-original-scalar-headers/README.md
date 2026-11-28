# Original Main scalar-header obligations

Refs #416. The scoped review of `d775f44e1a` confirmed two additional omissions
from the application obligation inventory: raw arithmetic in inline Integer
range bounds in Main's top-level declarations, and the same bounds in Main's
local functions and procedures. The existing initializer traces list raw RHS
checks; their normalized `Integer.Declaration.bounds` fields do not retain the
endpoint expression obligations. `InitializerChecksAt.callable` skips callable
bodies, while the callable definitions retained the same RHS-only trace.

`ApplicationPackageOriginalScalarHeaders.lean` reconstructs both missing
families in namespace `Silver.ApplicationPackageScalarHeaders`. It imports
`ApplicationPackageMainInitialization`, without the final assembly or assurance
modules. `RangeSyntaxAt` records original range-reader equations and raw
`ArrayGrammar.SourceAt` trees with the arbitrary original array table.
Each `Header` stores its actual pre-declaration frame and original expressions.
Its obligations use that frame's scalar ranges and array table, with the same
empty-initials/nonelaborating view used by the original constraint reader.
This does not assume an empty array table or narrow accepted source domains.

`TopHeadersAt` follows the complete `ScalarDeclarationsAt` history;
`LocalHeadersAt` follows `FunctionLocalsAt`. `FunctionHeadersAt` and
`ProcedureHeadersAt` connect the local inventories to their original callable
source histories, and `CallableHeadersAt` folds every `MixedDeclarationsAt`
entry, including unused callables. Every scalar declaration contributes a row;
an absent inline constraint contributes an empty endpoint list. Original
declaration order and per-declaration scope are preserved in each projection.

The integration API is `main_headers original`, for an original
`MainInventory.SourceAt` witness. It derives a `MainHeaders` value with `.top`
and `.callables`, its `.SourceAt original` relation, and
`Integer.discharged headers.obligations = true`. The inventory and its source
relation have no discharged-check, semantic-inference, safety or successful
decoder field. The complete arithmetic discharge is a separate theorem result,
derived from the accepted native `ScalarConstraintAt` endpoint readings.

## Validation and repair history

Focused Linux x86_64 / Lean 4.34.1 validation
`20261128T025106-8326d2194017` passed with a fresh audit of 29,051 declarations.
All 1,731 captured source hashes matched, with no missing input. The checked
module SHA-256 is
`166bd5eecefeed8513b8a9bf803e4908fd05c45e2f3f9081b9422482604bf243`.
Build 4.365 s, audit 3.011 s, managed elapsed 17.252 s. The managed runner used
CPUs 6–7, automatic two workers/two threads and 8,192 MiB per process.

The two failed drafts are retained. The first needed a nonreserved local name,
the original `Table.items` projection, explicit `Header` type inference and a
qualified list-obligations reference. The second exposed only a proof-script
normalization mismatch: unfolding the complete list fold hid the induction
hypothesis. The final proof states the exact cons decomposition before applying
the two discharge facts. These repairs changed no native source, declared
domain, proof budget, source pin or obligation family.

This is focused helper validation, without independent kernel replay or native
validation. The integration stream owns insertion into `MainSyntax`, complete
application assurance, actual-source/native/regression validation and closing
review. This helper does not by itself repair the inherited standalone
single-unit endpoint's inventory. Proof/source-design policy selected GPT-6
Astra Max; the live model/effort and token/cost measurements are not independently
exposed. No CLI memory was updated.

The separate source-proof subthread `/root/416_visibility_proof_fix` reviewed
the frozen module hash above and found no blocker. It checked both raw endpoint
equations, each actual pre-declaration scope, the unchanged array-reader
defaults, every top-level/local/callable history constructor, unused and
empty-local callable cases, and the separation of source facts from discharge.
That review made no edits and launched no proof run. Its critical-proof policy
setting is Astra Max; independently confirmed live settings and separate
elapsed/token/cost measurements were not supplied.

## Remaining scoped review findings

The read-only review also checked the source/semantic boundary and canonical
effect endpoint in `d775f44e1a`, with `ReaderEffectsImports` from `584a446186`.
At review time all 1,759 captured inputs of
`20261128T024046-a299f2a081fc` matched. The owned endpoint file hashes agreed
with that commit and the captured source manifest:

- `ApplicationPackageOriginalAssembly`: `9e2b8e1905fdb3bb39295de2ca3ff8f8f62f41b49e195f66de88feb8177493e8`.
- `ApplicationPackageOriginalAssurance`: `a9fa9c89f3e36ef854dab3732335814856cf52a0754293be476bb43ffce7f42b`.
- `ApplicationPackageReaderEffectsImports`: `71b22ee3f8d7b4df1ff2fb13f4e92a4f7ef6217ffd69917d691b1b5cb6986753`.

`SourceMeaning` retains original accepted native histories and source syntax;
`NativeFacts`, `Checked`, `Semantic`, `InitialValues` and runtime assurance are
separate derived propositions. `interpreted_bound_assurance` obtains
`ReaderEffects` from the original completion leaf effect imports; it introduces
no semantic coverage premise. Function global preservation follows every exact
completion-order prefix and the original return's empty write mask, rather than
being inferred from the value-only function interface.

No additional raw arithmetic family was found in package signatures or formals:
`packageTypeAt` consumes one simple type mark, and signature parsing immediately
requires its separator. Named subtype declaration endpoints already appear in
the specification inventory. Raw function return expressions are retained by
`ResultValuesAt.function` and `ActualAt`, copied unchanged into
`RoutineCode.definition.results`, and enumerated by `phasedObligations` through
`actualsObligations`. Integer results include the expression's intermediate
arithmetic checks and result-subtype containment; Boolean results include their
condition obligations. Procedure copy-back reads local formal cells in original
formal order.

The Main String/Character/argument/Boolean correction and the separate package
routine-local raw-header correction are owned by the integration/source streams.
This report identifies the two Main omissions and the checked supplemental
helper; it does not assert that the final consumer has already been updated.
No proof or native run was launched for the read-only review. Review policy
selected Astra Max; live settings and separate review elapsed/token/cost data
are unavailable. This is not an independent review of the effects subthread's
own adapter or scalar-header helper.
