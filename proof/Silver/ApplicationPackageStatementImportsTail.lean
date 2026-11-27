module

public import Silver.ApplicationPackageStatementImportsTotalized
public import Silver.PredicateAdapter

@[expose] public section

namespace Silver.ApplicationPackageBodies.StatementImports
open Compose Compose.Expressions Predicate

/-- Original At_Body_Stop expression, using the existing interpreted token
callee. This is a source-body equation, not a stop-recognizer postcondition. -/
structure StopLibrary (inherited : Inherited.Libraries) where
  call : Source → Nat → BodyStop → Bool
  source : ∀ text, ValidText text → ∀ position, ValidCursor text position → ∀ stop,
    call text position stop = Adapter.atStopExpr.eval inherited.calls.body
      {text, position, stop} (takeTokenCall := inherited.inherited.function .takeToken)

namespace StopLibrary

theorem meaning {inherited : Inherited.Libraries} (library : StopLibrary inherited)
    (text : Source) (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position)
    (stop : BodyStop) : library.call text position stop = atBodyStop text position stop := by
  rw [library.source text valid position bounded stop]
  have ended := interpreted_take _ inherited.source text valid position (.word "end") bounded
    (by unfold ValidToken; decide)
  have alternative := interpreted_take _ inherited.source text valid position (.word "else") bounded
    (by unfold ValidToken; decide)
  have arm := interpreted_take _ inherited.source text valid position (.word "elsif") bounded
    (by unfold ValidToken; decide)
  have returned := interpreted_take _ inherited.source text valid position (.word "return") bounded
    (by unfold ValidToken; decide)
  dsimp only [ShellToken.word, spelling, isWord] at ended alternative arm returned
  cases stop <;>
    simp [Adapter.atStopExpr, Adapter.Expr.eval, ShellToken.word, ended, alternative, arm, returned,
      atBodyStop]

noncomputable def interpreted {inherited : Inherited.Libraries} (library : StopLibrary inherited)
    (text : Source) (position : Nat) (stop : BodyStop) : Bool :=
  extend (LoopNative.CursorDomain text position) (library.call text position stop) (atBodyStop text position stop)

theorem interpreted_native {inherited : Inherited.Libraries} (library : StopLibrary inherited)
    (text : Source) (valid : ValidText text) (position : Nat) (bounded : ValidCursor text position)
    (stop : BodyStop) : library.interpreted text position stop = library.call text position stop :=
  extend_native ⟨valid, bounded⟩

theorem interpreted_meaning {inherited : Inherited.Libraries} (library : StopLibrary inherited) :
    library.interpreted = atBodyStop := by
  funext text position stop
  apply extend_model
  intro valid
  exact library.meaning text valid.1 position valid.2 stop

/-- The whole original expression, not merely its observed result, provides a
canonical source interpretation for any already-bound inherited dictionary. -/
def expression (inherited : Inherited.Libraries) : StopLibrary inherited where
  call text position stop := Adapter.atStopExpr.eval inherited.calls.body {text, position, stop}
    (takeTokenCall := inherited.inherited.function .takeToken)
  source _ _ _ _ _ := rfl

end StopLibrary
end Silver.ApplicationPackageBodies.StatementImports
