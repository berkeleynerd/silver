module

public import Silver.FunctionSourceUnique

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions Silver.Compose.Expressions

/-- A nonfunction declaration leaves the complete callable metadata unchanged. -/
theorem declarationAt_functions_of_no_function {text state arguments}
    (noFunction : (functionDeclarationAt text state arguments).position = 0)
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).functions = state.functions := by
  dsimp only [declarationAt] at accepted ⊢
  rw [ite_eq_right (not_not_intro noFunction)] at accepted ⊢
  split at accepted
  · rename_i positive
    rw [ite_eq_left positive]
    have source := subtype_declaration_sound text state arguments positive
    generalize nextEq : subtypeDeclarationAt text state arguments = next at source ⊢
    cases source
    rfl
  · rename_i noSubtype
    rw [ite_eq_right noSubtype]
    split at accepted
    · rename_i positive
      rw [ite_eq_left positive]
      obtain ⟨declaration, source⟩ := scalar_declaration_sound text state arguments positive
      generalize nextEq : scalarDeclarationAt text state arguments = next at source ⊢
      cases source
      rfl
    · rename_i noScalar
      rw [ite_eq_right noScalar]
      split at accepted
      · rename_i positive
        rw [ite_eq_left positive]
        exact arrayDeclarationAt_functions positive
      · rename_i noArray
        rw [ite_eq_right noArray]
        split at accepted
        · rename_i positive
          rw [ite_eq_left positive]
          have source := boolean_declaration_sound text state arguments positive
          generalize nextEq : booleanDeclarationAt text state arguments = next at source ⊢
          cases source
          rfl
        · rename_i noBoolean
          rw [ite_eq_right noBoolean]
          split at accepted
          · rename_i positive
            rw [ite_eq_left positive]
            obtain ⟨declaration, source⟩ := character_declaration_sound text state arguments positive
            generalize nextEq : characterDeclarationAt text state arguments = next at source ⊢
            cases source
            rfl
          · rename_i noCharacter
            rw [ite_eq_right noCharacter]
            obtain ⟨declaration, source⟩ := string_declaration_sound text state arguments accepted
            generalize nextEq : stringDeclarationAt text state arguments = next at source ⊢
            cases source
            rfl

/-- Every accepted function is retained in declaration order, including unused
ones. Ordinary steps follow the exact selected scanner and cannot skip a
successful function declaration. -/
inductive FunctionDeclarationsAt (text : Source) (arguments : Bool) :
    ParserState → List Definition → ParserState → Prop
  | done {state} : state.position ≠ 0 → fixedAfter text state.position "begin" true ≠ 0 →
      FunctionDeclarationsAt text arguments state [] state
  | function {state final definition rest} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true = 0 →
      FunctionDeclarationSource text state arguments definition →
      FunctionDeclarationsAt text arguments (functionDeclarationAt text state arguments) rest final →
      FunctionDeclarationsAt text arguments state (definition :: rest) final
  | other {state final rest} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true = 0 →
      (functionDeclarationAt text state arguments).position = 0 →
      (declarationAt text state arguments).position ≠ 0 →
      FunctionDeclarationsAt text arguments (declarationAt text state arguments) rest final →
      FunctionDeclarationsAt text arguments state rest final

theorem FunctionDeclarationSource.accepted {text state arguments definition}
    (source : FunctionDeclarationSource text state arguments definition) :
    (functionDeclarationAt text state arguments).position ≠ 0 := by
  cases source
  assumption

theorem functionDeclarationsLoop_source (text : Source) (arguments : Bool) (fuel : Nat)
    (state : ParserState) (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (declarationsLoop text arguments fuel state).position ≠ 0) :
    ∃ definitions, FunctionDeclarationsAt text arguments state definitions
      (declarationsLoop text arguments fuel state) := by
  induction fuel generalizing state with
  | zero => simp [declarationsLoop, invalidState] at accepted
  | succ fuel ih =>
    by_cases positive : state.position = 0
    · simp [declarationsLoop, positive, invalidState] at accepted
    · by_cases stop : fixedAfter text state.position "begin" true ≠ 0
      · refine ⟨[], ?_⟩
        simpa [declarationsLoop, positive, stop] using FunctionDeclarationsAt.done positive stop
      · by_cases failed : (declarationAt text state arguments).position = 0
        · simp [declarationsLoop, positive, stop, failed, invalidState] at accepted
        · have remaining : (declarationsLoop text arguments fuel (declarationAt text state arguments)).position ≠ 0 := by
            simpa [declarationsLoop, positive, stop, failed] using accepted
          obtain ⟨rest, following⟩ := ih (declarationAt text state arguments)
            (model_declaration_valid text textValid state arguments valid) remaining
          by_cases function : (functionDeclarationAt text state arguments).position ≠ 0
          · have selected : declarationAt text state arguments = functionDeclarationAt text state arguments := by
              dsimp only [declarationAt]
              rw [ite_eq_left function]
            obtain ⟨definition, source⟩ := functionDeclarationAt_source textValid valid function
            rw [selected] at following
            refine ⟨definition :: rest, ?_⟩
            simpa [declarationsLoop, positive, stop, selected, function] using
              FunctionDeclarationsAt.function positive (by omega) source following
          · refine ⟨rest, ?_⟩
            simpa [declarationsLoop, positive, stop, failed] using
              FunctionDeclarationsAt.other positive (by omega) (by omega) failed following

theorem functionDeclarations_source {text arguments state}
    (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (declarationsAt text state arguments).position ≠ 0) :
    ∃ definitions, FunctionDeclarationsAt text arguments state definitions (declarationsAt text state arguments) :=
  functionDeclarationsLoop_source text arguments _ state textValid valid accepted

theorem FunctionDeclarationsAt.checked {text arguments state definitions final}
    (source : FunctionDeclarationsAt text arguments state definitions final)
    (textValid : ValidText text) (valid : ValidState text state) :
    DefinitionsChecked (catalogSignatures state.functions) definitions ∧
      catalogSignatures final.functions = catalogSignatures state.functions ++ definitions.map Definition.signature := by
  induction source with
  | done => exact ⟨trivial, (List.append_nil _).symm⟩
  | function _ _ first _ ih =>
    have following := ih (model_function_declaration_valid textValid valid)
    rw [first.catalog valid] at following
    refine ⟨⟨first.checked valid, following.1⟩, ?_⟩
    simpa only [List.map_cons, List.append_assoc, List.singleton_append] using following.2
  | other _ _ noFunction accepted _ ih =>
    have following := ih (model_declaration_valid _ textValid _ _ valid)
    rw [declarationAt_functions_of_no_function noFunction accepted] at following
    exact following

theorem FunctionDeclarationsAt.unique {text arguments state left right leftFinal rightFinal}
    (a : FunctionDeclarationsAt text arguments state left leftFinal)
    (b : FunctionDeclarationsAt text arguments state right rightFinal) : left = right := by
  induction a generalizing right rightFinal with
  | done _ stop =>
    cases b with
    | done => rfl
    | function _ more | other _ more => exact False.elim (stop more)
  | function _ more first _ ih =>
    cases b with
    | done _ stop => exact False.elim (stop more)
    | other _ _ noFunction => exact False.elim (first.accepted noFunction)
    | function _ _ second rest =>
      rw [first.unique second, ih rest]
  | other _ more noFunction _ _ ih =>
    cases b with
    | done _ stop => exact False.elim (stop more)
    | function _ _ first => exact False.elim (first.accepted noFunction)
    | other _ _ _ _ rest => exact ih rest

end Silver.Compose
