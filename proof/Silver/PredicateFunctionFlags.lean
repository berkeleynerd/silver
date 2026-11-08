module

public import Silver.PredicateFlags

@[expose] public section

namespace Silver.Predicate
open Compose ScalarFunctions

mutual
  def Flag.statement (flag : Flag) : Statement → Bool
    | .simple item => flag.simple item
    | .scalarAssign _ | .callAssign _ | .arrayAssign _ | .booleanAssign _ | .booleanArrayAssign _ =>
        flag == .assignment
    | .reject => false
    | .choice _ yes no => flag.statements yes || flag.statements no
    | .forLoop _ _ _ _ body | .arrayLoop _ _ _ body => flag.statements body
  termination_by item => sizeOf item
  def Flag.statements (flag : Flag) : List Statement → Bool
    | [] => false
    | item :: rest => flag.statement item || flag.statements rest
  termination_by items => sizeOf items
end

mutual
  theorem source_lower_flags (flag : Flag) (item : SourceStatement) :
      flag.statement item.lower = flag.source item := by
    cases item with
    | simple item => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | callAssign update => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | scalarAssign update => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | booleanAssign update => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | booleanArrayAssign update => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | arrayAssign update => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | reject => simp only [SourceStatement.lower, Flag.statement, Flag.source]
    | choice condition yes tail =>
        simp only [SourceStatement.lower, Flag.statement, Flag.source,
          statements_lower_flags flag yes, alternative_lower_flags flag tail]
    | forLoop index reverse lower upper body | arrayLoop index reverse array body =>
        simp only [SourceStatement.lower, Flag.statement, Flag.source, statements_lower_flags flag body]
  termination_by sizeOf item
  theorem alternative_lower_flags (flag : Flag) (tail : SourceAlternative) :
      flag.statements tail.lower = flag.alternative tail := by
    cases tail with
    | absent => simp only [SourceAlternative.lower, Flag.statements, Flag.alternative]
    | otherwise items => simpa only [SourceAlternative.lower, Flag.alternative] using statements_lower_flags flag items
    | elsif condition yes tail =>
        simp only [SourceAlternative.lower, Flag.statements, Flag.statement, Flag.alternative,
          statements_lower_flags flag yes, alternative_lower_flags flag tail, Bool.or_false]
  termination_by sizeOf tail
  theorem statements_lower_flags (flag : Flag) (items : List SourceStatement) :
      flag.statements (lowerStatements items) = flag.sources items := by
    cases items with
    | nil => simp only [lowerStatements, Flag.statements, Flag.sources]
    | cons item rest =>
        simp only [lowerStatements, Flag.statements, Flag.sources,
          source_lower_flags flag item, statements_lower_flags flag rest]
  termination_by sizeOf items
end


def Program.assignmentFlag (program : Program) : Bool :=
  Flag.assignment.statements program.statements ||
    program.functions.any (fun definition => Flag.assignment.statements definition.body)

private theorem array_functionAssignments_preserved {text arguments state declaration final}
    (source : ArrayDeclarationAt text arguments state declaration final) :
    final.assignedInFunctions = state.assignedInFunctions := by
  cases source with
  | declaration _ _ _ _ _ _ values _ _ =>
      have fields := congrArg ParserState.assignedInFunctions (arrayValues_fields values)
      exact fields

private theorem booleanArray_functionAssignments_preserved {text arguments state final}
    (source : BooleanArrayDeclarationAt text arguments state final) :
    final.assignedInFunctions = state.assignedInFunctions := by
  have fields := congrArg ParserState.assignedInFunctions (boolean_array_declaration_fields source)
  exact fields

private theorem declarationAt_functionAssignments_of_no_function {text state arguments}
    (noFunction : (functionDeclarationAt text state arguments).position = 0)
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).assignedInFunctions = state.assignedInFunctions := by
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
        by_cases kind : (arrayDeclarationParts text state).isBoolean = true
        · exact booleanArray_functionAssignments_preserved (boolean_array_declaration_sound text state arguments kind positive)
        · obtain ⟨declaration, source⟩ := array_declaration_sound text state arguments
            (Bool.eq_false_iff.mpr kind) positive
          exact array_functionAssignments_preserved source
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


private theorem functionBodyAt_assignment {text outer frame first after resultType arguments}
    (accepted : (functionBodyAt text outer frame first after resultType arguments).position ≠ 0) :
    (functionBodyAt text outer frame first after resultType arguments).assignedInFunctions =
      (outer.assignedInFunctions || (functionSourceFinal text frame arguments).assigned) := by
  dsimp only [functionBodyAt] at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i locals
    rw [ite_eq_right locals]
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i parameters
      rw [ite_eq_right parameters]
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i checks
        rw [ite_eq_right checks]
        rfl

theorem _root_.Silver.Compose.FunctionBodySource.assignment {text frame first after resultType arguments definition}
    (source : FunctionBodySource text frame first after resultType arguments definition) :
    (functionSourceFinal text frame arguments).assigned = Flag.assignment.statements definition.body := by
  cases source with
  | parsed _ _ _ body _ =>
      have observed := bodyTail_flags body .assignment
      simpa only [Flag.observe, functionSourceScan, bodyOf, Bool.false_or,
        sourceFunctionDefinition, statements_lower_flags] using observed

theorem _root_.Silver.Compose.FunctionDeclarationSource.assignment {text state arguments definition}
    (source : FunctionDeclarationSource text state arguments definition) :
    (functionDeclarationAt text state arguments).assignedInFunctions =
      (state.assignedInFunctions || Flag.assignment.statements definition.body) := by
  cases source with
  | parsed accepted body =>
      have stages := functionDeclarationAt_stages accepted
      rw [stages.equation, functionBodyAt_assignment stages.body, body.assignment]

theorem _root_.Silver.Compose.FunctionDeclarationsAt.assignments {text arguments state definitions final}
    (source : FunctionDeclarationsAt text arguments state definitions final) :
    final.assignedInFunctions =
      (state.assignedInFunctions || definitions.any (fun definition => Flag.assignment.statements definition.body)) := by
  induction source with
  | done => simp only [List.any_nil, Bool.or_false]
  | function _ _ first _ ih =>
      rw [ih, first.assignment]
      simp only [List.any_cons, Bool.or_assoc]
  | other _ _ noFunction accepted _ ih =>
      rw [ih, declarationAt_functionAssignments_of_no_function noFunction accepted]

theorem _root_.Silver.Sequence.FunctionStepAt.assignments {text form token state definitions next event}
    (source : Sequence.FunctionStepAt text form token state definitions next)
    (parsed : StepAt text form token state next event) :
    next.assignedInFunctions =
      (state.assignedInFunctions || definitions.any (fun definition => Flag.assignment.statements definition.body)) := by
  cases source with
  | declarations source => exact source.assignments
  | other ordinary _ =>
      simpa only [List.any_nil, Bool.or_false] using step_functionAssignments_preserved ordinary parsed

theorem _root_.Silver.Sequence.FunctionTokensAt.assignments {text form tokens state definitions final}
    (source : Sequence.FunctionTokensAt text form tokens state definitions final) :
    final.assignedInFunctions =
      (state.assignedInFunctions || definitions.any (fun definition => Flag.assignment.statements definition.body)) := by
  induction source with
  | done => simp only [List.any_nil, Bool.or_false]
  | next head first _ ih =>
      rw [ih, first.assignments head]
      simp only [List.any_append, Bool.or_assoc]

theorem _root_.Silver.Sequence.FunctionTokensAt.scan_assigned {text form tokens state definitions final}
    (source : Sequence.FunctionTokensAt text form tokens state definitions final)
    (assigned output : Bool) (absorbs : (assigned || state.assignedInFunctions) = assigned) :
    (scanTokens text form tokens ⟨state, assigned, output⟩).assigned =
      (assigned || definitions.any (fun definition => Flag.assignment.statements definition.body)) := by
  induction source generalizing assigned with
  | done => simp only [scanTokens, List.any_nil, Bool.or_false]
  | @next token tokens state middle final event firstDefinitions restDefinitions head first _ ih =>
      have kept := first.assignments head
      have following := ih (assigned || middle.assignedInFunctions) (by simp only [Bool.or_assoc, Bool.or_self])
      rw [scanTokens, head.scanned]
      change (scanTokens text form tokens ⟨middle, assigned || middle.assignedInFunctions, output⟩).assigned = _
      rw [following, kept, List.any_append]
      simp only [← Bool.or_assoc, absorbs]

theorem prefix_function_flags {text form definitions}
    (source : Sequence.FunctionTokensAt text form.helper form.prefix initialState definitions (prefixScan text form).state) :
    (prefixScan text form).assigned = definitions.any (fun definition => Flag.assignment.statements definition.body) ∧
    (prefixScan text form).state.assignedInFunctions = definitions.any (fun definition => Flag.assignment.statements definition.body) := by
  have fields := source.assignments
  have scanned := source.scan_assigned false false rfl
  exact ⟨by simpa only [prefixScan, initialScan, Bool.false_or] using scanned,
    by simpa only [initialState, Bool.false_or] using fields⟩

end Silver.Predicate
