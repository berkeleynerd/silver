# Bounded semantic/native peer check — 2026-11-10

Reviewed semantic commit: `a71e3ccfbf4051628fc9f509d903e57d53011c45`.
Native comparison: `src/silver_output_profile.adb` at `95d84db1f8963113ab43afa2bcf1478577f05574`
(parser implementation last changed at `91fd84a7e5`). This is a read-only peer
comparison by the native author, not the semantic author, limited to the lead's
four requested interfaces. Selected subthread setting: Astra Max; runtime model
and effort are not independently exposed in this resumed context. Separate elapsed,
token and cost measurements were not captured. No proof run was started for this
review, and the existing native run `20261110T002858-36ecd7c485a1` remained active.

No consequential mismatch found in the bounded scope:

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
not assumptions discharged by this peer comparison or evidence of a newly found
semantic defect. Native complete contracts, complete Lean/source checks and final
independent critical review remain separate requirements.
