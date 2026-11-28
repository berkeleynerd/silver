# Metadata abstraction source-policy repair — 2026-11-28

The timeout-policy auditor run exposed an existing integration omission in
`e35fd0a741`: `Audit_Normalized_Report` hides the expression bodies of
`Application_Metadata.Valid` and `Application_Metadata.Owned_Views_Match`, while
the Python source-policy auditor only recognizes its listed unqualified names.
The unchanged baseline auditor rejects the same source. The failed 79-test run
is retained in [the timeout packet](../native-timeout-policy/README.md).

The repair adds only those two complete qualified annotation forms, only in
`silver_library_reports.adb`. Both predicates remain executable guards with
identical arguments in the declarative `Object_Policy`. Hiding their definitions
adds no facts and suppresses no obligation. Native source is unchanged; complete
native discharge remains required. The [independent review](../metadata-abstraction-source-review.md)
checks the exact repair and its annotation semantics.

Managed run `20261128T004851-ac8b9ff03797` passed all 79 auditor tests with two
automatically allocated workers on guest CPUs 4–5. Existing tests now exercise
both qualified names, case/layout variation, incomplete statements, changed
packages/targets/annotation forms, and wrong source files. Its log and events are
retained here. This is Python audit validation, not a new native proof result.

Keep the active native run's script inputs frozen. This repair and the timeout
change are prepared separately for integration at its terminal boundary.
