module

public import Silver.ScalarProcedureComposition
public import Silver.FunctionSourceUnique
public import Silver.ProcedureDeclarationMeaning

@[expose] public section

namespace Silver.ScalarProcedures

/-- Later function declarations enlarge the global evaluator but never the
function-signature prefix visible to an already accepted procedure body. -/
theorem Definition.checked_functions_append {definition : Definition}
    {functions : ScalarFunctions.Signatures} {earlier : Signatures}
    (checked : definition.Checked functions earlier) (more : ScalarFunctions.Signatures) :
    definition.Checked (functions ++ more) earlier := by
  obtain ⟨formed, after, checked⟩ := checked
  have parts := (definition.check_iff functions earlier after).mp checked
  have ready := (definition.ready_iff functions).mp parts.1
  have callablePrefix : (functions ++ more).take definition.functionCount = functions.take definition.functionCount :=
    List.take_append_of_le_length ready.2.2.2.2.2
  refine ⟨formed, after, (definition.check_iff (functions ++ more) earlier after).mpr ⟨?_, ?_⟩⟩
  · apply (definition.ready_iff (functions ++ more)).mpr
    refine ⟨ready.1, ready.2.1, ready.2.2.1, ready.2.2.2.1, ready.2.2.2.2.1, ?_⟩
    have bound := ready.2.2.2.2.2
    simp only [List.length_append]
    omega
  · simpa only [callablePrefix] using parts.2

theorem definitionsChecked_functions_append {functions : ScalarFunctions.Signatures}
    {earlier : Signatures} {definitions : List Definition}
    (checked : DefinitionsChecked functions earlier definitions) (more : ScalarFunctions.Signatures) :
    DefinitionsChecked (functions ++ more) earlier definitions := by
  induction definitions generalizing earlier with
  | nil => trivial
  | cons definition rest ih =>
      exact ⟨definition.checked_functions_append checked.1 more, ih checked.2⟩

end Silver.ScalarProcedures

namespace Silver.Compose
open Predicate Silver.Compose.Expressions

theorem FunctionDeclarationSource.accepted {text state arguments definition}
    (source : FunctionDeclarationSource text state arguments definition) :
    (functionDeclarationAt text state arguments).position ≠ 0 := by
  cases source
  assumption

theorem declarationAt_functions_of_no_function {text state arguments}
    (noFunction : (functionDeclarationAt text state arguments).position = 0)
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).functions = state.functions := by
  dsimp only [declarationAt] at accepted ⊢
  rw [ite_eq_right (not_not_intro noFunction)] at accepted ⊢
  split at accepted
  · rename_i acceptedProcedure
    rw [ite_eq_left acceptedProcedure]
    exact (procedureDeclarationAt_preserves_outer text state arguments acceptedProcedure).functions
  · rename_i noProcedure
    rw [ite_eq_right noProcedure]
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


theorem declarationAt_procedures_of_no_procedure {text state arguments}
    (noProcedure : (procedureDeclarationAt text state arguments).position = 0)
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).procedures = state.procedures := by
  dsimp only [declarationAt] at accepted ⊢
  split at accepted
  · rename_i acceptedFunction
    rw [ite_eq_left acceptedFunction]
    exact (functionDeclarationAt_preserves_outer text state arguments acceptedFunction).procedures
  · rename_i noFunction
    rw [ite_eq_right noFunction]
    rw [ite_eq_right (not_not_intro noProcedure)] at accepted ⊢
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
          exact arrayDeclarationAt_procedures positive
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


theorem ProcedureBodySource.unique {text frame first after arguments left right}
    (a : ProcedureBodySource text frame first after arguments left)
    (b : ProcedureBodySource text frame first after arguments right) : left = right := by
  cases a with
  | parsed initialization ordinary =>
    cases b with
    | parsed otherInitialization otherOrdinary =>
      obtain ⟨rfl, rfl, rfl, rfl, _⟩ := initialization.locals.unique otherInitialization.locals
      have actuals := (initialization.prefixRead.unique otherInitialization.prefixRead).1
      have items := ordinary.unique otherOrdinary
      cases actuals
      cases items
      rfl

theorem ProcedureDeclarationSource.unique {text state arguments left right}
    (a : ProcedureDeclarationSource text state arguments left)
    (b : ProcedureDeclarationSource text state arguments right) : left = right := by
  cases a with
  | parsed _ body => cases b with
    | parsed _ other => exact body.unique other

/-- Every source declaration is retained in the scanner's actual order. The
separate result lists preserve both callable orders; each procedure definition
also retains the function-signature prefix visible at its declaration. -/
inductive MixedDeclarationsAt (text : Source) (arguments : Bool) :
    ParserState → List ScalarFunctions.Definition → List ScalarProcedures.Definition → ParserState → Prop
  | done {state} : state.position ≠ 0 → fixedAfter text state.position "begin" true ≠ 0 →
      MixedDeclarationsAt text arguments state [] [] state
  | function {state final definition functions procedures} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true = 0 →
      FunctionDeclarationSource text state arguments definition →
      MixedDeclarationsAt text arguments (functionDeclarationAt text state arguments) functions procedures final →
      MixedDeclarationsAt text arguments state (definition :: functions) procedures final
  | procedure {state final definition functions procedures} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true = 0 →
      (functionDeclarationAt text state arguments).position = 0 →
      ProcedureDeclarationSource text state arguments definition →
      MixedDeclarationsAt text arguments (procedureDeclarationAt text state arguments) functions procedures final →
      MixedDeclarationsAt text arguments state functions (definition :: procedures) final
  | other {state final functions procedures} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true = 0 →
      (functionDeclarationAt text state arguments).position = 0 →
      (procedureDeclarationAt text state arguments).position = 0 →
      (declarationAt text state arguments).position ≠ 0 →
      MixedDeclarationsAt text arguments (declarationAt text state arguments) functions procedures final →
      MixedDeclarationsAt text arguments state functions procedures final

theorem mixedDeclarationsLoop_source (text : Source) (arguments : Bool) (fuel : Nat)
    (state : ParserState) (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (declarationsLoop text arguments fuel state).position ≠ 0) :
    ∃ functions procedures, MixedDeclarationsAt text arguments state functions procedures
      (declarationsLoop text arguments fuel state) := by
  induction fuel generalizing state with
  | zero => simp [declarationsLoop, invalidState] at accepted
  | succ fuel ih =>
    by_cases positive : state.position = 0
    · simp [declarationsLoop, positive, invalidState] at accepted
    · by_cases stop : fixedAfter text state.position "begin" true ≠ 0
      · refine ⟨[], [], ?_⟩
        simpa [declarationsLoop, positive, stop] using MixedDeclarationsAt.done positive stop
      · by_cases failed : (declarationAt text state arguments).position = 0
        · simp [declarationsLoop, positive, stop, failed, invalidState] at accepted
        · have remaining : (declarationsLoop text arguments fuel (declarationAt text state arguments)).position ≠ 0 := by
            simpa [declarationsLoop, positive, stop, failed] using accepted
          obtain ⟨functions, procedures, following⟩ := ih (declarationAt text state arguments)
            (model_declaration_valid text textValid state arguments valid) remaining
          by_cases function : (functionDeclarationAt text state arguments).position ≠ 0
          · have selected : declarationAt text state arguments = functionDeclarationAt text state arguments := by
              dsimp only [declarationAt]
              rw [ite_eq_left function]
            obtain ⟨definition, source⟩ := functionDeclarationAt_source textValid valid function
            rw [selected] at following
            refine ⟨definition :: functions, procedures, ?_⟩
            simpa [declarationsLoop, positive, stop, selected, function] using
              MixedDeclarationsAt.function positive (by omega) source following
          · by_cases procedure : (procedureDeclarationAt text state arguments).position ≠ 0
            · have selected : declarationAt text state arguments = procedureDeclarationAt text state arguments := by
                dsimp only [declarationAt]
                rw [ite_eq_right function, ite_eq_left procedure]
              obtain ⟨definition, source⟩ := procedureDeclarationAt_source textValid valid procedure
              rw [selected] at following
              refine ⟨functions, definition :: procedures, ?_⟩
              simpa [declarationsLoop, positive, stop, selected, procedure] using
                MixedDeclarationsAt.procedure positive (by omega) (by omega) source following
            · refine ⟨functions, procedures, ?_⟩
              simpa [declarationsLoop, positive, stop, failed] using
                MixedDeclarationsAt.other positive (by omega) (by omega) (by omega) failed following

theorem mixedDeclarations_source {text arguments state}
    (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (declarationsAt text state arguments).position ≠ 0) :
    ∃ functions procedures, MixedDeclarationsAt text arguments state functions procedures
      (declarationsAt text state arguments) :=
  mixedDeclarationsLoop_source text arguments _ state textValid valid accepted

theorem MixedDeclarationsAt.functions_checked {text arguments state functions procedures final}
    (source : MixedDeclarationsAt text arguments state functions procedures final)
    (textValid : ValidText text) (valid : ValidState text state) :
    ScalarFunctions.DefinitionsChecked (catalogSignatures state.functions) functions ∧
      catalogSignatures final.functions =
        catalogSignatures state.functions ++ functions.map ScalarFunctions.Definition.signature := by
  induction source with
  | done => exact ⟨trivial, (List.append_nil _).symm⟩
  | procedure _ _ _ first _ ih =>
    have following := ih (model_procedure_declaration_valid textValid valid)
    rw [(procedureDeclarationAt_preserves_outer _ _ _ first.accepted).functions] at following
    exact following
  | function _ _ first _ ih =>
    have following := ih (model_function_declaration_valid textValid valid)
    rw [first.catalog valid] at following
    refine ⟨⟨first.checked valid, following.1⟩, ?_⟩
    simpa only [List.map_cons, List.append_assoc, List.singleton_append] using following.2
  | other _ _ noFunction _ accepted _ ih =>
    have following := ih (model_declaration_valid _ textValid _ _ valid)
    rw [declarationAt_functions_of_no_function noFunction accepted] at following
    exact following

theorem MixedDeclarationsAt.procedure_catalog {text arguments state functions procedures final}
    (source : MixedDeclarationsAt text arguments state functions procedures final)
    (textValid : ValidText text) (valid : ValidState text state) :
    ProcedureBindings.catalogSignatures final.procedures =
      ProcedureBindings.catalogSignatures state.procedures ++ procedures.map ScalarProcedures.Definition.signature := by
  induction source with
  | done => exact (List.append_nil _).symm
  | procedure _ _ _ first _ ih =>
    have following := ih (model_procedure_declaration_valid textValid valid)
    rw [first.catalog valid] at following
    simpa only [List.map_cons, List.append_assoc, List.singleton_append] using following
  | function _ _ first _ ih =>
    have following := ih (model_function_declaration_valid textValid valid)
    rw [(functionDeclarationAt_preserves_outer _ _ _ first.accepted).procedures] at following
    exact following
  | other _ _ _ noProcedure accepted _ ih =>
    have following := ih (model_declaration_valid _ textValid _ _ valid)
    rw [declarationAt_procedures_of_no_procedure noProcedure accepted] at following
    exact following

theorem MixedDeclarationsAt.unique {text arguments state leftFunctions leftProcedures rightFunctions rightProcedures leftFinal rightFinal}
    (a : MixedDeclarationsAt text arguments state leftFunctions leftProcedures leftFinal)
    (b : MixedDeclarationsAt text arguments state rightFunctions rightProcedures rightFinal) :
    leftFunctions = rightFunctions ∧ leftProcedures = rightProcedures := by
  induction a generalizing rightFunctions rightProcedures rightFinal with
  | done _ stop =>
    cases b with
    | done => exact ⟨rfl, rfl⟩
    | function _ more | procedure _ more | other _ more => exact False.elim (stop more)
  | function _ more first _ ih =>
    cases b with
    | done _ stop => exact False.elim (stop more)
    | procedure _ _ noFunction | other _ _ noFunction => exact False.elim (first.accepted noFunction)
    | function _ _ second rest =>
      obtain ⟨rfl, rfl⟩ := ih rest
      rw [first.unique second]
      exact ⟨rfl, rfl⟩
  | procedure _ more noFunction first _ ih =>
    cases b with
    | done _ stop => exact False.elim (stop more)
    | function _ _ other => exact False.elim (other.accepted noFunction)
    | other _ _ _ noProcedure => exact False.elim (first.accepted noProcedure)
    | procedure _ _ _ second rest =>
      obtain ⟨rfl, rfl⟩ := ih rest
      rw [first.unique second]
      exact ⟨rfl, rfl⟩
  | other _ more noFunction noProcedure _ _ ih =>
    cases b with
    | done _ stop => exact False.elim (stop more)
    | function _ _ first => exact False.elim (first.accepted noFunction)
    | procedure _ _ _ first => exact False.elim (first.accepted noProcedure)
    | other _ _ _ _ _ rest => exact ih rest

end Silver.Compose
