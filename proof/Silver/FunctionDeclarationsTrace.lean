module

public import Silver.ProcedureDeclarationTrace

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions Silver.Compose.Expressions

/-- The function projection retains its original source/checked/unique API.
The underlying mixed trace also retains every procedure for its own checking. -/
def FunctionDeclarationsAt (text : Source) (arguments : Bool) (state : ParserState)
    (definitions : List Definition) (final : ParserState) : Prop :=
  ∃ procedures, MixedDeclarationsAt text arguments state definitions procedures final

theorem functionDeclarationsLoop_source (text : Source) (arguments : Bool) (fuel : Nat)
    (state : ParserState) (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (declarationsLoop text arguments fuel state).position ≠ 0) :
    ∃ definitions, FunctionDeclarationsAt text arguments state definitions
      (declarationsLoop text arguments fuel state) := by
  obtain ⟨functions, procedures, source⟩ :=
    mixedDeclarationsLoop_source text arguments fuel state textValid valid accepted
  exact ⟨functions, procedures, source⟩

theorem functionDeclarations_source {text arguments state}
    (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (declarationsAt text state arguments).position ≠ 0) :
    ∃ definitions, FunctionDeclarationsAt text arguments state definitions (declarationsAt text state arguments) :=
  functionDeclarationsLoop_source text arguments _ state textValid valid accepted

theorem FunctionDeclarationsAt.callableTypesKnown {text arguments state definitions final}
    (source : FunctionDeclarationsAt text arguments state definitions final)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    CallableTypesKnown final := by
  obtain ⟨procedures, trace⟩ := source
  exact trace.callableTypesKnown textValid valid known

theorem FunctionDeclarationsAt.checked {text arguments state definitions final}
    (source : FunctionDeclarationsAt text arguments state definitions final)
    (textValid : ValidText text) (valid : ValidState text state) (known : CallableTypesKnown state) :
    DefinitionsChecked (catalogSignatures state.functions state.arrayNames.types) definitions ∧
      catalogSignatures final.functions final.arrayNames.types = catalogSignatures state.functions state.arrayNames.types ++ definitions.map Definition.signature := by
  obtain ⟨procedures, trace⟩ := source
  exact trace.functions_checked textValid valid known

theorem FunctionDeclarationsAt.unique {text arguments state left right leftFinal rightFinal}
    (a : FunctionDeclarationsAt text arguments state left leftFinal)
    (b : FunctionDeclarationsAt text arguments state right rightFinal) : left = right := by
  obtain ⟨leftProcedures, first⟩ := a
  obtain ⟨rightProcedures, second⟩ := b
  exact (first.unique second).1

end Silver.Compose
