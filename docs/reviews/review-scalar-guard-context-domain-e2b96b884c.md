# Native context domain mismatch — 2026-10-26

Static assessment of canonical `e2b96b884c205420c369e2369ef4f0bb38d85d84`
against native-author `src/silver_output_profile.adb` SHA256
`81481d9f9352edd5ae27aafb83064a91543b46cd4d7871c12a333f67dad6841d`.
Selected assessor: GPT-6 Astra, Extra High. Live settings, elapsed assessment
time, and token/cost measurements are not independently exposed. No proof runner
was used for this assessment. Flow-source author independently confirmed it.

## Missing implication

`PredicateNativeState.lean` defines `Native.ValidContext` using valid String
names, valid dynamic-name state, `ScalarExpression.ValidEnvironment`, and
`ScalarMetadata.BaseReady`. The latter, in `PredicateFlowInvariant.lean`,
requires mutable `Bounds = Declared_Bounds`, a declaration-prefix bound, and
nonempty intervals only in that prefix.

Native `Valid_Context` additionally calls `Valid_Mutable_Bounds`, which requires
every mutable binding's bounds to be nonempty, including a mutable binding
beyond `Declaration_Count`. `ValidEnvironment` checks spans and bounded Integer
endpoints; bounded empty intervals remain permitted.

## Concrete context-only counterexample

Take text `"a"`, no String names, dynamic span `(0, 0)`, and one scalar binding:

```
First = 1; After = 2; Bounds = (1, 0); Declared_Bounds = (1, 0);
Mutable = True; Is_Static = False;
Declaration_Count = 0
```

The old Lean `Native.ValidContext` holds: the scalar span is valid; both empty
intervals have bounded endpoints; mutable bounds equal declared bounds; and
the declaration prefix is empty. Native `Valid_Mutable_Bounds` is false because
the mutable interval is empty. This is a static mathematical witness, not a
claim of a newly executed Lean counterexample check.

For flow-taking calls, `FlowReady.contained` plus its mutable-cell nonemptiness
provides an actual contained value and therefore implies nonempty declared
bounds. Context-only helper interfaces, including `Bare_Target`, `Scalar_Target`,
`Body_String_Target`, and `Length_At`, do not have that flow premise.

The conditional Lean theorems remain valid. The gap is applicability of their
context-only native equations on an overly broad domain; this assessment does
not claim a reachable admitted-language execution with the counterexample.

## Authorized exact repair

Append an indexed mutable-nonempty requirement to `BaseReady`, preserving the
existing `Native.ValidContext` projection shape. Derive the exact native
mutable-bounds predicate using this field and `BodyReady` equality. Native
`Valid_Context` supplies the new requirement directly.

Preserve admitted-context coverage through header readiness and immutable loop
index append. Repair the existing constructors in `PredicateOuterReadiness`,
`PredicateHeaderFlow`, `PredicateBodyMeaning`, and `PredicateLoopFlowValidity`.
Do not add a suffix-immutable restriction to the general native domain or weaken
native contracts. Root assigned these five semantic files exclusively to the
flow-source author; validation, review, and issue closure remain pending.

The final source cohort separately retains exact `Valid_State`, `Valid_Context`,
`Valid_Flow`, `Valid_Body`, and newly explicit `Valid_Condition` source checks.
