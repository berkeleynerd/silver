module

public import Silver.ProcedureNameFreeNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

namespace Silver.Predicate.ProcedureNameNative.SourceChecks
open Silver.SourceBridge

def headers : List (String × String × List String) := [
  ("actual_name_step", ";", expectedTokens "(Text : String; Position, After, Target_First, Target_After : Literal_Position) return Name_Scan_Step with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then After <= Text'Last + 1 and then Target_First > 0 and then Valid_Name_State (Text, Target_First, Target_After), Post => Actual_Name_Step'Result.Next = 0 or else Actual_Name_Step'Result.Next in Position + 1 .. After"),
  ("actual_name_step", "is", expectedTokens "(Text : String; Position, After, Target_First, Target_After : Literal_Position) return Name_Scan_Step"),
  ("actual_name_free_model", ";", expectedTokens "(Text : String; Position, After, Target_First, Target_After : Literal_Position) return Boolean with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then After <= Text'Last + 1 and then Target_First > 0 and then Valid_Name_State (Text, Target_First, Target_After), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position)"),
  ("actual_name_free_model", "is", expectedTokens "(Text : String; Position, After, Target_First, Target_After : Literal_Position) return Boolean"),
  ("actual_name_free", ";", expectedTokens "(Text : String; First, After, Target_First, Target_After : Literal_Position) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then First <= Text'Last + 1 and then After <= Text'Last + 1 and then Target_First > 0 and then Valid_Name_State (Text, Target_First, Target_After), Post => (Static => Actual_Name_Free'Result = Actual_Name_Free_Model (Text, First, After, Target_First, Target_After))"),
  ("actual_name_free", "is", expectedTokens "(Text : String; First, After, Target_First, Target_After : Literal_Position) return Boolean")]

/-- The exact imperative loop and its complete contract are retained alongside
the recursive tree. The static equality is a native proof obligation. -/
def loopBody : List String := expectedTokens
  "Position : Literal_Position := First; begin if Position = 0 or else Position > After then return False; end if; while Position < After loop pragma Loop_Invariant (Position in First .. After); pragma Loop_Invariant (Static => Actual_Name_Free_Model (Text, First, After, Target_First, Target_After) = Actual_Name_Free_Model (Text, Position, After, Target_First, Target_After)); pragma Loop_Variant (Increases => Position); declare Next : constant Name_Scan_Step := Actual_Name_Step (Text, Position, After, Target_First, Target_After); begin if Next.Next = 0 or else not Next.Free then return False; end if; Position := Next.Next; end; end loop; return True; end Actual_Name_Free;"

structure Checked (tokens : List String) : Prop where
  stepTree : stepBody.checked parameters parameters = true
  modelTree : freeBody.checked parameters = true
  headers : ∀ item ∈ headers, functionHeader item.1 item.2.1 tokens = some item.2.2
  record : Silver.Lexical.SourceBridge.recordDeclaration "name_scan_step" tokens =
    some (expectedTokens "record Next : Literal_Position; Free : Boolean; end record")
  step : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "actual_name_step" tokens =
    some (stepBody.render ++ ["end", "actual_name_step", ";"])
  model : Source.expressionBody "actual_name_free_model" tokens = some freeBody.render
  loop : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "actual_name_free" tokens = some loopBody

/-- Source shapes and complete-domain native equations are both required. This
theorem does not identify a finished scanner with its model as a premise. -/
theorem checked_scanner (tokens : List String) (checked : Checked tokens) :
    Checked tokens ∧ ∀ {domain : Compose.Expressions.StateDomain}
      (calls : Compose.Expressions.Calls),
      Compose.Expressions.RawHelperEquations calls (domain := domain) →
      ∀ step model scan, FreeDefinitionEquations calls step model scan →
      ∀ text position after targetFirst targetAfter,
        StepDomain text position after targetFirst targetAfter →
        scan text position after targetFirst targetAfter = actualNameFree text position after targetFirst targetAfter := by
  refine ⟨checked, ?_⟩
  intro domain calls inherited step model scan definitions text position after targetFirst targetAfter valid
  exact interpreted_free calls inherited step model scan definitions text position after targetFirst targetAfter valid

end Silver.Predicate.ProcedureNameNative.SourceChecks
