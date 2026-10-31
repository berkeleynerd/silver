# Boolean integration: scalar declaration equation

2026-10-30, review input `33649e1ee5` and the unchanged scalar declaration
bodies on that branch. The source-integration subthread identified this while
investigating the failed denotation proof; the declaration-bridge subthread
independently compared the same three definitions. Both selected GPT-6 Astra /
Extra High. Runtime confirmation and separate review time/token/cost totals
are unavailable.

**M1, medium:** `ComposeScalarDenotations.scalarDeclarationEquation` adds a
final Boolean lookup rejection absent from the actual Ada
`Scalar_Declaration_At`, the typed `scalarDeclarationBody`, and the independent
`ComposeAdmission.scalarDeclarationAt`. `Scalar_Type_At` already checks Boolean
hiding. The auxiliary equation must describe the actual body even for arbitrary
callee interpretations, so the extra clause makes its unconditional denotation
theorem false. Repeated reduction attempts exhausted elaboration limits before
exposing the unequal expressions; this was not merely a resource problem.

Remove the extra clause from this auxiliary equation, preserve the Ada, typed
tree and admission rules, and check the original denotation proof plus its
consumers. No compiler behavior defect or delivered assurance failure was
demonstrated. The unpublished Boolean source checkpoint remains incomplete;
retain the failed/interrupted attempts with their actual outcomes.
