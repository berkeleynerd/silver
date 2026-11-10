# Bounded semantic/native peer check — 2026-11-10

Reviewed semantic commit: `a71e3ccfbf4051628fc9f509d903e57d53011c45`.
Native comparison: `src/silver_output_profile.adb` at `95d84db1f8963113ab43afa2bcf1478577f05574`
(parser implementation last changed at `91fd84a7e5`). This is a read-only peer
comparison by the native author, not the semantic author, limited to the lead's
four requested interfaces. Selected subthread setting: Astra Max; runtime model
and effort are not independently exposed in this resumed context. Separate elapsed,
token and cost measurements were not captured. No proof run was started for this
review, and the existing native run `20261110T002858-36ecd7c485a1` remained active.

The initial pass concluded: **No consequential mismatch found in the bounded
scope.** That assessment and its structural correspondences are retained below as
history. The dated follow-up supersedes that conclusion for prefix refinability.

- **Prefix frame and order:** native `Procedure_Input_Frame` skips `out` formals
  and appends initialized inputs after locals; `Procedure_Prefix` visits outputs
  in declaration order and calls every RHS using the original frozen `Frame`.
  Semantic `Definition.inputAnalysis` / `inputFrame`, `outTypes`, `prefixCheck`
  and `frame` match this split. `checkActuals` checks exact arity against the same
  incoming flow; `frame` evaluates the complete initializer list in `prefixState`
  before binding any output. `outputTargets` restores original writable-formal
  order while tracking separate Integer/Boolean input and output counters.
- **Full-domain body entry:** native `Append_Procedure_Parameter` installs formal
  bounds and `Context_Of` / `Body_Environment` widens mutable entries. Semantic
  `parameterAnalysis`, `Definition.analysis` and `initialFlow` use those declared
  domains. Prefix results do not become body invariants. `DefinitionsSafe` and
  `Definition.execution_sound` quantify over every fitting input tuple, including
  unused definitions. Both paths require a nonempty ordinary body if there are no
  leading output assignments, and permit the prefix itself to supply Ada's
  required statement when outputs exist.
- **Input and copy-back ranges:** native `Procedure_Actuals_After` retains the
  original `Facts` for every actual; `Procedure_Target_Actual` checks incoming
  containment for `in out` and full formal-range containment in each writable
  object's declared range. Semantic `bindActuals`, `Call.check`, `checkActuals`
  and `checkTargets` enforce the same two directions. Both caller updates install
  complete formal intervals, leave Boolean predicate relations absent and retain
  unrelated state. In-input immutability agrees in both parameter analyses.
- **Body visibility:** native procedure bodies receive only earlier function and
  procedure tables from the pre-declaration state; functions pass an empty
  procedure catalogue. Semantic procedure definitions retain `functionCount`,
  check and execute against that function prefix, and `compileFrom` constructs
  procedures against the exact earlier procedure environment. Closed scalar-only
  statement checks exclude capture, I/O and input access; function scalar-only
  checks continue to exclude procedure calls.

The still-pending source construction must derive initializer/target identities,
`functionCount`, exact earlier procedure prefixes, lexical name hiding and source
order from accepted source. Those are expected source-correspondence obligations,
not assumptions discharged by this peer comparison. They remain separate from
the confirmed prefix-refinement mismatch below. Native complete contracts, complete Lean/source checks and final
independent critical review remain separate requirements.

## 2026-11-10 follow-up: immutable input refinement in Boolean prefix RHSs

The semantic/source peer identified a distinction this initial native-author pass
missed. `Procedure_Prefix_Step` uses `Context_Of(Read_Frame)` without overriding
`Declaration_Count`, so that count includes all input formals. `Bare_Target` then
refines only mutable bindings; an immutable `in` formal is not guard-refinable
within a Boolean prefix RHS. Ordinary body checking correctly sets the count to
locals only, allowing immutable formals to refine on guarded paths.

At the reviewed semantic commit, `Definition.prefixCheck` uses `inputAnalysis`,
whose `parameterAnalysis` makes formals refinable. Therefore it models ordinary
short-circuit refinement for immutable inputs in prefix expressions, while the
reviewed native parser rejects such expressions when their safety needs it.

Direct checks against the retained native executable confirmed all three
controls using `subtype Den is Integer range 0..1`:

- `N:in Den; B:out Boolean` with prefix
  `B:=N>0 and then (1/N)=1;`: rejected, exit 2.
- The same immutable-input expression in the ordinary body after prefix
  `B:=False;`: accepted, exit 0.
- `N:in out Den` with the guarded expression in the prefix: accepted, exit 0.

The frozen-frame requirement does not imply disabling refinement inside each
individual RHS. The recommended minimal repair is to thread the known local
declaration count through the three prefix helpers and use it in the RHS context,
matching the ordinary-body treatment while preserving the same frozen read frame
and full declared formal domains. This needs fresh complete-helper checks and
updated source correspondence; the active pre-repair proof remains evidence only
for its original inputs. The lead selected this native correction, and the implementation now threads that
count through the prefix helpers. Managed build `20261110T011921-1abbf6ac3b3b` and
regression `20261110T012006-51adf33fb7b7` passed all five controls: immutable-in
prefix, ordinary-body, in-out prefix and false short-circuit prefix accept; the
unguarded division rejects. [Retained evidence](../evidence/scalar-procedures-20261109/prefix-refinement-repair/result.json).
Complete changed-helper/caller verification and full assurance remain pending.
