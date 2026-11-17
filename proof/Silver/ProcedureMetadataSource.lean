module

public import Silver.ProcedureMetadataNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

namespace Silver.Predicate.ProcedureMetadataNative.SourceChecks
open Silver.SourceBridge

def specHeaders : List (String × List String) := [
  ("procedure_model", expectedTokens "(Source : String) return Silver_Procedure_Bindings.Metadata with Ghost => Static, Global => null"),
  ("local_procedures", expectedTokens "(Source : String) return Silver_Procedure_Bindings.Metadata with Global => null, Post => (Static => Local_Procedures'Result = Procedure_Model (Source))")]

def bodyHeaders : List (String × String × List String) := [
  ("procedure_model", "is", expectedTokens "(Source : String) return Procedures.Metadata"),
  ("local_procedures", "is", expectedTokens "(Source : String) return Procedures.Metadata"),
  ("read_form", ";", expectedTokens "(Source : String; Form : Form_Kind) return Scan_Result with Global => null, Post => (Static => Read_Form'Result = Form_Result (Source, Form))")]

/-- The expression-function extractor removes precisely the outer source
parentheses; the renderer retains them for occurrences inside ordinary code. -/
def modelTokens : List String := (modelBody.render.drop 1).dropLast

structure Checked (specification implementation : List String) : Prop where
  scope : modelBody.scoped ["source"] = true ∧ executableBody.scoped ["source"] = true
  specHeaders : ∀ item ∈ specHeaders, functionHeader item.1 ";" specification = some item.2
  bodyHeaders : ∀ item ∈ bodyHeaders, functionHeader item.1 item.2.1 implementation = some item.2.2
  model : expressionDeclaration "procedure_model" implementation = some (modelTokens, [])
  executable : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "local_procedures" implementation =
    some (executableBody.render ++ ["end", "local_procedures", ";"])

end Silver.Predicate.ProcedureMetadataNative.SourceChecks
