module

public import Silver.PredicateStatementFlags
public import Silver.PredicateShell
public import Silver.SequenceMixedTrace

@[expose] public section

namespace Silver.Predicate
open Compose ScalarFunctions

mutual
  def Flag.statement (flag : Flag) : Statement → Bool
    | .simple item => flag.simple item
    | .scalarAssign _ | .callAssign _ | .arrayAssign _ | .booleanAssign _ | .booleanArrayAssign _ =>
        flag == .assignment
    | .procedureCall call => (flag == .assignment) && call.actuals.any Flag.actualWrite
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
    | procedureCall call => simp only [SourceStatement.lower, Flag.statement, Flag.source]
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
    program.functions.any (fun definition => Flag.assignment.statements definition.body) ||
    program.procedures.any (fun definition => !definition.initializers.isEmpty || Flag.assignment.statements definition.body)

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

private theorem declarationAt_functionAssignments_of_no_callable {text state arguments}
    (noProcedure : (procedureDeclarationAt text state arguments).position = 0)
    (noFunction : (functionDeclarationAt text state arguments).position = 0)
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    (declarationAt text state arguments).assignedInFunctions = state.assignedInFunctions := by
  dsimp only [declarationAt] at accepted ⊢
  rw [ite_eq_right (not_not_intro noFunction), ite_eq_right (not_not_intro noProcedure)] at accepted ⊢
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

theorem _root_.Silver.Compose.ProcedureOrdinarySource.flags {text frame arguments items}
    (source : ProcedureOrdinarySource text frame arguments items) (flag : Flag) :
    flag.observe (procedureSourceFinal text frame arguments) =
      (flag.observe (procedureSourceScan text frame arguments) || flag.sources items) := by
  cases source with
  | initialized _ body => exact bodyTail_flags body flag
  | uninitialized _ body => exact body_flags body flag

theorem _root_.Silver.Compose.ProcedureBodySource.assignment {text frame first after arguments definition}
    (source : ProcedureBodySource text frame first after arguments definition) :
    (procedureSourceFinal text frame arguments).assigned =
      (!definition.initializers.isEmpty || Flag.assignment.statements definition.body) := by
  cases source with
  | parsed initialization ordinary =>
      have observed := ordinary.flags .assignment
      simpa only [Flag.observe, procedureSourceScan, bodyOf, initialization.initialized_flag,
        sourceProcedureDefinition, statements_lower_flags] using observed

theorem _root_.Silver.Compose.ProcedureDeclarationSource.assignment {text state arguments definition}
    (source : ProcedureDeclarationSource text state arguments definition) :
    (procedureDeclarationAt text state arguments).assignedInFunctions =
      (state.assignedInFunctions ||
        (!definition.initializers.isEmpty || Flag.assignment.statements definition.body)) := by
  cases source with
  | parsed accepted body =>
      have stages := procedureDeclarationAt_stages accepted
      rw [stages.equation, procedureBodyAt_assigned stages.body, body.assignment]

theorem _root_.Silver.Compose.MixedDeclarationsAt.assignments {text arguments state functions procedures final}
    (source : MixedDeclarationsAt text arguments state functions procedures final) :
    final.assignedInFunctions =
      (state.assignedInFunctions || functions.any (fun definition => Flag.assignment.statements definition.body) ||
        procedures.any (fun definition => !definition.initializers.isEmpty || Flag.assignment.statements definition.body)) := by
  induction source with
  | done => simp only [List.any_nil, Bool.or_false]
  | procedure _ _ _ first _ ih =>
      rw [ih, first.assignment]
      simp [List.any_cons, Bool.or_assoc, Bool.or_left_comm]
  | function _ _ first _ ih =>
      rw [ih, first.assignment]
      simp only [List.any_cons, Bool.or_assoc]
  | other _ _ noFunction noProcedure accepted _ ih =>
      rw [ih, declarationAt_functionAssignments_of_no_callable noProcedure noFunction accepted]

theorem _root_.Silver.Sequence.MixedStepAt.assignments {text form token state functions procedures next event}
    (source : Sequence.MixedStepAt text form token state functions procedures next)
    (parsed : StepAt text form token state next event) :
    next.assignedInFunctions =
      (state.assignedInFunctions || functions.any (fun definition => Flag.assignment.statements definition.body) ||
        procedures.any (fun definition => !definition.initializers.isEmpty || Flag.assignment.statements definition.body)) := by
  cases source with
  | declarations source => exact source.assignments
  | other ordinary _ _ =>
      simpa only [List.any_nil, Bool.or_false] using step_functionAssignments_preserved ordinary parsed

theorem _root_.Silver.Sequence.MixedTokensAt.assignments {text form tokens state functions procedures final}
    (source : Sequence.MixedTokensAt text form tokens state functions procedures final) :
    final.assignedInFunctions =
      (state.assignedInFunctions || functions.any (fun definition => Flag.assignment.statements definition.body) ||
        procedures.any (fun definition => !definition.initializers.isEmpty || Flag.assignment.statements definition.body)) := by
  induction source with
  | done => simp only [List.any_nil, Bool.or_false]
  | next head first _ ih =>
      rw [ih, first.assignments head]
      simp [List.any_append, Bool.or_assoc, Bool.or_left_comm, Bool.or_comm]

theorem _root_.Silver.Sequence.MixedTokensAt.scan_assigned {text form tokens state functions procedures final}
    (source : Sequence.MixedTokensAt text form tokens state functions procedures final)
    (assigned output : Bool) (absorbs : (assigned || state.assignedInFunctions) = assigned) :
    (scanTokens text form tokens ⟨state, assigned, output⟩).assigned =
      (assigned || functions.any (fun definition => Flag.assignment.statements definition.body) ||
        procedures.any (fun definition => !definition.initializers.isEmpty || Flag.assignment.statements definition.body)) := by
  induction source generalizing assigned with
  | done => simp only [scanTokens, List.any_nil, Bool.or_false]
  | @next token tokens state middle final event firstFunctions firstProcedures restFunctions restProcedures head first _ ih =>
      have kept := first.assignments head
      have following := ih (assigned || middle.assignedInFunctions) (by simp only [Bool.or_assoc, Bool.or_self])
      rw [scanTokens, head.scanned]
      change (scanTokens text form tokens ⟨middle, assigned || middle.assignedInFunctions, output⟩).assigned = _
      rw [following, kept, List.any_append, List.any_append]
      simp only [← Bool.or_assoc, absorbs]
      simp [Bool.or_assoc, Bool.or_left_comm, Bool.or_comm]

theorem prefix_callable_flags {text form functions procedures}
    (source : Sequence.MixedTokensAt text form.helper form.prefix initialState functions procedures (prefixScan text form).state) :
    (prefixScan text form).assigned =
        (functions.any (fun definition => Flag.assignment.statements definition.body) ||
          procedures.any (fun definition => !definition.initializers.isEmpty || Flag.assignment.statements definition.body)) ∧
      (prefixScan text form).state.assignedInFunctions =
        (functions.any (fun definition => Flag.assignment.statements definition.body) ||
          procedures.any (fun definition => !definition.initializers.isEmpty || Flag.assignment.statements definition.body)) := by
  have fields := source.assignments
  have scanned := source.scan_assigned false false rfl
  exact ⟨by simpa only [prefixScan, initialScan, Bool.false_or] using scanned,
    by simpa only [initialState, Bool.false_or] using fields⟩

end Silver.Predicate
