module

public import Silver.ApplicationPackageImportCandidate
public import Silver.ApplicationPackageImportImports
public import Silver.OutputBodyCertificate
public import Silver.OutputSpecCertificate
import all Init.Data.Repr

@[expose] public section

namespace Silver.ApplicationPackageImport.SourceChecks
open SourceBridge

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem actual_checked : Native.Source.Checked Silver.Source.outputBodyTokens where
  trees := Native.trees_checked
  header := by
    refine Eq.trans ?_ Native.Source.candidate_checked.header
    decide +kernel
  body := by
    refine Eq.trans ?_ Native.Source.candidate_checked.body
    decide +kernel

theorem actual_specification :
    functionHeader "imported_package" ";" Silver.Source.outputSpecTokens = some (expectedTokens
      "(Main_Source : String) return String with Global => null, Post => Imported_Package'Result'First = 1 and then (Imported_Package'Result'Length = 0 or else Silver_Package_Bindings.Is_Identifier (Imported_Package'Result))") := by
  decide +kernel

structure CheckedSource : Prop where
  specification : Silver.Source.lex Silver.Source.outputProfileSpec = some Silver.Source.outputSpecTokens
  implementation : Silver.Source.lex Silver.Source.outputProfileBody = some Silver.Source.outputBodyTokens
  scanner : Native.Source.Checked Silver.Source.outputBodyTokens

theorem checked_source : CheckedSource :=
  ⟨Silver.Source.outputSpecTokens_correct, Silver.Source.outputBodyTokens_correct, actual_checked⟩

/-- The same tree bound to the original implementation has the interpreted
scanner meaning and a completed result within the source-derived loop bound. -/
theorem checked_execution (imports : ApplicationPackageImports.Imports)
    (outputCalls : Output.Calls) (output : Output.PrimitiveCalls)
    (sourceMeaning : Output.Expressions.PrimitiveInterpretation outputCalls output)
    (source : Source) (fuel : Nat) (enough : source.length + 2 ≤ fuel)
    (prior : ApplicationNative.Locals) :
    Native.Source.Checked Silver.Source.outputBodyTokens ∧
      Native.execute (importedCalls imports output) fuel prior source = Model.imported modelCalls fuel source ∧
      ∃ result, Native.execute (importedCalls imports output) fuel prior source = some result :=
  ⟨actual_checked, execute_imports imports outputCalls output sourceMeaning source fuel enough prior⟩

end Silver.ApplicationPackageImport.SourceChecks
