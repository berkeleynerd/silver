module

public import Silver.ApplicationAdmissionSourceShape
public import Silver.OutputSpecCertificate
public import Silver.OutputBodyCertificate
import all Init.Data.Repr

@[expose] public section

/-! Exact original-source binding for Analyze_Application, its four public
aliases, and the complete analysis-result representation. The wrapper's
execution equation and its callee interpretations are composed separately. -/
namespace Silver.ApplicationAdmission.Native.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem actual_checked : Checked Silver.Source.outputSpecTokens Silver.Source.outputBodyTokens where
  trees := checked_trees
  wrapperHeader := by decide +kernel
  wrapperBody := by
    simp only [analyzeBody, Body.render, Command.list, List.foldr, Command.render, Command.renderElse]
    decide +kernel
  aliasHeaders := by
    intro entry member
    simp only [aliases, List.mem_cons, List.not_mem_nil, or_false] at member
    rcases member with rfl | rfl | rfl | rfl
    all_goals decide +kernel
  aliasBodies := by
    intro entry member
    simp only [aliases, List.mem_cons, List.not_mem_nil, or_false] at member
    rcases member with rfl | rfl | rfl | rfl
    all_goals decide +kernel
  record := by decide +kernel
  invalid := by decide +kernel

structure CheckedSource : Prop where
  specification : Silver.Source.lex Silver.Source.outputProfileSpec = some Silver.Source.outputSpecTokens
  implementation : Silver.Source.lex Silver.Source.outputProfileBody = some Silver.Source.outputBodyTokens
  admission : Checked Silver.Source.outputSpecTokens Silver.Source.outputBodyTokens

theorem checked_source : CheckedSource :=
  ⟨Silver.Source.outputSpecTokens_correct, Silver.Source.outputBodyTokens_correct, actual_checked⟩

end Silver.ApplicationAdmission.Native.SourceChecks
