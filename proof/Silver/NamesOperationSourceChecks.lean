module

public import Silver.NamesEquations
public import Silver.NamesSourceShape
public import Silver.SourceDeclarations
public import Silver.NamesSpecCertificate
public import Silver.NamesBodyCertificate
import all Init.Data.Repr

@[expose] public section

/-! Focused actual-source check of the shared operation reader. This uses only
Names certificates; NamesSourceBridge retains the separate complete imported
identifier/context source closure for the shared full-source checkpoint. -/
namespace Silver.Names.OperationSourceChecks
open Silver.SourceBridge

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

structure CheckedOperation : Prop where
  specification : Source.lex Source.namesSpec = some Source.namesSpecTokens
  implementation : Source.lex Source.namesBody = some Source.namesBodyTokens
  reviewedShape : Source.namesSpecTokens = SourceShape.spec ∧ Source.namesBodyTokens = SourceShape.body
  wellFormed : Native.WellFormedTrees
  wellScoped : Native.WellScopedTrees
  operation : Source.expressionBody "operation_after" Source.namesBodyTokens = some Native.operationBody.render
  operationName : Source.expressionBody "operation_name" Source.namesBodyTokens = some Native.nameBody.render
  specificationHeader : functionHeader "operation_after" ";" Source.namesSpecTokens = some (expectedTokens
    "(Text : String; Position : Literal_Position; Operation : Operation_Kind; Hidden : Boolean; Context_First : Cursor := 1; Package_First, Package_After : Literal_Position := 0) return Literal_Position with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Context_First <= Text'Last + 1 and then Valid_Name_State (Text, Package_First, Package_After), Post => Operation_After'Result = 0 or else Operation_After'Result in Position + 1 .. Text'Last + 1")
  implementationHeader : functionHeader "operation_after" "is" Source.namesBodyTokens = some (expectedTokens
    "(Text : String; Position : Literal_Position; Operation : Operation_Kind; Hidden : Boolean; Context_First : Cursor := 1; Package_First, Package_After : Literal_Position := 0) return Literal_Position")

theorem checked_operation : CheckedOperation where
  specification := Source.namesSpecTokens_correct
  implementation := Source.namesBodyTokens_correct
  reviewedShape := by decide +kernel
  wellFormed := Native.checked_precedence
  wellScoped := Native.checked_scopes
  operation := by decide +kernel
  operationName := by decide +kernel
  specificationHeader := by decide +kernel
  implementationHeader := by decide +kernel

/-- The matched operation body has the full native-domain interpretation,
including absent/invalid context results and optional package spans. The imported
source meanings remain explicit, as in the complete Names source bridge. -/
theorem checked_operation_meaning (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (valid : ValidText text) (position : Nat) (operation : Operation)
    (hidden : Bool) (contextFirst packageFirst packageAfter : Nat)
    (bound : position ≤ text.length + 1)
    (contextValid : ValidContext text contextFirst packageFirst packageAfter) :
    CheckedOperation ∧
      calls.operationAfter text position operation hidden contextFirst packageFirst packageAfter =
        operationAfter text position operation hidden contextFirst packageFirst packageAfter :=
  ⟨checked_operation, interpreted_operation calls source text valid position operation hidden
    contextFirst packageFirst packageAfter bound contextValid⟩

end Silver.Names.OperationSourceChecks
