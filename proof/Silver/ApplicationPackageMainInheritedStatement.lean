module

public import Silver.ApplicationPackageBasicSyntax
public import Silver.ApplicationPackageMainIdentities

@[expose] public section

namespace Silver.Applications
open Predicate Packages

theorem function_statement_extend {shape : Bindings.Shape} {analysis : Integer.Analysis}
    {before after : Flow} {booleans : Boolean.Analysis} {functions : ScalarFunctions.Signatures}
    {procedures : ScalarProcedures.Signatures} {update : ScalarFunctions.Assignment}
    (extraFunctions : ScalarFunctions.Signatures) (extraProcedures : ScalarProcedures.Signatures)
    (checked : (Statement.callAssign update).check shape analysis before booleans functions procedures = some after) :
    (Statement.callAssign update).check shape analysis before booleans
      (functions ++ extraFunctions) (procedures ++ extraProcedures) = some after := by
  simp only [Statement.check] at checked ⊢
  split at checked
  · rename_i accepted
    obtain ⟨extended, same⟩ := local_function_check extraFunctions accepted
    simp only [extended, ite_true, same]
    exact checked
  · contradiction

theorem procedure_statement_extend {shape : Bindings.Shape} {analysis : Integer.Analysis}
    {before after : Flow} {booleans : Boolean.Analysis} {functions : ScalarFunctions.Signatures}
    {procedures : ScalarProcedures.Signatures} {call : ScalarProcedures.Call}
    (extraFunctions : ScalarFunctions.Signatures) (extraProcedures : ScalarProcedures.Signatures)
    (checked : (Statement.procedureCall call).check shape analysis before booleans functions procedures = some after) :
    (Statement.procedureCall call).check shape analysis before booleans
      (functions ++ extraFunctions) (procedures ++ extraProcedures) = some after := by
  simp only [Statement.check] at checked ⊢
  split at checked
  · rename_i accepted
    obtain ⟨extended, same⟩ := local_procedure_check extraProcedures accepted
    simp only [extended, ite_true, same]
    exact checked
  · contradiction

/-- Every original inherited leaf preserves its exact output when the package
callable tables are appended to the local tables. This covers local calls as
well as all existing scalar, array, String and external-operation leaves. -/
theorem inherited_statement_extend {text context scan item result catalog nativeProcedures}
    (source : BasicStepAt text context scan item result catalog nativeProcedures)
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {before after : Flow}
    {booleans : Boolean.Analysis} {functions : ScalarFunctions.Signatures}
    {procedures : ScalarProcedures.Signatures}
    (extraFunctions : ScalarFunctions.Signatures) (extraProcedures : ScalarProcedures.Signatures)
    (checked : item.lower.check shape analysis before booleans functions procedures = some after) :
    item.lower.check shape analysis before booleans
      (functions ++ extraFunctions) (procedures ++ extraProcedures) = some after := by
  cases source.payload with
  | primitive _ payload =>
    cases payload <;> simp only [SourceStatement.lower] at checked ⊢
    all_goals first
      | exact function_statement_extend extraFunctions extraProcedures checked
      | simpa only [Statement.check] using checked
  | procedure _ _ =>
    simp only [SourceStatement.lower] at checked ⊢
    exact procedure_statement_extend extraFunctions extraProcedures checked

end Silver.Applications
