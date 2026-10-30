module

public import Silver.ComposeBooleanDeclarationNative
public import Silver.ComposeBounds

@[expose] public section

/-! Pointwise imported-call normalization for the ordinary declaration body.
The condition-reader premise is restricted to the exact initializer call after
its executable guard. The downstream source bridge derives it from the native
condition interpretation, including its full elaboration-domain preconditions. -/
namespace Silver.Compose.BooleanDeclarationNative
open Predicate Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

structure LexicalMeaning (imports : Imports) (text : Source) : Prop where
  skip : ∀ position, ValidCursor text position → imports.skip text position = skipAt text position
  nameAfter : ∀ position, ValidCursor text position → imports.nameAfter text position = Compose.nameAfter text position
  take : ∀ position token, ValidCursor text position →
    imports.take text position token = tokenAfter text position token.shell

theorem Token.taken_bound (text : Source) (position : Nat) (token : Token) :
    ValidCursor text (tokenAfter text position token.shell) := by
  cases token <;> exact fixedAfter_result_bound text _ _ _ (by decide)

theorem parts_meaning (imports : Imports) (text : Source) (state : ParserState)
    (lexical : LexicalMeaning imports text) (bounded : ValidCursor text state.position) :
    parts imports text state = booleanDeclarationParts text state := by
  have firstBound := model_skip_valid text state.position bounded
  have afterBound := model_name_valid text (skipAt text state.position)
  have colonBound := Token.taken_bound text (nameAfter text (skipAt text state.position)) .colon
  have constantBound := Token.taken_bound text
    (tokenAfter text (nameAfter text (skipAt text state.position)) Token.colon.shell) .constantKeyword
  have typeInputBound : ValidCursor text
      (if tokenAfter text (tokenAfter text (nameAfter text (skipAt text state.position)) Token.colon.shell)
          Token.constantKeyword.shell ≠ 0 then
        tokenAfter text (tokenAfter text (nameAfter text (skipAt text state.position)) Token.colon.shell)
          Token.constantKeyword.shell else tokenAfter text (nameAfter text (skipAt text state.position)) Token.colon.shell) := by
    split <;> assumption
  have typeFirstBound := model_skip_valid text _ typeInputBound
  dsimp only [parts]
  rw [lexical.skip _ bounded, lexical.nameAfter _ firstBound, lexical.take _ .colon afterBound,
    lexical.take _ .constantKeyword colonBound, lexical.skip _ typeInputBound,
    lexical.take _ .booleanName typeFirstBound, lexical.take _ .assignment (Token.taken_bound text _ .booleanName)]
  rfl

/-- Each field is an imported call at an executed source argument, rather than
an assumed equivalence of the declaration scanner. The native constructor must
prove the condition field from its checked body, helper calls and contracts. -/
structure ImportsMeaning (imports : Imports) (text : Source) (state : ParserState)
    (arguments : Bool) : Prop where
  lexical : LexicalMeaning imports text
  position : ValidCursor text state.position
  newName : let p := booleanDeclarationParts text state
    imports.newName text state p.first p.after arguments = newNameAllowed text state p.first p.after arguments
  nameIsBoolean : let p := booleanDeclarationParts text state
    imports.nameIsBoolean text p.first p.after = Named.nameIs text p.first p.after ("boolean".toList.map Char.toNat)
  lookup : ∀ kind, let p := booleanDeclarationParts text state
    imports.lookup kind text state p.typeFirst p.typeAfter = BooleanDeclarationNative.lookup kind text state p.typeFirst p.typeAfter
  context : imports.contextOf ⟨state, false, false⟩ = contextOf ⟨state, false, false⟩
  initial : let p := booleanDeclarationParts text state
    imports.initialFlow (elaborationContext modelImports state p) = booleanDeclarationFacts state
  condition : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = true →
    imports.conditionInto text (elaborationContext modelImports state (booleanDeclarationParts text state))
      (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state)
      state.scalarNames.length state.arrayNames.values = booleanDeclarationValue text state
  following : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = true →
    imports.take text (booleanDeclarationValue text state).after .semicolon = booleanDeclarationFollowing text state
  invalid : imports.invalid = invalidState

theorem reject_meaning (imports : Imports) (text : Source) (state : ParserState) (arguments : Bool)
    (meaning : ImportsMeaning imports text state arguments) :
    reject imports text state arguments (booleanDeclarationParts text state) =
      !booleanDeclarationReady text state arguments (booleanDeclarationParts text state) := by
  rw [← model_reject]
  dsimp +instances only [reject, modelImports]
  simp only [meaning.newName, meaning.nameIsBoolean, meaning.lookup]

theorem imports_meaning (imports : Imports) (text : Source) (state : ParserState) (arguments : Bool)
    (meaning : ImportsMeaning imports text state arguments) :
    body.eval imports {text, state, arguments} = booleanDeclarationAt text state arguments := by
  have context : elaborationContext imports state (booleanDeclarationParts text state) =
      elaborationContext modelImports state (booleanDeclarationParts text state) := by
    unfold elaborationContext
    rw [meaning.context]
    rfl
  rw [denotation]
  simp only [equation, parts_meaning imports text state meaning.lexical meaning.position,
    reject_meaning imports text state arguments meaning]
  unfold booleanDeclarationAt
  dsimp only
  by_cases ready : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = true
  · simp only [ready, Bool.not_true, Bool.false_eq_true, ↓reduceIte, context,
      meaning.initial, meaning.condition ready, meaning.following ready, meaning.invalid,
      addBooleanBinding]
  · have rejected : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = false :=
      Bool.eq_false_iff.mpr ready
    simp only [rejected, Bool.not_false, ↓reduceIte, meaning.invalid]

end Silver.Compose.BooleanDeclarationNative
