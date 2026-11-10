# Procedure report caller proof repair — 2026-11-10

Production-budget focused run `20261110T044716-a975e2f83ff2` failed on the
complete postconditions of `Record_OK` and `Mixed_Record_Congruence`; all other
selected obligations passed. The solvers exhausted their 100,000-step budgets.
The earlier exploratory 30-second run had the same outstanding obligations.
This packet retains the failed run, its exact source and complete-caller line
selector, full output and native report. It remains failed.

Commit `224a3b43bd` adds caller-local `Hide_Info` for the initializer and
procedure-output classifiers, following the existing list-policy abstraction.
`Record_OK` needs congruence at equal parsed fields. The mixed raw-report caller
uses the exact equalities supplied by the already-proved classifier helpers.
Hiding their bodies removes solver facts; it adds no assumption, changes no
executable behavior or contract, and leaves all obligations required. The native
proof author, selected Astra Max, checked this bounded approach before the edit;
that is a conceptual peer check, not final independent acceptance.

The exact annotation-target policy and its existing rejection controls were
updated together. Focused run `20261110T064902-721f8e13e659` passed all three
`CompilerHideInfoPolicyTests` methods on Linux. The complete-caller native retry
is `20261110T064952-f310bd0d591b`, at two workers with unchanged production prover
settings. Its outcome and the complete final native checkpoint remain pending.
