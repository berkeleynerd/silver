module

public import Silver.ComposeSourceBridge
public import Silver.ComposeModelEquations
public import Silver.ComposeModelRanges
public import Silver.ComposeModelLegal

@[expose] public section

/-! A concrete inhabitant of the composed source-interpretation interface.
The helper equations, range contracts and executed lexical-call domains are
proved independently. Actual Ada/frontend interpretation remains the documented
premise of correspondence for arbitrary implementation callees. -/

namespace Silver.Compose.SourceBridge

theorem model_interpreted : InterpretedSource Expressions.modelCalls where
  lexical := ⟨Guarded.Expressions.modelCalls, fixedAt, rfl, Lexical.model_interpreted⟩
  definitions := Expressions.model_definitions Expressions.model_ranges
  legal := Expressions.model_legal

end Silver.Compose.SourceBridge
